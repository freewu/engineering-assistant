import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「材料用量」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kMaterialLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('材料用量', '砖块水泥砂子，一算就有'),
  AppLanguage.zhHant: ToolText('材料用量', '磚塊水泥砂子，一算就有'),
  AppLanguage.en: ToolText('Materials', 'Bricks, concrete, cement, sand'),
  AppLanguage.ja: ToolText('材料数量', 'レンガ・生コン・セメント・砂を概算'),
  AppLanguage.es: ToolText(
    'Materiales',
    'Ladrillos, hormigón, cemento y arena',
  ),
};
