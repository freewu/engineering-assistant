import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'insulation_lang.dart';
import 'insulation_page.dart';

Widget _builder(BuildContext context) => const InsulationPage();

/// 「保温隔热」的工具卡片元数据。
ToolInfo get insulationTool => ToolInfo(
  id: 'insulation',
  lang: kInsulationLang,
  icon: Icons.ac_unit_rounded,
  color: AppColors.primary,
  builder: _builder,
);
