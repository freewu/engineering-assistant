import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「油漆涂料」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kPaintLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('油漆涂料', '墙面、天棚与门窗的涂刷面积与用量'),
  AppLanguage.zhHant: ToolText('油漆塗料', '牆面、天棚與門窗的塗刷面積與用量'),
  AppLanguage.en: ToolText('Paints', 'Paint areas and coating quantities'),
  AppLanguage.ja: ToolText('塗装', '壁・天井・建具の塗装面積と使用量'),
  AppLanguage.es: ToolText('Pinturas', 'Superficies y cantidad de pintura'),
};
