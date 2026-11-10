import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'decoration_strings.dart';

/// 「装饰装修」的设置项：打开时默认展示哪个 tab（墙面 / 天棚 / 楼地面）。
///
/// 存在 `decoration.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class DecorationSetting extends StatelessWidget {
  const DecorationSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = decorationStrings;
    return ToolTabSetting(
      toolId: 'decoration',
      labels: [s.tabWall, s.tabCeiling, s.tabFloor],
      controller: controller,
    );
  }
}
