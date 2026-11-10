import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「模板工程」页的文案：四个 tab（柱 / 梁 / 墙 / 楼梯）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充。
class FormworkStrings {
  const FormworkStrings({
    required this.tabColumn,
    required this.tabBeam,
    required this.tabWall,
    required this.tabStair,
    required this.columnSection,
    required this.columnMode,
    required this.modeRectangle,
    required this.modeTie,
    required this.columnA,
    required this.columnB,
    required this.columnHeight,
    required this.columnResult,
    required this.columnFormula,
    required this.tieFormula,
    required this.tieHint,
    required this.columnHint,
    required this.beamSection,
    required this.beamBottomWidth,
    required this.beamHeight,
    required this.beamLength,
    required this.beamResult,
    required this.beamFormula,
    required this.beamHint,
    required this.wallSection,
    required this.wallLength,
    required this.wallHeight,
    required this.wallOpening,
    required this.wallSide,
    required this.wallResult,
    required this.wallFormula,
    required this.wallHint,
    required this.stairSection,
    required this.stairSteps,
    required this.stairTreadWidth,
    required this.stairRiser,
    required this.stairFlightWidth,
    required this.stairLanding,
    required this.stairResult,
    required this.stairFormula,
    required this.stairHint,
    required this.note,
  });

  final String tabColumn;
  final String tabBeam;
  final String tabWall;
  final String tabStair;

  final String columnSection;
  final String columnMode;
  final String modeRectangle;
  final String modeTie;
  final String columnA;
  final String columnB;
  final String columnHeight;
  final String columnResult;

  /// 「S = 2 × ({0} + {1}) × {2} = {3} m²」。
  final String columnFormula;

  /// 「S = (2 × ({0} + {1}) + 2 × {2} × {3}) × {4} = {5} m²」。
  final String tieFormula;
  final String tieHint;
  final String columnHint;

  final String beamSection;
  final String beamBottomWidth;
  final String beamHeight;
  final String beamLength;
  final String beamResult;

  /// 「S = ({0} + 2 × {1}) × {2} = {3} m²」。
  final String beamFormula;
  final String beamHint;

  final String wallSection;
  final String wallLength;
  final String wallHeight;
  final String wallOpening;
  final String wallSide;
  final String wallResult;

  /// 「S = ({0} × {1} − {2}) + {3} = {4} m²」。
  final String wallFormula;
  final String wallHint;

  final String stairSection;
  final String stairSteps;
  final String stairTreadWidth;
  final String stairRiser;
  final String stairFlightWidth;
  final String stairLanding;
  final String stairResult;

  /// 「S = ({0} + {1}) × {2} = {3} m²」。
  final String stairFormula;
  final String stairHint;

  final String note;

  /// 柱子的计算模式名称。
  String modeLabel(ColumnFormMode mode) => switch (mode) {
    ColumnFormMode.rectangle => modeRectangle,
    ColumnFormMode.tie => modeTie,
  };
}

/// 柱模板的两种算法：矩形柱 / 构造柱（带马牙槎）。
enum ColumnFormMode {
  /// 矩形柱：S = 截面周长 × 柱高。
  rectangle,

  /// 构造柱：截面周长 + 马牙槎展开长度。
  tie,
}

/// 各语言的「模板工程」文案。
const Map<AppLanguage, FormworkStrings>
kFormworkStrings = <AppLanguage, FormworkStrings>{
  AppLanguage.zhHans: FormworkStrings(
    tabColumn: '柱',
    tabBeam: '梁',
    tabWall: '墙',
    tabStair: '楼梯',
    columnSection: '柱模板',
    columnMode: '柱子类型',
    modeRectangle: '矩形柱',
    modeTie: '构造柱',
    columnA: '截面 a',
    columnB: '截面 b',
    columnHeight: '柱高 H',
    columnResult: '模板面积',
    columnFormula: 'S = 2 × ({0} + {1}) × {2} = {3} m²',
    tieFormula: 'S = (2 × ({0} + {1}) + 2 × {2} × {3}) × {4} = {5} m²',
    tieHint:
        '构造柱按（截面周长 + 马牙槎展开长度）× 柱高计算：马牙槎每边凸出 60 mm、每米柱高 5 槎，240 × 240 柱每米 1.56 ㎡。',
    columnHint: '矩形柱 S = 2 ×（截面 a + 截面 b）× 柱高，按模板与混凝土的接触面积计算；柱与梁板交接处按规范另有说明。',
    beamSection: '梁模板',
    beamBottomWidth: '梁底宽 b',
    beamHeight: '梁高 h',
    beamLength: '梁长 L',
    beamResult: '模板面积',
    beamFormula: 'S = ({0} + 2 × {1}) × {2} = {3} m²',
    beamHint: 'S =（梁底宽 + 2 × 梁高）× 梁长。梁与板连接时两侧模板不扣板厚，所以按梁的全高计算。',
    wallSection: '墙模板',
    wallLength: '墙长 L',
    wallHeight: '墙高 H',
    wallOpening: '门窗洞口面积',
    wallSide: '洞口侧壁面积',
    wallResult: '模板面积',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint: 'S = 墙长 × 墙高 − 门窗洞口面积 + 洞口侧壁面积；不扣除单个 ≤ 0.3 ㎡ 的孔洞，侧壁模板并入墙体。',
    stairSection: '楼梯模板',
    stairSteps: '踏步数',
    stairTreadWidth: '踏步宽',
    stairRiser: '踏步高',
    stairFlightWidth: '梯段宽',
    stairLanding: '休息平台长',
    stairResult: '模板面积',
    stairFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    stairHint:
        '按侧面展开面积计算，含踏步的踏面与踢面：展开斜长 = 踏步数 × √(踏步宽² + 踏步高²)，再加休息平台长度，最后乘梯段宽。',
    note:
        '按《房屋建筑与装饰工程工程量计算规范》GB/T 50854-2024 清单规则计算，单位是模板与混凝土的接触面积（㎡）；实际支模面积与当地定额的取值口径可能不同，以图纸与定额为准。',
  ),
  AppLanguage.zhHant: FormworkStrings(
    tabColumn: '柱',
    tabBeam: '樑',
    tabWall: '牆',
    tabStair: '樓梯',
    columnSection: '柱模板',
    columnMode: '柱子類型',
    modeRectangle: '矩形柱',
    modeTie: '構造柱',
    columnA: '截面 a',
    columnB: '截面 b',
    columnHeight: '柱高 H',
    columnResult: '模板面積',
    columnFormula: 'S = 2 × ({0} + {1}) × {2} = {3} m²',
    tieFormula: 'S = (2 × ({0} + {1}) + 2 × {2} × {3}) × {4} = {5} m²',
    tieHint:
        '構造柱按（截面周長 + 馬牙槎展開長度）× 柱高計算：馬牙槎每邊凸出 60 mm、每米柱高 5 槎，240 × 240 柱每米 1.56 ㎡。',
    columnHint: '矩形柱 S = 2 ×（截面 a + 截面 b）× 柱高，按模板與混凝土的接觸面積計算；柱與樑板交接處按規範另有說明。',
    beamSection: '樑模板',
    beamBottomWidth: '樑底寬 b',
    beamHeight: '樑高 h',
    beamLength: '樑長 L',
    beamResult: '模板面積',
    beamFormula: 'S = ({0} + 2 × {1}) × {2} = {3} m²',
    beamHint: 'S =（樑底寬 + 2 × 樑高）× 樑長。樑與板連接時兩側模板不扣板厚，所以按樑的全高計算。',
    wallSection: '牆模板',
    wallLength: '牆長 L',
    wallHeight: '牆高 H',
    wallOpening: '門窗洞口面積',
    wallSide: '洞口側壁面積',
    wallResult: '模板面積',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint: 'S = 牆長 × 牆高 − 門窗洞口面積 + 洞口側壁面積；不扣除單個 ≤ 0.3 ㎡ 的孔洞，側壁模板並入牆體。',
    stairSection: '樓梯模板',
    stairSteps: '踏步數',
    stairTreadWidth: '踏步寬',
    stairRiser: '踏步高',
    stairFlightWidth: '梯段寬',
    stairLanding: '休息平台長',
    stairResult: '模板面積',
    stairFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    stairHint:
        '按側面展開面積計算，含踏步的踏面與踢面：展開斜長 = 踏步數 × √(踏步寬² + 踏步高²)，再加休息平台長度，最後乘梯段寬。',
    note:
        '按《房屋建築與裝飾工程工程量計算規範》GB/T 50854-2024 清單規則計算，單位是模板與混凝土的接觸面積（㎡）；實際支模面積與當地定額的取值口徑可能不同，以圖紙與定額為準。',
  ),
  AppLanguage.en: FormworkStrings(
    tabColumn: 'Column',
    tabBeam: 'Beam',
    tabWall: 'Wall',
    tabStair: 'Stair',
    columnSection: 'Column formwork',
    columnMode: 'Column type',
    modeRectangle: 'Rectangular column',
    modeTie: 'Tie column',
    columnA: 'Side a',
    columnB: 'Side b',
    columnHeight: 'Column height H',
    columnResult: 'Formwork area',
    columnFormula: 'S = 2 × ({0} + {1}) × {2} = {3} m²',
    tieFormula: 'S = (2 × ({0} + {1}) + 2 × {2} × {3}) × {4} = {5} m²',
    tieHint:
        'Tie columns take (perimeter + toothed joint development) × height: teeth protrude 60 mm on each side, five per metre of height, so a 240 × 240 column gives 1.56 m² per metre.',
    columnHint:
        'Rectangular column S = 2 × (side a + side b) × height, measured on the concrete contact area. Junctions with beams and slabs follow the code separately.',
    beamSection: 'Beam formwork',
    beamBottomWidth: 'Beam width b',
    beamHeight: 'Beam depth h',
    beamLength: 'Beam length L',
    beamResult: 'Formwork area',
    beamFormula: 'S = ({0} + 2 × {1}) × {2} = {3} m²',
    beamHint:
        'S = (beam width + 2 × beam depth) × length. Where the beam meets a slab the side forms are not reduced by the slab thickness, so the full depth counts.',
    wallSection: 'Wall formwork',
    wallLength: 'Wall length L',
    wallHeight: 'Wall height H',
    wallOpening: 'Opening area',
    wallSide: 'Reveal area',
    wallResult: 'Formwork area',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint:
        'S = length × height − openings + reveals. Openings up to 0.3 m² are not deducted; reveal formwork is added to the wall.',
    stairSection: 'Stair formwork',
    stairSteps: 'Number of steps',
    stairTreadWidth: 'Tread width',
    stairRiser: 'Riser height',
    stairFlightWidth: 'Flight width',
    stairLanding: 'Landing length',
    stairResult: 'Formwork area',
    stairFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    stairHint:
        'Developed side area including treads and risers: developed length = steps × √(tread² + riser²), plus the landing length, all times the flight width.',
    note:
        'Measured with the GB/T 50854-2024 bill-of-quantities rules; the unit is the concrete contact area in m². Local norms may measure formwork differently, so drawings and norms govern.',
  ),
  AppLanguage.ja: FormworkStrings(
    tabColumn: '柱',
    tabBeam: '梁',
    tabWall: '壁',
    tabStair: '階段',
    columnSection: '柱型枠',
    columnMode: '柱の種類',
    modeRectangle: '矩形柱',
    modeTie: '袖壁付き柱',
    columnA: '断面 a',
    columnB: '断面 b',
    columnHeight: '柱高さ H',
    columnResult: '型枠面積',
    columnFormula: 'S = 2 × ({0} + {1}) × {2} = {3} m²',
    tieFormula: 'S = (2 × ({0} + {1}) + 2 × {2} × {3}) × {4} = {5} m²',
    tieHint:
        '袖壁付き柱は（断面周長 + 噛み合わせの展開長さ）× 柱高さで計算します。噛み合わせは片側 60 mm 突出、1 m あたり 5 か所で、240 × 240 の柱は 1 m あたり 1.56 ㎡です。',
    columnHint:
        '矩形柱は S = 2 ×（断面 a + 断面 b）× 柱高さ。コンクリートとの接触面積で計算し、梁・スラブとの取り合いは規準によります。',
    beamSection: '梁型枠',
    beamBottomWidth: '梁幅 b',
    beamHeight: '梁せい h',
    beamLength: '梁長さ L',
    beamResult: '型枠面積',
    beamFormula: 'S = ({0} + 2 × {1}) × {2} = {3} m²',
    beamHint: 'S =（梁幅 + 2 × 梁せい）× 梁長さ。スラブと接する部分の側枠はスラブ厚を控除しないため、梁せいの全高で計算します。',
    wallSection: '壁型枠',
    wallLength: '壁長さ L',
    wallHeight: '壁高さ H',
    wallOpening: '開口部面積',
    wallSide: '開口部側面面積',
    wallResult: '型枠面積',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint: 'S = 壁長さ × 壁高さ − 開口部面積 + 開口部側面面積。0.3 ㎡ 以下の開口は控除せず、側面の型枠は壁に含めます。',
    stairSection: '階段型枠',
    stairSteps: '段数',
    stairTreadWidth: '踏面幅',
    stairRiser: '蹴上げ高さ',
    stairFlightWidth: '階段幅',
    stairLanding: '踊り場長さ',
    stairResult: '型枠面積',
    stairFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    stairHint:
        '踏面と蹴上げを含む側面の展開面積で計算します。展開長さ = 段数 × √(踏面² + 蹴上げ²)、これに踊り場長さを足して階段幅を掛けます。',
    note:
        'GB/T 50854-2024 の数量計算規則による、コンクリートとの接触面積（㎡）です。実際の型枠面積は地域の積算基準と異なる場合があるため、図面と積算基準によります。',
  ),
  AppLanguage.es: FormworkStrings(
    tabColumn: 'Pilar',
    tabBeam: 'Viga',
    tabWall: 'Muro',
    tabStair: 'Escalera',
    columnSection: 'Encofrado de pilar',
    columnMode: 'Tipo de pilar',
    modeRectangle: 'Pilar rectangular',
    modeTie: 'Pilar de arriostramiento',
    columnA: 'Lado a',
    columnB: 'Lado b',
    columnHeight: 'Altura del pilar H',
    columnResult: 'Superficie de encofrado',
    columnFormula: 'S = 2 × ({0} + {1}) × {2} = {3} m²',
    tieFormula: 'S = (2 × ({0} + {1}) + 2 × {2} × {3}) × {4} = {5} m²',
    tieHint:
        'Los pilares de arriostramiento se miden por (perímetro + desarrollo del dentado) × altura: el dentado sobresale 60 mm por lado, cinco por metro, de modo que un pilar de 240 × 240 da 1.56 m² por metro.',
    columnHint:
        'Pilar rectangular S = 2 × (lado a + lado b) × altura, medido sobre la superficie de contacto con el hormigón. Los encuentros con vigas y losas siguen la norma aparte.',
    beamSection: 'Encofrado de viga',
    beamBottomWidth: 'Ancho de viga b',
    beamHeight: 'Canto de viga h',
    beamLength: 'Longitud de viga L',
    beamResult: 'Superficie de encofrado',
    beamFormula: 'S = ({0} + 2 × {1}) × {2} = {3} m²',
    beamHint:
        'S = (ancho + 2 × canto) × longitud. Donde la viga se encuentra con la losa no se descuenta el espesor, así que cuenta el canto completo.',
    wallSection: 'Encofrado de muro',
    wallLength: 'Longitud del muro L',
    wallHeight: 'Altura del muro H',
    wallOpening: 'Área de huecos',
    wallSide: 'Área de jambas',
    wallResult: 'Superficie de encofrado',
    wallFormula: 'S = ({0} × {1} − {2}) + {3} = {4} m²',
    wallHint:
        'S = longitud × altura − huecos + jambas. No se descuentan huecos de hasta 0.3 m²; el encofrado de jambas se suma al muro.',
    stairSection: 'Encofrado de escalera',
    stairSteps: 'Número de escalones',
    stairTreadWidth: 'Huella',
    stairRiser: 'Contrahuella',
    stairFlightWidth: 'Ancho del tramo',
    stairLanding: 'Longitud del descansillo',
    stairResult: 'Superficie de encofrado',
    stairFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    stairHint:
        'Superficie lateral desarrollada con huellas y contrahuellas: longitud desarrollada = escalones × √(huella² + contrahuella²), más el descansillo, todo por el ancho del tramo.',
    note:
        'Medido con las reglas GB/T 50854-2024; la unidad es la superficie de contacto con el hormigón en m². La normativa local puede medir el encofrado de otro modo: mandan los planos y la norma.',
  ),
};

/// 当前语言下的「模板工程」文案。
FormworkStrings get formworkStrings => toolText(kFormworkStrings);
