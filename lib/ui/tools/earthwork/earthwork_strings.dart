import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「土石方工程」页的文案：三个 tab（场地平整 / 基坑基槽开挖 / 管沟土方）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充；不要在这里拼句子，
/// 日语 / 西语的语序和中文不同。
class EarthworkStrings {
  const EarthworkStrings({
    required this.tabLeveling,
    required this.tabExcavation,
    required this.tabTrench,
    required this.levelingSection,
    required this.buildingLength,
    required this.buildingWidth,
    required this.levelingResult,
    required this.levelingFormula,
    required this.levelingHint,
    required this.excavationSection,
    required this.baseLength,
    required this.baseWidth,
    required this.workFace,
    required this.depth,
    required this.excavationResult,
    required this.excavationFormula,
    required this.excavationHint,
    required this.trenchSection,
    required this.pipeDiameter,
    required this.pipeLength,
    required this.trenchResult,
    required this.trenchFormula,
    required this.trenchHint,
    required this.note,
  });

  final String tabLeveling;
  final String tabExcavation;
  final String tabTrench;

  final String levelingSection;
  final String buildingLength;
  final String buildingWidth;
  final String levelingResult;

  /// 「S = {0} m × {1} m = {2} m²」。
  final String levelingFormula;
  final String levelingHint;

  final String excavationSection;
  final String baseLength;
  final String baseWidth;
  final String workFace;
  final String depth;
  final String excavationResult;

  /// 「V = ({0} m + 2 × {1} m) × ({2} m + 2 × {1} m) × {3} m = {4} m³」。
  final String excavationFormula;
  final String excavationHint;

  final String trenchSection;
  final String pipeDiameter;
  final String pipeLength;
  final String trenchResult;

  /// 「V = ({0} m + 2 × {1} m) × {2} m × {3} m = {4} m³」。
  final String trenchFormula;
  final String trenchHint;

  final String note;
}

/// 各语言的「土石方工程」文案。
const Map<AppLanguage, EarthworkStrings>
kEarthworkStrings = <AppLanguage, EarthworkStrings>{
  AppLanguage.zhHans: EarthworkStrings(
    tabLeveling: '场地平整',
    tabExcavation: '基坑基槽',
    tabTrench: '管沟土方',
    levelingSection: '场地平整',
    buildingLength: '首层外围长度 L',
    buildingWidth: '首层外围宽度 B',
    levelingResult: '平整面积',
    levelingFormula: 'S = {0} m × {1} m = {2} m²',
    levelingHint: 'S = 建筑物首层结构外围水平面积；只做 ±30 cm 以内的挖填找平，超过按挖土方计算。',
    excavationSection: '基坑 / 基槽开挖',
    baseLength: '垫层底长度 a',
    baseWidth: '垫层底宽度 b',
    workFace: '工作面 c',
    depth: '挖土深度 H',
    excavationResult: '开挖体积',
    excavationFormula:
        'V = ({0} m + 2 × {1} m) × ({2} m + 2 × {1} m) × {3} m = {4} m³',
    excavationHint:
        'V =（a + 2c）×（b + 2c）× H。a、b 是基础垫层底长宽，c 是工作面（清单默认 600 mm，图纸有规定按图纸）；清单不计算放坡量，放坡由投标人综合考虑。',
    trenchSection: '管沟土方',
    pipeDiameter: '管外径',
    pipeLength: '管沟长度 L',
    trenchResult: '管沟体积',
    trenchFormula: 'V = ({0} m + 2 × {1} m) × {2} m × {3} m = {4} m³',
    trenchHint:
        'V =（管外径 + 2c）× H × L，有垫层与无垫层用同一个式子（垫层外扩宽度并入工作面 c）；各类井的土方并入管沟计算。',
    note:
        '按《房屋建筑与装饰工程工程量计算规范》GB/T 50854-2024 清单规则计算，不含放坡与支护；实际结算以图纸、施工组织设计与当地定额为准。',
  ),
  AppLanguage.zhHant: EarthworkStrings(
    tabLeveling: '場地平整',
    tabExcavation: '基坑基槽',
    tabTrench: '管溝土方',
    levelingSection: '場地平整',
    buildingLength: '首層外圍長度 L',
    buildingWidth: '首層外圍寬度 B',
    levelingResult: '平整面積',
    levelingFormula: 'S = {0} m × {1} m = {2} m²',
    levelingHint: 'S = 建築物首層結構外圍水平面積；只做 ±30 cm 以內的挖填找平，超過按挖土方計算。',
    excavationSection: '基坑 / 基槽開挖',
    baseLength: '墊層底長度 a',
    baseWidth: '墊層底寬度 b',
    workFace: '工作面 c',
    depth: '挖土深度 H',
    excavationResult: '開挖體積',
    excavationFormula:
        'V = ({0} m + 2 × {1} m) × ({2} m + 2 × {1} m) × {3} m = {4} m³',
    excavationHint:
        'V =（a + 2c）×（b + 2c）× H。a、b 是基礎墊層底長寬，c 是工作面（清單預設 600 mm，圖紙有規定按圖紙）；清單不計算放坡量，放坡由投標人綜合考慮。',
    trenchSection: '管溝土方',
    pipeDiameter: '管外徑',
    pipeLength: '管溝長度 L',
    trenchResult: '管溝體積',
    trenchFormula: 'V = ({0} m + 2 × {1} m) × {2} m × {3} m = {4} m³',
    trenchHint:
        'V =（管外徑 + 2c）× H × L，有墊層與無墊層用同一個式子（墊層外擴寬度併入工作面 c）；各類井的土方併入管溝計算。',
    note:
        '按《房屋建築與裝飾工程工程量計算規範》GB/T 50854-2024 清單規則計算，不含放坡與支護；實際結算以圖紙、施工組織設計與當地定額為準。',
  ),
  AppLanguage.en: EarthworkStrings(
    tabLeveling: 'Site grading',
    tabExcavation: 'Pit / trench',
    tabTrench: 'Pipe trench',
    levelingSection: 'Site grading',
    buildingLength: 'Ground-floor outer length L',
    buildingWidth: 'Ground-floor outer width B',
    levelingResult: 'Grading area',
    levelingFormula: 'S = {0} m × {1} m = {2} m²',
    levelingHint:
        'S = outer horizontal area of the ground floor. Only cut and fill within ±30 cm counts; deeper work is measured as excavation.',
    excavationSection: 'Foundation pit / trench excavation',
    baseLength: 'Cushion bottom length a',
    baseWidth: 'Cushion bottom width b',
    workFace: 'Working space c',
    depth: 'Excavation depth H',
    excavationResult: 'Excavated volume',
    excavationFormula:
        'V = ({0} m + 2 × {1} m) × ({2} m + 2 × {1} m) × {3} m = {4} m³',
    excavationHint:
        'V = (a + 2c) × (b + 2c) × H, where a and b are the cushion bottom dimensions and c the working space (600 mm by default, drawings take precedence). Slopes are not measured under the bill-of-quantities rules; bidders allow for them.',
    trenchSection: 'Pipe trench earthwork',
    pipeDiameter: 'Pipe outer diameter',
    pipeLength: 'Trench length L',
    trenchResult: 'Trench volume',
    trenchFormula: 'V = ({0} m + 2 × {1} m) × {2} m × {3} m = {4} m³',
    trenchHint:
        'V = (outside diameter + 2c) × H × L, the same formula with or without a cushion (the cushion extension is folded into c). Earthwork of manholes and pits is added to the trench.',
    note:
        'Measured with the GB/T 50854-2024 bill-of-quantities rules, slopes and shoring excluded; drawings, method statements and local norms govern at settlement.',
  ),
  AppLanguage.ja: EarthworkStrings(
    tabLeveling: '敷地均し',
    tabExcavation: '掘削',
    tabTrench: '配管溝',
    levelingSection: '敷地均し',
    buildingLength: '1 階外周の長さ L',
    buildingWidth: '1 階外周の幅 B',
    levelingResult: '均し面積',
    levelingFormula: 'S = {0} m × {1} m = {2} m²',
    levelingHint: 'S = 1 階の構造外周水平面積。±30 cm 以内の切盛のみで、それ以上は掘削土量として算定します。',
    excavationSection: '基礎掘削（土坑・溝）',
    baseLength: '捨てコン底の長さ a',
    baseWidth: '捨てコン底の幅 b',
    workFace: '余掘り c',
    depth: '掘削深さ H',
    excavationResult: '掘削体積',
    excavationFormula:
        'V = ({0} m + 2 × {1} m) × ({2} m + 2 × {1} m) × {3} m = {4} m³',
    excavationHint:
        'V =（a + 2c）×（b + 2c）× H。a・b は基礎捨てコン底の寸法、c は余掘り（既定 600 mm、図面指定があれば図面優先）。数量表では法勾配分は算入せず、入札者が考慮します。',
    trenchSection: '配管溝の土工',
    pipeDiameter: '管の外径',
    pipeLength: '溝の長さ L',
    trenchResult: '溝の体積',
    trenchFormula: 'V = ({0} m + 2 × {1} m) × {2} m × {3} m = {4} m³',
    trenchHint:
        'V =（管外径 + 2c）× H × L。捨てコンあり・なしで同じ式（捨てコンの張り出しは c に含める）。マンホール等の土量は溝に算入します。',
    note:
        'GB/T 50854-2024 の数量計算規則による算定で、法勾配と山留めは含みません。精算は図面・施工計画・地域の積算基準によります。',
  ),
  AppLanguage.es: EarthworkStrings(
    tabLeveling: 'Nivelación',
    tabExcavation: 'Foso / zanja',
    tabTrench: 'Zanja de tubos',
    levelingSection: 'Nivelación del terreno',
    buildingLength: 'Longitud exterior planta baja L',
    buildingWidth: 'Ancho exterior planta baja B',
    levelingResult: 'Área nivelada',
    levelingFormula: 'S = {0} m × {1} m = {2} m²',
    levelingHint:
        'S = superficie horizontal exterior de la planta baja. Solo cuenta el desmonte y relleno dentro de ±30 cm; más profundidad se mide como excavación.',
    excavationSection: 'Excavación de foso / zanja',
    baseLength: 'Longitud base del solado a',
    baseWidth: 'Ancho base del solado b',
    workFace: 'Espacio de trabajo c',
    depth: 'Profundidad de excavación H',
    excavationResult: 'Volumen excavado',
    excavationFormula:
        'V = ({0} m + 2 × {1} m) × ({2} m + 2 × {1} m) × {3} m = {4} m³',
    excavationHint:
        'V = (a + 2c) × (b + 2c) × H, con a y b las dimensiones de la base del solado y c el espacio de trabajo (600 mm por defecto; manda el plano). La medición no incluye taludes; el licitador los considera.',
    trenchSection: 'Movimiento de tierras en zanja',
    pipeDiameter: 'Diámetro exterior del tubo',
    pipeLength: 'Longitud de la zanja L',
    trenchResult: 'Volumen de zanja',
    trenchFormula: 'V = ({0} m + 2 × {1} m) × {2} m × {3} m = {4} m³',
    trenchHint:
        'V = (diámetro exterior + 2c) × H × L, la misma fórmula con o sin solado (el ensanche del solado se suma a c). Las tierras de pozos y arquetas se añaden a la zanja.',
    note:
        'Medido con las reglas de medición GB/T 50854-2024, sin taludes ni entibación; en la liquidación mandan los planos, el estudio de ejecución y la normativa local.',
  ),
};

/// 当前语言下的「土石方工程」文案。
EarthworkStrings get earthworkStrings => toolText(kEarthworkStrings);
