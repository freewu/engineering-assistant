import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'masonry_strings.dart';

/// 「砌筑工程」的设置项：打开时默认展示哪个 tab
/// （砖墙 / 砖基础 / 特殊墙体）。
///
/// 存在 `masonry.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class MasonrySetting extends StatelessWidget {
  const MasonrySetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = masonryStrings;
    return ToolTabSetting(
      toolId: 'masonry',
      labels: [s.tabWall, s.tabFoundation, s.tabSpecial],
      controller: controller,
    );
  }
}
