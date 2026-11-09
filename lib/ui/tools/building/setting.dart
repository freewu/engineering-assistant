import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../widgets/tool_tab_setting.dart';
import 'building_area_strings.dart';

/// 「建筑面积」的设置项：打开时默认展示哪个 tab。
class BuildingAreaSetting extends StatelessWidget {
  const BuildingAreaSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = buildingAreaStrings;
    return ToolTabSetting(
      toolId: 'building_area',
      labels: [
        s.tabSingle,
        s.tabMulti,
        s.tabBalcony,
        s.tabCanopy,
        s.tabVestibule,
        s.tabShed,
      ],
      controller: controller,
    );
  }
}
