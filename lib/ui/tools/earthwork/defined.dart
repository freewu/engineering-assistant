import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'earthwork_lang.dart';
import 'earthwork_page.dart';

Widget _builder(BuildContext context) => const EarthworkPage();

/// 「土石方工程」的工具卡片元数据。
ToolInfo get earthworkTool => ToolInfo(
  id: 'earthwork',
  lang: kEarthworkLang,
  icon: Icons.landscape_rounded,
  color: AppColors.primary,
  builder: _builder,
);
