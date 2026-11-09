import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import 'rebar.dart';
import 'rebar_lang.dart';
import 'rebar_strings.dart';

/// 钢筋工程量页：直钢筋 / 箍筋 / 弯起钢筋 / 速查表 四个 tab。
///
/// 清单规则（GB/T 50854-2024）：设计图示中心线长度 × 单位理论质量。
/// 长度输入一律 mm（施工图习惯），结果显示中心线长度（mm）与质量（kg）。
/// 输入走 [ToolDraft]（id `rebar`），数值留空就不计算。
class RebarPage extends StatefulWidget {
  const RebarPage({super.key});

  @override
  State<RebarPage> createState() => _RebarPageState();
}

class _RebarPageState extends State<RebarPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('rebar');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kRebarTabCount,
    initialIndex:
        (_draft.integer('tab') ?? currentSettings?.toolTabFor('rebar') ?? 0)
            .clamp(0, kRebarTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 直钢筋：构件长度 / 保护层 / 单端弯钩 / 直径 / 根数
  late final TextEditingController _memberLength = _draft.controller(
    'memberLength',
    '6000',
  );
  late final TextEditingController _cover = _draft.controller('cover', '25');
  late final TextEditingController _hook = _draft.controller('hook', '0');
  late final TextEditingController _diameter = _draft.controller(
    'diameter',
    '20',
  );
  late final TextEditingController _count = _draft.controller('count', '1');

  // 箍筋：截面 a / b / 保护层 / 直径 / 根数
  late final TextEditingController _sectionA = _draft.controller(
    'sectionA',
    '300',
  );
  late final TextEditingController _sectionB = _draft.controller(
    'sectionB',
    '600',
  );
  late final TextEditingController _stirrupCover = _draft.controller(
    'stirrupCover',
    '25',
  );
  late final TextEditingController _stirrupDiameter = _draft.controller(
    'stirrupDiameter',
    '8',
  );
  late final TextEditingController _stirrupCount = _draft.controller(
    'stirrupCount',
    '1',
  );

  // 弯起钢筋：直段长 / 斜段长 / 弯曲调整值 / 弯钩长 / 直径 / 根数
  late final TextEditingController _straightPart = _draft.controller(
    'straightPart',
    '4000',
  );
  late final TextEditingController _inclinedPart = _draft.controller(
    'inclinedPart',
    '500',
  );
  late final TextEditingController _bendAdjustment = _draft.controller(
    'bendAdjustment',
    '0',
  );
  late final TextEditingController _bentHook = _draft.controller(
    'bentHook',
    '0',
  );
  late final TextEditingController _bentDiameter = _draft.controller(
    'bentDiameter',
    '20',
  );
  late final TextEditingController _bentCount = _draft.controller(
    'bentCount',
    '1',
  );

  RebarStrings get _s => rebarStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _memberLength,
      _cover,
      _hook,
      _diameter,
      _count,
      _sectionA,
      _sectionB,
      _stirrupCover,
      _stirrupDiameter,
      _stirrupCount,
      _straightPart,
      _inclinedPart,
      _bendAdjustment,
      _bentHook,
      _bentDiameter,
      _bentCount,
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

  double? get _straightLength => _calc(
    [_memberLength, _cover, _hook],
    (v) =>
        straightRebarLength(memberLength: v[0], cover: v[1], hookLength: v[2]),
  );

  double? get _stirrupLength => _calc(
    [_sectionA, _sectionB, _stirrupCover, _stirrupDiameter],
    (v) => stirrupRebarLength(
      sectionA: v[0],
      sectionB: v[1],
      cover: v[2],
      diameter: v[3],
    ),
  );

  double? get _bentLength => _calc(
    [_straightPart, _inclinedPart, _bendAdjustment, _bentHook],
    (v) => bentRebarLength(
      straightPart: v[0],
      inclinedPart: v[1],
      bendAdjustment: v[2],
      hookLength: v[3],
    ),
  );

  /// 钢筋质量：根数留空按 1 根算，中心线长度与直径必须算得出来。
  double? _mass(
    double? length,
    TextEditingController diameterController,
    TextEditingController countController,
  ) {
    final diameter = _input(diameterController);
    if (length == null || diameter == null) return null;
    return rebarMass(
      length: length,
      diameter: diameter,
      count: (_input(countController) ?? 1).round(),
    );
  }

  double? get _straightMass => _mass(_straightLength, _diameter, _count);
  double? get _stirrupMass =>
      _mass(_stirrupLength, _stirrupDiameter, _stirrupCount);
  double? get _bentMass => _mass(_bentLength, _bentDiameter, _bentCount);

  @override
  Widget build(BuildContext context) {
    final tabs = <String>[
      _s.tabStraight,
      _s.tabStirrup,
      _s.tabBent,
      _s.tabTable,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kRebarLang).name),
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
              key: const Key('rebar-tabs'),
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
              children: [
                _straightTab(),
                _stirrupTab(),
                _bentTab(),
                _tableTab(),
              ],
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

  Widget _tab({
    required Key key,
    required String title,
    required List<Widget> children,
    required String hint,
    required String lengthTitle,
    required double? length,
    required String? lengthFormula,
    required String massTitle,
    required double? mass,
    required String? massFormula,
  }) => _page([
    ToolSection(
      key: key,
      title: title,
      icon: Icons.straighten_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...children, const SizedBox(height: 8), _hint(hint)],
      ),
    ),
    const SizedBox(height: 12),
    ToolResultCard(
      key: Key('${key.toString()}-length'),
      title: lengthTitle,
      value: length,
      unit: 'mm',
      formula: lengthFormula,
    ),
    const SizedBox(height: 12),
    ToolResultCard(
      key: Key('${key.toString()}-mass'),
      title: massTitle,
      value: mass,
      unit: 'kg',
      icon: Icons.scale_rounded,
      formula: massFormula,
    ),
    _note(),
  ]);

  Widget _straightTab() {
    final length = _straightLength;
    final mass = _straightMass;
    return _tab(
      key: const Key('rebar-straight'),
      title: _s.straightSection,
      hint: _s.straightHint,
      lengthTitle: _s.lengthResult,
      length: length,
      lengthFormula: length == null
          ? null
          : fill(_s.straightFormula, [
              _fmt(_input(_memberLength)),
              _fmt(_input(_cover)),
              _fmt(_input(_hook)),
              _fmt(length),
            ]),
      massTitle: _s.massResult,
      mass: mass,
      massFormula: mass == null
          ? null
          : fill(_s.massFormula, [
              _fmt(_input(_count) ?? 1),
              _fmt(length == null ? null : length / 1000),
              _fmt(_input(_diameter)),
              _fmt(mass),
            ]),
      children: [
        _row([
          _field(_s.memberLength, 'mm', _memberLength),
          _field(_s.cover, 'mm', _cover),
        ]),
        _row([
          _field(_s.hookLength, 'mm', _hook),
          _field(_s.diameter, 'mm', _diameter),
        ]),
        _field(_s.count, '', _count),
      ],
    );
  }

  Widget _stirrupTab() {
    final length = _stirrupLength;
    final mass = _stirrupMass;
    return _tab(
      key: const Key('rebar-stirrup'),
      title: _s.stirrupSection,
      hint: _s.stirrupHint,
      lengthTitle: _s.lengthResult,
      length: length,
      lengthFormula: length == null
          ? null
          : fill(_s.stirrupFormula, [
              _fmt(_input(_sectionA)),
              _fmt(_input(_sectionB)),
              _fmt(_input(_stirrupCover)),
              _fmt(_input(_stirrupDiameter)),
              _fmt(length),
            ]),
      massTitle: _s.massResult,
      mass: mass,
      massFormula: mass == null
          ? null
          : fill(_s.massFormula, [
              _fmt(_input(_stirrupCount) ?? 1),
              _fmt(length == null ? null : length / 1000),
              _fmt(_input(_stirrupDiameter)),
              _fmt(mass),
            ]),
      children: [
        _row([
          _field(_s.sectionA, 'mm', _sectionA),
          _field(_s.sectionB, 'mm', _sectionB),
        ]),
        _row([
          _field(_s.cover, 'mm', _stirrupCover),
          _field(_s.diameter, 'mm', _stirrupDiameter),
        ]),
        _field(_s.count, '', _stirrupCount),
      ],
    );
  }

  Widget _bentTab() {
    final length = _bentLength;
    final mass = _bentMass;
    return _tab(
      key: const Key('rebar-bent'),
      title: _s.bentSection,
      hint: _s.bentHint,
      lengthTitle: _s.lengthResult,
      length: length,
      lengthFormula: length == null
          ? null
          : fill(_s.bentFormula, [
              _fmt(_input(_straightPart)),
              _fmt(_input(_inclinedPart)),
              _fmt(_input(_bendAdjustment)),
              _fmt(_input(_bentHook)),
              _fmt(length),
            ]),
      massTitle: _s.massResult,
      mass: mass,
      massFormula: mass == null
          ? null
          : fill(_s.massFormula, [
              _fmt(_input(_bentCount) ?? 1),
              _fmt(length == null ? null : length / 1000),
              _fmt(_input(_bentDiameter)),
              _fmt(mass),
            ]),
      children: [
        _row([
          _field(_s.straightPart, 'mm', _straightPart),
          _field(_s.inclinedPart, 'mm', _inclinedPart),
        ]),
        _row([
          _field(_s.bendAdjustment, 'mm', _bendAdjustment),
          _field(_s.hookLength, 'mm', _bentHook),
        ]),
        _row([
          _field(_s.diameter, 'mm', _bentDiameter),
          _field(_s.count, '', _bentCount),
        ]),
      ],
    );
  }

  /// 速查表：常用直径的理论质量（W = 0.00617 × d²）。
  Widget _tableTab() => _page([
    ToolSection(
      key: const Key('rebar-table'),
      title: _s.tableSection,
      icon: Icons.table_rows_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tableRow(_s.tableDiameter, _s.tableMass, header: true),
          Divider(height: 14, color: AppColors.outline),
          for (final diameter in kCommonDiameters)
            _tableRow(
              'φ$diameter',
              '${formatNumber(kReferenceMassPerMeter[diameter] ?? rebarMassPerMeter(diameter.toDouble()))} kg/m',
              note: '0.00617 × $diameter²',
            ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _hint(_s.tableHint),
    ),
    _note(),
  ]);

  Widget _tableRow(
    String left,
    String right, {
    bool header = false,
    String? note,
  }) {
    final style = TextStyle(
      color: header ? AppColors.textSecondary : AppColors.textPrimary,
      fontSize: header ? 11.5 : 13.5,
      fontWeight: header ? FontWeight.w600 : FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(left, style: style)),
          Expanded(
            child: Text(
              right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.copyWith(
                color: header ? AppColors.textSecondary : AppColors.primary,
                fontWeight: header ? FontWeight.w600 : FontWeight.w700,
              ),
            ),
          ),
          if (note != null)
            Text(
              note,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
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
