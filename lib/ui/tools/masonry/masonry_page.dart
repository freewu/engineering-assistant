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
import 'masonry.dart';
import 'masonry_lang.dart';
import 'masonry_strings.dart';

/// 砌筑工程量页：砖墙 / 砖基础 / 特殊墙体三个 tab。
///
/// 清单规则（GB/T 50854-2024）：按设计图示尺寸以体积计算，不扣除单个
/// ≤ 0.3 ㎡ 的孔洞。输入走 [ToolDraft]（id `masonry`），数值留空就不计算。
class MasonryPage extends StatefulWidget {
  const MasonryPage({super.key});

  @override
  State<MasonryPage> createState() => _MasonryPageState();
}

class _MasonryPageState extends State<MasonryPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('masonry');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kMasonryTabCount,
    initialIndex:
        (_draft.integer('tab') ?? currentSettings?.toolTabFor('masonry') ?? 0)
            .clamp(0, kMasonryTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 砖墙：墙长 / 墙高 / 墙厚 / 洞口 / 混凝土构件
  late final TextEditingController _wallLength = _draft.controller(
    'wallLength',
    '10',
  );
  late final TextEditingController _wallHeight = _draft.controller(
    'wallHeight',
    '3',
  );
  late final TextEditingController _wallThickness = _draft.controller(
    'wallThickness',
    '0.24',
  );
  late final TextEditingController _openingArea = _draft.controller(
    'openingArea',
    '6',
  );
  late final TextEditingController _concreteVolume = _draft.controller(
    'concreteVolume',
    '0',
  );

  // 砖基础：墙厚 / 基础高度 / 折加高度或大放脚体积 / L中 / L内
  late FoundationMode _foundationMode =
      _draft.enumOf('foundationMode', FoundationMode.values) ??
      FoundationMode.addedHeight;
  late final TextEditingController _foundationThickness = _draft.controller(
    'foundationThickness',
    '0.24',
  );
  late final TextEditingController _foundationHeight = _draft.controller(
    'foundationHeight',
    '1.2',
  );
  late final TextEditingController _addedHeight = _draft.controller(
    'addedHeight',
    '0.197',
  );
  late final TextEditingController _centerlineLength = _draft.controller(
    'centerlineLength',
    '30',
  );
  late final TextEditingController _netLength = _draft.controller(
    'netLength',
    '20',
  );
  late final TextEditingController _stepVolume = _draft.controller(
    'stepVolume',
    '0',
  );

  // 特殊墙体：类型 / 长 / 高 / 厚 / 孔洞体积
  late MasonryWallType _wallType =
      _draft.enumOf('wallType', MasonryWallType.values) ??
      MasonryWallType.hollow;
  late final TextEditingController _specialLength = _draft.controller(
    'specialLength',
    '10',
  );
  late final TextEditingController _specialHeight = _draft.controller(
    'specialHeight',
    '3',
  );
  late final TextEditingController _specialThickness = _draft.controller(
    'specialThickness',
    '0.24',
  );
  late final TextEditingController _holeVolume = _draft.controller(
    'holeVolume',
    '0',
  );

  MasonryStrings get _s => masonryStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _wallLength,
      _wallHeight,
      _wallThickness,
      _openingArea,
      _concreteVolume,
      _foundationThickness,
      _foundationHeight,
      _addedHeight,
      _centerlineLength,
      _netLength,
      _stepVolume,
      _specialLength,
      _specialHeight,
      _specialThickness,
      _holeVolume,
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

  /// 读一个输入框；空着、不是数字或负数时返回 null（结果显示「—」）。
  double? _input(TextEditingController controller) {
    final value = double.tryParse(controller.text);
    if (value == null || !value.isFinite || value < 0) return null;
    return value;
  }

  double? get _wallVolume {
    final length = _input(_wallLength);
    final height = _input(_wallHeight);
    final thickness = _input(_wallThickness);
    if (length == null || height == null || thickness == null) return null;
    return brickWallVolume(
      length: length,
      height: height,
      thickness: thickness,
      openingArea: _input(_openingArea) ?? 0,
      concreteVolume: _input(_concreteVolume) ?? 0,
    );
  }

  double? get _foundationVolume {
    final thickness = _input(_foundationThickness);
    final height = _input(_foundationHeight);
    final centerline = _input(_centerlineLength);
    final net = _input(_netLength);
    if (thickness == null ||
        height == null ||
        centerline == null ||
        net == null) {
      return null;
    }
    if (_foundationMode == FoundationMode.addedHeight) {
      final added = _input(_addedHeight);
      if (added == null) return null;
      return brickFoundationVolume(
        thickness: thickness,
        height: height,
        addedHeight: added,
        centerlineLength: centerline,
        netLength: net,
      );
    }
    final step = _input(_stepVolume);
    if (step == null) return null;
    return brickFoundationWithStepVolume(
      thickness: thickness,
      height: height,
      centerlineLength: centerline,
      netLength: net,
      stepVolume: step,
    );
  }

  double? get _specialVolume {
    final length = _input(_specialLength);
    final height = _input(_specialHeight);
    final thickness = _input(_specialThickness);
    if (length == null || height == null || thickness == null) return null;
    return specialWallVolume(
      length: length,
      height: height,
      thickness: thickness,
      // 只有多孔砖墙扣孔洞，空斗墙 / 空花墙按外形体积算
      holeVolume: _wallType == MasonryWallType.perforated
          ? (_input(_holeVolume) ?? 0)
          : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String>[_s.tabWall, _s.tabFoundation, _s.tabSpecial];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kMasonryLang).name),
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
              key: const Key('masonry-tabs'),
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
              children: [_wallTab(), _foundationTab(), _specialTab()],
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

  Widget _wallTab() {
    final volume = _wallVolume;
    final opening = _input(_openingArea);
    final deducted = opening != null && deductedOpening(opening) > 0;
    return _page([
      ToolSection(
        key: const Key('masonry-wall'),
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
              _field(_s.wallThickness, 'm', _wallThickness),
              _field(_s.openingArea, 'm²', _openingArea),
            ]),
            _field(_s.concreteVolume, 'm³', _concreteVolume),
            const SizedBox(height: 8),
            _hint(_s.wallHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('masonry-wall-result'),
        title: _s.wallResult,
        value: volume,
        unit: 'm³',
        formula: volume == null
            ? null
            : fill(_s.wallFormula, [
                _fmt(_input(_wallLength)),
                _fmt(_input(_wallHeight)),
                // 洞口 ≤ 0.3 ㎡ 不扣除，算式里也按 0 显示
                deducted ? _fmt(opening) : '0',
                _fmt(_input(_wallThickness)),
                _fmt(_input(_concreteVolume) ?? 0),
                _fmt(volume),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _foundationTab() {
    final volume = _foundationVolume;
    final added = _foundationMode == FoundationMode.addedHeight;
    return _page([
      ToolSection(
        key: const Key('masonry-foundation'),
        title: _s.foundationSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolSelect<FoundationMode>(
              key: const Key('masonry-foundation-mode'),
              label: _s.foundationMode,
              value: _foundationMode,
              items: FoundationMode.values,
              labelOf: (mode) => switch (mode) {
                FoundationMode.addedHeight => _s.modeAddedHeight,
                FoundationMode.stepVolume => _s.modeStepVolume,
              },
              onChanged: (mode) {
                _draft.setEnum('foundationMode', mode);
                setState(() => _foundationMode = mode);
              },
            ),
            const SizedBox(height: 12),
            _row([
              _field(_s.foundationThickness, 'm', _foundationThickness),
              _field(_s.foundationHeight, 'm', _foundationHeight),
            ]),
            _row([
              if (added)
                _field(_s.addedHeight, 'm', _addedHeight)
              else
                _field(_s.stepVolume, 'm³', _stepVolume),
              _field(_s.centerlineLength, 'm', _centerlineLength),
            ]),
            _field(_s.netLength, 'm', _netLength),
            const SizedBox(height: 8),
            _hint(_s.foundationHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('masonry-foundation-result'),
        title: _s.foundationResult,
        value: volume,
        unit: 'm³',
        formula: volume == null
            ? null
            : added
            ? fill(_s.foundationFormula, [
                _fmt(_input(_foundationThickness)),
                _fmt(_input(_foundationHeight)),
                _fmt(_input(_addedHeight)),
                _fmt(_input(_centerlineLength)),
                _fmt(_input(_netLength)),
                _fmt(volume),
              ])
            : fill(_s.foundationStepFormula, [
                _fmt(_input(_foundationThickness)),
                _fmt(_input(_foundationHeight)),
                _fmt(_input(_centerlineLength)),
                _fmt(_input(_netLength)),
                _fmt(_input(_stepVolume)),
                _fmt(volume),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _specialTab() {
    final volume = _specialVolume;
    final perforated = _wallType == MasonryWallType.perforated;
    return _page([
      ToolSection(
        key: const Key('masonry-special'),
        title: _s.specialSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolSelect<MasonryWallType>(
              key: const Key('masonry-special-type'),
              label: _s.specialType,
              value: _wallType,
              items: MasonryWallType.values,
              labelOf: _s.typeLabel,
              onChanged: (type) {
                _draft.setEnum('wallType', type);
                setState(() => _wallType = type);
              },
            ),
            const SizedBox(height: 12),
            _row([
              _field(_s.wallLength, 'm', _specialLength),
              _field(_s.wallHeight, 'm', _specialHeight),
            ]),
            if (perforated)
              _row([
                _field(_s.wallThickness, 'm', _specialThickness),
                _field(_s.holeVolume, 'm³', _holeVolume),
              ])
            else
              _field(_s.wallThickness, 'm', _specialThickness),
            const SizedBox(height: 8),
            _hint(_s.specialHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('masonry-special-result'),
        title: _s.specialResult,
        value: volume,
        unit: 'm³',
        formula: volume == null
            ? null
            : perforated
            ? fill(_s.specialHoleFormula, [
                _fmt(_input(_specialLength)),
                _fmt(_input(_specialHeight)),
                _fmt(_input(_specialThickness)),
                _fmt(_input(_holeVolume) ?? 0),
                _fmt(volume),
              ])
            : fill(_s.specialFormula, [
                _fmt(_input(_specialLength)),
                _fmt(_input(_specialHeight)),
                _fmt(_input(_specialThickness)),
                _fmt(volume),
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
