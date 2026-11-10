import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'decoration_lang.dart';
import 'decoration_page.dart';

Widget _builder(BuildContext context) => const DecorationPage();

/// 「装饰装修」的工具卡片元数据。
ToolInfo get decorationTool => ToolInfo(
  id: 'decoration',
  lang: kDecorationLang,
  icon: Icons.format_paint_rounded,
  color: AppColors.primary,
  builder: _builder,
);
