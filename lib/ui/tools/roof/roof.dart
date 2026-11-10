/// 屋面及防水工程（GB/T 50854-2024）。
///
/// 四类常见项：平屋面防水、坡屋面防水、楼地面防水、墙基防水。
/// 均按设计图示尺寸以面积（㎡）计算，翻边高度≥ 300 mm 时按展开面积并入。
/// 本文件不依赖 Flutter，便于单测。
library;

import 'dart:math' as math;

/// 页面上的 tab 数量（平屋面 / 坡屋面 / 楼地面 / 墙基）。
const int kRoofTabCount = 4;

/// 需要另计翻边的起始高度（m）：≥ 0.3 m 按展开面积并入，不足的不另计。
const double kUpturnThreshold = 0.3;

/// 翻边展开面积（㎡）：高度 ≥ [kUpturnThreshold] 时按长度 × 高度并入。
double upturnArea({required double length, required double height}) =>
    height >= kUpturnThreshold ? length * height : 0;

/// 平屋面防水面积（㎡）：S = 主墙间净面积 +（L外 + L内）× 翻边高度。
///
/// [netArea] 是主墙间水平投影净面积，[upturnLength] 是女儿墙等翻边的长度
/// （外墙外边线 + 内墙净长），[upturnHeight] 是翻边高度。
double flatRoofArea({
  required double netArea,
  double upturnLength = 0,
  double upturnHeight = 0,
}) => netArea + upturnArea(length: upturnLength, height: upturnHeight);

/// 坡度延尺系数 C = 1 / cosα（α 为屋面坡度角）。
double slopeFactor(double angleDegrees) =>
    1 / math.cos(angleDegrees * math.pi / 180);

/// 坡屋面防水面积（㎡）：S = 水平投影面积 × 延尺系数 C。
double pitchedRoofArea({
  required double projectedArea,
  required double angleDegrees,
}) => projectedArea * slopeFactor(angleDegrees);

/// 楼地面防水面积（㎡）：S = 主墙间净面积 + 翻边展开面积。
///
/// 翻边高度 ≥ 0.3 m（卫生间、厨房等上翻部位）时按展开面积并入。
double floorWaterproofArea({
  required double netArea,
  double upturnLength = 0,
  double upturnHeight = 0,
}) => netArea + upturnArea(length: upturnLength, height: upturnHeight);

/// 墙基防水面积（㎡）：S = 外墙中心线长 × 实铺宽 + 内墙净长 × 实铺宽。
double wallBaseWaterproofArea({
  required double centerlineLength,
  required double netLength,
  required double width,
}) => (centerlineLength + netLength) * width;
