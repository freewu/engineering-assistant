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
import 'material.dart';
import 'material_lang.dart';
import 'material_strings.dart';

/// 「材料用量」估算页：砖块 / 混凝土 / 水泥 / 砂子 四个 tab，各自独立计算。
///
/// 所有输入都走 [ToolDraft]（工具 id `material`），切 tab、退出再进来都还在。
/// 公式只做经验估算，正式下料以图纸与配合比为准。
class MaterialUsagePage extends StatefulWidget {
  const MaterialUsagePage({super.key});

  @override
  State<MaterialUsagePage> createState() => _MaterialUsagePageState();
}

class _MaterialUsagePageState extends State<MaterialUsagePage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('material');

  /// 四个 tab：砖块 / 混凝土 / 水泥 / 砂子。
  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kMaterialTabCount,
    initialIndex:
        (_draft.integer('tab') ?? currentSettings?.toolTabFor('material') ?? 0)
            .clamp(0, kMaterialTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 数值都带一个常用默认值（还是可以清空，清空就不计算）
  late final TextEditingController _brickVolume = _draft.controller(
    'brickVolume',
    '10',
  );
  late final TextEditingController _concreteArea = _draft.controller(
    'concreteArea',
    '20',
  );
  late final TextEditingController _concreteThickness = _draft.controller(
    'concreteThickness',
    kCushionThickness.toString(),
  );
  late final TextEditingController _cementArea = _draft.controller(
    'cementArea',
    '20',
  );
  late final TextEditingController _sandArea = _draft.controller(
    'sandArea',
    '20',
  );

  late BrickType _brickType =
      _draft.enumOf('brickType', BrickType.values) ?? BrickType.standard;

  /// 水泥单耗只允许取经验档位，存的是 `double`，回落 0.05。
  late double _cementRate = kCementRates.contains(_draft.number('cementRate'))
      ? _draft.number('cementRate')!
      : kCementRates.last;

  MaterialStrings get _s => materialStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _brickVolume,
      _concreteArea,
      _concreteThickness,
      _cementArea,
      _sandArea,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabChanged() {
    // 指示器动画期间也要重绘，顺便把当前 tab 记进草稿
    if (!mounted) return;
    if (!_tabs.indexIsChanging) _draft.set('tab', _tabs.index);
    setState(() {});
  }

  /// 读输入框里的数；空着或不是数就返回 null（结果显示为「—」）。
  double? _input(TextEditingController controller) {
    final value = double.tryParse(controller.text);
    if (value == null || !value.isFinite || value < 0) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String>[
      _s.tabBricks,
      _s.tabConcrete,
      _s.tabCement,
      _s.tabSand,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kMaterialLang).name),
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
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
              labelPadding: EdgeInsets.zero,
              tabs: [
                // 每个 tab 用自己的强调色，和换算页「常见」标签同一套色板
                for (final (index, label) in tabs.indexed)
                  Tab(
                    height: 38,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
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
                _tab(child: _bricksTab()),
                _tab(child: _concreteTab()),
                _tab(child: _cementTab()),
                _tab(child: _sandTab()),
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
  Widget _tab({required Widget child}) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 660),
        child: child,
      ),
    ),
  );

  Widget _bricksTab() {
    final volume = _input(_brickVolume);
    final count = volume == null ? null : brickCount(volume, _brickType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSection(
          key: const Key('material-bricks'),
          title: _s.bricksSection,
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolSelect<BrickType>(
                key: const Key('material-brick-type'),
                label: _s.brickType,
                value: _brickType,
                items: BrickType.values,
                labelOf: (type) => type == BrickType.standard
                    ? _s.brickStandard
                    : _s.brickPerforated,
                onChanged: (type) {
                  _draft.setEnum('brickType', type);
                  setState(() => _brickType = type);
                },
              ),
              const SizedBox(height: 12),
              ToolNumberField(
                label: _s.volume,
                suffix: _s.cubicMeterUnit,
                controller: _brickVolume,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ToolResultCard(
          key: const Key('material-brick-result'),
          title: _s.brickResult,
          value: count,
          unit: _s.pieceUnit,
          formula: count == null
              ? null
              : fill(_s.brickFormula, [
                  formatNumber(volume!, significantDigits: 10),
                  '${_brickType.perCubicMeter}',
                  formatNumber(count, significantDigits: 10),
                ]),
        ),
        const SizedBox(height: 12),
        ToolSection(
          title: _s.wallSection,
          icon: Icons.lightbulb_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final wall in WallThickness.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _s.wallName(wall),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      Text(
                        '${wall.perSquareMeter} ${_s.pieceUnit}/㎡',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _note(),
      ],
    );
  }

  Widget _concreteTab() {
    final area = _input(_concreteArea);
    final thickness = _input(_concreteThickness);
    final result = area == null || thickness == null
        ? null
        : concreteVolume(area, thickness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSection(
          key: const Key('material-concrete'),
          title: _s.concreteSection,
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolNumberField(
                label: _s.area,
                suffix: '㎡',
                controller: _concreteArea,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              ToolNumberField(
                label: _s.thickness,
                suffix: 'm',
                controller: _concreteThickness,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              _hint(_s.concreteHint),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ToolResultCard(
          key: const Key('material-concrete-result'),
          title: _s.concreteResult,
          value: result,
          unit: _s.cubicMeterUnit,
          formula: result == null
              ? null
              : fill(_s.concreteFormula, [
                  formatNumber(area!, significantDigits: 10),
                  formatNumber(thickness!, significantDigits: 10),
                  formatNumber(result, significantDigits: 10),
                ]),
        ),
        _note(),
      ],
    );
  }

  Widget _cementTab() {
    final area = _input(_cementArea);
    final result = area == null ? null : cementTons(area, _cementRate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSection(
          key: const Key('material-cement'),
          title: _s.cementSection,
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolNumberField(
                label: _s.buildingArea,
                suffix: '㎡',
                controller: _cementArea,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              ToolSelect<double>(
                key: const Key('material-cement-rate'),
                label: _s.cementRate,
                value: _cementRate,
                items: kCementRates,
                labelOf: (rate) => '${_trimZero(rate)} ${_s.tonUnit}/㎡',
                onChanged: (rate) {
                  _draft.set('cementRate', rate);
                  setState(() => _cementRate = rate);
                },
              ),
              const SizedBox(height: 8),
              _hint(_s.cementHint),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ToolResultCard(
          key: const Key('material-cement-result'),
          title: _s.cementResult,
          value: result,
          unit: _s.tonUnit,
          formula: result == null
              ? null
              : fill(_s.cementFormula, [
                  formatNumber(area!, significantDigits: 10),
                  _trimZero(_cementRate),
                  formatNumber(result, significantDigits: 10),
                ]),
        ),
        _note(),
      ],
    );
  }

  Widget _sandTab() {
    final area = _input(_sandArea);
    final result = area == null ? null : sandVolume(area);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSection(
          key: const Key('material-sand'),
          title: _s.sandSection,
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolNumberField(
                label: _s.buildingArea,
                suffix: '㎡',
                controller: _sandArea,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              _hint(_s.sandHint),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ToolResultCard(
          key: const Key('material-sand-result'),
          title: _s.sandResult,
          value: result,
          unit: _s.cubicMeterUnit,
          formula: result == null
              ? null
              : fill(_s.sandFormula, [
                  formatNumber(area!, significantDigits: 10),
                  formatNumber(result, significantDigits: 10),
                ]),
        ),
        _note(),
      ],
    );
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
}

/// 去掉小数的 `.0`：0.1 → 0.1、0.050 → 0.05、1.0 → 1。
String _trimZero(double value) {
  final text = value.toStringAsFixed(3);
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
