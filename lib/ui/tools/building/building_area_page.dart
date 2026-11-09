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
import 'building_area.dart';
import 'building_area_lang.dart';
import 'building_area_strings.dart';

/// 建筑面积计算页：单层 / 多层 / 阳台 / 雨篷 / 门斗 / 车棚货棚 六个 tab。
///
/// 每个 tab 只算自己那部分，切 tab 不影响别的输入；每个 tab 底部都有
/// 「合计建筑面积」，把六部分里已填的加起来。输入走 [ToolDraft]（id `building_area`）。
class BuildingAreaPage extends StatefulWidget {
  const BuildingAreaPage({super.key});

  @override
  State<BuildingAreaPage> createState() => _BuildingAreaPageState();
}

class _BuildingAreaPageState extends State<BuildingAreaPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('building_area');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kBuildingTabCount,
    initialIndex:
        (_draft.integer('tab') ??
                currentSettings?.toolTabFor('building_area') ??
                0)
            .clamp(0, kBuildingTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 数值都带一个常用默认值（还是可以清空，清空的项不计算，合计也跳过它）
  // 单层建筑：L / B / 结构高度
  late final TextEditingController _length = _draft.controller('length', '10');
  late final TextEditingController _width = _draft.controller('width', '8');
  late final TextEditingController _height = _draft.controller('height', '3.6');

  // 多层建筑：层数 / 每层面积
  late final TextEditingController _floors = _draft.controller('floors', '3');
  late final TextEditingController _perFloor = _draft.controller(
    'perFloor',
    '80',
  );

  // 阳台
  late final TextEditingController _balcony = _draft.controller('balcony', '4');

  // 雨篷：投影面积 / 外挑宽度 / 有柱无柱
  late final TextEditingController _canopy = _draft.controller('canopy', '6');
  late final TextEditingController _canopyWidth = _draft.controller(
    'canopyWidth',
    '2.4',
  );
  late bool _hasColumns = _draft.flag('hasColumns');

  // 门斗：围护面积 / 结构层高
  late final TextEditingController _vestibule = _draft.controller(
    'vestibule',
    '3',
  );
  late final TextEditingController _vestibuleHeight = _draft.controller(
    'vestibuleHeight',
    '2.4',
  );

  // 车棚 / 货棚
  late final TextEditingController _shed = _draft.controller('shed', '20');

  BuildingAreaStrings get _s => buildingAreaStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _length,
      _width,
      _height,
      _floors,
      _perFloor,
      _balcony,
      _canopy,
      _canopyWidth,
      _vestibule,
      _vestibuleHeight,
      _shed,
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

  double? get _singleArea => _calc([
    _length,
    _width,
    _height,
  ], (v) => singleStoreyArea(v[0], v[1], v[2]));

  double? get _multiArea =>
      _calc([_floors, _perFloor], (v) => multiStoreyArea(v[0].round(), v[1]));

  double? get _balconyArea => _calc([_balcony], (v) => balconyArea(v[0]));

  double? get _canopyArea => _calc([
    _canopy,
    _canopyWidth,
  ], (v) => canopyArea(v[0], width: v[1], hasColumns: _hasColumns));

  double? get _vestibuleArea =>
      _calc([_vestibule, _vestibuleHeight], (v) => vestibuleArea(v[0], v[1]));

  double? get _shedArea => _calc([_shed], (v) => shedArea(v[0]));

  /// 六部分面积；``null`` 表示该项还没填。
  List<double?> get _parts => [
    _singleArea,
    _multiArea,
    _balconyArea,
    _canopyArea,
    _vestibuleArea,
    _shedArea,
  ];

  /// 合计：全都没填时显示「—」，否则已填的相加。
  double? get _total {
    final parts = _parts;
    if (parts.every((part) => part == null)) return null;
    return totalArea(parts);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String>[
      _s.tabSingle,
      _s.tabMulti,
      _s.tabBalcony,
      _s.tabCanopy,
      _s.tabVestibule,
      _s.tabShed,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kBuildingAreaLang).name),
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
              key: const Key('building-tabs'),
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
              children: [
                _singleTab(),
                _multiTab(),
                _balconyTab(),
                _canopyTab(),
                _vestibuleTab(),
                _shedTab(),
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

  Widget _singleTab() {
    final area = _singleArea;
    final height = _input(_height);
    // 结构高度不足 2.2 m 只算一半，公式里把系数写出来
    final factor = (height ?? kFullAreaHeight) >= kFullAreaHeight ? '1' : '1/2';
    return _page([
      ToolSection(
        key: const Key('building-single'),
        title: _s.singleSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.length,
                    suffix: 'm',
                    controller: _length,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.width,
                    suffix: 'm',
                    controller: _width,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ToolNumberField(
              label: _s.height,
              suffix: 'm',
              controller: _height,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.singleHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('building-single-result'),
        title: _s.singleResult,
        value: area,
        unit: _s.squareMeter,
        formula: area == null
            ? null
            : fill(_s.singleFormula, [
                _fmt(_input(_length)),
                _fmt(_input(_width)),
                factor,
                _fmt(area),
              ]),
      ),
      _totalCard(),
      _note(),
    ]);
  }

  Widget _multiTab() {
    final area = _multiArea;
    return _page([
      ToolSection(
        key: const Key('building-multi'),
        title: _s.multiSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.floors,
                    suffix: _s.floorUnit,
                    controller: _floors,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ToolNumberField(
                    label: _s.perFloorArea,
                    suffix: _s.squareMeter,
                    controller: _perFloor,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _hint(_s.multiHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('building-multi-result'),
        title: _s.multiResult,
        value: area,
        unit: _s.squareMeter,
        formula: area == null
            ? null
            : fill(_s.multiFormula, [
                _fmt(_input(_floors)?.roundToDouble()),
                _fmt(_input(_perFloor)),
                _fmt(area),
              ]),
      ),
      _totalCard(),
      _note(),
    ]);
  }

  Widget _balconyTab() {
    final area = _balconyArea;
    return _page([
      ToolSection(
        key: const Key('building-balcony'),
        title: _s.balconySection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolNumberField(
              label: _s.balconyArea,
              suffix: _s.squareMeter,
              controller: _balcony,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.balconyHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('building-balcony-result'),
        title: _s.balconyResult,
        value: area,
        unit: _s.squareMeter,
        formula: area == null
            ? null
            : fill(_s.balconyFormula, [_fmt(_input(_balcony)), _fmt(area)]),
      ),
      _totalCard(),
      _note(),
    ]);
  }

  Widget _canopyTab() {
    final area = _canopyArea;
    final raw = _input(_canopy);
    final width = _input(_canopyWidth);
    // 无柱且宽度不过 2.1 m 时不计入，结果算 0，公式行改成规则说明
    final skipped = area == null
        ? false
        : !_hasColumns && (width ?? 0) <= kCanopyMinWidth;
    final String? formula;
    if (area == null) {
      formula = null;
    } else if (skipped) {
      formula = _s.canopySkipped;
    } else {
      formula = fill(_s.canopyFormula, [_fmt(raw), _fmt(area)]);
    }
    return _page([
      ToolSection(
        key: const Key('building-canopy'),
        title: _s.canopySection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolNumberField(
              label: _s.canopyArea,
              suffix: _s.squareMeter,
              controller: _canopy,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.canopyWidth,
                    suffix: 'm',
                    controller: _canopyWidth,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolSelect<bool>(
                    key: const Key('building-canopy-columns'),
                    label: _s.withColumns,
                    value: _hasColumns,
                    items: const [true, false],
                    labelOf: (value) =>
                        value ? _s.withColumns : _s.withoutColumns,
                    onChanged: (value) {
                      _draft.setFlag('hasColumns', value);
                      setState(() => _hasColumns = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _hint(_s.canopyHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('building-canopy-result'),
        title: _s.canopyResult,
        value: area,
        unit: _s.squareMeter,
        formula: formula,
      ),
      _totalCard(),
      _note(),
    ]);
  }

  Widget _vestibuleTab() {
    final area = _vestibuleArea;
    final height = _input(_vestibuleHeight);
    final factor = (height ?? kFullAreaHeight) >= kFullAreaHeight ? '1' : '1/2';
    return _page([
      ToolSection(
        key: const Key('building-vestibule'),
        title: _s.vestibuleSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolNumberField(
              label: _s.vestibuleArea,
              suffix: _s.squareMeter,
              controller: _vestibule,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ToolNumberField(
              label: _s.storeyHeight,
              suffix: 'm',
              controller: _vestibuleHeight,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.vestibuleHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('building-vestibule-result'),
        title: _s.vestibuleResult,
        value: area,
        unit: _s.squareMeter,
        formula: area == null
            ? null
            : fill(_s.vestibuleFormula, [
                _fmt(_input(_vestibule)),
                factor,
                _fmt(area),
              ]),
      ),
      _totalCard(),
      _note(),
    ]);
  }

  Widget _shedTab() {
    final area = _shedArea;
    return _page([
      ToolSection(
        key: const Key('building-shed'),
        title: _s.shedSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolNumberField(
              label: _s.shedArea,
              suffix: _s.squareMeter,
              controller: _shed,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.shedHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('building-shed-result'),
        title: _s.shedResult,
        value: area,
        unit: _s.squareMeter,
        formula: area == null
            ? null
            : fill(_s.shedFormula, [_fmt(_input(_shed)), _fmt(area)]),
      ),
      _totalCard(),
      _note(),
    ]);
  }

  /// 合计卡：六部分里已填的相加，附规则说明。
  Widget _totalCard() => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: ToolResultCard(
      key: const Key('building-total'),
      title: _s.total,
      value: _total,
      unit: _s.squareMeter,
      formula: _s.totalHint,
      icon: Icons.functions_rounded,
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
