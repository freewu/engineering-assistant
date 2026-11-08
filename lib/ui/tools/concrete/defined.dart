import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'concrete_lang.dart';
import 'concrete_page.dart';

Widget _builder(BuildContext context) => const ConcreteMemberPage();

/// 「混凝土构件」的工具卡片元数据。
ToolInfo get concreteTool => ToolInfo(
  id: 'concrete',
  lang: kConcreteLang,
  icon: Icons.view_in_ar_rounded,
  color: AppColors.orange,
  builder: _builder,
);
