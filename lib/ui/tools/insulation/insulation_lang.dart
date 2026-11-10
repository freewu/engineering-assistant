import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「保温隔热」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kInsulationLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('保温隔热', '屋面、墙面与柱的保温面积与体积'),
  AppLanguage.zhHant: ToolText('隔熱保溫', '屋面、牆面與柱的保溫面積與體積'),
  AppLanguage.en: ToolText(
    'Insulation',
    'Roof, wall and column areas and volumes',
  ),
  AppLanguage.ja: ToolText('断熱', '屋根・壁・柱の断熱面積と体積'),
  AppLanguage.es: ToolText(
    'Aislamiento',
    'Superficies y volúmenes en cubiertas, muros y pilares',
  ),
};
