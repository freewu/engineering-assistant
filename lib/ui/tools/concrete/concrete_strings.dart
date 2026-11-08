import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「混凝土构件」页面文案（五种语言）。
///
/// 带参数的话术一律写成 `{0}` / `{1}` 占位，用 `fill()` 填充：日语 / 西语的
/// 语序和中文不一样，不要用字符串拼接。
class ConcreteStrings {
  const ConcreteStrings({
    required this.tabColumn,
    required this.tabBeam,
    required this.tabSlab,
    required this.tabWall,
    required this.tabStair,
    required this.columnSection,
    required this.beamSection,
    required this.slabSection,
    required this.wallSection,
    required this.stairSection,
    required this.sectionA,
    required this.sectionB,
    required this.columnHeight,
    required this.beamLength,
    required this.netLength,
    required this.netWidth,
    required this.slabThickness,
    required this.holeArea,
    required this.wallLength,
    required this.wallHeight,
    required this.wallThickness,
    required this.planArea,
    required this.equivalentThickness,
    required this.meterUnit,
    required this.squareMeter,
    required this.cubicMeter,
    required this.columnResult,
    required this.beamResult,
    required this.slabResult,
    required this.wallResult,
    required this.stairResult,
    required this.columnFormula,
    required this.beamFormula,
    required this.slabFormula,
    required this.slabHoleFormula,
    required this.wallFormula,
    required this.stairFormula,
    required this.columnHint,
    required this.beamHint,
    required this.slabHint,
    required this.wallHint,
    required this.stairHint,
    required this.note,
  });

  final String tabColumn;
  final String tabBeam;
  final String tabSlab;
  final String tabWall;
  final String tabStair;

  final String columnSection;
  final String beamSection;
  final String slabSection;
  final String wallSection;
  final String stairSection;

  final String sectionA;
  final String sectionB;
  final String columnHeight;
  final String beamLength;
  final String netLength;
  final String netWidth;
  final String slabThickness;
  final String holeArea;
  final String wallLength;
  final String wallHeight;
  final String wallThickness;
  final String planArea;
  final String equivalentThickness;

  final String meterUnit;
  final String squareMeter;
  final String cubicMeter;

  final String columnResult;
  final String beamResult;
  final String slabResult;
  final String wallResult;
  final String stairResult;

  final String columnFormula;
  final String beamFormula;
  final String slabFormula;
  final String slabHoleFormula;
  final String wallFormula;
  final String stairFormula;

  final String columnHint;
  final String beamHint;
  final String slabHint;
  final String wallHint;
  final String stairHint;

  final String note;
}

const Map<AppLanguage, ConcreteStrings>
kConcreteStrings = <AppLanguage, ConcreteStrings>{
  AppLanguage.zhHans: ConcreteStrings(
    tabColumn: '柱',
    tabBeam: '梁',
    tabSlab: '板',
    tabWall: '墙',
    tabStair: '楼梯',
    columnSection: '矩形柱',
    beamSection: '矩形梁',
    slabSection: '现浇板',
    wallSection: '混凝土墙',
    stairSection: '楼梯',
    sectionA: '截面 a',
    sectionB: '截面 b',
    columnHeight: '柱高 H',
    beamLength: '梁净长 L',
    netLength: '净长',
    netWidth: '净宽',
    slabThickness: '板厚',
    holeArea: '孔洞面积',
    wallLength: '墙长',
    wallHeight: '墙高',
    wallThickness: '墙厚',
    planArea: '水平投影面积',
    equivalentThickness: '折算厚度',
    meterUnit: 'm',
    squareMeter: '㎡',
    cubicMeter: 'm³',
    columnResult: '柱体积',
    beamResult: '梁体积',
    slabResult: '板体积',
    wallResult: '墙体积',
    stairResult: '楼梯体积',
    columnFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    beamFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabHoleFormula: 'V = （{0} m × {1} m − {2} ㎡）× {3} m = {4} m³',
    wallFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    stairFormula: 'V = {0} ㎡ × {1} m = {2} m³',
    columnHint: 'a、b 是截面尺寸，H 取基础顶面至梁底（无梁时算至板底）。',
    beamHint: 'a、b 是截面尺寸，L 取柱间净距，与柱相交的部分不重复计算。',
    slabHint: '净长、净宽算至梁侧；单个孔洞面积 > 0.3 ㎡ 才扣除，≤ 300 mm × 300 mm 一律不扣。',
    wallHint: '墙高与板连接算至板底，与梁连接算至梁底。',
    stairHint: '折算厚度按定额取 0.2 ~ 0.3 m，常用 0.25 m；水平投影面积含踏步与休息平台。',
    note: '按设计图示尺寸以体积计算，不扣除钢筋、螺栓、预埋铁件及单个 ≤ 300 mm × 300 mm 的孔洞。',
  ),
  AppLanguage.zhHant: ConcreteStrings(
    tabColumn: '柱',
    tabBeam: '梁',
    tabSlab: '板',
    tabWall: '牆',
    tabStair: '樓梯',
    columnSection: '矩形柱',
    beamSection: '矩形梁',
    slabSection: '現澆板',
    wallSection: '混凝土牆',
    stairSection: '樓梯',
    sectionA: '截面 a',
    sectionB: '截面 b',
    columnHeight: '柱高 H',
    beamLength: '梁淨長 L',
    netLength: '淨長',
    netWidth: '淨寬',
    slabThickness: '板厚',
    holeArea: '孔洞面積',
    wallLength: '牆長',
    wallHeight: '牆高',
    wallThickness: '牆厚',
    planArea: '水平投影面積',
    equivalentThickness: '折算厚度',
    meterUnit: 'm',
    squareMeter: '㎡',
    cubicMeter: 'm³',
    columnResult: '柱體積',
    beamResult: '梁體積',
    slabResult: '板體積',
    wallResult: '牆體積',
    stairResult: '樓梯體積',
    columnFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    beamFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabHoleFormula: 'V = （{0} m × {1} m − {2} ㎡）× {3} m = {4} m³',
    wallFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    stairFormula: 'V = {0} ㎡ × {1} m = {2} m³',
    columnHint: 'a、b 是截面尺寸，H 取基礎頂面至梁底（無梁時算至板底）。',
    beamHint: 'a、b 是截面尺寸，L 取柱間淨距，與柱相交的部分不重複計算。',
    slabHint: '淨長、淨寬算至梁側；單個孔洞面積 > 0.3 ㎡ 才扣除，≤ 300 mm × 300 mm 一律不扣。',
    wallHint: '牆高與板連接算至板底，與梁連接算至梁底。',
    stairHint: '折算厚度按定額取 0.2 ~ 0.3 m，常用 0.25 m；水平投影面積含踏步與休息平台。',
    note: '按設計圖示尺寸以體積計算，不扣除鋼筋、螺栓、預埋鐵件及單個 ≤ 300 mm × 300 mm 的孔洞。',
  ),
  AppLanguage.en: ConcreteStrings(
    tabColumn: 'Column',
    tabBeam: 'Beam',
    tabSlab: 'Slab',
    tabWall: 'Wall',
    tabStair: 'Stair',
    columnSection: 'Rectangular column',
    beamSection: 'Rectangular beam',
    slabSection: 'Cast-in-place slab',
    wallSection: 'Concrete wall',
    stairSection: 'Stair',
    sectionA: 'Section a',
    sectionB: 'Section b',
    columnHeight: 'Column height H',
    beamLength: 'Clear span L',
    netLength: 'Clear length',
    netWidth: 'Clear width',
    slabThickness: 'Slab thickness',
    holeArea: 'Hole area',
    wallLength: 'Wall length',
    wallHeight: 'Wall height',
    wallThickness: 'Wall thickness',
    planArea: 'Plan area',
    equivalentThickness: 'Equivalent thickness',
    meterUnit: 'm',
    squareMeter: 'm²',
    cubicMeter: 'm³',
    columnResult: 'Column volume',
    beamResult: 'Beam volume',
    slabResult: 'Slab volume',
    wallResult: 'Wall volume',
    stairResult: 'Stair volume',
    columnFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    beamFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabHoleFormula: 'V = ({0} m × {1} m − {2} m²) × {3} m = {4} m³',
    wallFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    stairFormula: 'V = {0} m² × {1} m = {2} m³',
    columnHint:
        'a and b are the section sizes; H runs from the top of the '
        'footing to the beam soffit (to the slab soffit without a beam).',
    beamHint:
        'a and b are the section sizes; L is the clear distance between '
        'columns, so the part inside a column is not counted twice.',
    slabHint:
        'Clear length and width are measured to the beam faces. Holes '
        'larger than 0.3 m² each are deducted; 300 × 300 mm or smaller '
        'never are.',
    wallHint:
        'Wall height stops at the slab soffit when connected to a slab, '
        'at the beam soffit when connected to a beam.',
    stairHint:
        'Equivalent thickness is 0.2 ~ 0.3 m by the local quota, 0.25 m is '
        'common; the plan area includes treads and landings.',
    note:
        'Measured as volume from the design dimensions; reinforcement, '
        'bolts, embedded steel parts and holes of 300 × 300 mm or less '
        'are not deducted.',
  ),
  AppLanguage.ja: ConcreteStrings(
    tabColumn: '柱',
    tabBeam: '梁',
    tabSlab: 'スラブ',
    tabWall: '壁',
    tabStair: '階段',
    columnSection: '矩形柱',
    beamSection: '矩形梁',
    slabSection: '現場打ちスラブ',
    wallSection: 'コンクリート壁',
    stairSection: '階段',
    sectionA: '断面 a',
    sectionB: '断面 b',
    columnHeight: '柱高さ H',
    beamLength: '梁の内法長さ L',
    netLength: '内法長さ',
    netWidth: '内法幅',
    slabThickness: 'スラブ厚',
    holeArea: '開口面積',
    wallLength: '壁長さ',
    wallHeight: '壁高さ',
    wallThickness: '壁厚',
    planArea: '水平投影面積',
    equivalentThickness: '換算厚さ',
    meterUnit: 'm',
    squareMeter: '㎡',
    cubicMeter: 'm³',
    columnResult: '柱の体積',
    beamResult: '梁の体積',
    slabResult: 'スラブの体積',
    wallResult: '壁の体積',
    stairResult: '階段の体積',
    columnFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    beamFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabHoleFormula: 'V = （{0} m × {1} m − {2} ㎡）× {3} m = {4} m³',
    wallFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    stairFormula: 'V = {0} ㎡ × {1} m = {2} m³',
    columnHint: 'a・b は断面寸法、H は基礎天端から梁底まで（梁がなければスラブ底まで）。',
    beamHint: 'a・b は断面寸法、L は柱の内法である。柱に接する部分は二重に計上しない。',
    slabHint:
        '内法長さ・内法幅は梁側まで。1 か所 0.3 ㎡ を超える開口のみ差し引き、300 mm × 300 mm 以下は差し引かない。',
    wallHint: '壁高さは、スラブと接する場合はスラブ底まで、梁と接する場合は梁底まで。',
    stairHint: '換算厚さは積算基準で 0.2 ~ 0.3 m、通常は 0.25 m。水平投影面積には踏面と踊り場を含む。',
    note: '設計図の寸法で体積を求める。鉄筋・ボルト・埋込金物、および 300 mm × 300 mm 以下の開口は差し引かない。',
  ),
  AppLanguage.es: ConcreteStrings(
    tabColumn: 'Pilar',
    tabBeam: 'Viga',
    tabSlab: 'Losa',
    tabWall: 'Muro',
    tabStair: 'Escalera',
    columnSection: 'Pilar rectangular',
    beamSection: 'Viga rectangular',
    slabSection: 'Losa in situ',
    wallSection: 'Muro de hormigón',
    stairSection: 'Escalera',
    sectionA: 'Sección a',
    sectionB: 'Sección b',
    columnHeight: 'Altura H',
    beamLength: 'Luz libre L',
    netLength: 'Longitud libre',
    netWidth: 'Ancho libre',
    slabThickness: 'Espesor',
    holeArea: 'Área del hueco',
    wallLength: 'Longitud del muro',
    wallHeight: 'Altura del muro',
    wallThickness: 'Espesor del muro',
    planArea: 'Área en planta',
    equivalentThickness: 'Espesor equivalente',
    meterUnit: 'm',
    squareMeter: 'm²',
    cubicMeter: 'm³',
    columnResult: 'Volumen del pilar',
    beamResult: 'Volumen de la viga',
    slabResult: 'Volumen de la losa',
    wallResult: 'Volumen del muro',
    stairResult: 'Volumen de la escalera',
    columnFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    beamFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    slabHoleFormula: 'V = ({0} m × {1} m − {2} m²) × {3} m = {4} m³',
    wallFormula: 'V = {0} m × {1} m × {2} m = {3} m³',
    stairFormula: 'V = {0} m² × {1} m = {2} m³',
    columnHint:
        'a y b son las dimensiones de la sección; H va de la cara '
        'superior de la cimentación al intradós de la viga (o de la losa '
        'si no hay viga).',
    beamHint:
        'a y b son las dimensiones de la sección; L es la luz libre entre '
        'pilares, así que la parte dentro del pilar no se cuenta dos veces.',
    slabHint:
        'La longitud y el ancho libres se miden hasta la cara de la viga. '
        'Solo se descuentan huecos de más de 0.3 m² cada uno; los de '
        '300 × 300 mm o menos nunca.',
    wallHint:
        'La altura del muro llega al intradós de la losa si conecta con '
        'losa, o al intradós de la viga si conecta con viga.',
    stairHint:
        'El espesor equivalente es de 0.2 ~ 0.3 m según el banco de precios '
        '(0.25 m es lo habitual); el área en planta incluye huellas y '
        'descansillos.',
    note:
        'Se mide en volumen según las dimensiones del proyecto; no se '
        'descuentan armaduras, pernos, piezas embebidas ni huecos de '
        '300 × 300 mm o menores.',
  ),
};

/// 按当前界面语言取文案。
ConcreteStrings get concreteStrings => toolText(kConcreteStrings);
