import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import 'decoration.dart';
import 'decoration_lang.dart';
import 'decoration_strings.dart';

/// 装饰装修工程量页：墙面 / 天棚 / 楼地面三个 tab。
///
/// 按设计图示尺寸以面积（㎡）计算，单个 ≤ 0.3 ㎡ 的孔洞不扣。输入走
/// [ToolDraft]（id `decoration`），数值留空就不计算（结果显示「—」）。
class DecorationPage extends StatefulWidget {
  const DecorationPage({super.key});

  @override
  State<DecorationPage> createState() => _DecorationPageState();
}

class _DecorationPageState extends State<DecorationPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('decoration');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kDecorationTabCount,
    initialIndex:
        (_draft.integer('tab') ??
                currentSettings?.toolTabFor('decoration') ??
                0)
            .clamp(0, kDecorationTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 墙面：墙长 / 墙高 / 洞口 / 侧壁 / 附墙柱梁
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
    '0',
  );
  late final TextEditingController _wallAttached = _draft.controller(
    'wallAttached',
    '0',
  );

  // 天棚：净面积 / 梁侧面
  late final TextEditingController _ceilingArea = _draft.controller(
    'ceilingArea',
    '80',
  );
  late final TextEditingController _ceilingBeam = _draft.controller(
    'ceilingBeam',
    '4',
  );

  // 楼地面：净面积 / 构筑物
  late final TextEditingController _floorArea = _draft.controller(
    'floorArea',
    '80',
  );
  late final TextEditingController _floorStructure = _draft.controller(
    'floorStructure',
    '2',
  );

  DecorationStrings get _s => decorationStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _wallLength,
      _wallHeight,
      _wallOpening,
      _wallSide,
      _wallAttached,
      _ceilingArea,
      _ceilingBeam,
      _floorArea,
      _floorStructure,
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

  double? get _wallResult {
    final length = _input(_wallLength);
    final height = _input(_wallHeight);
    if (length == null || height == null) return null;
    return wallFinishArea(
      length: length,
      height: height,
      openingArea: _input(_wallOpening) ?? 0,
      sideArea: _input(_wallSide) ?? 0,
      attachedArea: _input(_wallAttached) ?? 0,
    );
  }

  double? get _ceilingResult {
    final area = _input(_ceilingArea);
    if (area == null) return null;
    return ceilingFinishArea(
      netArea: area,
      beamSideArea: _input(_ceilingBeam) ?? 0,
    );
  }

  double? get _floorResult {
    final area = _input(_floorArea);
    if (area == null) return null;
    return floorFinishArea(
      netArea: area,
      structureArea: _input(_floorStructure) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = <String>[_s.tabWall, _s.tabCeiling, _s.tabFloor];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kDecorationLang).name),
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
              key: const Key('decoration-tabs'),
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
              children: [_wallTab(), _ceilingTab(), _floorTab()],
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

  Widget _wallTab() {
    final area = _wallResult;
    return _page([
      ToolSection(
        key: const Key('decoration-wall'),
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
              _field(_s.openingArea, 'm²', _wallOpening),
              _field(_s.sideArea, 'm²', _wallSide),
            ]),
            _field(_s.attachedArea, 'm²', _wallAttached),
            const SizedBox(height: 8),
            _hint(_s.wallHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('decoration-wall-result'),
        title: _s.wallResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.wallFormula, [
                _fmt(_input(_wallLength)),
                _fmt(_input(_wallHeight)),
                _fmt(deductedHole(_input(_wallOpening) ?? 0)),
                _fmt(_input(_wallSide) ?? 0),
                _fmt(_input(_wallAttached) ?? 0),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _ceilingTab() {
    final area = _ceilingResult;
    return _page([
      ToolSection(
        key: const Key('decoration-ceiling'),
        title: _s.ceilingSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.netArea, 'm²', _ceilingArea),
              _field(_s.beamSideArea, 'm²', _ceilingBeam),
            ]),
            const SizedBox(height: 8),
            _hint(_s.ceilingHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('decoration-ceiling-result'),
        title: _s.ceilingResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.ceilingFormula, [
                _fmt(_input(_ceilingArea)),
                _fmt(_input(_ceilingBeam) ?? 0),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _floorTab() {
    final area = _floorResult;
    return _page([
      ToolSection(
        key: const Key('decoration-floor'),
        title: _s.floorSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.netArea, 'm²', _floorArea),
              _field(_s.structureArea, 'm²', _floorStructure),
            ]),
            const SizedBox(height: 8),
            _hint(_s.floorHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('decoration-floor-result'),
        title: _s.floorResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.floorFormula, [
                _fmt(_input(_floorArea)),
                _fmt(deductedHole(_input(_floorStructure) ?? 0)),
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
