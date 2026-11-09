import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'concrete_strings.dart';

/// 「混凝土构件」的设置项：打开时默认展示哪个 tab（柱 / 梁 / 板 / 墙 / 楼梯）。
///
/// 存在 `concrete.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class ConcreteSetting extends StatelessWidget {
  const ConcreteSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = concreteStrings;
    return ToolTabSetting(
      toolId: 'concrete',
      labels: [s.tabColumn, s.tabBeam, s.tabSlab, s.tabWall, s.tabStair],
      controller: controller,
    );
  }
}
