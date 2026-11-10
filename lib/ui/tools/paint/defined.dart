import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'paint_lang.dart';
import 'paint_page.dart';

Widget _builder(BuildContext context) => const PaintPage();

/// 「油漆涂料」的工具卡片元数据。
ToolInfo get paintTool => ToolInfo(
  id: 'paint',
  lang: kPaintLang,
  icon: Icons.brush_rounded,
  color: AppColors.orange,
  builder: _builder,
);
