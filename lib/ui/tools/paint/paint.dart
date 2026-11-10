/// 油漆涂料工程量（GB/T 50854-2024）。
///
/// 三类常见项：墙面涂料、天棚涂料、门窗油漆。涂刷面积按设计图示尺寸以面积（㎡）
/// 计算，涂料用量 = 面积 × 遍数 × 单耗。单个 ≤ 0.3 ㎡ 的孔洞不扣除。
/// 本文件不依赖 Flutter，便于单测。
library;

import 'dart:math' as math;

/// 页面上的 tab 数量（墙面 / 天棚 / 门窗）。
const int kPaintTabCount = 3;

/// 不扣除的单个孔洞（洞口）面积上限（㎡）。
const double kPaintHoleThreshold = 0.3;

/// 每桶涂料净重的默认值（kg），常见包装 20 kg 或 18 L。
const double kDefaultPaintCanWeight = 20;

/// 要扣除的洞口面积（㎡）：单个 ≤ 0.3 ㎡ 的孔洞不扣。
double paintDeductedOpening(double area) =>
    area > kPaintHoleThreshold ? area : 0;

/// 墙面涂刷面积（㎡）：S = 墙长 × 墙高 − 门窗洞口面积。
///
/// 单个 ≤ 0.3 ㎡ 的洞口不扣（如开关插座、小检修口）。
double wallPaintArea({
  required double length,
  required double height,
  double openingArea = 0,
}) => math.max(0, length * height - paintDeductedOpening(openingArea));

/// 天棚涂刷面积（㎡）：S = 主墙间净面积 + 梁侧面面积。
double ceilingPaintArea({required double netArea, double beamSideArea = 0}) =>
    math.max(0, netArea) + math.max(0, beamSideArea);

/// 门窗油漆面积（㎡）：S = 樘数 × 每樘洞口面积 × 展开系数。
///
/// 展开系数按清单规则取：单层木门窗 1.0、双层 2.0、框宽超出定额时按系数表调整。
double joineryPaintArea({
  required double count,
  required double areaPerUnit,
  double unfoldFactor = 1,
}) => math.max(0, count) * math.max(0, areaPerUnit) * math.max(0, unfoldFactor);

/// 涂料用量（kg）：G = 面积 × 遍数 × 单耗。
///
/// [coats] 是涂刷遍数，[consumption] 是单遍单耗（kg/(㎡·遍)）。
double paintUsage({
  required double area,
  required int coats,
  required double consumption,
}) => math.max(0, area) * math.max(0, coats) * math.max(0, consumption);

/// 折合桶数：按每桶净重向上取整，用量为 0 或桶重非正时返回 0。
int paintCans({required double usage, required double canWeight}) {
  if (usage <= 0 || canWeight <= 0) return 0;
  return (usage / canWeight).ceil();
}
