import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'insulation_strings.dart';

/// 「保温隔热」的设置项：打开时默认展示哪个 tab（屋面 / 墙面 / 柱）。
///
/// 存在 `insulation.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class InsulationSetting extends StatelessWidget {
  const InsulationSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = insulationStrings;
    return ToolTabSetting(
      toolId: 'insulation',
      labels: [s.tabRoof, s.tabWall, s.tabColumn],
      controller: controller,
    );
  }
}
