import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'material.dart';

/// 「材料用量」页的文案：四个 tab（砖块 / 混凝土 / 水泥 / 砂子）各一套。
///
/// 带参数的话术一律写成 `{0}` / `{1}` 模板，用 `fill()` 填充，页面里不拼句子。
class MaterialStrings {
  const MaterialStrings({
    required this.tabBricks,
    required this.tabConcrete,
    required this.tabCement,
    required this.tabSand,
    required this.bricksSection,
    required this.volume,
    required this.brickType,
    required this.brickStandard,
    required this.brickPerforated,
    required this.brickResult,
    required this.brickFormula,
    required this.wallSection,
    required this.wallNames,
    required this.concreteSection,
    required this.area,
    required this.thickness,
    required this.concreteResult,
    required this.concreteFormula,
    required this.concreteHint,
    required this.cementSection,
    required this.buildingArea,
    required this.cementRate,
    required this.cementResult,
    required this.cementFormula,
    required this.cementHint,
    required this.sandSection,
    required this.sandResult,
    required this.sandFormula,
    required this.sandHint,
    required this.pieceUnit,
    required this.cubicMeterUnit,
    required this.tonUnit,
    required this.note,
  });

  final String tabBricks;
  final String tabConcrete;
  final String tabCement;
  final String tabSand;

  final String bricksSection;
  final String volume;
  final String brickType;
  final String brickStandard;
  final String brickPerforated;
  final String brickResult;

  /// 「砖数 = {0} m³ × {1} = {2} 块」。
  final String brickFormula;

  /// 「每平方米砖数校核」，下面按墙厚列出 64 / 128 / 192 块。
  final String wallSection;

  /// 墙厚档位名称，键是 `WallThickness.name`（thin / standard / thick）。
  final Map<String, String> wallNames;

  final String concreteSection;
  final String area;
  final String thickness;
  final String concreteResult;

  /// 「混凝土 = {0} ㎡ × {1} m = {2} m³」。
  final String concreteFormula;
  final String concreteHint;

  final String cementSection;
  final String buildingArea;
  final String cementRate;
  final String cementResult;

  /// 「水泥 = {0} ㎡ × {1} = {2} 吨」。
  final String cementFormula;
  final String cementHint;

  final String sandSection;
  final String sandResult;

  /// 「砂子 = {0} ㎡ × 0.05 = {1} m³」。
  final String sandFormula;
  final String sandHint;

  final String pieceUnit;
  final String cubicMeterUnit;
  final String tonUnit;

  /// 页脚提示：经验估算值，正式下料以图纸与配合比为准。
  final String note;

  /// 墙厚档位的名称（12 墙 / 24 墙 / 37 墙）。
  String wallName(WallThickness wall) =>
      wallNames[wall.name] ?? '${wall.millimeters} mm';
}

/// 各语言的「材料用量」文案。
const Map<AppLanguage, MaterialStrings>
kMaterialStrings = <AppLanguage, MaterialStrings>{
  AppLanguage.zhHans: MaterialStrings(
    tabBricks: '砖块',
    tabConcrete: '混凝土',
    tabCement: '水泥',
    tabSand: '砂子',
    bricksSection: '墙体体积',
    volume: '墙体体积',
    brickType: '砖型',
    brickStandard: '标准红砖（512 块/m³）',
    brickPerforated: '多孔砖（320 块/m³）',
    brickResult: '砖块数量',
    brickFormula: '砖数 = {0} m³ × {1} = {2} 块',
    wallSection: '每平方米砖数校核',
    wallNames: <String, String>{
      'thin': '12 墙（120 mm）',
      'standard': '24 墙（240 mm）',
      'thick': '37 墙（370 mm）',
    },
    concreteSection: '浇筑部位',
    area: '面积',
    thickness: '厚度',
    concreteResult: '混凝土用量',
    concreteFormula: '混凝土 = {0} ㎡ × {1} m = {2} m³',
    concreteHint: '基础垫层常用 0.1 m，楼板常用 0.10 ~ 0.15 m。',
    cementSection: '建筑面积',
    buildingArea: '建筑面积',
    cementRate: '单耗',
    cementResult: '水泥用量',
    cementFormula: '水泥 = {0} ㎡ × {1} = {2} 吨',
    cementHint: '单耗按经验取 0.03 ~ 0.05 吨/㎡，框架结构取低值、砖混取高值。',
    sandSection: '建筑面积',
    sandResult: '砂子用量',
    sandFormula: '砂子 = {0} ㎡ × 0.05 = {1} m³',
    sandHint: '按建筑面积每平方米约 0.05 m³ 估算。',
    pieceUnit: '块',
    cubicMeterUnit: 'm³',
    tonUnit: '吨',
    note: '以上为经验估算值，正式下料以图纸、配合比与当地定额为准。',
  ),
  AppLanguage.zhHant: MaterialStrings(
    tabBricks: '磚塊',
    tabConcrete: '混凝土',
    tabCement: '水泥',
    tabSand: '砂子',
    bricksSection: '牆體體積',
    volume: '牆體體積',
    brickType: '磚型',
    brickStandard: '標準紅磚（512 塊/m³）',
    brickPerforated: '多孔磚（320 塊/m³）',
    brickResult: '磚塊數量',
    brickFormula: '磚數 = {0} m³ × {1} = {2} 塊',
    wallSection: '每平方公尺磚數校核',
    wallNames: <String, String>{
      'thin': '12 牆（120 mm）',
      'standard': '24 牆（240 mm）',
      'thick': '37 牆（370 mm）',
    },
    concreteSection: '澆築部位',
    area: '面積',
    thickness: '厚度',
    concreteResult: '混凝土用量',
    concreteFormula: '混凝土 = {0} ㎡ × {1} m = {2} m³',
    concreteHint: '基礎墊層常用 0.1 m，樓板常用 0.10 ~ 0.15 m。',
    cementSection: '建築面積',
    buildingArea: '建築面積',
    cementRate: '單耗',
    cementResult: '水泥用量',
    cementFormula: '水泥 = {0} ㎡ × {1} = {2} 噸',
    cementHint: '單耗按經驗取 0.03 ~ 0.05 噸/㎡，框架結構取低值、磚混取高值。',
    sandSection: '建築面積',
    sandResult: '砂子用量',
    sandFormula: '砂子 = {0} ㎡ × 0.05 = {1} m³',
    sandHint: '按建築面積每平方公尺約 0.05 m³ 估算。',
    pieceUnit: '塊',
    cubicMeterUnit: 'm³',
    tonUnit: '噸',
    note: '以上為經驗估算值，正式下料以圖紙、配合比與當地定額為準。',
  ),
  AppLanguage.en: MaterialStrings(
    tabBricks: 'Bricks',
    tabConcrete: 'Concrete',
    tabCement: 'Cement',
    tabSand: 'Sand',
    bricksSection: 'Wall volume',
    volume: 'Wall volume',
    brickType: 'Brick type',
    brickStandard: 'Standard red brick (512 per m³)',
    brickPerforated: 'Perforated brick (320 per m³)',
    brickResult: 'Bricks needed',
    brickFormula: 'bricks = {0} m³ × {1} = {2} pcs',
    wallSection: 'Check per square metre',
    wallNames: <String, String>{
      'thin': '120 mm wall',
      'standard': '240 mm wall',
      'thick': '370 mm wall',
    },
    concreteSection: 'Pour location',
    area: 'Area',
    thickness: 'Thickness',
    concreteResult: 'Concrete volume',
    concreteFormula: 'concrete = {0} m² × {1} m = {2} m³',
    concreteHint: 'Cushions are usually 0.1 m; slabs 0.10–0.15 m.',
    cementSection: 'Floor area',
    buildingArea: 'Floor area',
    cementRate: 'Rate',
    cementResult: 'Cement needed',
    cementFormula: 'cement = {0} m² × {1} = {2} t',
    cementHint:
        'Typical 0.03–0.05 t per m²; use the low end for frames, the high end for brick-concrete.',
    sandSection: 'Floor area',
    sandResult: 'Sand needed',
    sandFormula: 'sand = {0} m² × 0.05 = {1} m³',
    sandHint: 'Roughly 0.05 m³ per m² of floor area.',
    pieceUnit: 'pcs',
    cubicMeterUnit: 'm³',
    tonUnit: 't',
    note:
        'Empirical estimates only; take quantities from drawings and mix designs for actual work.',
  ),
  AppLanguage.ja: MaterialStrings(
    tabBricks: 'レンガ',
    tabConcrete: 'コンクリート',
    tabCement: 'セメント',
    tabSand: '砂',
    bricksSection: '壁の体積',
    volume: '壁の体積',
    brickType: 'レンガの種類',
    brickStandard: '標準赤レンガ（512 個/m³）',
    brickPerforated: '多孔レンガ（320 個/m³）',
    brickResult: 'レンガの必要数',
    brickFormula: 'レンガ = {0} m³ × {1} = {2} 個',
    wallSection: '1 ㎡あたりの個数で確認',
    wallNames: <String, String>{
      'thin': '120 mm 壁',
      'standard': '240 mm 壁',
      'thick': '370 mm 壁',
    },
    concreteSection: '打設部位',
    area: '面積',
    thickness: '厚さ',
    concreteResult: 'コンクリート量',
    concreteFormula: 'コンクリート = {0} ㎡ × {1} m = {2} m³',
    concreteHint: '基礎捨てコンは 0.1 m、スラブは 0.10〜0.15 m が一般的です。',
    cementSection: '延べ床面積',
    buildingArea: '延べ床面積',
    cementRate: '原単位',
    cementResult: 'セメント量',
    cementFormula: 'セメント = {0} ㎡ × {1} = {2} t',
    cementHint: '原単位は 0.03〜0.05 t/㎡。ラーメン構造は低め、組積造は高めです。',
    sandSection: '延べ床面積',
    sandResult: '砂の必要量',
    sandFormula: '砂 = {0} ㎡ × 0.05 = {1} m³',
    sandHint: '延べ床面積 1 ㎡あたり約 0.05 m³ で見積もります。',
    pieceUnit: '個',
    cubicMeterUnit: 'm³',
    tonUnit: 't',
    note: 'いずれも概算値です。実際の発注は図面・配合計画・地域の積算基準に従ってください。',
  ),
  AppLanguage.es: MaterialStrings(
    tabBricks: 'Ladrillos',
    tabConcrete: 'Hormigón',
    tabCement: 'Cemento',
    tabSand: 'Arena',
    bricksSection: 'Volumen del muro',
    volume: 'Volumen del muro',
    brickType: 'Tipo de ladrillo',
    brickStandard: 'Ladrillo común (512 por m³)',
    brickPerforated: 'Ladrillo perforado (320 por m³)',
    brickResult: 'Ladrillos necesarios',
    brickFormula: 'ladrillos = {0} m³ × {1} = {2} uds.',
    wallSection: 'Comprobación por metro cuadrado',
    wallNames: <String, String>{
      'thin': 'Muro de 120 mm',
      'standard': 'Muro de 240 mm',
      'thick': 'Muro de 370 mm',
    },
    concreteSection: 'Punto de hormigonado',
    area: 'Superficie',
    thickness: 'Espesor',
    concreteResult: 'Volumen de hormigón',
    concreteFormula: 'hormigón = {0} m² × {1} m = {2} m³',
    concreteHint: 'Soleras de 0.1 m; losas de 0.10 a 0.15 m.',
    cementSection: 'Superficie construida',
    buildingArea: 'Superficie construida',
    cementRate: 'Consumo',
    cementResult: 'Cemento necesario',
    cementFormula: 'cemento = {0} m² × {1} = {2} t',
    cementHint:
        'Consumo típico de 0.03 a 0.05 t por m²; el valor bajo para pórticos y el alto para muros portantes.',
    sandSection: 'Superficie construida',
    sandResult: 'Arena necesaria',
    sandFormula: 'arena = {0} m² × 0.05 = {1} m³',
    sandHint: 'Aproximadamente 0.05 m³ por m² construido.',
    pieceUnit: 'uds.',
    cubicMeterUnit: 'm³',
    tonUnit: 't',
    note:
        'Valores orientativos; para el pedido real use los planos, las dosificaciones y la normativa local.',
  ),
};

/// 当前语言的「材料用量」文案。
MaterialStrings get materialStrings => toolText(kMaterialStrings);
