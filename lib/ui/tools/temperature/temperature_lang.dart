import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「温度换算」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kTemperatureLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('温度换算', '摄氏华氏，连同体感'),
  AppLanguage.zhHant: ToolText('溫度換算', '攝氏華氏，連同體感'),
  AppLanguage.en: ToolText(
    'Temperature',
    'Celsius, Fahrenheit and how it feels',
  ),
  AppLanguage.ja: ToolText('温度換算', '摂氏・華氏と体感'),
  AppLanguage.es: ToolText('Temperatura', 'Celsius, Fahrenheit y sensación'),
};
