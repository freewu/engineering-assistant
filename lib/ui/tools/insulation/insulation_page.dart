import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import 'insulation.dart';
import 'insulation_lang.dart';
import 'insulation_strings.dart';

/// 保温隔热工程量页：屋面 / 墙面 / 柱三个 tab。
///
/// 面积按设计图示尺寸以㎡计算，体积 = 面积 × 保温层厚度。输入走
/// [ToolDraft]（id `insulation`），数值留空就不计算（结果显示「—」）。
class InsulationPage extends StatefulWidget {
  const InsulationPage({super.key});

  @override
  State<InsulationPage> createState() => _InsulationPageState();
}

class _InsulationPageState extends State<InsulationPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('insulation');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kInsulationTabCount,
    initialIndex:
        (_draft.integer('tab') ??
                currentSettings?.toolTabFor('insulation') ??
                0)
            .clamp(0, kInsulationTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 屋面：投影面积 / 孔洞面积 / 平均厚度
  late final TextEditingController _roofArea = _draft.controller(
    'roofArea',
    '100',
  );
  late final TextEditingController _roofHole = _draft.controller(
    'roofHole',
    '0',
  );
  late final TextEditingController _roofThickness = _draft.controller(
    'roofThickness',
    '0.1',
  );

  // 墙面：墙长 / 墙高 / 洞口 / 侧壁 / 厚度
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
  late final TextEditingController _wallThickness = _draft.controller(
    'wallThickness',
    '0.05',
  );

  // 柱：中心线展开长度 / 柱高 / 梁所占面积 / 厚度
  late final TextEditingController _columnPerimeter = _draft.controller(
    'columnPerimeter',
    '1.2',
  );
  late final TextEditingController _columnHeight = _draft.controller(
    'columnHeight',
    '3',
  );
  late final TextEditingController _columnBeam = _draft.controller(
    'columnBeam',
    '0.5',
  );
  late final TextEditingController _columnThickness = _draft.controller(
    'columnThickness',
    '0.05',
  );

  InsulationStrings get _s => insulationStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _roofArea,
      _roofHole,
      _roofThickness,
      _wallLength,
      _wallHeight,
      _wallOpening,
      _wallSide,
      _wallThickness,
      _columnPerimeter,
      _columnHeight,
      _columnBeam,
      _columnThickness,
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

  double? get _roofInsulationArea {
    final area = _input(_roofArea);
    if (area == null) return null;
    return roofInsulationArea(
      projectedArea: area,
      holeArea: _input(_roofHole) ?? 0,
    );
  }

  double? get _wallInsulationArea {
    final length = _input(_wallLength);
    final height = _input(_wallHeight);
    if (length == null || height == null) return null;
    return wallInsulationArea(
      length: length,
      height: height,
      openingArea: _input(_wallOpening) ?? 0,
      sideArea: _input(_wallSide) ?? 0,
    );
  }

  double? get _columnInsulationArea {
    final perimeter = _input(_columnPerimeter);
    final height = _input(_columnHeight);
    if (perimeter == null || height == null) return null;
    return columnInsulationArea(
      perimeterCenterline: perimeter,
      height: height,
      beamArea: _input(_columnBeam) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = <String>[_s.tabRoof, _s.tabWall, _s.tabColumn];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kInsulationLang).name),
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
              key: const Key('insulation-tabs'),
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
              children: [_roofTab(), _wallTab(), _columnTab()],
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

  Widget _roofTab() {
    final area = _roofInsulationArea;
    final thickness = _input(_roofThickness);
    return _page([
      ToolSection(
        key: const Key('insulation-roof'),
        title: _s.roofSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.projectedArea, 'm²', _roofArea),
              _field(_s.holeArea, 'm²', _roofHole),
            ]),
            _field(_s.avgThickness, 'm', _roofThickness),
            const SizedBox(height: 8),
            _hint(_s.roofHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('insulation-roof-area'),
        title: _s.roofAreaResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.roofAreaFormula, [
                _fmt(_input(_roofArea)),
                _fmt(_input(_roofHole) ?? 0),
                _fmt(area),
              ]),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('insulation-roof-volume'),
        title: _s.volumeResult,
        value: area == null || thickness == null
            ? null
            : insulationVolume(area: area, thickness: thickness),
        unit: 'm³',
        formula: area == null || thickness == null
            ? null
            : fill(_s.volumeFormula, [
                _fmt(area),
                _fmt(thickness),
                _fmt(insulationVolume(area: area, thickness: thickness)),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _wallTab() {
    final area = _wallInsulationArea;
    final thickness = _input(_wallThickness);
    return _page([
      ToolSection(
        key: const Key('insulation-wall'),
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
            _field(_s.thickness, 'm', _wallThickness),
            const SizedBox(height: 8),
            _hint(_s.wallHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('insulation-wall-area'),
        title: _s.wallAreaResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.wallAreaFormula, [
                _fmt(_input(_wallLength)),
                _fmt(_input(_wallHeight)),
                _fmt(_input(_wallOpening) ?? 0),
                _fmt(_input(_wallSide) ?? 0),
                _fmt(area),
              ]),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('insulation-wall-volume'),
        title: _s.volumeResult,
        value: area == null || thickness == null
            ? null
            : insulationVolume(area: area, thickness: thickness),
        unit: 'm³',
        formula: area == null || thickness == null
            ? null
            : fill(_s.volumeFormula, [
                _fmt(area),
                _fmt(thickness),
                _fmt(insulationVolume(area: area, thickness: thickness)),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _columnTab() {
    final area = _columnInsulationArea;
    final thickness = _input(_columnThickness);
    return _page([
      ToolSection(
        key: const Key('insulation-column'),
        title: _s.columnSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.columnPerimeter, 'm', _columnPerimeter),
              _field(_s.columnHeight, 'm', _columnHeight),
            ]),
            _row([
              _field(_s.beamArea, 'm²', _columnBeam),
              _field(_s.thickness, 'm', _columnThickness),
            ]),
            const SizedBox(height: 8),
            _hint(_s.columnHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('insulation-column-area'),
        title: _s.columnAreaResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.columnAreaFormula, [
                _fmt(_input(_columnPerimeter)),
                _fmt(_input(_columnHeight)),
                _fmt(_input(_columnBeam) ?? 0),
                _fmt(area),
              ]),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('insulation-column-volume'),
        title: _s.volumeResult,
        value: area == null || thickness == null
            ? null
            : insulationVolume(area: area, thickness: thickness),
        unit: 'm³',
        formula: area == null || thickness == null
            ? null
            : fill(_s.volumeFormula, [
                _fmt(area),
                _fmt(thickness),
                _fmt(insulationVolume(area: area, thickness: thickness)),
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
