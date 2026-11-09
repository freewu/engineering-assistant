import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「砌筑工程」页的文案：三个 tab（砖墙 / 砖基础 / 特殊墙体）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充；不要在这里拼句子，
/// 日语 / 西语的语序和中文不同。
class MasonryStrings {
  const MasonryStrings({
    required this.tabWall,
    required this.tabFoundation,
    required this.tabSpecial,
    required this.wallSection,
    required this.wallLength,
    required this.wallHeight,
    required this.wallThickness,
    required this.openingArea,
    required this.concreteVolume,
    required this.wallResult,
    required this.wallFormula,
    required this.wallHint,
    required this.foundationSection,
    required this.foundationMode,
    required this.modeAddedHeight,
    required this.modeStepVolume,
    required this.foundationThickness,
    required this.foundationHeight,
    required this.addedHeight,
    required this.centerlineLength,
    required this.netLength,
    required this.stepVolume,
    required this.foundationResult,
    required this.foundationFormula,
    required this.foundationStepFormula,
    required this.foundationHint,
    required this.specialSection,
    required this.specialType,
    required this.typeHollow,
    required this.typeOpenwork,
    required this.typePerforated,
    required this.holeVolume,
    required this.specialResult,
    required this.specialFormula,
    required this.specialHoleFormula,
    required this.specialHint,
    required this.note,
  });

  final String tabWall;
  final String tabFoundation;
  final String tabSpecial;

  final String wallSection;
  final String wallLength;
  final String wallHeight;
  final String wallThickness;
  final String openingArea;
  final String concreteVolume;
  final String wallResult;

  /// 「V = ({0} × {1} − {2}) × {3} − {4} = {5} m³」。
  final String wallFormula;
  final String wallHint;

  final String foundationSection;
  final String foundationMode;
  final String modeAddedHeight;
  final String modeStepVolume;
  final String foundationThickness;
  final String foundationHeight;
  final String addedHeight;
  final String centerlineLength;
  final String netLength;
  final String stepVolume;
  final String foundationResult;

  /// 「V = {0} × ({1} + {2}) × ({3} + {4}) = {5} m³」。
  final String foundationFormula;

  /// 「V = {0} × {1} × ({2} + {3}) + {4} = {5} m³」。
  final String foundationStepFormula;
  final String foundationHint;

  final String specialSection;
  final String specialType;
  final String typeHollow;
  final String typeOpenwork;
  final String typePerforated;
  final String holeVolume;
  final String specialResult;

  /// 「V = {0} × {1} × {2} = {3} m³」。
  final String specialFormula;

  /// 「V = {0} × {1} × {2} − {3} = {4} m³」。
  final String specialHoleFormula;
  final String specialHint;

  final String note;

  /// 墙体类型下拉框里的名称。
  String typeLabel(MasonryWallType type) => switch (type) {
    MasonryWallType.hollow => typeHollow,
    MasonryWallType.openwork => typeOpenwork,
    MasonryWallType.perforated => typePerforated,
  };
}

/// 特殊墙体的三种类型：空斗墙 / 空花墙 / 多孔砖墙。
enum MasonryWallType {
  /// 空斗墙：按外形体积计算，不扣除空洞。
  hollow,

  /// 空花墙：按空花部分外形体积计算，不扣除空洞。
  openwork,

  /// 多孔砖墙：按设计图示尺寸以体积计算，扣除孔洞。
  perforated,
}

/// 砖基础的计算方式：折加高度 / 大放脚体积。
enum FoundationMode {
  /// 折加高度：V = t × (H + 折加高度) × (L中 + L内)。
  addedHeight,

  /// 大放脚体积：V = t × H × (L中 + L内) + 大放脚体积。
  stepVolume,
}

/// 各语言的「砌筑工程」文案。
const Map<AppLanguage, MasonryStrings>
kMasonryStrings = <AppLanguage, MasonryStrings>{
  AppLanguage.zhHans: MasonryStrings(
    tabWall: '砖墙',
    tabFoundation: '砖基础',
    tabSpecial: '特殊墙体',
    wallSection: '砖墙',
    wallLength: '墙长 L',
    wallHeight: '墙高 H',
    wallThickness: '墙厚 t',
    openingArea: '门窗洞口面积',
    concreteVolume: '混凝土构件体积',
    wallResult: '砖墙体积',
    wallFormula: 'V = ({0} × {1} − {2}) × {3} − {4} = {5} m³',
    wallHint:
        'V = (墙长 × 墙高 − 门窗洞口面积) × 墙厚 − 混凝土构件体积。墙长外墙按中心线、内墙按净长；墙高外墙算至檐口、内墙算至板底；不扣除单个 ≤ 0.3 ㎡ 的孔洞，圈梁 / 构造柱 / 过梁要扣。',
    foundationSection: '砖基础',
    foundationMode: '计算方式',
    modeAddedHeight: '折加高度',
    modeStepVolume: '大放脚体积',
    foundationThickness: '墙厚 t',
    foundationHeight: '基础高度 H',
    addedHeight: '折加高度',
    centerlineLength: '外墙中心线长 L中',
    netLength: '内墙净长 L内',
    stepVolume: '大放脚增加体积',
    foundationResult: '砖基础体积',
    foundationFormula: 'V = {0} × ({1} + {2}) × ({3} + {4}) = {5} m³',
    foundationStepFormula: 'V = {0} × {1} × ({2} + {3}) + {4} = {5} m³',
    foundationHint:
        '折加高度法：V = 墙厚 ×（基础高度 + 折加高度）×（L中 + L内）；图纸直接给出大放脚体积时改用「大放脚体积」：V = 墙厚 × 基础高度 ×（L中 + L内）+ 大放脚体积。',
    specialSection: '特殊墙体',
    specialType: '墙体类型',
    typeHollow: '空斗墙',
    typeOpenwork: '空花墙',
    typePerforated: '多孔砖墙',
    holeVolume: '孔洞体积',
    specialResult: '墙体体积',
    specialFormula: 'V = {0} × {1} × {2} = {3} m³',
    specialHoleFormula: 'V = {0} × {1} × {2} − {3} = {4} m³',
    specialHint: '空斗墙按外形体积计算、不扣除空洞；空花墙按空花部分外形体积计算、不扣除空洞；多孔砖墙按设计图示尺寸以体积计算并扣除孔洞。',
    note:
        '按《房屋建筑与装饰工程工程量计算规范》GB/T 50854-2024 清单规则计算；墙厚标准砖 240 墙取 0.24 m、120 墙取 0.115 m，实际以图纸与当地定额为准。',
  ),
  AppLanguage.zhHant: MasonryStrings(
    tabWall: '磚牆',
    tabFoundation: '磚基礎',
    tabSpecial: '特殊牆體',
    wallSection: '磚牆',
    wallLength: '牆長 L',
    wallHeight: '牆高 H',
    wallThickness: '牆厚 t',
    openingArea: '門窗洞口面積',
    concreteVolume: '混凝土構件體積',
    wallResult: '磚牆體積',
    wallFormula: 'V = ({0} × {1} − {2}) × {3} − {4} = {5} m³',
    wallHint:
        'V = (牆長 × 牆高 − 門窗洞口面積) × 牆厚 − 混凝土構件體積。牆長外牆按中心線、內牆按淨長；牆高外牆算至簷口、內牆算至板底；不扣除單個 ≤ 0.3 ㎡ 的孔洞，圈樑 / 構造柱 / 過樑要扣。',
    foundationSection: '磚基礎',
    foundationMode: '計算方式',
    modeAddedHeight: '折加高度',
    modeStepVolume: '大放腳體積',
    foundationThickness: '牆厚 t',
    foundationHeight: '基礎高度 H',
    addedHeight: '折加高度',
    centerlineLength: '外牆中心線長 L中',
    netLength: '內牆淨長 L內',
    stepVolume: '大放腳增加體積',
    foundationResult: '磚基礎體積',
    foundationFormula: 'V = {0} × ({1} + {2}) × ({3} + {4}) = {5} m³',
    foundationStepFormula: 'V = {0} × {1} × ({2} + {3}) + {4} = {5} m³',
    foundationHint:
        '折加高度法：V = 牆厚 ×（基礎高度 + 折加高度）×（L中 + L內）；圖紙直接給出大放腳體積時改用「大放腳體積」：V = 牆厚 × 基礎高度 ×（L中 + L內）+ 大放腳體積。',
    specialSection: '特殊牆體',
    specialType: '牆體類型',
    typeHollow: '空斗牆',
    typeOpenwork: '空花牆',
    typePerforated: '多孔磚牆',
    holeVolume: '孔洞體積',
    specialResult: '牆體體積',
    specialFormula: 'V = {0} × {1} × {2} = {3} m³',
    specialHoleFormula: 'V = {0} × {1} × {2} − {3} = {4} m³',
    specialHint: '空斗牆按外形體積計算、不扣除空洞；空花牆按空花部分外形體積計算、不扣除空洞；多孔磚牆按設計圖示尺寸以體積計算並扣除孔洞。',
    note:
        '按《房屋建築與裝飾工程工程量計算規範》GB/T 50854-2024 清單規則計算；牆厚標準磚 240 牆取 0.24 m、120 牆取 0.115 m，實際以圖紙與當地定額為準。',
  ),
  AppLanguage.en: MasonryStrings(
    tabWall: 'Brick wall',
    tabFoundation: 'Brick footing',
    tabSpecial: 'Special walls',
    wallSection: 'Brick wall',
    wallLength: 'Wall length L',
    wallHeight: 'Wall height H',
    wallThickness: 'Wall thickness t',
    openingArea: 'Opening area',
    concreteVolume: 'Concrete members volume',
    wallResult: 'Wall volume',
    wallFormula: 'V = ({0} × {1} − {2}) × {3} − {4} = {5} m³',
    wallHint:
        'V = (length × height − openings) × thickness − concrete members. Exterior walls are measured on the centre line, interior walls on the clear length; height runs to the eaves outside and to the slab soffit inside. Openings up to 0.3 m² are not deducted; ring beams, tie columns and lintels are.',
    foundationSection: 'Brick footing',
    foundationMode: 'Method',
    modeAddedHeight: 'Added height',
    modeStepVolume: 'Stepped footing volume',
    foundationThickness: 'Wall thickness t',
    foundationHeight: 'Footing height H',
    addedHeight: 'Added height',
    centerlineLength: 'Exterior centre-line length',
    netLength: 'Interior clear length',
    stepVolume: 'Stepped footing volume',
    foundationResult: 'Footing volume',
    foundationFormula: 'V = {0} × ({1} + {2}) × ({3} + {4}) = {5} m³',
    foundationStepFormula: 'V = {0} × {1} × ({2} + {3}) + {4} = {5} m³',
    foundationHint:
        'Added-height method: V = thickness × (height + added height) × (exterior centre line + interior clear length). When the drawings give the stepped footing volume, use it instead: V = thickness × height × (lengths) + stepped volume.',
    specialSection: 'Special walls',
    specialType: 'Wall type',
    typeHollow: 'Hollow-brick wall',
    typeOpenwork: 'Openwork wall',
    typePerforated: 'Perforated-brick wall',
    holeVolume: 'Void volume',
    specialResult: 'Wall volume',
    specialFormula: 'V = {0} × {1} × {2} = {3} m³',
    specialHoleFormula: 'V = {0} × {1} × {2} − {3} = {4} m³',
    specialHint:
        'Hollow-brick walls take the overall shape volume with voids ignored; openwork walls take the openwork shape volume with voids ignored; perforated-brick walls take the volume from the drawings and deduct the voids.',
    note:
        'Measured with the GB/T 50854-2024 bill-of-quantities rules. A standard 240 mm wall counts as 0.24 m and a 120 mm wall as 0.115 m; drawings and local norms govern.',
  ),
  AppLanguage.ja: MasonryStrings(
    tabWall: '磚積み壁',
    tabFoundation: '基礎',
    tabSpecial: '特殊な壁',
    wallSection: '磚積み壁',
    wallLength: '壁長さ L',
    wallHeight: '壁高さ H',
    wallThickness: '壁厚 t',
    openingArea: '開口部面積',
    concreteVolume: 'コンクリート部材の体積',
    wallResult: '壁体積',
    wallFormula: 'V = ({0} × {1} − {2}) × {3} − {4} = {5} m³',
    wallHint:
        'V = 壁長さ × 壁高さ − 開口部面積 に壁厚を掛け、コンクリート部材の体積を差し引きます。壁長さは外壁が中心線、内壁が内法長さ。0.3 ㎡ 以下の開口は控除しませんが、圈梁・构造柱・まぐさは控除します。',
    foundationSection: '磚積み基礎',
    foundationMode: '計算方法',
    modeAddedHeight: '加算高さ',
    modeStepVolume: 'フーチング体積',
    foundationThickness: '壁厚 t',
    foundationHeight: '基礎高さ H',
    addedHeight: '加算高さ',
    centerlineLength: '外壁中心線長さ',
    netLength: '内壁内法長さ',
    stepVolume: 'フーチングの増加体積',
    foundationResult: '基礎体積',
    foundationFormula: 'V = {0} × ({1} + {2}) × ({3} + {4}) = {5} m³',
    foundationStepFormula: 'V = {0} × {1} × ({2} + {3}) + {4} = {5} m³',
    foundationHint:
        '加算高さ方式：V = 壁厚 ×（基礎高さ + 加算高さ）×（外壁中心線 + 内壁内法）。図面にフーチング体積の記載がある場合はそちらを使います：V = 壁厚 × 基礎高さ ×（長さの和）+ フーチング体積。',
    specialSection: '特殊な壁',
    specialType: '壁の種類',
    typeHollow: '空斗磚壁',
    typeOpenwork: '透かし磚壁',
    typePerforated: '多孔磚壁',
    holeVolume: '空隙体積',
    specialResult: '壁体積',
    specialFormula: 'V = {0} × {1} × {2} = {3} m³',
    specialHoleFormula: 'V = {0} × {1} × {2} − {3} = {4} m³',
    specialHint:
        '空斗磚壁は外形体積で空隙を控除しません。透かし磚壁も透かし部分の外形体積で空隙を控除しません。多孔磚壁は図面寸法の体積から空隙を控除します。',
    note:
        'GB/T 50854-2024 の数量計算規則によります。標準磚の 240 壁は 0.24 m、120 壁は 0.115 m とし、実際は図面と地域の積算基準によります。',
  ),
  AppLanguage.es: MasonryStrings(
    tabWall: 'Muro de ladrillo',
    tabFoundation: 'Cimiento',
    tabSpecial: 'Muros especiales',
    wallSection: 'Muro de ladrillo',
    wallLength: 'Longitud del muro L',
    wallHeight: 'Altura del muro H',
    wallThickness: 'Espesor del muro t',
    openingArea: 'Área de huecos',
    concreteVolume: 'Volumen de elementos de hormigón',
    wallResult: 'Volumen del muro',
    wallFormula: 'V = ({0} × {1} − {2}) × {3} − {4} = {5} m³',
    wallHint:
        'V = (longitud × altura − huecos) × espesor − elementos de hormigón. Los muros exteriores se miden por su eje y los interiores por la longitud libre; la altura llega al alero fuera y al forjado dentro. No se descuentan huecos de hasta 0.3 m², pero sí zunchos, pilares y dinteles.',
    foundationSection: 'Cimiento de ladrillo',
    foundationMode: 'Método',
    modeAddedHeight: 'Altura añadida',
    modeStepVolume: 'Volumen de escalonado',
    foundationThickness: 'Espesor del muro t',
    foundationHeight: 'Altura del cimiento H',
    addedHeight: 'Altura añadida',
    centerlineLength: 'Longitud eje exterior',
    netLength: 'Longitud libre interior',
    stepVolume: 'Volumen del escalonado',
    foundationResult: 'Volumen del cimiento',
    foundationFormula: 'V = {0} × ({1} + {2}) × ({3} + {4}) = {5} m³',
    foundationStepFormula: 'V = {0} × {1} × ({2} + {3}) + {4} = {5} m³',
    foundationHint:
        'Método de altura añadida: V = espesor × (altura + altura añadida) × (eje exterior + longitud libre interior). Si el plano da el volumen del escalonado, úsalo: V = espesor × altura × (longitudes) + volumen del escalonado.',
    specialSection: 'Muros especiales',
    specialType: 'Tipo de muro',
    typeHollow: 'Muro de ladrillo hueco',
    typeOpenwork: 'Muro calado',
    typePerforated: 'Muro de ladrillo perforado',
    holeVolume: 'Volumen de huecos',
    specialResult: 'Volumen del muro',
    specialFormula: 'V = {0} × {1} × {2} = {3} m³',
    specialHoleFormula: 'V = {0} × {1} × {2} − {3} = {4} m³',
    specialHint:
        'Los muros de ladrillo hueco se miden por su volumen exterior sin descontar huecos; los muros calados, por el volumen exterior de la parte calada sin descontar huecos; los muros de ladrillo perforado, por el volumen de plano descontando los huecos.',
    note:
        'Medido con las reglas GB/T 50854-2024. Un muro estándar de 240 mm cuenta como 0.24 m y uno de 120 mm como 0.115 m; mandan los planos y la normativa local.',
  ),
};

/// 当前语言下的「砌筑工程」文案。
MasonryStrings get masonryStrings => toolText(kMasonryStrings);
