import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/settings_card.dart';
import '../tool_catalog.dart';
import '../widgets/tool_select.dart';
import 'concrete_member.dart';
import 'concrete_strings.dart';

/// 「混凝土构件」的设置项：打开时默认展示哪个 tab（柱 / 梁 / 板 / 墙 / 楼梯）。
///
/// 存在 `concrete.tab`；改完会清掉草稿里记住的 tab，这样下次进来就是新默认值。
class ConcreteSetting extends StatelessWidget {
  const ConcreteSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final tool = toolById('concrete');
    final s = concreteStrings;
    final labels = <String>[
      s.tabColumn,
      s.tabBeam,
      s.tabSlab,
      s.tabWall,
      s.tabStair,
    ];
    return SettingsCard(
      icon: tool?.icon ?? Icons.view_in_ar_rounded,
      title: tool?.name ?? '混凝土构件',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSelect<int>(
            key: const Key('settings-concrete-tab'),
            label: t.settingsDefaultTab,
            value: controller.concreteTab,
            items: [for (var i = 0; i < kConcreteTabCount; i++) i],
            labelOf: (index) => labels[index],
            onChanged: controller.setConcreteTab,
          ),
          const SizedBox(height: 8),
          Text(
            t.settingsEngineeringHint,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
