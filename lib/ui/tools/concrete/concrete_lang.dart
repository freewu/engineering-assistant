import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「混凝土构件」卡片的多语言文案：名称与卖点。
const Map<AppLanguage, ToolText> kConcreteLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText('混凝土构件', '柱梁板墙楼梯，按体积算'),
  AppLanguage.zhHant: ToolText('混凝土構件', '柱梁板牆樓梯，按體積算'),
  AppLanguage.en: ToolText('Concrete', 'Columns, beams, slabs, walls, stairs'),
  AppLanguage.ja: ToolText('コンクリート', '柱・梁・スラブ・壁・階段の体積'),
  AppLanguage.es: ToolText(
    'Hormigón',
    'Pilares, vigas, losas, muros, escaleras',
  ),
};
