import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'building_area_lang.dart';
import 'building_area_page.dart';

Widget _builder(BuildContext context) => const BuildingAreaPage();

/// 「建筑面积」的工具卡片元数据。
ToolInfo get buildingAreaTool => ToolInfo(
  id: 'building_area',
  lang: kBuildingAreaLang,
  icon: Icons.apartment_rounded,
  color: AppColors.violet,
  builder: _builder,
);
