import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'rebar_lang.dart';
import 'rebar_page.dart';

Widget _builder(BuildContext context) => const RebarPage();

/// 「钢筋工程」的工具卡片元数据。
ToolInfo get rebarTool => ToolInfo(
  id: 'rebar',
  lang: kRebarLang,
  icon: Icons.view_stream_rounded,
  color: AppColors.primary,
  builder: _builder,
);
