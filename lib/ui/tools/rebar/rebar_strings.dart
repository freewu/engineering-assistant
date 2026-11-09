import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「钢筋工程」页的文案：三个 tab（直钢筋 / 箍筋 / 弯起钢筋）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充；不要在这里拼句子，
/// 日语 / 西语的语序和中文不同。长度一律以 mm 展示，质量以 kg 展示。
class RebarStrings {
  const RebarStrings({
    required this.tabStraight,
    required this.tabStirrup,
    required this.tabBent,
    required this.tabTable,
    required this.tableSection,
    required this.tableDiameter,
    required this.tableMass,
    required this.tableHint,
    required this.straightSection,
    required this.memberLength,
    required this.cover,
    required this.hookLength,
    required this.diameter,
    required this.count,
    required this.lengthResult,
    required this.massResult,
    required this.straightFormula,
    required this.straightHint,
    required this.stirrupSection,
    required this.sectionA,
    required this.sectionB,
    required this.stirrupFormula,
    required this.stirrupHint,
    required this.bentSection,
    required this.straightPart,
    required this.inclinedPart,
    required this.bendAdjustment,
    required this.bentFormula,
    required this.bentHint,
    required this.massFormula,
    required this.note,
  });

  final String tabStraight;
  final String tabStirrup;
  final String tabBent;

  /// 「速查表」tab：常用直径的理论质量（φ6 ~ φ32）。
  final String tabTable;
  final String tableSection;
  final String tableDiameter;
  final String tableMass;
  final String tableHint;

  final String straightSection;
  final String memberLength;
  final String cover;
  final String hookLength;
  final String diameter;
  final String count;

  final String lengthResult;
  final String massResult;

  /// 「L = {0} − 2 × {1} + 2 × {2} = {3} mm」（构件长度 / 保护层 / 弯钩 / 结果）。
  final String straightFormula;
  final String straightHint;

  final String stirrupSection;
  final String sectionA;
  final String sectionB;

  /// 「L = 2 × ({0} + {1}) − 8 × {2} + 2 × 11.9 × {3} = {4} mm」。
  final String stirrupFormula;
  final String stirrupHint;

  final String bentSection;
  final String straightPart;
  final String inclinedPart;
  final String bendAdjustment;

  /// 「L = {0} + {1} − {2} + {3} = {4} mm」。
  final String bentFormula;
  final String bentHint;

  /// 「W = {0} × {1} × 0.00617 × {2}² = {3} kg」（根数 / 长度 m / 直径 / 结果）。
  final String massFormula;

  final String note;
}

/// 各语言的「钢筋工程」文案。
const Map<AppLanguage, RebarStrings>
kRebarStrings = <AppLanguage, RebarStrings>{
  AppLanguage.zhHans: RebarStrings(
    tabStraight: '直钢筋',
    tabStirrup: '箍筋',
    tabBent: '弯起钢筋',
    tabTable: '速查表',
    tableSection: '常用钢筋理论质量',
    tableDiameter: '直径 d',
    tableMass: '理论质量',
    tableHint:
        'W = 0.00617 × d²（kg/m）；φ6 ~ φ32 是常用规格，其它直径代入同一个式子即可。表中的数值按规范取整，与公式只差四舍五入。',
    straightSection: '直钢筋',
    memberLength: '构件长度 l',
    cover: '保护层 c',
    hookLength: '单端弯钩长度',
    diameter: '钢筋直径 d',
    count: '根数 n',
    lengthResult: '中心线长度 L',
    massResult: '钢筋质量 W',
    straightFormula: 'L = {0} − 2 × {1} + 2 × {2} = {3} mm',
    straightHint:
        'L = 构件长度 − 2 × 保护层 + 2 × 弯钩长度；保护层梁 25 mm、板 20 mm、柱 30 mm（设计有规定按设计），180° 弯钩平直段常取 6.25d。',
    stirrupSection: '抗震箍筋',
    sectionA: '构件截面 a',
    sectionB: '构件截面 b',
    stirrupFormula: 'L = 2 × ({0} + {1}) − 8 × {2} + 2 × 11.9 × {3} = {4} mm',
    stirrupHint:
        'L = 2 ×（a + b）− 8 × 保护层 + 2 × 11.9d，135° 弯钩平直段按 11.9d 计；a、b 取箍筋外皮对应的构件截面尺寸。',
    bentSection: '弯起钢筋',
    straightPart: '直段长',
    inclinedPart: '斜段长',
    bendAdjustment: '弯曲调整值',
    bentFormula: 'L = {0} + {1} − {2} + {3} = {4} mm',
    bentHint: 'L = 直段长 + 斜段长 − 弯曲调整值 + 弯钩长；量度差值按弯折角度取 0.35d ~ 2d（90° 取 2d）。',
    massFormula: 'W = {0} × {1} × 0.00617 × {2}² = {3} kg',
    note:
        '按 GB/T 50854-2024 清单规则，以设计图示钢筋中心线长度 × 单位理论质量计算；只计设计标明的搭接与锚固长度，施工搭接（定尺搭接等）不计，已含在综合单价里。',
  ),
  AppLanguage.zhHant: RebarStrings(
    tabStraight: '直鋼筋',
    tabStirrup: '箍筋',
    tabBent: '彎起鋼筋',
    tabTable: '速查表',
    tableSection: '常用鋼筋理論質量',
    tableDiameter: '直徑 d',
    tableMass: '理論質量',
    tableHint:
        'W = 0.00617 × d²（kg/m）；φ6 ~ φ32 是常用規格，其它直徑代入同一個式子即可。表中的數值按規範取整，與公式只差四捨五入。',
    straightSection: '直鋼筋',
    memberLength: '構件長度 l',
    cover: '保護層 c',
    hookLength: '單端彎鉤長度',
    diameter: '鋼筋直徑 d',
    count: '根數 n',
    lengthResult: '中心線長度 L',
    massResult: '鋼筋質量 W',
    straightFormula: 'L = {0} − 2 × {1} + 2 × {2} = {3} mm',
    straightHint:
        'L = 構件長度 − 2 × 保護層 + 2 × 彎鉤長度；保護層梁 25 mm、板 20 mm、柱 30 mm（設計有規定按設計），180° 彎鉤平直段常取 6.25d。',
    stirrupSection: '抗震箍筋',
    sectionA: '構件截面 a',
    sectionB: '構件截面 b',
    stirrupFormula: 'L = 2 × ({0} + {1}) − 8 × {2} + 2 × 11.9 × {3} = {4} mm',
    stirrupHint:
        'L = 2 ×（a + b）− 8 × 保護層 + 2 × 11.9d，135° 彎鉤平直段按 11.9d 計；a、b 取箍筋外皮對應的構件截面尺寸。',
    bentSection: '彎起鋼筋',
    straightPart: '直段長',
    inclinedPart: '斜段長',
    bendAdjustment: '彎曲調整值',
    bentFormula: 'L = {0} + {1} − {2} + {3} = {4} mm',
    bentHint: 'L = 直段長 + 斜段長 − 彎曲調整值 + 彎鉤長；量度差值按彎折角度取 0.35d ~ 2d（90° 取 2d）。',
    massFormula: 'W = {0} × {1} × 0.00617 × {2}² = {3} kg',
    note:
        '按 GB/T 50854-2024 清單規則，以設計圖示鋼筋中心線長度 × 單位理論質量計算；只計設計標明的搭接與錨固長度，施工搭接（定尺搭接等）不計，已含於綜合單價。',
  ),
  AppLanguage.en: RebarStrings(
    tabStraight: 'Straight bar',
    tabStirrup: 'Stirrup',
    tabBent: 'Bent-up bar',
    tabTable: 'Table',
    tableSection: 'Theoretical mass of common bars',
    tableDiameter: 'Diameter d',
    tableMass: 'Mass per metre',
    tableHint:
        'W = 0.00617 × d² (kg/m). φ6 to φ32 are the common sizes; any other diameter goes into the same formula. Table values are the rounded standard ones.',
    straightSection: 'Straight bar',
    memberLength: 'Member length l',
    cover: 'Concrete cover c',
    hookLength: 'Hook length (one end)',
    diameter: 'Bar diameter d',
    count: 'Number of bars n',
    lengthResult: 'Centre-line length L',
    massResult: 'Bar mass W',
    straightFormula: 'L = {0} − 2 × {1} + 2 × {2} = {3} mm',
    straightHint:
        'L = member length − 2 × cover + 2 × hook. Cover is 25 mm for beams, 20 mm for slabs, 30 mm for columns unless the drawings say otherwise; a 180° hook takes about 6.25d.',
    stirrupSection: 'Seismic stirrup',
    sectionA: 'Section a',
    sectionB: 'Section b',
    stirrupFormula: 'L = 2 × ({0} + {1}) − 8 × {2} + 2 × 11.9 × {3} = {4} mm',
    stirrupHint:
        'L = 2 × (a + b) − 8 × cover + 2 × 11.9d for 135° hooks; a and b are the member section measured to the outside of the stirrup.',
    bentSection: 'Bent-up bar',
    straightPart: 'Straight part',
    inclinedPart: 'Inclined part',
    bendAdjustment: 'Bend deduction',
    bentFormula: 'L = {0} + {1} − {2} + {3} = {4} mm',
    bentHint:
        'L = straight part + inclined part − bend deduction + hook. The deduction is 0.35d to 2d depending on the bend angle (2d for 90°).',
    massFormula: 'W = {0} × {1} × 0.00617 × {2}² = {3} kg',
    note:
        'Measured with GB/T 50854-2024: centre-line length × theoretical unit mass. Only laps and anchorages shown on the drawings count; construction laps are excluded and covered by the unit rate.',
  ),
  AppLanguage.ja: RebarStrings(
    tabStraight: '直筋',
    tabStirrup: '帯筋',
    tabBent: '折曲げ筋',
    tabTable: '早見表',
    tableSection: '常用鉄筋の理論質量',
    tableDiameter: '径 d',
    tableMass: '理論質量',
    tableHint:
        'W = 0.00617 × d²（kg/m）。表は φ6〜φ32 の常用サイズで、他の径も同じ式で求められます。表の値は規格の丸め値です。',
    straightSection: '直筋',
    memberLength: '部材長さ l',
    cover: 'かぶり厚 c',
    hookLength: '片端のフック長',
    diameter: '鉄筋径 d',
    count: '本数 n',
    lengthResult: '中心線長さ L',
    massResult: '鉄筋質量 W',
    straightFormula: 'L = {0} − 2 × {1} + 2 × {2} = {3} mm',
    straightHint:
        'L = 部材長さ − 2 × かぶり厚 + 2 × フック長。かぶり厚は梁 25 mm・スラブ 20 mm・柱 30 mm（図面指定があれば図面優先）、180° フックの定着は通常 6.25d。',
    stirrupSection: '耐震帯筋',
    sectionA: '断面 a',
    sectionB: '断面 b',
    stirrupFormula: 'L = 2 × ({0} + {1}) − 8 × {2} + 2 × 11.9 × {3} = {4} mm',
    stirrupHint:
        'L = 2 ×（a + b）− 8 × かぶり厚 + 2 × 11.9d。135° フックの余長を 11.9d として算定し、a・b は帯筋の外側で測った断面寸法。',
    bentSection: '折曲げ筋',
    straightPart: '直線部',
    inclinedPart: '斜め部',
    bendAdjustment: '折曲げ補正値',
    bentFormula: 'L = {0} + {1} − {2} + {3} = {4} mm',
    bentHint: 'L = 直線部 + 斜め部 − 折曲げ補正値 + フック長。補正値は折曲げ角度により 0.35d〜2d（90° は 2d）。',
    massFormula: 'W = {0} × {1} × 0.00617 × {2}² = {3} kg',
    note:
        'GB/T 50854-2024 の数量規則により、設計図の中心線長さ × 単位理論質量で算定。図示された重ね継手と定着長さのみを算入し、施工上の重ね継手は含めません（単価に含む）。',
  ),
  AppLanguage.es: RebarStrings(
    tabStraight: 'Barra recta',
    tabStirrup: 'Estribo',
    tabBent: 'Barra doblada',
    tabTable: 'Tabla',
    tableSection: 'Masa teórica de barras comunes',
    tableDiameter: 'Diámetro d',
    tableMass: 'Masa por metro',
    tableHint:
        'W = 0.00617 × d² (kg/m). φ6 a φ32 son los calibres habituales; cualquier otro diámetro usa la misma fórmula. Los valores de la tabla son los redondeados de norma.',
    straightSection: 'Barra recta',
    memberLength: 'Longitud del elemento l',
    cover: 'Recubrimiento c',
    hookLength: 'Longitud del gancho (un extremo)',
    diameter: 'Diámetro de barra d',
    count: 'Número de barras n',
    lengthResult: 'Longitud en eje L',
    massResult: 'Masa de acero W',
    straightFormula: 'L = {0} − 2 × {1} + 2 × {2} = {3} mm',
    straightHint:
        'L = longitud del elemento − 2 × recubrimiento + 2 × gancho. Recubrimiento: 25 mm en vigas, 20 mm en losas, 30 mm en pilares (manda el plano); el gancho de 180° suele tomar 6.25d.',
    stirrupSection: 'Estribo antisísmico',
    sectionA: 'Sección a',
    sectionB: 'Sección b',
    stirrupFormula: 'L = 2 × ({0} + {1}) − 8 × {2} + 2 × 11.9 × {3} = {4} mm',
    stirrupHint:
        'L = 2 × (a + b) − 8 × recubrimiento + 2 × 11.9d para ganchos de 135°; a y b son la sección medida al exterior del estribo.',
    bentSection: 'Barra doblada',
    straightPart: 'Tramo recto',
    inclinedPart: 'Tramo inclinado',
    bendAdjustment: 'Corrección por doblez',
    bentFormula: 'L = {0} + {1} − {2} + {3} = {4} mm',
    bentHint:
        'L = tramo recto + tramo inclinado − corrección por doblez + gancho. La corrección va de 0.35d a 2d según el ángulo (2d para 90°).',
    massFormula: 'W = {0} × {1} × 0.00617 × {2}² = {3} kg',
    note:
        'Medido con GB/T 50854-2024: longitud en eje × masa teórica unitaria. Solo cuentan los solapes y anclajes indicados en el plano; los solapes de ejecución quedan en el precio unitario.',
  ),
};

/// 当前语言下的「钢筋工程」文案。
RebarStrings get rebarStrings => toolText(kRebarStrings);
