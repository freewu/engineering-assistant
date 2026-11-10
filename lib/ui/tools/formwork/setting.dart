import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'formwork_strings.dart';

/// 「模板工程」的设置项：打开时默认展示哪个 tab（柱 / 梁 / 墙 / 楼梯）。
///
/// 存在 `formwork.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class FormworkSetting extends StatelessWidget {
  const FormworkSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = formworkStrings;
    return ToolTabSetting(
      toolId: 'formwork',
      labels: [s.tabColumn, s.tabBeam, s.tabWall, s.tabStair],
      controller: controller,
    );
  }
}
