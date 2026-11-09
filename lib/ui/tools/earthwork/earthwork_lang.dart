import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「土石方工程」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kEarthworkLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('土石方工程', '场地平整、开挖、管沟土方'),
  AppLanguage.zhHant: ToolText('土石方工程', '場地平整、開挖、管溝土方'),
  AppLanguage.en: ToolText('Earthwork', 'Grading, excavation, pipe trenches'),
  AppLanguage.ja: ToolText('土工', '敷地均し・掘削・配管溝'),
  AppLanguage.es: ToolText(
    'Movimiento de tierras',
    'Nivelación, excavación, zanjas',
  ),
};
