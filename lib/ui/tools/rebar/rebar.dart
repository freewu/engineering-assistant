/// 钢筋工程量（GB/T 50854-2024）。
///
/// 清单规则：按设计图示钢筋中心线长度 × 单位理论质量计算。只计算设计标明的
/// 搭接与锚固长度，施工搭接（定尺搭接等）不计入，已含在综合单价里。
/// 三类常见钢筋：直钢筋、箍筋（抗震）、弯起钢筋，另附常用直径速查表。
/// 本文件不依赖 Flutter。
library;

import 'dart:math' as math;

/// 单位理论质量系数：每米质量 = 0.00617 × d²（kg/m，d 取 mm）。
///
/// 与钢材密度 7850 kg/m³ 一致：π/4 × d² × 7850 / 1e6 ≈ 0.006165 d²。
const double kRebarMassFactor = 0.00617;

/// 抗震箍筋 135° 弯钩的平直段系数：每个弯钩按 11.9d 增加。
const double kStirrupHookFactor = 11.9;

/// 常用保护层厚度（mm）：梁 25、板 20、柱 30；设计有规定时按设计。
const double kCoverBeam = 25;
const double kCoverSlab = 20;
const double kCoverColumn = 30;

/// 页面上的 tab 数量（直钢筋 / 箍筋 / 弯起钢筋 / 速查表）。
const int kRebarTabCount = 4;

/// 速查表里的常用钢筋直径（mm）。
const List<int> kCommonDiameters = <int>[
  6,
  8,
  10,
  12,
  14,
  16,
  18,
  20,
  22,
  25,
  28,
  32,
];

/// 常用直径的理论质量（kg/m），取自钢筋理论质量表的取整值。
///
/// 与 `0.00617 × d²` 只差四舍五入（如 φ25：3.85625 → 3.85），速查表按表值
/// 显示，算式仍用公式算。
const Map<int, double> kReferenceMassPerMeter = <int, double>{
  6: 0.222,
  8: 0.395,
  10: 0.617,
  12: 0.888,
  14: 1.21,
  16: 1.58,
  18: 2,
  20: 2.47,
  22: 2.98,
  25: 3.85,
  28: 4.83,
  32: 6.31,
};

/// 直钢筋中心线长度（mm）：L = l − 2c + 2 × 弯钩长。
///
/// [memberLength] 是构件长度 l，[cover] 是保护层 c，[hookLength] 是单个弯钩
/// 增加的长度（180° 弯钩平直段常取 6.25d，两端各加一个）。扣成负数时按 0 算。
double straightRebarLength({
  required double memberLength,
  required double cover,
  double hookLength = 0,
}) => math.max(0, memberLength - 2 * cover + 2 * hookLength);

/// 抗震箍筋中心线长度（mm）：L = 2 × (a + b) − 8c + 2 × 11.9d。
///
/// [sectionA] / [sectionB] 是构件截面 a、b，[cover] 是保护层 c，[diameter] 是
/// 箍筋直径 d；两个 135° 弯钩各按 11.9d 计。
double stirrupRebarLength({
  required double sectionA,
  required double sectionB,
  required double cover,
  required double diameter,
}) => math.max(
  0,
  2 * (sectionA + sectionB) - 8 * cover + 2 * kStirrupHookFactor * diameter,
);

/// 弯起钢筋中心线长度（mm）：L = 直段长 + 斜段长 − 弯曲调整值 + 弯钩长。
///
/// [bendAdjustment] 是量度差值（弯曲调整值），按弯折角度取 0.35d ~ 2d。
double bentRebarLength({
  required double straightPart,
  required double inclinedPart,
  double bendAdjustment = 0,
  double hookLength = 0,
}) => math.max(0, straightPart + inclinedPart - bendAdjustment + hookLength);

/// 每米理论质量（kg/m）：0.00617 × d²。
double rebarMassPerMeter(double diameter) =>
    kRebarMassFactor * diameter * diameter;

/// 钢筋质量（kg）：W = n × L（m）× 0.00617 × d²。
///
/// [length] 是单根中心线长度（mm），[diameter] 取 mm，[count] 是根数。
double rebarMass({
  required double length,
  required double diameter,
  int count = 1,
}) => count * length / 1000 * rebarMassPerMeter(diameter);
