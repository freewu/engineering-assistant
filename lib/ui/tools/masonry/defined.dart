import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'masonry_lang.dart';
import 'masonry_page.dart';

Widget _builder(BuildContext context) => const MasonryPage();

/// 「砌筑工程」的工具卡片元数据。
ToolInfo get masonryTool => ToolInfo(
  id: 'masonry',
  lang: kMasonryLang,
  icon: Icons.dashboard_customize_rounded,
  color: AppColors.primary,
  builder: _builder,
);
