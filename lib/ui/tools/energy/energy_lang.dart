import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「热量换算」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kEnergyLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('热量换算', '瓦时焦耳卡路里'),
  AppLanguage.zhHant: ToolText('熱量換算', '瓦時焦耳卡路里'),
  AppLanguage.en: ToolText('Energy', 'Watt-hours, joules, calories'),
  AppLanguage.ja: ToolText('熱量換算', 'ワット時・ジュール・カロリー'),
  AppLanguage.es: ToolText('Energía', 'Vatios hora, julios, calorías'),
};
