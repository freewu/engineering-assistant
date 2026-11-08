import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「建筑面积」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kBuildingAreaLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('建筑面积', '单层多层阳台，分项算'),
  AppLanguage.zhHant: ToolText('建築面積', '單層多層陽台，分項算'),
  AppLanguage.en: ToolText('Floor area', 'Storeys, balconies, canopies'),
  AppLanguage.ja: ToolText('建築面積', '単層・多層・バルコニー別に算定'),
  AppLanguage.es: ToolText('Superficie', 'Plantas, balcones y marquesinas'),
};
