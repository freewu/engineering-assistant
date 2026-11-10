/// 保温隔热工程（GB/T 50854-2024）。
///
/// 三类常见项：屋面、墙面、柱。面积按设计图示尺寸以㎡计算，
/// 体积 = 面积 × 保温层厚度。单个 ≤ 0.3 ㎡ 的孔洞不扣除。
/// 本文件不依赖 Flutter，便于单测。
library;

import 'dart:math' as math;

/// 页面上的 tab 数量（屋面 / 墙面 / 柱）。
const int kInsulationTabCount = 3;

/// 不扣除的单个孔洞 / 梁所占面积上限（㎡）。
const double kInsulationHoleThreshold = 0.3;

/// 屋面保温隔热面积（㎡）：S = 水平投影面积 − 应扣除的孔洞面积。
///
/// 单个 ≤ 0.3 ㎡ 的孔洞不扣除。
double roofInsulationArea({
  required double projectedArea,
  double holeArea = 0,
}) => math.max(0, projectedArea - deductedArea(holeArea));

/// 墙面保温隔热面积（㎡）：S = 墙长 × 墙高 − 门窗洞口面积 + 侧壁面积。
///
/// 单个 ≤ 0.3 ㎡ 的洞口不扣除，洞口侧壁的保温并入墙面。
double wallInsulationArea({
  required double length,
  required double height,
  double openingArea = 0,
  double sideArea = 0,
}) => math.max(0, length * height - deductedArea(openingArea)) + sideArea;

/// 柱保温隔热面积（㎡）：S = 保温层中心线展开长度 × 柱高 − 梁所占面积。
///
/// [perimeterCenterline] 是保温层中心线的展开长度（m），梁所占面积
/// **大于 0.3 ㎡** 才扣除。
double columnInsulationArea({
  required double perimeterCenterline,
  required double height,
  double beamArea = 0,
}) => math.max(0, perimeterCenterline * height - deductedArea(beamArea));

/// 保温隔热体积（m³）：V = 面积 × 保温层厚度。
double insulationVolume({required double area, required double thickness}) =>
    area * thickness;

/// 要扣除的面积：只有大于 0.3 ㎡ 的孔洞 / 梁所占面积才扣。
double deductedArea(double area) => area > kInsulationHoleThreshold ? area : 0;
