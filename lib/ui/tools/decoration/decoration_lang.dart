import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「装饰装修」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kDecorationLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('装饰装修', '墙面、天棚与楼地面的装饰面积'),
  AppLanguage.zhHant: ToolText('裝飾裝修', '牆面、天棚與樓地面的裝飾面積'),
  AppLanguage.en: ToolText('Finishes', 'Wall, ceiling and floor finish areas'),
  AppLanguage.ja: ToolText('仕上げ', '壁・天井・床の仕上げ面積'),
  AppLanguage.es: ToolText(
    'Revestimientos',
    'Superficies de muros, techos y suelos',
  ),
};
