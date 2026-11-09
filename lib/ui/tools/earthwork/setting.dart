import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'earthwork_strings.dart';

/// 「土石方工程」的设置项：打开时默认展示哪个 tab（场地平整 / 基坑基槽 / 管沟土方）。
///
/// 存在 `earthwork.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class EarthworkSetting extends StatelessWidget {
  const EarthworkSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = earthworkStrings;
    return ToolTabSetting(
      toolId: 'earthwork',
      labels: [s.tabLeveling, s.tabExcavation, s.tabTrench],
      controller: controller,
    );
  }
}
