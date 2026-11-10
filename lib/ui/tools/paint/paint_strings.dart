import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「油漆涂料」页的文案：三个 tab（墙面 / 天棚 / 门窗）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充：
/// 面积算式 3~4 个参数、用量算式 4 个参数、桶数算式 3 个参数。
class PaintStrings {
  const PaintStrings({
    required this.tabWall,
    required this.tabCeiling,
    required this.tabJoinery,
    required this.coats,
    required this.coatUnit,
    required this.consumption,
    required this.consumptionUnit,
    required this.canWeight,
    required this.canUnit,
    required this.areaResult,
    required this.usageResult,
    required this.cansResult,
    required this.usageFormula,
    required this.cansFormula,
    required this.wallSection,
    required this.wallLength,
    required this.wallHeight,
    required this.openingArea,
    required this.wallAreaFormula,
    required this.wallHint,
    required this.ceilingSection,
    required this.netArea,
    required this.beamSideArea,
    required this.ceilingAreaFormula,
    required this.ceilingHint,
    required this.joinerySection,
    required this.unitCount,
    required this.countUnit,
    required this.areaPerUnit,
    required this.unfoldFactor,
    required this.joineryAreaFormula,
    required this.joineryHint,
    required this.note,
  });

  final String tabWall;
  final String tabCeiling;
  final String tabJoinery;

  /// 三个 tab 共用的「遍数 / 单耗 / 每桶净重」标签与单位。
  final String coats;
  final String coatUnit;
  final String consumption;
  final String consumptionUnit;

  /// 「每桶净重」的标签与桶的单位（结果「折合桶数」也用它）。
  final String canWeight;
  final String canUnit;

  final String areaResult;
  final String usageResult;
  final String cansResult;

  /// 「G = {0} m² × {1} 遍 × {2} kg/(㎡·遍) = {3} kg」。
  final String usageFormula;

  /// 「N = ⌈{0} kg ÷ {1} kg/桶⌉ = {2} 桶」。
  final String cansFormula;

  final String wallSection;
  final String wallLength;
  final String wallHeight;
  final String openingArea;

  /// 「S = {0} × {1} − {2} = {3} m²」。
  final String wallAreaFormula;
  final String wallHint;

  final String ceilingSection;
  final String netArea;
  final String beamSideArea;

  /// 「S = {0} + {1} = {2} m²」。
  final String ceilingAreaFormula;
  final String ceilingHint;

  final String joinerySection;
  final String unitCount;

  /// 「樘数」输入框的后缀单位。
  final String countUnit;
  final String areaPerUnit;
  final String unfoldFactor;

  /// 「S = {0} × {1} × {2} = {3} m²」。
  final String joineryAreaFormula;
  final String joineryHint;

  final String note;
}

/// 各语言的「油漆涂料」文案。
const Map<AppLanguage, PaintStrings>
kPaintStrings = <AppLanguage, PaintStrings>{
  AppLanguage.zhHans: PaintStrings(
    tabWall: '墙面',
    tabCeiling: '天棚',
    tabJoinery: '门窗',
    coats: '遍数',
    coatUnit: '遍',
    consumption: '单遍单耗',
    consumptionUnit: 'kg/(㎡·遍)',
    canWeight: '每桶净重',
    canUnit: '桶',
    areaResult: '涂刷面积',
    usageResult: '涂料用量',
    cansResult: '折合桶数',
    usageFormula: 'G = {0} m² × {1} 遍 × {2} kg/(㎡·遍) = {3} kg',
    cansFormula: 'N = ⌈{0} kg ÷ {1} kg/桶⌉ = {2} 桶',
    wallSection: '墙面涂料',
    wallLength: '墙长 L',
    wallHeight: '墙高 H',
    openingArea: '门窗洞口面积',
    wallAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    wallHint: 'S = 墙长 × 墙高 − 门窗洞口面积；单个 ≤ 0.3 ㎡ 的洞口不扣，栏杆、扶手等按展开面积另计。',
    ceilingSection: '天棚涂料',
    netArea: '主墙间净面积',
    beamSideArea: '梁侧面面积',
    ceilingAreaFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint: 'S = 主墙间净面积 + 梁侧面面积；不扣单个 ≤ 0.3 ㎡ 的孔洞。',
    joinerySection: '门窗油漆',
    unitCount: '樘数',
    countUnit: '樘',
    areaPerUnit: '每樘洞口面积',
    unfoldFactor: '展开系数',
    joineryAreaFormula: 'S = {0} × {1} × {2} = {3} m²',
    joineryHint: 'S = 樘数 × 每樘洞口面积 × 展开系数；单层木门窗取 1.0，双层取 2.0，钢门窗按框外围面积。',
    note:
        '按 GB/T 50854-2024 清单规则算涂刷面积，单耗按涂料说明书取（内墙乳胶漆两遍约 0.2 ~ 0.3 kg/(㎡·遍)）。'
        '桶数是向上取整的估算，实际备料建议留 5% ~ 10% 余量。',
  ),
  AppLanguage.zhHant: PaintStrings(
    tabWall: '牆面',
    tabCeiling: '天棚',
    tabJoinery: '門窗',
    coats: '遍數',
    coatUnit: '遍',
    consumption: '單遍單耗',
    consumptionUnit: 'kg/(㎡·遍)',
    canWeight: '每桶淨重',
    canUnit: '桶',
    areaResult: '塗刷面積',
    usageResult: '塗料用量',
    cansResult: '折合桶數',
    usageFormula: 'G = {0} m² × {1} 遍 × {2} kg/(㎡·遍) = {3} kg',
    cansFormula: 'N = ⌈{0} kg ÷ {1} kg/桶⌉ = {2} 桶',
    wallSection: '牆面塗料',
    wallLength: '牆長 L',
    wallHeight: '牆高 H',
    openingArea: '門窗洞口面積',
    wallAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    wallHint: 'S = 牆長 × 牆高 − 門窗洞口面積；單個 ≤ 0.3 ㎡ 的洞口不扣，欄杆、扶手等按展開面積另計。',
    ceilingSection: '天棚塗料',
    netArea: '主牆間淨面積',
    beamSideArea: '樑側面面積',
    ceilingAreaFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint: 'S = 主牆間淨面積 + 樑側面面積；不扣單個 ≤ 0.3 ㎡ 的孔洞。',
    joinerySection: '門窗油漆',
    unitCount: '樘數',
    countUnit: '樘',
    areaPerUnit: '每樘洞口面積',
    unfoldFactor: '展開係數',
    joineryAreaFormula: 'S = {0} × {1} × {2} = {3} m²',
    joineryHint: 'S = 樘數 × 每樘洞口面積 × 展開係數；單層木門窗取 1.0，雙層取 2.0，鋼門窗按框外圍面積。',
    note:
        '按 GB/T 50854-2024 清單規則算塗刷面積，單耗按塗料說明書取（內牆乳膠漆兩遍約 0.2 ~ 0.3 kg/(㎡·遍)）。'
        '桶數是向上取整的估算，實際備料建議留 5% ~ 10% 餘量。',
  ),
  AppLanguage.en: PaintStrings(
    tabWall: 'Wall',
    tabCeiling: 'Ceiling',
    tabJoinery: 'Doors & windows',
    coats: 'Coats',
    coatUnit: 'coats',
    consumption: 'Consumption per coat',
    consumptionUnit: 'kg/(m²·coat)',
    canWeight: 'Net weight per can',
    canUnit: 'cans',
    areaResult: 'Paint area',
    usageResult: 'Paint required',
    cansResult: 'Cans (rounded up)',
    usageFormula: 'G = {0} m² × {1} coats × {2} kg/(m²·coat) = {3} kg',
    cansFormula: 'N = ⌈{0} kg ÷ {1} kg/can⌉ = {2} cans',
    wallSection: 'Wall paint',
    wallLength: 'Wall length L',
    wallHeight: 'Wall height H',
    openingArea: 'Opening area',
    wallAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    wallHint:
        'S = length × height − openings. Openings up to 0.3 m² are not deducted; railings and handrails are measured by their unfolded area.',
    ceilingSection: 'Ceiling paint',
    netArea: 'Net area between walls',
    beamSideArea: 'Beam side area',
    ceilingAreaFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint:
        'S = net area + beam sides. Openings up to 0.3 m² are not deducted.',
    joinerySection: 'Joinery paint',
    unitCount: 'Number of units',
    countUnit: 'pcs',
    areaPerUnit: 'Opening area per unit',
    unfoldFactor: 'Unfold factor',
    joineryAreaFormula: 'S = {0} × {1} × {2} = {3} m²',
    joineryHint:
        'S = units × opening area × unfold factor. Use 1.0 for single-layer wood joinery, 2.0 for double-layer, and the frame area for steel doors and windows.',
    note:
        'Areas follow the GB/T 50854-2024 bill-of-quantities rules and the consumption comes from the data sheet (interior emulsion, two coats: about 0.2–0.3 kg/(m²·coat)). Cans are rounded up, so allow 5–10% extra when ordering.',
  ),
  AppLanguage.ja: PaintStrings(
    tabWall: '壁',
    tabCeiling: '天井',
    tabJoinery: '建具',
    coats: '塗り回数',
    coatUnit: '回',
    consumption: '1 回あたり使用量',
    consumptionUnit: 'kg/(㎡·回)',
    canWeight: '1 缶の正味量',
    canUnit: '缶',
    areaResult: '塗装面積',
    usageResult: '塗料使用量',
    cansResult: '必要缶数',
    usageFormula: 'G = {0} m² × {1} 回 × {2} kg/(㎡·回) = {3} kg',
    cansFormula: 'N = ⌈{0} kg ÷ {1} kg/缶⌉ = {2} 缶',
    wallSection: '壁の塗装',
    wallLength: '壁長さ L',
    wallHeight: '壁高さ H',
    openingArea: '開口部面積',
    wallAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    wallHint: 'S = 壁長さ × 壁高さ − 開口部面積。0.3 ㎡ 以下の開口は控除せず、手すりなどは展開面積で別途計上します。',
    ceilingSection: '天井の塗装',
    netArea: '壁間の正味面積',
    beamSideArea: '梁の側面面積',
    ceilingAreaFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint: 'S = 壁間の正味面積 + 梁の側面面積。0.3 ㎡ 以下の開口は控除しません。',
    joinerySection: '建具の塗装',
    unitCount: '数量',
    countUnit: 'か所',
    areaPerUnit: '1 か所の開口面積',
    unfoldFactor: '展開係数',
    joineryAreaFormula: 'S = {0} × {1} × {2} = {3} m²',
    joineryHint: 'S = 数量 × 開口面積 × 展開係数。単層の木製建具は 1.0、二重は 2.0、鋼製建具は枠の外周面積で計ります。',
    note:
        'GB/T 50854-2024 の数量計算規則で塗装面積を求め、使用量は塗料の仕様書の値によります（内装用エマルション、2 回塗りで約 0.2 ~ 0.3 kg/(㎡·回)）。'
        '缶数は切り上げの概算なので、発注時は 5 ~ 10% の余裕を見てください。',
  ),
  AppLanguage.es: PaintStrings(
    tabWall: 'Muro',
    tabCeiling: 'Techo',
    tabJoinery: 'Carpintería',
    coats: 'Manos',
    coatUnit: 'manos',
    consumption: 'Consumo por mano',
    consumptionUnit: 'kg/(m²·mano)',
    canWeight: 'Peso neto por cubeta',
    canUnit: 'cubetas',
    areaResult: 'Superficie a pintar',
    usageResult: 'Pintura necesaria',
    cansResult: 'Cubetas necesarias',
    usageFormula: 'G = {0} m² × {1} manos × {2} kg/(m²·mano) = {3} kg',
    cansFormula: 'N = ⌈{0} kg ÷ {1} kg por cubeta⌉ = {2} cubetas',
    wallSection: 'Pintura de muros',
    wallLength: 'Longitud del muro L',
    wallHeight: 'Altura del muro H',
    openingArea: 'Área de huecos',
    wallAreaFormula: 'S = {0} × {1} − {2} = {3} m²',
    wallHint:
        'S = longitud × altura − huecos. Los huecos de hasta 0.3 m² no se descuentan; barandillas y pasamanos se miden por su superficie desplegada.',
    ceilingSection: 'Pintura de techos',
    netArea: 'Superficie neta entre muros',
    beamSideArea: 'Caras laterales de vigas',
    ceilingAreaFormula: 'S = {0} + {1} = {2} m²',
    ceilingHint:
        'S = superficie neta + caras laterales de vigas. Los huecos de hasta 0.3 m² no se descuentan.',
    joinerySection: 'Pintura de carpintería',
    unitCount: 'Número de unidades',
    countUnit: 'ud.',
    areaPerUnit: 'Área del hueco por unidad',
    unfoldFactor: 'Coeficiente de despiece',
    joineryAreaFormula: 'S = {0} × {1} × {2} = {3} m²',
    joineryHint:
        'S = unidades × área del hueco × coeficiente de despiece. Use 1.0 para carpintería de madera de una hoja, 2.0 para doble, y el área del marco para puertas y ventanas de acero.',
    note:
        'Las superficies siguen las reglas GB/T 50854-2024 y el consumo se toma de la ficha técnica (pintura plástica interior, dos manos: unos 0.2–0.3 kg/(m²·mano)). Las cubetas se redondean hacia arriba; pida un 5–10% de margen.',
  ),
};

/// 当前语言下的「油漆涂料」文案。
PaintStrings get paintStrings => toolText(kPaintStrings);
