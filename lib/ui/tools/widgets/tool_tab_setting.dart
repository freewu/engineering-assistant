import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/settings_card.dart';
import '../tool_catalog.dart';
import 'tool_select.dart';

/// 「默认标签页」设置卡片的公共外壳。
///
/// 带 tab 的工具（材料用量 / 建筑面积 / 混凝土构件）各在自己的 `setting.dart` 里
/// 包一层，把 tab 名称传进来；值存在 `<工具 id>.tab`，改完会清掉草稿里记住的
/// tab，下次打开立即生效。
class ToolTabSetting extends StatelessWidget {
  const ToolTabSetting({
    super.key,
    required this.toolId,
    required this.labels,
    required this.controller,
    this.fallbackTitle,
    this.fallbackIcon,
  });

  /// 工具 id，决定存储键（`<id>.tab`、下拉框 Key `settings-<id>-tab`）。
  final String toolId;

  /// tab 名称，顺序与页面上的 tab 一致；下标就是存下来的值。
  final List<String> labels;

  final SettingsController controller;

  /// 工具表里取不到名称 / 图标时的兜底。
  final String? fallbackTitle;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final tool = toolById(toolId);
    return SettingsCard(
      icon: tool?.icon ?? fallbackIcon ?? Icons.tune_rounded,
      title: tool?.name ?? fallbackTitle ?? toolId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSelect<int>(
            key: Key('settings-$toolId-tab'),
            label: t.settingsDefaultTab,
            value: controller.toolTabFor(toolId),
            items: [for (var i = 0; i < labels.length; i++) i],
            labelOf: (index) => labels[index],
            onChanged: (index) => controller.setToolTab(toolId, index),
          ),
          const SizedBox(height: 8),
          Text(
            t.settingsEngineeringHint,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
