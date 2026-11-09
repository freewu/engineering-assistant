import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'rebar_strings.dart';

/// 「钢筋工程」的设置项：打开时默认展示哪个 tab
/// （直钢筋 / 箍筋 / 弯起钢筋 / 速查表）。
///
/// 存在 `rebar.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class RebarSetting extends StatelessWidget {
  const RebarSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = rebarStrings;
    return ToolTabSetting(
      toolId: 'rebar',
      labels: [s.tabStraight, s.tabStirrup, s.tabBent, s.tabTable],
      controller: controller,
    );
  }
}
