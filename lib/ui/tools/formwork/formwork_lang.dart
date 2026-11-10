import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「模板工程」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kFormworkLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('模板工程', '柱、梁、墙、楼梯的模板接触面积'),
  AppLanguage.zhHant: ToolText('模板工程', '柱、樑、牆、樓梯的模板接觸面積'),
  AppLanguage.en: ToolText(
    'Formwork',
    'Contact area for columns, beams, walls, stairs',
  ),
  AppLanguage.ja: ToolText('型枠工事', '柱・梁・壁・階段の接触面積'),
  AppLanguage.es: ToolText(
    'Encofrados',
    'Superficie de contacto en pilares, vigas, muros y escaleras',
  ),
};
