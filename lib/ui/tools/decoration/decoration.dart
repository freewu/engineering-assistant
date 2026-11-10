/// 装饰装修工程量（GB/T 50854-2024）。
///
/// 三类常见项：墙面抹灰 / 天棚抹灰 / 楼地面，均按设计图示尺寸以面积（㎡）计算。
/// 单个 ≤ 0.3 ㎡ 的孔洞不扣除。本文件不依赖 Flutter，便于单测。
library;

import 'dart:math' as math;

/// 页面上的 tab 数量（墙面 / 天棚 / 楼地面）。
const int kDecorationTabCount = 3;

/// 不扣除的单个孔洞（洞口）面积上限（㎡）。
const double kDecorationHoleThreshold = 0.3;

/// 应扣除的面积：只有大于 0.3 ㎡ 的孔洞才扣。
double deductedHole(double area) => area > kDecorationHoleThreshold ? area : 0;

/// 墙面装饰面积（㎡）：S = 墙长 × 墙高 − 门窗洞口面积 + 洞口侧壁面积 + 附墙柱梁侧面。
///
/// 单个 ≤ 0.3 ㎡ 的孔洞不扣，附墙柱、梁的侧面并入墙面。
double wallFinishArea({
  required double length,
  required double height,
  double openingArea = 0,
  double sideArea = 0,
  double attachedArea = 0,
}) =>
    math.max(0, length * height - deductedHole(openingArea)) +
    sideArea +
    attachedArea;

/// 天棚装饰面积（㎡）：S = 主墙间净面积 + 梁侧面面积。
///
/// 不扣单个 ≤ 0.3 ㎡ 的孔洞，也不扣间壁墙。
double ceilingFinishArea({required double netArea, double beamSideArea = 0}) =>
    netArea + beamSideArea;

/// 楼地面装饰面积（㎡）：S = 主墙间净面积 − 凸出地面的构筑物面积。
double floorFinishArea({required double netArea, double structureArea = 0}) =>
    math.max(0, netArea - deductedHole(structureArea));
