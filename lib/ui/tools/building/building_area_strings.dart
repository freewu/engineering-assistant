import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「建筑面积」页的文案：六个 tab（单层 / 多层 / 阳台 / 雨篷 / 门斗 / 车棚货棚）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充；不要在这里拼句子，
/// 日语 / 西语的语序和中文不同。
class BuildingAreaStrings {
  const BuildingAreaStrings({
    required this.tabSingle,
    required this.tabMulti,
    required this.tabBalcony,
    required this.tabCanopy,
    required this.tabVestibule,
    required this.tabShed,
    required this.length,
    required this.width,
    required this.height,
    required this.floors,
    required this.perFloorArea,
    required this.storeyHeight,
    required this.withColumns,
    required this.withoutColumns,
    required this.squareMeter,
    required this.floorUnit,
    required this.singleSection,
    required this.singleResult,
    required this.singleFormula,
    required this.singleHint,
    required this.multiSection,
    required this.multiResult,
    required this.multiFormula,
    required this.multiHint,
    required this.balconySection,
    required this.balconyArea,
    required this.balconyResult,
    required this.balconyFormula,
    required this.balconyHint,
    required this.canopySection,
    required this.canopyArea,
    required this.canopyWidth,
    required this.canopyResult,
    required this.canopyFormula,
    required this.canopySkipped,
    required this.canopyHint,
    required this.vestibuleSection,
    required this.vestibuleArea,
    required this.vestibuleResult,
    required this.vestibuleFormula,
    required this.vestibuleHint,
    required this.shedSection,
    required this.shedArea,
    required this.shedResult,
    required this.shedFormula,
    required this.shedHint,
    required this.total,
    required this.totalHint,
    required this.note,
  });

  final String tabSingle;
  final String tabMulti;
  final String tabBalcony;
  final String tabCanopy;
  final String tabVestibule;
  final String tabShed;

  final String length;
  final String width;
  final String height;
  final String floors;
  final String perFloorArea;
  final String storeyHeight;
  final String withColumns;
  final String withoutColumns;

  final String squareMeter;
  final String floorUnit;

  final String singleSection;
  final String singleResult;

  /// 「S = {0} m × {1} m × {2} = {3} m²」，`{2}` 是 1 或 1/2。
  final String singleFormula;
  final String singleHint;

  final String multiSection;
  final String multiResult;

  /// 「S = {0} 层 × {1} m² = {2} m²」。
  final String multiFormula;
  final String multiHint;

  final String balconySection;
  final String balconyArea;
  final String balconyResult;

  /// 「S = {0} m² × 1/2 = {1} m²」。
  final String balconyFormula;
  final String balconyHint;

  final String canopySection;
  final String canopyArea;
  final String canopyWidth;
  final String canopyResult;

  /// 「S = {0} m² = {1} m²」。
  final String canopyFormula;

  /// 不计算时的说明：「无柱且宽度 ≤ 2.1 m，不计算建筑面积」。
  final String canopySkipped;
  final String canopyHint;

  final String vestibuleSection;
  final String vestibuleArea;
  final String vestibuleResult;

  /// 「S = {0} m² × {1} = {2} m²」，`{1}` 是 1 或 1/2。
  final String vestibuleFormula;
  final String vestibuleHint;

  final String shedSection;
  final String shedArea;
  final String shedResult;

  /// 「S = {0} m² × 1/2 = {1} m²」。
  final String shedFormula;
  final String shedHint;

  /// 「合计建筑面积」。
  final String total;
  final String totalHint;
  final String note;
}

/// 各语言的「建筑面积」文案。
const Map<AppLanguage, BuildingAreaStrings>
kBuildingAreaStrings = <AppLanguage, BuildingAreaStrings>{
  AppLanguage.zhHans: BuildingAreaStrings(
    tabSingle: '单层',
    tabMulti: '多层',
    tabBalcony: '阳台',
    tabCanopy: '雨篷',
    tabVestibule: '门斗',
    tabShed: '车棚',
    length: '长度 L',
    width: '宽度 B',
    height: '结构高度',
    floors: '层数',
    perFloorArea: '每层面积',
    storeyHeight: '结构层高',
    withColumns: '有柱',
    withoutColumns: '无柱',
    squareMeter: '㎡',
    floorUnit: '层',
    singleSection: '单层建筑',
    singleResult: '单层面积',
    singleFormula: 'S = {0} m × {1} m × {2} = {3} m²',
    singleHint: 'L、B 为外墙结构外围水平尺寸；结构高度 ≥ 2.2 m 算全面积，< 2.2 m 算 1/2。',
    multiSection: '多层建筑',
    multiResult: '多层面积',
    multiFormula: 'S = {0} 层 × {1} m² = {2} m²',
    multiHint: '按各层外墙结构外围水平面积之和；各层不一样大时逐层相加。',
    balconySection: '阳台',
    balconyArea: '围护结构外围水平面积',
    balconyResult: '阳台面积',
    balconyFormula: 'S = {0} m² × 1/2 = {1} m²',
    balconyHint: '无论封闭与否，均按 1/2 计算。',
    canopySection: '雨篷',
    canopyArea: '结构底板水平投影面积',
    canopyWidth: '外挑宽度',
    canopyResult: '雨篷面积',
    canopyFormula: 'S = {0} m² = {1} m²',
    canopySkipped: '无柱且宽度 ≤ 2.1 m，不计算建筑面积。',
    canopyHint: '有柱雨篷按全面积计算；无柱雨篷宽度 > 2.1 m 才计算。',
    vestibuleSection: '门斗',
    vestibuleArea: '围护结构外围水平面积',
    vestibuleResult: '门斗面积',
    vestibuleFormula: 'S = {0} m² × {1} = {2} m²',
    vestibuleHint: '结构层高 ≥ 2.2 m 算全面积，< 2.2 m 算 1/2。',
    shedSection: '车棚 / 货棚',
    shedArea: '顶盖水平投影面积',
    shedResult: '车棚面积',
    shedFormula: 'S = {0} m² × 1/2 = {1} m²',
    shedHint: '有顶盖无围护结构，按顶盖水平投影面积的 1/2 计算。',
    total: '合计建筑面积',
    totalHint: '六类构件按各自规则计算后相加，不计入的项按 0 处理。',
    note: '以上按建筑面积计算规范的常用条款估算，正式报建以现行规范与图纸为准。',
  ),
  AppLanguage.zhHant: BuildingAreaStrings(
    tabSingle: '單層',
    tabMulti: '多層',
    tabBalcony: '陽台',
    tabCanopy: '雨遮',
    tabVestibule: '門斗',
    tabShed: '車棚',
    length: '長度 L',
    width: '寬度 B',
    height: '結構高度',
    floors: '層數',
    perFloorArea: '每層面積',
    storeyHeight: '結構層高',
    withColumns: '有柱',
    withoutColumns: '無柱',
    squareMeter: '㎡',
    floorUnit: '層',
    singleSection: '單層建築',
    singleResult: '單層面積',
    singleFormula: 'S = {0} m × {1} m × {2} = {3} m²',
    singleHint: 'L、B 為外牆結構外圍水平尺寸；結構高度 ≥ 2.2 m 算全面積，< 2.2 m 算 1/2。',
    multiSection: '多層建築',
    multiResult: '多層面積',
    multiFormula: 'S = {0} 層 × {1} m² = {2} m²',
    multiHint: '按各層外牆結構外圍水平面積之和；各層不一樣大時逐層相加。',
    balconySection: '陽台',
    balconyArea: '圍護結構外圍水平面積',
    balconyResult: '陽台面積',
    balconyFormula: 'S = {0} m² × 1/2 = {1} m²',
    balconyHint: '無論封閉與否，均按 1/2 計算。',
    canopySection: '雨遮',
    canopyArea: '結構底板水平投影面積',
    canopyWidth: '外挑寬度',
    canopyResult: '雨遮面積',
    canopyFormula: 'S = {0} m² = {1} m²',
    canopySkipped: '無柱且寬度 ≤ 2.1 m，不計算建築面積。',
    canopyHint: '有柱雨遮按全面積計算；無柱雨遮寬度 > 2.1 m 才計算。',
    vestibuleSection: '門斗',
    vestibuleArea: '圍護結構外圍水平面積',
    vestibuleResult: '門斗面積',
    vestibuleFormula: 'S = {0} m² × {1} = {2} m²',
    vestibuleHint: '結構層高 ≥ 2.2 m 算全面積，< 2.2 m 算 1/2。',
    shedSection: '車棚 / 貨棚',
    shedArea: '頂蓋水平投影面積',
    shedResult: '車棚面積',
    shedFormula: 'S = {0} m² × 1/2 = {1} m²',
    shedHint: '有頂蓋無圍護結構，按頂蓋水平投影面積的 1/2 計算。',
    total: '合計建築面積',
    totalHint: '六類構件按各自規則計算後相加，不計入的項按 0 處理。',
    note: '以上按建築面積計算規範的常用條款估算，正式報建以現行規範與圖紙為準。',
  ),
  AppLanguage.en: BuildingAreaStrings(
    tabSingle: 'Single',
    tabMulti: 'Multi',
    tabBalcony: 'Balcony',
    tabCanopy: 'Canopy',
    tabVestibule: 'Lobby',
    tabShed: 'Shed',
    length: 'Length L',
    width: 'Width B',
    height: 'Structure height',
    floors: 'Floors',
    perFloorArea: 'Area per floor',
    storeyHeight: 'Storey height',
    withColumns: 'With columns',
    withoutColumns: 'Without columns',
    squareMeter: 'm²',
    floorUnit: 'floors',
    singleSection: 'Single-storey building',
    singleResult: 'Single-storey area',
    singleFormula: 'S = {0} m × {1} m × {2} = {3} m²',
    singleHint:
        'L and B are the outer horizontal dimensions; full area at 2.2 m and above, half below that.',
    multiSection: 'Multi-storey building',
    multiResult: 'Multi-storey area',
    multiFormula: 'S = {0} floors × {1} m² = {2} m²',
    multiHint:
        'Sum of the outer horizontal areas of every storey; add storeys one by one when they differ.',
    balconySection: 'Balcony',
    balconyArea: 'Outer horizontal area',
    balconyResult: 'Balcony area',
    balconyFormula: 'S = {0} m² × 1/2 = {1} m²',
    balconyHint: 'Always counted at one half, enclosed or not.',
    canopySection: 'Canopy',
    canopyArea: 'Projected slab area',
    canopyWidth: 'Projection width',
    canopyResult: 'Canopy area',
    canopyFormula: 'S = {0} m² = {1} m²',
    canopySkipped: 'Without columns and ≤ 2.1 m wide: not counted.',
    canopyHint:
        'Canopies on columns count in full; column-free ones only when wider than 2.1 m.',
    vestibuleSection: 'Entrance lobby',
    vestibuleArea: 'Outer horizontal area',
    vestibuleResult: 'Lobby area',
    vestibuleFormula: 'S = {0} m² × {1} = {2} m²',
    vestibuleHint:
        'Full area at 2.2 m storey height and above, half below that.',
    shedSection: 'Bicycle / goods shed',
    shedArea: 'Roof projected area',
    shedResult: 'Shed area',
    shedFormula: 'S = {0} m² × 1/2 = {1} m²',
    shedHint: 'Roofed but not enclosed, so half of the roof projection.',
    total: 'Total floor area',
    totalHint:
        'The six parts are computed by their own rules and added; skipped parts count as zero.',
    note:
        'Empirical application of the common floor-area rules; the official submission follows the current code and drawings.',
  ),
  AppLanguage.ja: BuildingAreaStrings(
    tabSingle: '単層',
    tabMulti: '多層',
    tabBalcony: 'バルコニー',
    tabCanopy: '庇',
    tabVestibule: '風除室',
    tabShed: '車棚',
    length: '長さ L',
    width: '幅 B',
    height: '構造高さ',
    floors: '階数',
    perFloorArea: '各階の面積',
    storeyHeight: '階高',
    withColumns: '柱あり',
    withoutColumns: '柱なし',
    squareMeter: 'm²',
    floorUnit: '階',
    singleSection: '単層建築',
    singleResult: '単層の面積',
    singleFormula: 'S = {0} m × {1} m × {2} = {3} m²',
    singleHint: 'L・B は外壁の外側水平寸法。構造高さ 2.2 m 以上で全面積、未満は 1/2。',
    multiSection: '多層建築',
    multiResult: '多層の面積',
    multiFormula: 'S = {0} 階 × {1} m² = {2} m²',
    multiHint: '各階の外壁外側水平面積の合計。階ごとに広さが違う場合は各階を足します。',
    balconySection: 'バルコニー',
    balconyArea: '外周水平面積',
    balconyResult: 'バルコニーの面積',
    balconyFormula: 'S = {0} m² × 1/2 = {1} m²',
    balconyHint: '閉じているかどうかに関わらず 1/2 で計算します。',
    canopySection: '庇',
    canopyArea: '構造スラブ水平投影面積',
    canopyWidth: '張り出し幅',
    canopyResult: '庇の面積',
    canopyFormula: 'S = {0} m² = {1} m²',
    canopySkipped: '柱なしで幅 2.1 m 以下のため算入しません。',
    canopyHint: '柱ありは全面積、柱なしは幅 2.1 m 超のときのみ算入します。',
    vestibuleSection: '風除室',
    vestibuleArea: '外周水平面積',
    vestibuleResult: '風除室の面積',
    vestibuleFormula: 'S = {0} m² × {1} = {2} m²',
    vestibuleHint: '階高 2.2 m 以上で全面積、未満は 1/2 で計算します。',
    shedSection: '車棚 / 物置棚',
    shedArea: '屋根水平投影面積',
    shedResult: '車棚の面積',
    shedFormula: 'S = {0} m² × 1/2 = {1} m²',
    shedHint: '屋根はあるが外壁がないため、屋根投影面積の 1/2 で計算します。',
    total: '建築面積の合計',
    totalHint: '6 種類をそれぞれの規則で計算して合計します。算入しない項目は 0 です。',
    note: '建築面積の一般的な算定規則による概算です。正式な申請は現行法令と図面に従ってください。',
  ),
  AppLanguage.es: BuildingAreaStrings(
    tabSingle: 'Una planta',
    tabMulti: 'Varias',
    tabBalcony: 'Balcón',
    tabCanopy: 'Marquesina',
    tabVestibule: 'Vestíbulo',
    tabShed: 'Cobertizo',
    length: 'Longitud L',
    width: 'Anchura B',
    height: 'Altura de estructura',
    floors: 'Plantas',
    perFloorArea: 'Superficie por planta',
    storeyHeight: 'Altura de planta',
    withColumns: 'Con pilares',
    withoutColumns: 'Sin pilares',
    squareMeter: 'm²',
    floorUnit: 'plantas',
    singleSection: 'Edificio de una planta',
    singleResult: 'Superficie de una planta',
    singleFormula: 'S = {0} m × {1} m × {2} = {3} m²',
    singleHint:
        'L y B son las dimensiones exteriores; superficie completa desde 2.2 m de altura, la mitad por debajo.',
    multiSection: 'Edificio de varias plantas',
    multiResult: 'Superficie de varias plantas',
    multiFormula: 'S = {0} plantas × {1} m² = {2} m²',
    multiHint:
        'Suma de las superficies exteriores de cada planta; si difieren, se suman una a una.',
    balconySection: 'Balcón',
    balconyArea: 'Superficie exterior',
    balconyResult: 'Superficie del balcón',
    balconyFormula: 'S = {0} m² × 1/2 = {1} m²',
    balconyHint: 'Siempre la mitad, esté cerrado o no.',
    canopySection: 'Marquesina',
    canopyArea: 'Superficie de la losa',
    canopyWidth: 'Vuelo',
    canopyResult: 'Superficie de la marquesina',
    canopyFormula: 'S = {0} m² = {1} m²',
    canopySkipped: 'Sin pilares y con vuelo ≤ 2.1 m: no computa.',
    canopyHint:
        'Con pilares computa entera; sin pilares solo si el vuelo supera 2.1 m.',
    vestibuleSection: 'Vestíbulo de entrada',
    vestibuleArea: 'Superficie exterior',
    vestibuleResult: 'Superficie del vestíbulo',
    vestibuleFormula: 'S = {0} m² × {1} = {2} m²',
    vestibuleHint:
        'Superficie completa desde 2.2 m de altura de planta, la mitad por debajo.',
    shedSection: 'Cobertizo de bicicletas / mercancías',
    shedArea: 'Superficie proyectada de cubierta',
    shedResult: 'Superficie del cobertizo',
    shedFormula: 'S = {0} m² × 1/2 = {1} m²',
    shedHint: 'Con cubierta pero sin cerramiento, se computa la mitad.',
    total: 'Superficie total',
    totalHint:
        'Las seis partes se calculan con su regla y se suman; las que no computan valen cero.',
    note:
        'Estimación según las reglas habituales de superficie construida; la tramitación oficial sigue la normativa vigente y los planos.',
  ),
};

/// 当前语言的「建筑面积」文案。
BuildingAreaStrings get buildingAreaStrings => toolText(kBuildingAreaStrings);
