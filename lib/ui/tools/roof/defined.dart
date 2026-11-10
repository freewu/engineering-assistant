import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'roof_lang.dart';
import 'roof_page.dart';

Widget _builder(BuildContext context) => const RoofPage();

/// 「屋面及防水工程」的工具卡片元数据。
ToolInfo get roofTool => ToolInfo(
  id: 'roof',
  lang: kRoofLang,
  icon: Icons.roofing_rounded,
  color: AppColors.primary,
  builder: _builder,
);
