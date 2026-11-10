/// 模板工程（GB/T 50854-2024）。
///
/// 按模板与混凝土的**接触面积**（㎡）计算：柱、梁、墙、楼梯四类常见构件。
/// 梁板连接处侧模不扣板厚，柱梁交接处按规范另有说明（本工具只算单构件）。
/// 本文件不依赖 Flutter，便于单测。
library;

import 'dart:math' as math;

/// 页面上的 tab 数量（柱 / 梁 / 墙 / 楼梯）。
const int kFormworkTabCount = 4;

/// 构造柱马牙槎每边凸出宽度（m）。
const double kToothProtrusion = 0.06;

/// 每米柱高上的马牙槎数量（常规做法每 200 mm 一槎，1 m 高即 5 槎）。
const double kToothCountPerMeter = 5;

/// 矩形柱模板面积（㎡）：S = 截面周长 × 柱高 = 2(a + b) × H。
///
/// [a]、[b] 是柱截面两边（m），[height] 是柱高（m）。
double columnFormworkArea({
  required double a,
  required double b,
  required double height,
}) => 2 * (a + b) * height;

/// 构造柱模板面积（㎡）：S =（截面周长 + 马牙槎展开长度）× 柱高。
///
/// 240 × 240 构造柱按每边 5 槎、凸出 60 mm 算，每米柱高的展开宽度是
/// 2 × 0.06 × 5 = 0.6 m，面积即 1.56 ㎡/m（0.96 + 0.6）。
double tieColumnFormworkArea({
  required double a,
  required double b,
  required double height,
  double protrusion = kToothProtrusion,
  double teethPerMeter = kToothCountPerMeter,
}) => (2 * (a + b) + 2 * protrusion * teethPerMeter) * height;

/// 矩形梁模板面积（㎡）：S =（梁底宽 + 2 × 梁高）× 梁长。
///
/// 梁与板连接时两侧模板不扣板厚，所以按梁的全高算。
double beamFormworkArea({
  required double bottomWidth,
  required double height,
  required double length,
}) => (bottomWidth + 2 * height) * length;

/// 墙模板面积（㎡）：S = 墙长 × 墙高 − 门窗洞口面积 + 洞口侧壁面积。
///
/// 单个 ≤ 0.3 ㎡ 的孔洞不扣除。
double wallFormworkArea({
  required double length,
  required double height,
  double openingArea = 0,
  double sideArea = 0,
}) {
  final opening = openingArea > kFormworkHoleThreshold ? openingArea : 0;
  return math.max(0, length * height - opening) + sideArea;
}

/// 不扣除的单个孔洞面积上限（㎡）。
const double kFormworkHoleThreshold = 0.3;

/// 楼梯踏步的展开斜长（m）：步数 × √(踏步宽² + 踏步高²)。
double stairSlopeLength({
  required int steps,
  required double treadWidth,
  required double riserHeight,
}) => steps * math.sqrt(treadWidth * treadWidth + riserHeight * riserHeight);

/// 楼梯模板面积（㎡）：S =（踏步展开斜长 + 休息平台长）× 梯段宽。
///
/// 侧面展开面积含踏步的踢面与踏面，休息平台并入同一宽度计算。
double stairFormworkArea({
  required int steps,
  required double treadWidth,
  required double riserHeight,
  required double flightWidth,
  double landingLength = 0,
}) =>
    (stairSlopeLength(
          steps: steps,
          treadWidth: treadWidth,
          riserHeight: riserHeight,
        ) +
        landingLength) *
    flightWidth;
