import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「压力换算」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kPressureLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('压力换算', '帕巴托，还有 psi'),
  AppLanguage.zhHant: ToolText('壓力換算', '帕巴托，還有 psi'),
  AppLanguage.en: ToolText('Pressure', 'Pascal, bar and psi'),
  AppLanguage.ja: ToolText('圧力換算', 'パスカル・バール・psi'),
  AppLanguage.es: ToolText('Presión', 'Pascal, bar y psi'),
};
