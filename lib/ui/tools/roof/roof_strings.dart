import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 「屋面及防水工程」页的文案：四个 tab（平屋面 / 坡屋面 / 楼地面 / 墙基）。
///
/// 带参数的话术写成 `{0}` 模板，用 `fill()` 填充。
class RoofStrings {
  const RoofStrings({
    required this.tabFlat,
    required this.tabSlope,
    required this.tabFloor,
    required this.tabBase,
    required this.flatSection,
    required this.netArea,
    required this.upturnLength,
    required this.upturnHeight,
    required this.flatResult,
    required this.flatFormula,
    required this.upturnIgnored,
    required this.flatHint,
    required this.slopeSection,
    required this.projectedArea,
    required this.slopeAngle,
    required this.slopeResult,
    required this.slopeFormula,
    required this.slopeHint,
    required this.floorSection,
    required this.floorNetArea,
    required this.floorUpturnLength,
    required this.floorResult,
    required this.floorFormula,
    required this.floorHint,
    required this.baseSection,
    required this.centerlineLength,
    required this.netLength,
    required this.baseWidth,
    required this.baseResult,
    required this.baseFormula,
    required this.baseHint,
    required this.note,
  });

  final String tabFlat;
  final String tabSlope;
  final String tabFloor;
  final String tabBase;

  final String flatSection;
  final String netArea;
  final String upturnLength;
  final String upturnHeight;
  final String flatResult;

  /// 「S = {0} + {1} × {2} = {3} m²」。
  final String flatFormula;

  /// 翻边高度不足 300 mm 时给出的提示（不另计面积）。
  final String upturnIgnored;
  final String flatHint;

  final String slopeSection;
  final String projectedArea;
  final String slopeAngle;
  final String slopeResult;

  /// 「S = {0} × {1} = {2} m²」，其中 {1} 是延尺系数 C。
  final String slopeFormula;
  final String slopeHint;

  final String floorSection;
  final String floorNetArea;
  final String floorUpturnLength;
  final String floorResult;

  /// 「S = {0} + {1} × {2} = {3} m²」。
  final String floorFormula;
  final String floorHint;

  final String baseSection;
  final String centerlineLength;
  final String netLength;
  final String baseWidth;
  final String baseResult;

  /// 「S = ({0} + {1}) × {2} = {3} m²」。
  final String baseFormula;
  final String baseHint;

  final String note;
}

/// 各语言的「屋面及防水工程」文案。
const Map<AppLanguage, RoofStrings> kRoofStrings = <AppLanguage, RoofStrings>{
  AppLanguage.zhHans: RoofStrings(
    tabFlat: '平屋面',
    tabSlope: '坡屋面',
    tabFloor: '楼地面',
    tabBase: '墙基',
    flatSection: '平屋面防水',
    netArea: '主墙间净面积',
    upturnLength: '翻边长度',
    upturnHeight: '翻边高度',
    flatResult: '防水面积',
    flatFormula: 'S = {0} + {1} × {2} = {3} m²',
    upturnIgnored: '翻边高度不足 300 mm，已并入水平投影面积，不另计',
    flatHint:
        'S = 主墙间净面积 +（L外 + L内）× 翻边高度。女儿墙、天窗、伸缩缝处的翻边高度 ≥ 300 mm 时按展开面积并入屋面，不足 300 mm 不另计。',
    slopeSection: '坡屋面防水',
    projectedArea: '水平投影面积',
    slopeAngle: '坡度角 α',
    slopeResult: '防水面积',
    slopeFormula: 'S = {0} × {1} = {2} m²',
    slopeHint:
        'S = 水平投影面积 × 延尺系数 C，C = 1 / cosα。α 是屋面坡度角，30° 时 C ≈ 1.1547；按檐口总宽 × 檐口总长算投影面积。',
    floorSection: '楼地面防水',
    floorNetArea: '主墙间净面积',
    floorUpturnLength: '翻边长度',
    floorResult: '防水面积',
    floorFormula: 'S = {0} + {1} × {2} = {3} m²',
    floorHint:
        'S = 主墙间净面积 + 翻边面积。卫生间、厨房等上翻部位高度 ≥ 300 mm 时按展开面积并入，不足 300 mm 不另计。',
    baseSection: '墙基防水',
    centerlineLength: '外墙中心线长 L中',
    netLength: '内墙净长 L内',
    baseWidth: '实铺宽度',
    baseResult: '防水面积',
    baseFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    baseHint: 'S = 外墙中心线长 × 实铺宽 + 内墙净长 × 实铺宽，即（L中 + L内）× 实铺宽。',
    note: '按《房屋建筑与装饰工程工程量计算规范》GB/T 50854-2024 清单规则计算；附加层、接缝与搭接已含在综合单价里，不另计面积。',
  ),
  AppLanguage.zhHant: RoofStrings(
    tabFlat: '平屋面',
    tabSlope: '斜屋面',
    tabFloor: '樓地面',
    tabBase: '牆基',
    flatSection: '平屋面防水',
    netArea: '主牆間淨面積',
    upturnLength: '翻邊長度',
    upturnHeight: '翻邊高度',
    flatResult: '防水面積',
    flatFormula: 'S = {0} + {1} × {2} = {3} m²',
    upturnIgnored: '翻邊高度不足 300 mm，已並入水平投影面積，不另計',
    flatHint:
        'S = 主牆間淨面積 +（L外 + L內）× 翻邊高度。女兒牆、天窗、伸縮縫處的翻邊高度 ≥ 300 mm 時按展開面積並入屋面，不足 300 mm 不另計。',
    slopeSection: '斜屋面防水',
    projectedArea: '水平投影面積',
    slopeAngle: '坡度角 α',
    slopeResult: '防水面積',
    slopeFormula: 'S = {0} × {1} = {2} m²',
    slopeHint:
        'S = 水平投影面積 × 延尺係數 C，C = 1 / cosα。α 是屋面坡度角，30° 時 C ≈ 1.1547；按簷口總寬 × 簷口總長算投影面積。',
    floorSection: '樓地面防水',
    floorNetArea: '主牆間淨面積',
    floorUpturnLength: '翻邊長度',
    floorResult: '防水面積',
    floorFormula: 'S = {0} + {1} × {2} = {3} m²',
    floorHint:
        'S = 主牆間淨面積 + 翻邊面積。衛生間、廚房等上翻部位高度 ≥ 300 mm 時按展開面積並入，不足 300 mm 不另計。',
    baseSection: '牆基防水',
    centerlineLength: '外牆中心線長 L中',
    netLength: '內牆淨長 L內',
    baseWidth: '實鋪寬度',
    baseResult: '防水面積',
    baseFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    baseHint: 'S = 外牆中心線長 × 實鋪寬 + 內牆淨長 × 實鋪寬，即（L中 + L內）× 實鋪寬。',
    note: '按《房屋建築與裝飾工程工程量計算規範》GB/T 50854-2024 清單規則計算；附加層、接縫與搭接已含在綜合單價裡，不另計面積。',
  ),
  AppLanguage.en: RoofStrings(
    tabFlat: 'Flat roof',
    tabSlope: 'Pitched roof',
    tabFloor: 'Floor',
    tabBase: 'Wall base',
    flatSection: 'Flat roof waterproofing',
    netArea: 'Net area between walls',
    upturnLength: 'Upturn length',
    upturnHeight: 'Upturn height',
    flatResult: 'Waterproofing area',
    flatFormula: 'S = {0} + {1} × {2} = {3} m²',
    upturnIgnored: 'Upturn under 300 mm is already inside the plan area',
    flatHint:
        'S = net area + (outer + inner wall lengths) × upturn height. Upturns at parapets, skylights and movement joints count only when 300 mm or higher.',
    slopeSection: 'Pitched roof waterproofing',
    projectedArea: 'Horizontal projected area',
    slopeAngle: 'Roof pitch α',
    slopeResult: 'Waterproofing area',
    slopeFormula: 'S = {0} × {1} = {2} m²',
    slopeHint:
        'S = projected area × slope factor C, where C = 1 / cos α. At 30° C is about 1.1547. The projected area is the eaves width times the eaves length.',
    floorSection: 'Floor waterproofing',
    floorNetArea: 'Net area between walls',
    floorUpturnLength: 'Upturn length',
    floorResult: 'Waterproofing area',
    floorFormula: 'S = {0} + {1} × {2} = {3} m²',
    floorHint:
        'S = net area + upturn area. Upturns in bathrooms and kitchens count when 300 mm or higher; lower ones are ignored.',
    baseSection: 'Wall base waterproofing',
    centerlineLength: 'Exterior centre-line length',
    netLength: 'Interior clear length',
    baseWidth: 'Laid width',
    baseResult: 'Waterproofing area',
    baseFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    baseHint:
        'S = exterior centre line × laid width + interior clear length × laid width, i.e. (lengths) × width.',
    note:
        'Measured with the GB/T 50854-2024 bill-of-quantities rules. Additional layers, joints and laps are covered by the unit rate and not measured separately.',
  ),
  AppLanguage.ja: RoofStrings(
    tabFlat: '陸屋根',
    tabSlope: '勾配屋根',
    tabFloor: '床',
    tabBase: '壁の立上り',
    flatSection: '陸屋根の防水',
    netArea: '壁間の正味面積',
    upturnLength: '立上り長さ',
    upturnHeight: '立上り高さ',
    flatResult: '防水面積',
    flatFormula: 'S = {0} + {1} × {2} = {3} m²',
    upturnIgnored: '立上りが 300 mm 未満のため水平投影面積に含め、別計上しません',
    flatHint:
        'S = 壁間の正味面積 +（外壁 + 内壁の長さ）× 立上り高さ。パラペット・天窓・伸縮継手の立上りが 300 mm 以上のときに展開面積を加算し、300 mm 未満は別計上しません。',
    slopeSection: '勾配屋根の防水',
    projectedArea: '水平投影面積',
    slopeAngle: '勾配角度 α',
    slopeResult: '防水面積',
    slopeFormula: 'S = {0} × {1} = {2} m²',
    slopeHint:
        'S = 水平投影面積 × 延長係数 C、C = 1 / cos α。α は屋根の勾配角度で、30° のとき C ≈ 1.1547。投影面積は軒の総幅 × 軒の総長さで求めます。',
    floorSection: '床の防水',
    floorNetArea: '壁間の正味面積',
    floorUpturnLength: '立上り長さ',
    floorResult: '防水面積',
    floorFormula: 'S = {0} + {1} × {2} = {3} m²',
    floorHint:
        'S = 壁間の正味面積 + 立上り面積。浴室・厨房などの立上りが 300 mm 以上のときに展開面積を加算し、300 mm 未満は別計上しません。',
    baseSection: '壁の立上り防水',
    centerlineLength: '外壁中心線長さ',
    netLength: '内壁内法長さ',
    baseWidth: '施工幅',
    baseResult: '防水面積',
    baseFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    baseHint: 'S = 外壁中心線長さ × 施工幅 + 内壁内法長さ × 施工幅、すなわち（長さの和）× 施工幅です。',
    note: 'GB/T 50854-2024 の数量計算規則によります。増張り、継手、重ね代は単価に含まれるため別計上しません。',
  ),
  AppLanguage.es: RoofStrings(
    tabFlat: 'Cubierta plana',
    tabSlope: 'Cubierta inclinada',
    tabFloor: 'Suelo',
    tabBase: 'Pie de muro',
    flatSection: 'Impermeabilización de cubierta plana',
    netArea: 'Superficie neta entre muros',
    upturnLength: 'Longitud de remate',
    upturnHeight: 'Altura de remate',
    flatResult: 'Superficie impermeabilizada',
    flatFormula: 'S = {0} + {1} × {2} = {3} m²',
    upturnIgnored:
        'El remate de menos de 300 mm ya está incluido en la proyección',
    flatHint:
        'S = superficie neta + (longitudes de muros exteriores e interiores) × altura del remate. Los remates en petos, claraboyas y juntas cuentan desde 300 mm de altura.',
    slopeSection: 'Impermeabilización de cubierta inclinada',
    projectedArea: 'Superficie proyectada',
    slopeAngle: 'Pendiente α',
    slopeResult: 'Superficie impermeabilizada',
    slopeFormula: 'S = {0} × {1} = {2} m²',
    slopeHint:
        'S = superficie proyectada × coeficiente C, con C = 1 / cos α. A 30° C es aproximadamente 1.1547. La superficie proyectada es el ancho de alero por su longitud.',
    floorSection: 'Impermeabilización de suelos',
    floorNetArea: 'Superficie neta entre muros',
    floorUpturnLength: 'Longitud de remate',
    floorResult: 'Superficie impermeabilizada',
    floorFormula: 'S = {0} + {1} × {2} = {3} m²',
    floorHint:
        'S = superficie neta + superficie de remates. Los remates de baños y cocinas cuentan desde 300 mm de altura; por debajo no se miden.',
    baseSection: 'Impermeabilización del pie de muro',
    centerlineLength: 'Longitud eje exterior',
    netLength: 'Longitud libre interior',
    baseWidth: 'Ancho extendido',
    baseResult: 'Superficie impermeabilizada',
    baseFormula: 'S = ({0} + {1}) × {2} = {3} m²',
    baseHint:
        'S = eje exterior × ancho + longitud libre interior × ancho, es decir, (suma de longitudes) × ancho.',
    note:
        'Medido con las reglas GB/T 50854-2024. Las capas adicionales, juntas y solapes van incluidos en el precio unitario y no se miden aparte.',
  ),
};

/// 当前语言下的「屋面及防水工程」文案。
RoofStrings get roofStrings => toolText(kRoofStrings);
