import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'roof_strings.dart';

/// 「屋面及防水工程」的设置项：打开时默认展示哪个 tab
/// （平屋面 / 坡屋面 / 楼地面 / 墙基）。
///
/// 存在 `roof.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class RoofSetting extends StatelessWidget {
  const RoofSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = roofStrings;
    return ToolTabSetting(
      toolId: 'roof',
      labels: [s.tabFlat, s.tabSlope, s.tabFloor, s.tabBase],
      controller: controller,
    );
  }
}
