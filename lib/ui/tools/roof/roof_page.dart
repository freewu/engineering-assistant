import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_result_card.dart';
import 'roof.dart';
import 'roof_lang.dart';
import 'roof_strings.dart';

/// 屋面及防水工程量页：平屋面 / 坡屋面 / 楼地面 / 墙基四个 tab。
///
/// 按设计图示尺寸以面积（㎡）计算，翻边高度 ≥ 300 mm 时按展开面积并入。
/// 输入走 [ToolDraft]（id `roof`），数值留空就不计算（结果显示「—」）。
class RoofPage extends StatefulWidget {
  const RoofPage({super.key});

  @override
  State<RoofPage> createState() => _RoofPageState();
}

class _RoofPageState extends State<RoofPage>
    with SingleTickerProviderStateMixin, AppAppearanceAware {
  late final ToolDraft _draft = ToolDraft('roof');

  /// 上次停留的 tab 优先，其次用设置页里选的默认 tab。
  late final TabController _tabs = TabController(
    length: kRoofTabCount,
    initialIndex:
        (_draft.integer('tab') ?? currentSettings?.toolTabFor('roof') ?? 0)
            .clamp(0, kRoofTabCount - 1),
    vsync: this,
  )..addListener(_onTabChanged);

  // 平屋面：净面积 / 翻边长 / 翻边高
  late final TextEditingController _flatArea = _draft.controller(
    'flatArea',
    '100',
  );
  late final TextEditingController _flatLength = _draft.controller(
    'flatLength',
    '60',
  );
  late final TextEditingController _flatHeight = _draft.controller(
    'flatHeight',
    '0.3',
  );

  // 坡屋面：投影面积 / 坡度角
  late final TextEditingController _slopeArea = _draft.controller(
    'slopeArea',
    '100',
  );
  late final TextEditingController _slopeAngle = _draft.controller(
    'slopeAngle',
    '30',
  );

  // 楼地面：净面积 / 翻边长 / 翻边高
  late final TextEditingController _floorArea = _draft.controller(
    'floorArea',
    '80',
  );
  late final TextEditingController _floorLength = _draft.controller(
    'floorLength',
    '40',
  );
  late final TextEditingController _floorHeight = _draft.controller(
    'floorHeight',
    '0.3',
  );

  // 墙基：L中 / L内 / 实铺宽
  late final TextEditingController _centerline = _draft.controller(
    'centerline',
    '30',
  );
  late final TextEditingController _netLength = _draft.controller(
    'netLength',
    '20',
  );
  late final TextEditingController _baseWidth = _draft.controller(
    'baseWidth',
    '0.24',
  );

  RoofStrings get _s => roofStrings;

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final controller in [
      _flatArea,
      _flatLength,
      _flatHeight,
      _slopeArea,
      _slopeAngle,
      _floorArea,
      _floorLength,
      _floorHeight,
      _centerline,
      _netLength,
      _baseWidth,
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

  double? get _flatAreaResult {
    final area = _input(_flatArea);
    if (area == null) return null;
    return flatRoofArea(
      netArea: area,
      upturnLength: _input(_flatLength) ?? 0,
      upturnHeight: _input(_flatHeight) ?? 0,
    );
  }

  double? get _slopeAreaResult {
    final area = _input(_slopeArea);
    final angle = _input(_slopeAngle);
    if (area == null || angle == null || angle >= 90) return null;
    return pitchedRoofArea(projectedArea: area, angleDegrees: angle);
  }

  double? get _floorAreaResult {
    final area = _input(_floorArea);
    if (area == null) return null;
    return floorWaterproofArea(
      netArea: area,
      upturnLength: _input(_floorLength) ?? 0,
      upturnHeight: _input(_floorHeight) ?? 0,
    );
  }

  double? get _baseAreaResult {
    final centerline = _input(_centerline);
    final net = _input(_netLength);
    final width = _input(_baseWidth);
    if (centerline == null || net == null || width == null) return null;
    return wallBaseWaterproofArea(
      centerlineLength: centerline,
      netLength: net,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = <String>[_s.tabFlat, _s.tabSlope, _s.tabFloor, _s.tabBase];
    return Scaffold(
      appBar: AppBar(
        title: Text(toolText(kRoofLang).name),
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
              key: const Key('roof-tabs'),
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
              children: [_flatTab(), _slopeTab(), _floorTab(), _baseTab()],
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

  Widget _flatTab() {
    final area = _flatAreaResult;
    final height = _input(_flatHeight);
    final ignored = height != null && height > 0 && height < kUpturnThreshold;
    return _page([
      ToolSection(
        key: const Key('roof-flat'),
        title: _s.flatSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(_s.netArea, 'm²', _flatArea),
            const SizedBox(height: 12),
            _row([
              _field(_s.upturnLength, 'm', _flatLength),
              _field(_s.upturnHeight, 'm', _flatHeight),
            ]),
            const SizedBox(height: 8),
            _hint(_s.flatHint),
            if (ignored) ...[
              const SizedBox(height: 6),
              _hint(_s.upturnIgnored),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('roof-flat-result'),
        title: _s.flatResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.flatFormula, [
                _fmt(_input(_flatArea)),
                _fmt(_input(_flatLength) ?? 0),
                _fmt(_input(_flatHeight) ?? 0),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _slopeTab() {
    final area = _slopeAreaResult;
    final angle = _input(_slopeAngle);
    return _page([
      ToolSection(
        key: const Key('roof-slope'),
        title: _s.slopeSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.projectedArea, 'm²', _slopeArea),
              _field(_s.slopeAngle, '°', _slopeAngle),
            ]),
            const SizedBox(height: 8),
            _hint(_s.slopeHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('roof-slope-result'),
        title: _s.slopeResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.slopeFormula, [
                _fmt(_input(_slopeArea)),
                _fmt(slopeFactor(angle!)),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _floorTab() {
    final area = _floorAreaResult;
    final height = _input(_floorHeight);
    final ignored = height != null && height > 0 && height < kUpturnThreshold;
    return _page([
      ToolSection(
        key: const Key('roof-floor'),
        title: _s.floorSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(_s.floorNetArea, 'm²', _floorArea),
            const SizedBox(height: 12),
            _row([
              _field(_s.floorUpturnLength, 'm', _floorLength),
              _field(_s.upturnHeight, 'm', _floorHeight),
            ]),
            const SizedBox(height: 8),
            _hint(_s.floorHint),
            if (ignored) ...[
              const SizedBox(height: 6),
              _hint(_s.upturnIgnored),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('roof-floor-result'),
        title: _s.floorResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.floorFormula, [
                _fmt(_input(_floorArea)),
                _fmt(_input(_floorLength) ?? 0),
                _fmt(_input(_floorHeight) ?? 0),
                _fmt(area),
              ]),
      ),
      _note(),
    ]);
  }

  Widget _baseTab() {
    final area = _baseAreaResult;
    return _page([
      ToolSection(
        key: const Key('roof-base'),
        title: _s.baseSection,
        icon: Icons.tune_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _field(_s.centerlineLength, 'm', _centerline),
              _field(_s.netLength, 'm', _netLength),
            ]),
            _field(_s.baseWidth, 'm', _baseWidth),
            const SizedBox(height: 8),
            _hint(_s.baseHint),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ToolResultCard(
        key: const Key('roof-base-result'),
        title: _s.baseResult,
        value: area,
        unit: 'm²',
        formula: area == null
            ? null
            : fill(_s.baseFormula, [
                _fmt(_input(_centerline)),
                _fmt(_input(_netLength)),
                _fmt(_input(_baseWidth)),
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
