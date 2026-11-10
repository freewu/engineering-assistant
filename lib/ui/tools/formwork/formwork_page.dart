import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import '../widgets/tool_select.dart';
import 'formwork.dart';
import 'formwork_lang.dart';
import 'formwork_strings.dart';

/// 模板工程量页：柱 / 梁 / 墙 / 楼梯四个 tab。
///
/// 按模板与混凝土的接触面积（㎡）计算。输入走 [ToolDraft]（id `formwork`），
/// 数值留空就不计算（结果显示「—」）。
class FormworkPage extends StatefulWidget {
  const FormworkPage({super.key});

  @override
  State<FormworkPage> createState() => _FormworkPageState();
}

class _FormworkPageState extends State<FormworkPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('formwork');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kFormworkTabCount,
    initialIndex:
        (_draft.integer('tab') ?? currentSettings?.toolTabFor('formwork') ?? 0)
            .clamp(0, kFormworkTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 柱：类型 / 截面 a、b / 柱高
  late ColumnFormMode _columnMode =
      _draft.enumOf('columnMode', ColumnFormMode.values) ??
      ColumnFormMode.rectangle;
  late final TextEditingController _columnA = _draft.controller(
    'columnA',
    '0.5',
  );
  late final TextEditingController _columnB = _draft.controller(
    'columnB',
    '0.5',
  );
  late final TextEditingController _columnHeight = _draft.controller(
    'columnHeight',
    '3',
  );

  // 梁：底宽 / 梁高 / 梁长
  late final TextEditingController _beamWidth = _draft.controller(
    'beamWidth',
    '0.3',
  );
  late final TextEditingController _beamHeight = _draft.controller(
    'beamHeight',
    '0.6',
  );
  late final TextEditingController _beamLength = _draft.controller(
    'beamLength',
    '6',
  );

  // 墙：墙长 / 墙高 / 洞口 / 侧壁
  late final TextEditingController _wallLength = _draft.controller(
    'wallLength',
    '10',
  );
  late final TextEditingController _wallHeight = _draft.controller(
    'wallHeight',
    '3',
  );
  late final TextEditingController _wallOpening = _draft.controller(
    'wallOpening',
    '6',
  );
  late final TextEditingController _wallSide = _draft.controller(
    'wallSide',
    '0.5',
  );

  // 楼梯：踏步数 / 踏步宽 / 踏步高 / 梯段宽 / 平台长
  late final TextEditingController _stairSteps = _draft.controller(
    'stairSteps',
    '10',
  );
  late final TextEditingController _stairTread = _draft.controller(
    'stairTread',
    '0.28',
  );
  late final TextEditingController _stairRiser = _draft.controller(
    'stairRiser',
    '0.15',
  );
  late final TextEditingController _stairWidth = _draft.controller(
    'stairWidth',
    '1.2',
  );
  late final TextEditingController _stairLanding = _draft.controller(
    'stairLanding',
    '1.2',
  );

  FormworkStrings get _s => formworkStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _columnA,
      _columnB,
      _columnHeight,
      _beamWidth,
      _beamHeight,
      _beamLength,
      _wallLength,
      _wallHeight,
      _wallOpening,
      _wallSide,
      _stairSteps,
      _stairTread,
      _stairRiser,
      _stairWidth,
      _stairLanding,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (!_tabs.indexIsChanging) _draft.set('tab', _tabs.index);
    setState(() {});
  }

  /// 读一个输入框；空着、不是数字或负数时返回 null。
  double? _input(TextEditingController controller) {
    final value = double.tryParse(controller.text);
    if (value == null || !value.isFinite || value < 0) return null;
    return value;
  }

  double? get _columnArea {
    final a = _input(_columnA);
    final b = _input(_columnB);
    final height = _input(_columnHeight);
    if (a == null || b == null || height == null) return null;
    return switch (_columnMode) {
      ColumnFormMode.rectangle => columnFormworkArea(
        a: a,
        b: b,
        height: height,
      ),
      ColumnFormMode.tie => tieColumnFormworkArea(a: a, b: b, height: height),
    };
  }

  double? get _beamArea {
    final width = _input(_beamWidth);
    final height = _input(_beamHeight);
    final length = _input(_beamLength);
    if (width == null || height == null || length == null) return null;
    return beamFormworkArea(bottomWidth: width, height: height, length: length);
  }

  double? get _wallArea {
    final length = _input(_wallLength);
    final height = _input(_wallHeight);
    if (length == null || height == null) return null;
    return wallFormworkArea(
      length: length,
      height: height,
      openingArea: _input(_wallOpening) ?? 0,
      sideArea: _input(_wallSide) ?? 0,
    );
  }

  double? get _stairArea {
    final steps = int.tryParse(_stairSteps.text);
    final tread = _input(_stairTread);
    final riser = _input(_stairRiser);
    final width = _input(_stairWidth);
    if (steps == null || steps < 0 || tread == null || riser == null) {
      return null;
    }
    if (width == null) return null;
    return stairFormworkArea(
      steps: steps,
      treadWidth: tread,
      riserHeight: riser,
      flightWidth: width,
      landingLength: _input(_stairLanding) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = <String>[_s.tabColumn, _s.tabBeam, _s.tabWall, _s.tabStair];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kFormworkLang).name),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: TabBar(
              key: const Key('formwork-tabs'),
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: [
                for (final (index, label) in labels.indexed)
                  Tab(
                    height: 38,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: index == _tabs.index
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: index == _tabs.index
                            ? _accent(index)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [_columnTab(), _beamTab(), _wallTab(), _stairTab()],
            ),
          ),
        ],
      ),
    );
  }

  Color _accent(int index) {
    final accents = AppColors.accents;
    return accents[index % accents.length];
  }

  Widget _page(List<Widget> children) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 660),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );

  Widget _columnTab() {
    final area = _columnArea;
    return _page([
      ToolSection(
        key: const Key('formwork-column'),
        title: _s.columnSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolSelect<ColumnFormMode>(
              key: const Key('formwork-column-mode'),
              label: _s.columnMode,
              value: _columnMode,
              items: ColumnFormMode.values,
              labelOf: _s.modeLabel,
              onChanged: (mode) {
                _draft.setEnum('columnMode', mode);
                setState(() => _columnMode = mode);
              },
            ),
            const SizedBox(height: 12),
            _row([
              _field(_s.columnA, 'm', _columnA),
              _field(_s.columnB, 'm', _columnB),
              _field(_s.columnHeight, 'm', _columnHeight),
            ]),
            const SizedBox(height: 8),
            _hint(
              _columnMode == ColumnFormMode.tie ? _s.tieHint : _s.columnHint,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('formwork-column-result'),
        title: _s.columnResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : _columnMode == ColumnFormMode.tie
            ? fill(_s.tieFormula, [
                _fmt(_input(_columnA)),
                _fmt(_input(_columnB)),
                _fmt(kToothProtrusion),
                _fmt(kToothCountPerMeter),
                _fmt(_input(_columnHeight)),
                _fmt(area),
              ])
            : fill(_s.columnFormula, [
                _fmt(_input(_columnA)),
                _fmt(_input(_columnB)),
                _fmt(_input(_columnHeight)),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _beamTab() {
    final area = _beamArea;
    return _page([
      ToolSection(
        key: const Key('formwork-beam'),
        title: _s.beamSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.beamBottomWidth, 'm', _beamWidth),
              _field(_s.beamHeight, 'm', _beamHeight),
            ]),
            _field(_s.beamLength, 'm', _beamLength),
            const SizedBox(height: 8),
            _hint(_s.beamHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('formwork-beam-result'),
        title: _s.beamResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.beamFormula, [
                _fmt(_input(_beamWidth)),
                _fmt(_input(_beamHeight)),
                _fmt(_input(_beamLength)),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _wallTab() {
    final area = _wallArea;
    return _page([
      ToolSection(
        key: const Key('formwork-wall'),
        title: _s.wallSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.wallLength, 'm', _wallLength),
              _field(_s.wallHeight, 'm', _wallHeight),
            ]),
            _row([
              _field(_s.wallOpening, 'm²', _wallOpening),
              _field(_s.wallSide, 'm²', _wallSide),
            ]),
            const SizedBox(height: 8),
            _hint(_s.wallHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('formwork-wall-result'),
        title: _s.wallResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.wallFormula, [
                _fmt(_input(_wallLength)),
                _fmt(_input(_wallHeight)),
                _fmt(_input(_wallOpening) ?? 0),
                _fmt(_input(_wallSide) ?? 0),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _stairTab() {
    final area = _stairArea;
    final steps = int.tryParse(_stairSteps.text);
    return _page([
      ToolSection(
        key: const Key('formwork-stair'),
        title: _s.stairSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.stairSteps, '', _stairSteps),
              _field(_s.stairTreadWidth, 'm', _stairTread),
              _field(_s.stairRiser, 'm', _stairRiser),
            ]),
            _row([
              _field(_s.stairFlightWidth, 'm', _stairWidth),
              _field(_s.stairLanding, 'm', _stairLanding),
            ]),
            const SizedBox(height: 8),
            _hint(_s.stairHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('formwork-stair-result'),
        title: _s.stairResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.stairFormula, [
                _fmt(
                  steps == null
                      ? null
                      : stairSlopeLength(
                          steps: steps,
                          treadWidth: _input(_stairTread) ?? 0,
                          riserHeight: _input(_stairRiser) ?? 0,
                        ),
                ),
                _fmt(_input(_stairLanding) ?? 0),
                _fmt(_input(_stairWidth)),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _field(
    String label,
    String suffix,
    TextEditingController controller,
  ) => ToolNumberField(
    label: label,
    suffix: suffix,
    controller: controller,
    onChanged: (_) => setState(() {}),
  );

  Widget _row(List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ],
    ),
  );

  Widget _hint(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10.5,
      height: 1.5,
    ),
  );

  Widget _note() => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(child: _hint(_s.note)),
      ],
    ),
  );

  /// 数值转成算式里的文字：去掉多余的 0，整数不带小数点。
  String _fmt(double? value) {
    if (value == null) return '—';
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toStringAsFixed(0);
    }
    return formatNumber(value, significantDigits: 10);
  }
}
