import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「面积换算」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kAreaLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('面积换算', '平方米到亩，一键换算'),
  AppLanguage.zhHant: ToolText('面積換算', '平方公尺到畝，一鍵換算'),
  AppLanguage.en: ToolText('Area', 'Square metres to mu, one tap'),
  AppLanguage.ja: ToolText('面積換算', '平方メートルから畝まで一発換算'),
  AppLanguage.es: ToolText(
    'Superficie',
    'De metros cuadrados a mu con un toque',
  ),
};
