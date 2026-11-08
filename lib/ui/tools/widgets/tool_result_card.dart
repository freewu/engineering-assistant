import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import 'tool_field.dart';

/// 计算类工具的结果卡：大号数值 + 单位，下面一行当前算式。
///
/// 材料用量、建筑面积这类「填参数 → 出一个数」的工具共用，避免各页复制样式。
class ToolResultCard extends StatelessWidget {
  const ToolResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.formula,
    this.icon = Icons.calculate_outlined,
  });

  /// 卡片标题，如「砖块数量」「合计建筑面积」。
  final String title;

  /// 结果；为 null 时显示「—」（输入还没填全）。
  final double? value;

  /// 单位文案，如「块」「㎡」「m³」。
  final String unit;

  /// 当前算式；结果为「—」时传 null。
  final String? formula;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ToolSection(
      title: title,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            value == null
                ? '—'
                : '${formatNumber(value!, significantDigits: 10)} $unit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (formula != null) ...[
            const SizedBox(height: 6),
            Text(
              formula!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
