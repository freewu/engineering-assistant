import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「保温隔热」页的文案：三个 tab（屋面 / 墙面 / 柱）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充。
class InsulationStrings {
  const InsulationStrings({
    required this.tabRoof,
    required this.tabWall,
    required this.tabColumn,
    required this.roofSection,
    required this.projectedArea,
    required this.holeArea,
    required this.avgThickness,
    required this.roofAreaResult,
    required this.roofAreaFormula,
    required this.volumeResult,
    required this.volumeFormula,
    required this.roofHint,
    required this.wallSection,
    required this.wallLength,
    required this.wallHeight,
    required this.openingArea,
    required this.sideArea,
    required this.thickness,
    required this.wallAreaResult,
    required this.wallAreaFormula,
    required this.wallHint,
    required this.columnSection,
    required this.columnPerimeter,
    required this.columnHeight,
    required this.beamArea,
    required this.columnAreaResult,
    required this.columnAreaFormula,
    required this.columnHint,
    required this.note,
  });

  final String tabRoof;
  final String tabWall;
  final String tabColumn;

  final String roofSection;
  final String projectedArea;
  final String holeArea;
  final String avgThickness;
  final String roofAreaResult;

  /// 「S = {0} − {1} = {2} m²」。
  final String roofAreaFormula;
  final String volumeResult;

  /// 「V = {0} × {1} = {2} m³」。
  final String volumeFormula;
  final String roofHint;

  final String wallSection;
  final String wallLength;
  final String wallHeight;
  final String openingArea;
  final String sideArea;
  final String thickness;
  final String wallAreaResult;

  /// 「S = ({0} × {1} − {2}) + {3} = {4} m²」。
  final String wallAreaFormula;
  final String wallHint;

  final String columnSection;
  final String columnPerimeter;
  final String columnHeight;
  final String beamArea;
  final String columnAreaResult;

  /// 「S = {0} × {1} − {2} = {3} m²」。
  final String columnAreaFormula;
  final String columnHint;

  final String note;
}

/// 各语言的「保温隔热」文案。
const Map<AppLanguage, InsulationStrings>
kInsulationStrings = <AppLanguage, InsulationStrings>{
  AppLanguage.zhHans: InsulationStrings(
    tabRoof: '屋面',
    tabWall: '墙面',
    tabColumn: '柱',
    roofSection: '屋面保温隔热',
    projectedArea: '水平投影面积',
    holeArea: '孔洞面积',
    avgThickness: '平均厚度',
    roofAreaResult: '保温面积',
    roofAreaFormula: 'S = {0} − {1} = {2} m²',
    volumeResult: '保温体积',
    volumeFormula: 'V = {0} × {1} = {2} m³',
    roofHint: 'S = 水平投影面积 − 应扣除的孔洞面积，大于 0.3 ㎡ 的孔洞才扣；V = S × 平均厚度（找坡时按平均厚度算）。',
    wallSection: '墙面保温隔热',
    wallLength: '墙长 L',
    wallHeight: '墙高 H',
    openingArea: '门窗洞口面积',
    sideArea: '洞口侧壁面积',
    thickness: '保温层厚度',
    wallAreaResult: '保温面积',
    wallAreaFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint: 'S = 墙长 × 墙高 − 门窗洞口面积 + 洞口侧壁面积；单个 ≤ 0.3 ㎡ 的孔洞不扣，侧壁保温并入墙面。',
    columnSection: '柱保温隔热',
    columnPerimeter: '保温层中心线展开长度',
    columnHeight: '柱高 H',
    beamArea: '梁所占面积',
    columnAreaResult: '保温面积',
    columnAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    columnHint: 'S = 保温层中心线展开长度 × 柱高 − 梁所占面积；只有大于 0.3 ㎡ 的梁所占面积才扣除。',
    note: '按《房屋建筑与装饰工程工程量计算规范》GB/T 50854-2024 清单规则计算；保温层厚度按设计图示，找坡屋面取平均厚度。',
  ),
  AppLanguage.zhHant: InsulationStrings(
    tabRoof: '屋面',
    tabWall: '牆面',
    tabColumn: '柱',
    roofSection: '屋面隔熱保溫',
    projectedArea: '水平投影面積',
    holeArea: '孔洞面積',
    avgThickness: '平均厚度',
    roofAreaResult: '保溫面積',
    roofAreaFormula: 'S = {0} − {1} = {2} m²',
    volumeResult: '保溫體積',
    volumeFormula: 'V = {0} × {1} = {2} m³',
    roofHint: 'S = 水平投影面積 − 應扣除的孔洞面積，大於 0.3 ㎡ 的孔洞才扣；V = S × 平均厚度（找坡時按平均厚度算）。',
    wallSection: '牆面隔熱保溫',
    wallLength: '牆長 L',
    wallHeight: '牆高 H',
    openingArea: '門窗洞口面積',
    sideArea: '洞口側壁面積',
    thickness: '保溫層厚度',
    wallAreaResult: '保溫面積',
    wallAreaFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint: 'S = 牆長 × 牆高 − 門窗洞口面積 + 洞口側壁面積；單個 ≤ 0.3 ㎡ 的孔洞不扣，側壁保溫並入牆面。',
    columnSection: '柱隔熱保溫',
    columnPerimeter: '保溫層中心線展開長度',
    columnHeight: '柱高 H',
    beamArea: '樑所佔面積',
    columnAreaResult: '保溫面積',
    columnAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    columnHint: 'S = 保溫層中心線展開長度 × 柱高 − 樑所佔面積；只有大於 0.3 ㎡ 的樑所佔面積才扣除。',
    note: '按《房屋建築與裝飾工程工程量計算規範》GB/T 50854-2024 清單規則計算；保溫層厚度按設計圖示，找坡屋面取平均厚度。',
  ),
  AppLanguage.en: InsulationStrings(
    tabRoof: 'Roof',
    tabWall: 'Wall',
    tabColumn: 'Column',
    roofSection: 'Roof insulation',
    projectedArea: 'Horizontal projected area',
    holeArea: 'Opening area',
    avgThickness: 'Average thickness',
    roofAreaResult: 'Insulation area',
    roofAreaFormula: 'S = {0} − {1} = {2} m²',
    volumeResult: 'Insulation volume',
    volumeFormula: 'V = {0} × {1} = {2} m³',
    roofHint:
        'S = projected area − openings larger than 0.3 m²; V = S × average thickness, which is how sloped screeds are measured.',
    wallSection: 'Wall insulation',
    wallLength: 'Wall length L',
    wallHeight: 'Wall height H',
    openingArea: 'Opening area',
    sideArea: 'Reveal area',
    thickness: 'Insulation thickness',
    wallAreaResult: 'Insulation area',
    wallAreaFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint:
        'S = length × height − openings + reveals. Openings up to 0.3 m² are not deducted and reveals are added to the wall.',
    columnSection: 'Column insulation',
    columnPerimeter: 'Developed centre-line length',
    columnHeight: 'Column height H',
    beamArea: 'Area taken by beams',
    columnAreaResult: 'Insulation area',
    columnAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    columnHint:
        'S = developed centre-line length × height − area taken by beams, and only beam areas over 0.3 m² are deducted.',
    note:
        'Measured with the GB/T 50854-2024 bill-of-quantities rules. Thickness follows the drawings; sloped roofs use the average thickness.',
  ),
  AppLanguage.ja: InsulationStrings(
    tabRoof: '屋根',
    tabWall: '壁',
    tabColumn: '柱',
    roofSection: '屋根の断熱',
    projectedArea: '水平投影面積',
    holeArea: '開口部面積',
    avgThickness: '平均厚さ',
    roofAreaResult: '断熱面積',
    roofAreaFormula: 'S = {0} − {1} = {2} m²',
    volumeResult: '断熱体積',
    volumeFormula: 'V = {0} × {1} = {2} m³',
    roofHint:
        'S = 水平投影面積 − 0.3 ㎡ を超える開口部の面積。V = S × 平均厚さで、勾配をつけた場合は平均厚さで計算します。',
    wallSection: '壁の断熱',
    wallLength: '壁長さ L',
    wallHeight: '壁高さ H',
    openingArea: '開口部面積',
    sideArea: '開口部側面面積',
    thickness: '断熱材の厚さ',
    wallAreaResult: '断熱面積',
    wallAreaFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint: 'S = 壁長さ × 壁高さ − 開口部面積 + 開口部側面面積。0.3 ㎡ 以下の開口は控除せず、側面の断熱は壁に含めます。',
    columnSection: '柱の断熱',
    columnPerimeter: '断熱材中心線の展開長さ',
    columnHeight: '柱高さ H',
    beamArea: '梁の占める面積',
    columnAreaResult: '断熱面積',
    columnAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    columnHint: 'S = 断熱材中心線の展開長さ × 柱高さ − 梁の占める面積。0.3 ㎡ を超える梁の面積のみ控除します。',
    note: 'GB/T 50854-2024 の数量計算規則によります。断熱材の厚さは図面によらず、勾配屋根は平均厚さを用います。',
  ),
  AppLanguage.es: InsulationStrings(
    tabRoof: 'Cubierta',
    tabWall: 'Muro',
    tabColumn: 'Pilar',
    roofSection: 'Aislamiento de cubierta',
    projectedArea: 'Superficie proyectada',
    holeArea: 'Área de huecos',
    avgThickness: 'Espesor medio',
    roofAreaResult: 'Superficie aislada',
    roofAreaFormula: 'S = {0} − {1} = {2} m²',
    volumeResult: 'Volumen de aislamiento',
    volumeFormula: 'V = {0} × {1} = {2} m³',
    roofHint:
        'S = superficie proyectada − huecos mayores de 0.3 m²; V = S × espesor medio, que es como se miden las pendientes formadas.',
    wallSection: 'Aislamiento de muro',
    wallLength: 'Longitud del muro L',
    wallHeight: 'Altura del muro H',
    openingArea: 'Área de huecos',
    sideArea: 'Área de jambas',
    thickness: 'Espesor del aislamiento',
    wallAreaResult: 'Superficie aislada',
    wallAreaFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint:
        'S = longitud × altura − huecos + jambas. Los huecos de hasta 0.3 m² no se descuentan y las jambas se suman al muro.',
    columnSection: 'Aislamiento de pilar',
    columnPerimeter: 'Longitud desarrollada del eje',
    columnHeight: 'Altura del pilar H',
    beamArea: 'Área ocupada por vigas',
    columnAreaResult: 'Superficie aislada',
    columnAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    columnHint:
        'S = longitud desarrollada del eje × altura − área ocupada por vigas, y solo se descuentan las vigas de más de 0.3 m².',
    note:
        'Medido con las reglas GB/T 50854-2024. El espesor sigue los planos; en cubiertas con pendiente se usa el espesor medio.',
  ),
};

/// 当前语言下的「保温隔热」文案。
InsulationStrings get insulationStrings => toolText(kInsulationStrings);
