import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import 'concrete_lang.dart';
import 'concrete_member.dart';
import 'concrete_strings.dart';

/// 混凝土构件工程量页：柱 / 梁 / 板 / 墙 / 楼梯五个 tab，一律按体积算。
///
/// 通用规则：按设计图示尺寸以体积计算，不扣除钢筋、螺栓、预埋铁件，以及
/// 单个 ≤ 300 mm × 300 mm 的孔洞。输入走 [ToolDraft]（id `concrete`），
/// 数值留空就不计算。
class ConcreteMemberPage extends StatefulWidget {
  const ConcreteMemberPage({super.key});

  @override
  State<ConcreteMemberPage> createState() => _ConcreteMemberPageState();
}

class _ConcreteMemberPageState extends State<ConcreteMemberPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('concrete');

  late final TabController _tabs = TabController(
    length: 5,
    initialIndex: (_draft.integer('tab') ?? 0).clamp(0, 4),
    vsync: this,
  )..addListener(_onTabChanged);

  // 矩形柱：a / b / H
  late final TextEditingController _columnA = _draft.controller('columnA', '');
  late final TextEditingController _columnB = _draft.controller('columnB', '');
  late final TextEditingController _columnH = _draft.controller('columnH', '');

  // 矩形梁：a / b / L
  late final TextEditingController _beamA = _draft.controller('beamA', '');
  late final TextEditingController _beamB = _draft.controller('beamB', '');
  late final TextEditingController _beamL = _draft.controller('beamL', '');

  // 现浇板：净长 / 净宽 / 板厚 / 孔洞面积（可空）
  late final TextEditingController _slabLength = _draft.controller(
    'slabLength',
    '',
  );
  late final TextEditingController _slabWidth = _draft.controller(
    'slabWidth',
    '',
  );
  late final TextEditingController _slabThickness = _draft.controller(
    'slabThickness',
    '',
  );
  late final TextEditingController _holeArea = _draft.controller(
    'holeArea',
    '',
  );

  // 混凝土墙：墙长 / 墙高 / 墙厚
  late final TextEditingController _wallLength = _draft.controller(
    'wallLength',
    '',
  );
  late final TextEditingController _wallHeight = _draft.controller(
    'wallHeight',
    '',
  );
  late final TextEditingController _wallThickness = _draft.controller(
    'wallThickness',
    '',
  );

  // 楼梯：水平投影面积 / 折算厚度
  late final TextEditingController _stairArea = _draft.controller(
    'stairArea',
    '',
  );
  late final TextEditingController _stairThickness = _draft.controller(
    'stairThickness',
    '',
  );

  ConcreteStrings get _s => concreteStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _columnA,
      _columnB,
      _columnH,
      _beamA,
      _beamB,
      _beamL,
      _slabLength,
      _slabWidth,
      _slabThickness,
      _holeArea,
      _wallLength,
      _wallHeight,
      _wallThickness,
      _stairArea,
      _stairThickness,
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

  double? get _column => _calc([
    _columnA,
    _columnB,
    _columnH,
  ], (v) => columnVolume(sectionA: v[0], sectionB: v[1], height: v[2]));

  double? get _beam => _calc([
    _beamA,
    _beamB,
    _beamL,
  ], (v) => beamVolume(sectionA: v[0], sectionB: v[1], length: v[2]));

  double? get _slab => _calc(
    [_slabLength, _slabWidth, _slabThickness],
    (v) => slabVolume(
      length: v[0],
      width: v[1],
      thickness: v[2],
      holeArea: _input(_holeArea) ?? 0,
    ),
  );

  double? get _wall => _calc([
    _wallLength,
    _wallHeight,
    _wallThickness,
  ], (v) => wallVolume(length: v[0], height: v[1], thickness: v[2]));

  double? get _stair => _calc([
    _stairArea,
    _stairThickness,
  ], (v) => stairVolume(planArea: v[0], equivalentThickness: v[1]));

  @override
  Widget build(BuildContext context) {
    final tabs = <String>[
      _s.tabColumn,
      _s.tabBeam,
      _s.tabSlab,
      _s.tabWall,
      _s.tabStair,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kConcreteLang).name),
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
              key: const Key('concrete-tabs'),
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
                _columnTab(),
                _beamTab(),
                _slabTab(),
                _wallTab(),
                _stairTab(),
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

  Widget _columnTab() {
    final volume = _column;
    return _page([
      ToolSection(
        key: const Key('concrete-column'),
        title: _s.columnSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.sectionA,
                    suffix: _s.meterUnit,
                    controller: _columnA,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.sectionB,
                    suffix: _s.meterUnit,
                    controller: _columnB,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ToolNumberField(
              label: _s.columnHeight,
              suffix: _s.meterUnit,
              controller: _columnH,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.columnHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('concrete-column-result'),
        title: _s.columnResult,
        value: volume,
        unit: _s.cubicMeter,
        formula: volume == null
            ? null
            : fill(_s.columnFormula, [
                _fmt(_input(_columnA)),
                _fmt(_input(_columnB)),
                _fmt(_input(_columnH)),
                _fmt(volume),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _beamTab() {
    final volume = _beam;
    return _page([
      ToolSection(
        key: const Key('concrete-beam'),
        title: _s.beamSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.sectionA,
                    suffix: _s.meterUnit,
                    controller: _beamA,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.sectionB,
                    suffix: _s.meterUnit,
                    controller: _beamB,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ToolNumberField(
              label: _s.beamLength,
              suffix: _s.meterUnit,
              controller: _beamL,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.beamHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('concrete-beam-result'),
        title: _s.beamResult,
        value: volume,
        unit: _s.cubicMeter,
        formula: volume == null
            ? null
            : fill(_s.beamFormula, [
                _fmt(_input(_beamA)),
                _fmt(_input(_beamB)),
                _fmt(_input(_beamL)),
                _fmt(volume),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _slabTab() {
    final volume = _slab;
    final length = _input(_slabLength);
    final width = _input(_slabWidth);
    final thickness = _input(_slabThickness);
    final hole = _input(_holeArea);
    // 孔洞留空 = 没有孔洞；超过 0.3 ㎡ 才从板面积里扣
    final deducted = hole != null && holeDeducted(hole);
    final String? formula;
    if (volume == null) {
      formula = null;
    } else if (deducted) {
      formula = fill(_s.slabHoleFormula, [
        _fmt(length),
        _fmt(width),
        _fmt(hole),
        _fmt(thickness),
        _fmt(volume),
      ]);
    } else {
      formula = fill(_s.slabFormula, [
        _fmt(length),
        _fmt(width),
        _fmt(thickness),
        _fmt(volume),
      ]);
    }
    return _page([
      ToolSection(
        key: const Key('concrete-slab'),
        title: _s.slabSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.netLength,
                    suffix: _s.meterUnit,
                    controller: _slabLength,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.netWidth,
                    suffix: _s.meterUnit,
                    controller: _slabWidth,
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
                    label: _s.slabThickness,
                    suffix: _s.meterUnit,
                    controller: _slabThickness,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.holeArea,
                    suffix: _s.squareMeter,
                    controller: _holeArea,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _hint(_s.slabHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('concrete-slab-result'),
        title: _s.slabResult,
        value: volume,
        unit: _s.cubicMeter,
        formula: formula,
      ),
      _note(),
    ]);
  }

  Widget _wallTab() {
    final volume = _wall;
    return _page([
      ToolSection(
        key: const Key('concrete-wall'),
        title: _s.wallSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ToolNumberField(
                    label: _s.wallLength,
                    suffix: _s.meterUnit,
                    controller: _wallLength,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumberField(
                    label: _s.wallHeight,
                    suffix: _s.meterUnit,
                    controller: _wallHeight,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ToolNumberField(
              label: _s.wallThickness,
              suffix: _s.meterUnit,
              controller: _wallThickness,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.wallHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('concrete-wall-result'),
        title: _s.wallResult,
        value: volume,
        unit: _s.cubicMeter,
        formula: volume == null
            ? null
            : fill(_s.wallFormula, [
                _fmt(_input(_wallLength)),
                _fmt(_input(_wallHeight)),
                _fmt(_input(_wallThickness)),
                _fmt(volume),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _stairTab() {
    final volume = _stair;
    return _page([
      ToolSection(
        key: const Key('concrete-stair'),
        title: _s.stairSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolNumberField(
              label: _s.planArea,
              suffix: _s.squareMeter,
              controller: _stairArea,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ToolNumberField(
              label: _s.equivalentThickness,
              suffix: _s.meterUnit,
              controller: _stairThickness,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _hint(_s.stairHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('concrete-stair-result'),
        title: _s.stairResult,
        value: volume,
        unit: _s.cubicMeter,
        formula: volume == null
            ? null
            : fill(_s.stairFormula, [
                _fmt(_input(_stairArea)),
                _fmt(_input(_stairThickness)),
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
