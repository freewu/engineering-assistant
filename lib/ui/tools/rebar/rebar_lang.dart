import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「钢筋工程」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kRebarLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('钢筋工程', '直钢筋、箍筋、弯起钢筋与速查表'),
  AppLanguage.zhHant: ToolText('鋼筋工程', '直鋼筋、箍筋、彎起鋼筋與速查表'),
  AppLanguage.en: ToolText(
    'Reinforcement',
    'Bars, stirrups, bent-up bars, table',
  ),
  AppLanguage.ja: ToolText('鉄筋工事', '直筋・帯筋・折曲げ筋・早見表'),
  AppLanguage.es: ToolText(
    'Armaduras',
    'Barras, estribos, barras dobladas y tabla',
  ),
};
