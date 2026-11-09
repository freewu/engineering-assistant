import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import 'earthwork.dart';
import 'earthwork_lang.dart';
import 'earthwork_strings.dart';

/// 土石方工程量计算页：场地平整 / 基坑基槽 / 管沟土方 三个 tab。
///
/// 清单规则（GB/T 50854-2024）不计算放坡量，所以三个公式都只用
/// 垫层底尺寸、工作面与挖深。输入走 [ToolDraft]（id `earthwork`）。
class EarthworkPage extends StatefulWidget {
  const EarthworkPage({super.key});

  @override
  State<EarthworkPage> createState() => _EarthworkPageState();
}

class _EarthworkPageState extends State<EarthworkPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('earthwork');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kEarthworkTabCount,
    initialIndex:
        (_draft.integer('tab') ?? currentSettings?.toolTabFor('earthwork') ?? 0)
            .clamp(0, kEarthworkTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 场地平整：首层结构外围长宽
  late final TextEditingController _siteLength = _draft.controller(
    'siteLength',
    '30',
  );
  late final TextEditingController _siteWidth = _draft.controller(
    'siteWidth',
    '20',
  );

  // 基坑 / 基槽：垫层底长宽 + 工作面 + 挖深
  late final TextEditingController _baseLength = _draft.controller(
    'baseLength',
    '6',
  );
  late final TextEditingController _baseWidth = _draft.controller(
    'baseWidth',
    '4',
  );
  late final TextEditingController _workFace = _draft.controller(
    'workFace',
    '0.6',
  );
  late final TextEditingController _depth = _draft.controller('depth', '3');

  // 管沟：管外径 + 工作面 + 挖深 + 长度
  late final TextEditingController _pipeDiameter = _draft.controller(
    'pipeDiameter',
    '0.5',
  );
  late final TextEditingController _pipeWorkFace = _draft.controller(
    'pipeWorkFace',
    '0.6',
  );
  late final TextEditingController _pipeDepth = _draft.controller(
    'pipeDepth',
    '1.5',
  );
  late final TextEditingController _pipeLength = _draft.controller(
    'pipeLength',
    '50',
  );

  EarthworkStrings get _s => earthworkStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _siteLength,
      _siteWidth,
      _baseLength,
      _baseWidth,
      _workFace,
      _depth,
      _pipeDiameter,
      _pipeWorkFace,
      _pipeDepth,
      _pipeLength,
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

  /// 读一个输入框；空着或不是非负数时返回 null（结果显示「—」）。
  double? _input(TextEditingController controller) {
    final value = double.tryParse(controller.text);
    if (value == null || !value.isFinite || value < 0) return null;
    return value;
  }

  /// 多个输入都填好了才计算，缺一个就返回 null。
  double? _calc(
    List<TextEditingController> controllers,
    double Function(List<double> values) compute,
  ) {
    final values = <double>[];
    for (final controller in controllers) {
      final value = _input(controller);
      if (value == null) return null;
      values.add(value);
    }
    return compute(values);
  }

  double? get _levelingArea =>
      _calc([_siteLength, _siteWidth], (v) => siteLevelingArea(v[0], v[1]));

  double? get _excavation {
    final values = [_baseLength, _baseWidth, _depth, _workFace];
    final parsed = <double>[];
    // 工作面留空时按清单默认 600 mm 算，其余三个必须填
    for (final (index, controller) in values.indexed) {
      final value = _input(controller);
      if (value == null) {
        if (index == values.length - 1) {
          parsed.add(kDefaultWorkFace);
          continue;
        }
        return null;
      }
      parsed.add(value);
    }
    return excavationVolume(
      length: parsed[0],
      width: parsed[1],
      depth: parsed[2],
      workFace: parsed[3],
    );
  }

  double? get _trench {
    final values = [_pipeDiameter, _pipeDepth, _pipeLength, _pipeWorkFace];
    final parsed = <double>[];
    for (final (index, controller) in values.indexed) {
      final value = _input(controller);
      if (value == null) {
        if (index == values.length - 1) {
          parsed.add(kDefaultWorkFace);
          continue;
        }
        return null;
      }
      parsed.add(value);
    }
    return pipeTrenchVolume(
      pipeDiameter: parsed[0],
      depth: parsed[1],
      length: parsed[2],
      workFace: parsed[3],
    );
  }

  /// 实际参与计算的工作面（留空时是清单默认值）。
  double get _excavationWorkFace => _input(_workFace) ?? kDefaultWorkFace;

  double get _trenchWorkFace => _input(_pipeWorkFace) ?? kDefaultWorkFace;

  @override
  Widget build(BuildContext context) {
    final tabs = <String>[_s.tabLeveling, _s.tabExcavation, _s.tabTrench];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kEarthworkLang).name),
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
              key: const Key('earthwork-tabs'),
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
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              tabs: [
                for (final (index, label) in tabs.indexed)
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
              children: [_levelingTab(), _excavationTab(), _trenchTab()],
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

  /// 每个 tab 的公共外壳：可滚动 + 居中限宽。
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

  Widget _levelingTab() {
    final area = _levelingArea;
    return _page([
      ToolSection(
        key: const Key('earthwork-leveling'),
        title: _s.levelingSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.buildingLength,
                    suffix: 'm',
                    controller: _siteLength,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.buildingWidth,
                    suffix: 'm',
                    controller: _siteWidth,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _hint(_s.levelingHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('earthwork-leveling-result'),
        title: _s.levelingResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.levelingFormula, [
                _fmt(_input(_siteLength)),
                _fmt(_input(_siteWidth)),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _excavationTab() {
    final volume = _excavation;
    final workFace = _excavationWorkFace;
    return _page([
      ToolSection(
        key: const Key('earthwork-excavation'),
        title: _s.excavationSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.baseLength,
                    suffix: 'm',
                    controller: _baseLength,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.baseWidth,
                    suffix: 'm',
                    controller: _baseWidth,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.workFace,
                    suffix: 'm',
                    controller: _workFace,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.depth,
                    suffix: 'm',
                    controller: _depth,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _hint(_s.excavationHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('earthwork-excavation-result'),
        title: _s.excavationResult,
        value: volume,
        unit: 'm³',
        formula: volume == null
            ? null
            : fill(_s.excavationFormula, [
                _fmt(_input(_baseLength)),
                _fmt(workFace),
                _fmt(_input(_baseWidth)),
                _fmt(_input(_depth)),
                _fmt(volume),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _trenchTab() {
    final volume = _trench;
    final workFace = _trenchWorkFace;
    return _page([
      ToolSection(
        key: const Key('earthwork-trench'),
        title: _s.trenchSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.pipeDiameter,
                    suffix: 'm',
                    controller: _pipeDiameter,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.pipeLength,
                    suffix: 'm',
                    controller: _pipeLength,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.workFace,
                    suffix: 'm',
                    controller: _pipeWorkFace,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.depth,
                    suffix: 'm',
                    controller: _pipeDepth,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _hint(_s.trenchHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('earthwork-trench-result'),
        title: _s.trenchResult,
        value: volume,
        unit: 'm³',
        formula: volume == null
            ? null
            : fill(_s.trenchFormula, [
                _fmt(_input(_pipeDiameter)),
                _fmt(workFace),
                _fmt(_input(_pipeDepth)),
                _fmt(_input(_pipeLength)),
                _fmt(volume),
              ]),
      ),
      _note(),
    ]);
  }

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
