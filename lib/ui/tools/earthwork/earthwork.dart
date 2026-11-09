/// 土石方工程量（GB/T 50854-2024 清单规则）。
///
/// 三类常见项：场地平整、基坑 / 基槽开挖、管沟土方。清单规则里**不计算放坡
/// 工程量**（放坡与支护由投标人在综合单价里自行考虑），所以这里的公式都是
/// 「垫层底面积 × 挖深」加工作面，不带放坡系数。本文件不依赖 Flutter，便于单测。
library;

/// 清单默认工作面宽度（m）：图纸有规定时按图纸。
const double kDefaultWorkFace = 0.6;

/// 场地平整的找平厚度界限（m）：±30 cm 以内算场地平整，超过按挖土方算。
const double kLevelingTolerance = 0.3;

/// 页面上的 tab 数量（场地平整 / 基坑基槽开挖 / 管沟土方）。
const int kEarthworkTabCount = 3;

/// 场地平整面积（㎡）：S = 建筑物首层结构外围水平面积。
///
/// 只做 ±30 cm 以内的挖填找平；超过 [kLevelingTolerance] 的厚度要按挖土方另算。
double siteLevelingArea(double length, double width) => length * width;

/// 基坑 / 基槽开挖体积（m³）：V =（a + 2c）×（b + 2c）× H。
///
/// [length] / [width] 是基础垫层底的长宽（a、b），[workFace] 是工作面 c，
/// [depth] 是挖土深度 H。清单不计算放坡量，所以没有放坡系数这一项。
double excavationVolume({
  required double length,
  required double width,
  required double depth,
  double workFace = kDefaultWorkFace,
}) => (length + 2 * workFace) * (width + 2 * workFace) * depth;

/// 管沟土方（m³）：V =（管外径 + 2c）× H × L。
///
/// 有垫层与无垫层在清单规则里用同一个式子：垫层外扩的宽度并入工作面 c，
/// 不再单独加；各类井的土方并入管沟计算（把井那段长度算进 [length] 即可）。
double pipeTrenchVolume({
  required double pipeDiameter,
  required double depth,
  required double length,
  double workFace = kDefaultWorkFace,
}) => (pipeDiameter + 2 * workFace) * depth * length;
