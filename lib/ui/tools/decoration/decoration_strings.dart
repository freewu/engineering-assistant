import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「装饰装修」页的文案：三个 tab（墙面 / 天棚 / 楼地面）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充。
class DecorationStrings {
  const DecorationStrings({
    required this.tabWall,
    required this.tabCeiling,
    required this.tabFloor,
    required this.wallSection,
    required this.wallLength,
    required this.wallHeight,
    required this.openingArea,
    required this.sideArea,
    required this.attachedArea,
    required this.wallResult,
    required this.wallFormula,
    required this.wallHint,
    required this.ceilingSection,
    required this.netArea,
    required this.beamSideArea,
    required this.ceilingResult,
    required this.ceilingFormula,
    required this.ceilingHint,
    required this.floorSection,
    required this.structureArea,
    required this.floorResult,
    required this.floorFormula,
    required this.floorHint,
    required this.note,
  });

  final String tabWall;
  final String tabCeiling;
  final String tabFloor;

  final String wallSection;
  final String wallLength;
  final String wallHeight;
  final String openingArea;
  final String sideArea;
  final String attachedArea;
  final String wallResult;

  /// 「S = ({0} × {1} − {2}) + {3} + {4} = {5} m²」。
  final String wallFormula;
  final String wallHint;

  final String ceilingSection;
  final String netArea;
  final String beamSideArea;
  final String ceilingResult;

  /// 「S = {0} + {1} = {2} m²」。
  final String ceilingFormula;
  final String ceilingHint;

  final String floorSection;
  final String structureArea;
  final String floorResult;

  /// 「S = {0} − {1} = {2} m²」。
  final String floorFormula;
  final String floorHint;

  final String note;
}

/// 各语言的「装饰装修」文案。
const Map<AppLanguage, DecorationStrings>
kDecorationStrings = <AppLanguage, DecorationStrings>{
  AppLanguage.zhHans: DecorationStrings(
    tabWall: '墙面',
    tabCeiling: '天棚',
    tabFloor: '楼地面',
    wallSection: '墙面装饰',
    wallLength: '墙长 L',
    wallHeight: '墙高 H',
    openingArea: '门窗洞口面积',
    sideArea: '洞口侧壁面积',
    attachedArea: '附墙柱梁侧面',
    wallResult: '装饰面积',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} + {4} = {5} m²',
    wallHint:
        'S = 墙长 × 墙高 − 门窗洞口面积 + 洞口侧壁面积 + 附墙柱梁侧面；单个 ≤ 0.3 ㎡ 的孔洞不扣，附墙柱、梁的侧面并入墙面。',
    ceilingSection: '天棚装饰',
    netArea: '主墙间净面积',
    beamSideArea: '梁侧面面积',
    ceilingResult: '装饰面积',
    ceilingFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint: 'S = 主墙间净面积 + 梁侧面面积；不扣单个 ≤ 0.3 ㎡ 的孔洞，也不扣间壁墙。',
    floorSection: '楼地面装饰',
    structureArea: '凸出地面构筑物面积',
    floorResult: '装饰面积',
    floorFormula: 'S = {0} − {1} = {2} m²',
    floorHint: 'S = 主墙间净面积 − 凸出地面的构筑物、设备基础等所占面积；门洞开口部分并入。',
    note: '按《房屋建筑与装饰工程工程量计算规范》GB/T 50854-2024 清单规则计算；踢脚线、门窗套等另列项目，这里只算面层面积。',
  ),
  AppLanguage.zhHant: DecorationStrings(
    tabWall: '牆面',
    tabCeiling: '天棚',
    tabFloor: '樓地面',
    wallSection: '牆面裝飾',
    wallLength: '牆長 L',
    wallHeight: '牆高 H',
    openingArea: '門窗洞口面積',
    sideArea: '洞口側壁面積',
    attachedArea: '附牆柱樑側面',
    wallResult: '裝飾面積',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} + {4} = {5} m²',
    wallHint:
        'S = 牆長 × 牆高 − 門窗洞口面積 + 洞口側壁面積 + 附牆柱樑側面；單個 ≤ 0.3 ㎡ 的孔洞不扣，附牆柱、樑的側面並入牆面。',
    ceilingSection: '天棚裝飾',
    netArea: '主牆間淨面積',
    beamSideArea: '樑側面面積',
    ceilingResult: '裝飾面積',
    ceilingFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint: 'S = 主牆間淨面積 + 樑側面面積；不扣單個 ≤ 0.3 ㎡ 的孔洞，也不扣間壁牆。',
    floorSection: '樓地面裝飾',
    structureArea: '凸出地面構築物面積',
    floorResult: '裝飾面積',
    floorFormula: 'S = {0} − {1} = {2} m²',
    floorHint: 'S = 主牆間淨面積 − 凸出地面的構築物、設備基礎等所佔面積；門洞開口部分並入。',
    note: '按《房屋建築與裝飾工程工程量計算規範》GB/T 50854-2024 清單規則計算；踢腳線、門窗套等另列項目，這裡只算面層面積。',
  ),
  AppLanguage.en: DecorationStrings(
    tabWall: 'Wall',
    tabCeiling: 'Ceiling',
    tabFloor: 'Floor',
    wallSection: 'Wall finishes',
    wallLength: 'Wall length L',
    wallHeight: 'Wall height H',
    openingArea: 'Opening area',
    sideArea: 'Reveal area',
    attachedArea: 'Pilasters and beam sides',
    wallResult: 'Finish area',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} + {4} = {5} m²',
    wallHint:
        'S = length × height − openings + reveals + pilaster and beam sides. Openings up to 0.3 m² are not deducted and attached pilasters and beams are added.',
    ceilingSection: 'Ceiling finishes',
    netArea: 'Net area between walls',
    beamSideArea: 'Beam side area',
    ceilingResult: 'Finish area',
    ceilingFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint:
        'S = net area + beam sides. Openings up to 0.3 m² and partition walls are not deducted.',
    floorSection: 'Floor finishes',
    structureArea: 'Area of built-in structures',
    floorResult: 'Finish area',
    floorFormula: 'S = {0} − {1} = {2} m²',
    floorHint:
        'S = net area − structures and equipment bases rising above the floor. Door openings are included.',
    note:
        'Measured with the GB/T 50854-2024 bill-of-quantities rules. Skirtings and window reveals are separate items; only the surface area is measured here.',
  ),
  AppLanguage.ja: DecorationStrings(
    tabWall: '壁',
    tabCeiling: '天井',
    tabFloor: '床',
    wallSection: '壁の仕上げ',
    wallLength: '壁長さ L',
    wallHeight: '壁高さ H',
    openingArea: '開口部面積',
    sideArea: '開口部側面面積',
    attachedArea: '付け柱・梁の側面',
    wallResult: '仕上げ面積',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} + {4} = {5} m²',
    wallHint:
        'S = 壁長さ × 壁高さ − 開口部面積 + 開口部側面面積 + 付け柱・梁の側面。0.3 ㎡ 以下の開口は控除せず、付け柱や梁の側面は壁に含めます。',
    ceilingSection: '天井の仕上げ',
    netArea: '壁間の正味面積',
    beamSideArea: '梁の側面面積',
    ceilingResult: '仕上げ面積',
    ceilingFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint: 'S = 壁間の正味面積 + 梁の側面面積。0.3 ㎡ 以下の開口や間仕切り壁は控除しません。',
    floorSection: '床の仕上げ',
    structureArea: '突出する構造物の面積',
    floorResult: '仕上げ面積',
    floorFormula: 'S = {0} − {1} = {2} m²',
    floorHint: 'S = 壁間の正味面積 − 床から突出する構造物や設備基礎の面積。出入口の開口部分は含めます。',
    note: 'GB/T 50854-2024 の数量計算規則によります。幅木や窓枠は別項目とし、ここでは仕上げ面積のみを計算します。',
  ),
  AppLanguage.es: DecorationStrings(
    tabWall: 'Muro',
    tabCeiling: 'Techo',
    tabFloor: 'Suelo',
    wallSection: 'Revestimiento de muros',
    wallLength: 'Longitud del muro L',
    wallHeight: 'Altura del muro H',
    openingArea: 'Área de huecos',
    sideArea: 'Área de jambas',
    attachedArea: 'Caras de pilastras y vigas',
    wallResult: 'Superficie revestida',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} + {4} = {5} m²',
    wallHint:
        'S = longitud × altura − huecos + jambas + caras de pilastras y vigas. Los huecos de hasta 0.3 m² no se descuentan y las pilastras adosadas se suman.',
    ceilingSection: 'Revestimiento de techos',
    netArea: 'Superficie neta entre muros',
    beamSideArea: 'Caras laterales de vigas',
    ceilingResult: 'Superficie revestida',
    ceilingFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint:
        'S = superficie neta + caras laterales de vigas. Los huecos de hasta 0.3 m² y los tabiques no se descuentan.',
    floorSection: 'Revestimiento de suelos',
    structureArea: 'Área de elementos salientes',
    floorResult: 'Superficie revestida',
    floorFormula: 'S = {0} − {1} = {2} m²',
    floorHint:
        'S = superficie neta − elementos y bases de equipos que sobresalen del suelo. Los huecos de paso se incluyen.',
    note:
        'Medido con las reglas GB/T 50854-2024. Los zócalos y las jambas de ventanas son partidas aparte; aquí solo se mide la superficie.',
  ),
};

/// 当前语言下的「装饰装修」文案。
DecorationStrings get decorationStrings => toolText(kDecorationStrings);
