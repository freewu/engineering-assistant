import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import 'paint.dart';
import 'paint_lang.dart';
import 'paint_strings.dart';

/// 油漆涂料页：墙面 / 天棚 / 门窗三个 tab。
///
/// 先按清单规则算涂刷面积（㎡），再按「面积 × 遍数 × 单耗」算涂料用量（kg）
/// 与向上取整的折合桶数。输入走 [ToolDraft]（id `paint`），数值留空就不计算。
class PaintPage extends StatefulWidget {
  const PaintPage({super.key});

  @override
  State<PaintPage> createState() => _PaintPageState();
}

class _PaintPageState extends State<PaintPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('paint');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kPaintTabCount,
    initialIndex:
        (_draft.integer('tab') ?? currentSettings?.toolTabFor('paint') ?? 0)
            .clamp(0, kPaintTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 墙面：墙长 / 墙高 / 洞口 + 遍数 / 单耗 / 桶重
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
  late final TextEditingController _wallCoats = _draft.controller(
    'wallCoats',
    '2',
  );
  late final TextEditingController _wallConsumption = _draft.controller(
    'wallConsumption',
    '0.25',
  );
  late final TextEditingController _wallCanWeight = _draft.controller(
    'wallCanWeight',
    '20',
  );

  // 天棚：净面积 / 梁侧面 + 遍数 / 单耗 / 桶重
  late final TextEditingController _ceilingArea = _draft.controller(
    'ceilingArea',
    '80',
  );
  late final TextEditingController _ceilingBeam = _draft.controller(
    'ceilingBeam',
    '4',
  );
  late final TextEditingController _ceilingCoats = _draft.controller(
    'ceilingCoats',
    '2',
  );
  late final TextEditingController _ceilingConsumption = _draft.controller(
    'ceilingConsumption',
    '0.25',
  );
  late final TextEditingController _ceilingCanWeight = _draft.controller(
    'ceilingCanWeight',
    '20',
  );

  // 门窗：樘数 / 每樘面积 / 展开系数 + 遍数 / 单耗 / 桶重
  late final TextEditingController _joineryCount = _draft.controller(
    'joineryCount',
    '8',
  );
  late final TextEditingController _joineryArea = _draft.controller(
    'joineryArea',
    '3.6',
  );
  late final TextEditingController _joineryFactor = _draft.controller(
    'joineryFactor',
    '1',
  );
  late final TextEditingController _joineryCoats = _draft.controller(
    'joineryCoats',
    '2',
  );
  late final TextEditingController _joineryConsumption = _draft.controller(
    'joineryConsumption',
    '0.15',
  );
  late final TextEditingController _joineryCanWeight = _draft.controller(
    'joineryCanWeight',
    '20',
  );

  PaintStrings get _s => paintStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _wallLength,
      _wallHeight,
      _wallOpening,
      _wallCoats,
      _wallConsumption,
      _wallCanWeight,
      _ceilingArea,
      _ceilingBeam,
      _ceilingCoats,
      _ceilingConsumption,
      _ceilingCanWeight,
      _joineryCount,
      _joineryArea,
      _joineryFactor,
      _joineryCoats,
      _joineryConsumption,
      _joineryCanWeight,
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

  /// 遍数按整数读，空着返回 null。
  int? _coats(TextEditingController controller) => _input(controller)?.round();

  // 墙面
  double? get _wallArea {
    final length = _input(_wallLength);
    final height = _input(_wallHeight);
    if (length == null || height == null) return null;
    return wallPaintArea(
      length: length,
      height: height,
      openingArea: _input(_wallOpening) ?? 0,
    );
  }

  // 天棚
  double? get _ceilingAreaValue {
    final area = _input(_ceilingArea);
    if (area == null) return null;
    return ceilingPaintArea(
      netArea: area,
      beamSideArea: _input(_ceilingBeam) ?? 0,
    );
  }

  // 门窗
  double? get _joineryAreaValue {
    final count = _input(_joineryCount);
    final area = _input(_joineryArea);
    if (count == null || area == null) return null;
    return joineryPaintArea(
      count: count,
      areaPerUnit: area,
      unfoldFactor: _input(_joineryFactor) ?? 1,
    );
  }

  /// 某一行对应的涂料用量：面积、遍数、单耗任一缺失就不算。
  double? _usage(
    double? area,
    TextEditingController coats,
    TextEditingController consumption,
  ) {
    final n = _coats(coats);
    final unit = _input(consumption);
    if (area == null || n == null || unit == null) return null;
    return paintUsage(area: area, coats: n, consumption: unit);
  }

  /// 折合桶数：用量与桶重都填了才算。
  double? _cans(double? usage, TextEditingController canWeight) {
    final weight = _input(canWeight);
    if (usage == null || weight == null) return null;
    return paintCans(usage: usage, canWeight: weight).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final labels = <String>[_s.tabWall, _s.tabCeiling, _s.tabJoinery];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kPaintLang).name),
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
              key: const Key('paint-tabs'),
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
              children: [_wallTab(), _ceilingTab(), _joineryTab()],
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
    final area = _wallArea;
    final usage = _usage(area, _wallCoats, _wallConsumption);
    final cans = _cans(usage, _wallCanWeight);
    return _page([
      ToolSection(
        key: const Key('paint-wall'),
        title: _s.wallSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.wallLength, 'm', _wallLength),
              _field(_s.wallHeight, 'm', _wallHeight),
            ]),
            _field(_s.openingArea, 'm²', _wallOpening),
            _commonFields(_wallCoats, _wallConsumption, _wallCanWeight),
            const SizedBox(height: 8),
            _hint(_s.wallHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _results(
        suffix: 'wall',
        area: area,
        areaFormula: area == null
            ? null
            : fill(_s.wallAreaFormula, [
                _fmt(_input(_wallLength)),
                _fmt(_input(_wallHeight)),
                _fmt(paintDeductedOpening(_input(_wallOpening) ?? 0)),
                _fmt(area),
              ]),
        usage: usage,
        usageFormula: usage == null
            ? null
            : fill(_s.usageFormula, [
                _fmt(area),
                '${_coats(_wallCoats) ?? 0}',
                _fmt(_input(_wallConsumption) ?? 0),
                _fmt(usage),
              ]),
        cans: cans,
        cansFormula: cans == null
            ? null
            : fill(_s.cansFormula, [
                _fmt(usage ?? 0),
                _fmt(_input(_wallCanWeight) ?? 0),
                _fmt(cans),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _ceilingTab() {
    final area = _ceilingAreaValue;
    final usage = _usage(area, _ceilingCoats, _ceilingConsumption);
    final cans = _cans(usage, _ceilingCanWeight);
    return _page([
      ToolSection(
        key: const Key('paint-ceiling'),
        title: _s.ceilingSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.netArea, 'm²', _ceilingArea),
              _field(_s.beamSideArea, 'm²', _ceilingBeam),
            ]),
            _commonFields(
              _ceilingCoats,
              _ceilingConsumption,
              _ceilingCanWeight,
            ),
            const SizedBox(height: 8),
            _hint(_s.ceilingHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _results(
        suffix: 'ceiling',
        area: area,
        areaFormula: area == null
            ? null
            : fill(_s.ceilingAreaFormula, [
                _fmt(_input(_ceilingArea)),
                _fmt(_input(_ceilingBeam) ?? 0),
                _fmt(area),
              ]),
        usage: usage,
        usageFormula: usage == null
            ? null
            : fill(_s.usageFormula, [
                _fmt(area),
                '${_coats(_ceilingCoats) ?? 0}',
                _fmt(_input(_ceilingConsumption) ?? 0),
                _fmt(usage),
              ]),
        cans: cans,
        cansFormula: cans == null
            ? null
            : fill(_s.cansFormula, [
                _fmt(usage ?? 0),
                _fmt(_input(_ceilingCanWeight) ?? 0),
                _fmt(cans),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _joineryTab() {
    final area = _joineryAreaValue;
    final usage = _usage(area, _joineryCoats, _joineryConsumption);
    final cans = _cans(usage, _joineryCanWeight);
    return _page([
      ToolSection(
        key: const Key('paint-joinery'),
        title: _s.joinerySection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.unitCount, _s.countUnit, _joineryCount),
              _field(_s.areaPerUnit, 'm²', _joineryArea),
            ]),
            _field(_s.unfoldFactor, '', _joineryFactor),
            _commonFields(
              _joineryCoats,
              _joineryConsumption,
              _joineryCanWeight,
            ),
            const SizedBox(height: 8),
            _hint(_s.joineryHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _results(
        suffix: 'joinery',
        area: area,
        areaFormula: area == null
            ? null
            : fill(_s.joineryAreaFormula, [
                _fmt(_input(_joineryCount)),
                _fmt(_input(_joineryArea)),
                _fmt(_input(_joineryFactor) ?? 1),
                _fmt(area),
              ]),
        usage: usage,
        usageFormula: usage == null
            ? null
            : fill(_s.usageFormula, [
                _fmt(area),
                '${_coats(_joineryCoats) ?? 0}',
                _fmt(_input(_joineryConsumption) ?? 0),
                _fmt(usage),
              ]),
        cans: cans,
        cansFormula: cans == null
            ? null
            : fill(_s.cansFormula, [
                _fmt(usage ?? 0),
                _fmt(_input(_joineryCanWeight) ?? 0),
                _fmt(cans),
              ]),
      ),
      _note(),
    ]);
  }

  /// 三个 tab 共用的「遍数 / 单耗 / 每桶净重」一行。
  Widget _commonFields(
    TextEditingController coats,
    TextEditingController consumption,
    TextEditingController canWeight,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _row([
        _field(_s.coats, _s.coatUnit, coats),
        _field(_s.consumption, _s.consumptionUnit, consumption),
      ]),
      _field(_s.canWeight, 'kg', canWeight),
    ],
  );

  /// 涂刷面积 / 涂料用量 / 折合桶数三张结果卡。
  Widget _results({
    required String suffix,
    required double? area,
    required String? areaFormula,
    required double? usage,
    required String? usageFormula,
    required double? cans,
    required String? cansFormula,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ToolResultCard(
        key: Key('paint-$suffix-area'),
        title: _s.areaResult,
        value: area,
        unit: 'm²',
        formula: areaFormula,
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: Key('paint-$suffix-usage'),
        title: _s.usageResult,
        value: usage,
        unit: 'kg',
        formula: usageFormula,
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: Key('paint-$suffix-cans'),
        title: _s.cansResult,
        value: cans,
        unit: _s.canUnit,
        formula: cansFormula,
        icon: Icons.inventory_2_outlined,
      ),
    ],
  );

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
