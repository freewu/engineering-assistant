import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'formwork_lang.dart';
import 'formwork_page.dart';

Widget _builder(BuildContext context) => const FormworkPage();

/// 「模板工程」的工具卡片元数据。
ToolInfo get formworkTool => ToolInfo(
  id: 'formwork',
  lang: kFormworkLang,
  icon: Icons.dashboard_rounded,
  color: AppColors.primary,
  builder: _builder,
);
