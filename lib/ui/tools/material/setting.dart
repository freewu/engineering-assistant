import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'material_strings.dart';

/// 「材料用量」的设置项：打开时默认展示哪个 tab（砖块 / 混凝土 / 水泥 / 砂子）。
class MaterialSetting extends StatelessWidget {
  const MaterialSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = materialStrings;
    return ToolTabSetting(
      toolId: 'material',
      labels: [s.tabBricks, s.tabConcrete, s.tabCement, s.tabSand],
      controller: controller,
    );
  }
}
