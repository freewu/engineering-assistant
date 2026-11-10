import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「屋面及防水工程」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kRoofLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('屋面及防水', '平屋面、坡屋面、楼地面与墙基防水'),
  AppLanguage.zhHant: ToolText('屋面及防水', '平屋面、斜屋面、樓地面與牆基防水'),
  AppLanguage.en: ToolText(
    'Roof & waterproofing',
    'Flat and pitched roofs, floors, wall bases',
  ),
  AppLanguage.ja: ToolText('屋根・防水', '陸屋根・勾配屋根・床・立上りの防水'),
  AppLanguage.es: ToolText(
    'Cubiertas e impermeabilización',
    'Cubiertas, suelos y pies de muro',
  ),
};
