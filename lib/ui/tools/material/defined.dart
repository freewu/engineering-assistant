import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'material_lang.dart';
import 'material_page.dart';

Widget _builder(BuildContext context) => const MaterialUsagePage();

/// 「材料用量」的工具卡片元数据。
ToolInfo get materialTool => ToolInfo(
  id: 'material',
  lang: kMaterialLang,
  icon: Icons.foundation_rounded,
  color: AppColors.primary,
  builder: _builder,
);
