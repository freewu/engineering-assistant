import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「砌筑工程」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kMasonryLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('砌筑工程', '砖墙、砖基础与特殊墙体'),
  AppLanguage.zhHant: ToolText('砌築工程', '磚牆、磚基礎與特殊牆體'),
  AppLanguage.en: ToolText(
    'Masonry',
    'Brick walls, footings and special walls',
  ),
  AppLanguage.ja: ToolText('磚積み工事', '磚壁・基礎・特殊な壁'),
  AppLanguage.es: ToolText(
    'Albañilería',
    'Muros, cimientos y muros especiales',
  ),
};
