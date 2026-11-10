import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'paint_strings.dart';

/// 「油漆涂料」的设置项：打开时默认展示哪个 tab（墙面 / 天棚 / 门窗）。
///
/// 存在 `paint.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class PaintSetting extends StatelessWidget {
  const PaintSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = paintStrings;
    return ToolTabSetting(
      toolId: 'paint',
      labels: [s.tabWall, s.tabCeiling, s.tabJoinery],
      controller: controller,
    );
  }
}
