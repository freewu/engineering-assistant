/// 砌筑工程（GB/T 50854-2024）。
///
/// 三类常见项：砖墙、砖基础、特殊墙体（空斗墙 / 空花墙 / 多孔砖墙）。
/// 通用规则：按设计图示尺寸以体积计算，**不扣除单个 ≤ 0.3 ㎡ 的孔洞**；
/// 墙长外墙按中心线、内墙按净长，墙高外墙算至檐口、内墙算至板底。
/// 本文件不依赖 Flutter，便于单测。
library;

import 'dart:math' as math;

/// 页面上的 tab 数量（砖墙 / 砖基础 / 特殊墙体）。
const int kMasonryTabCount = 3;

/// 不扣除的单个孔洞面积上限（㎡）。
const double kMasonryHoleThreshold = 0.3;

/// 标准砖墙厚（m）：240 墙取 0.24，120 墙取 0.115。
const double kWallThickness240 = 0.24;
const double kWallThickness120 = 0.115;

/// 砖墙体积（m³）：V = (L × H − 门窗洞口面积) × t − 混凝土构件体积。
///
/// [length] 是墙长（外墙中心线 / 内墙净长），[height] 是墙高，[thickness] 是
/// 墙厚。单个 ≤ [kMasonryHoleThreshold] 的洞口不扣除；[concreteVolume] 是墙上
/// 的混凝土构件（圈梁、构造柱、过梁）体积，要从砖墙里扣掉。
double brickWallVolume({
  required double length,
  required double height,
  required double thickness,
  double openingArea = 0,
  double concreteVolume = 0,
}) {
  final opening = deductedOpening(openingArea);
  final wall = length * height - opening;
  return math.max(0, wall * thickness - concreteVolume);
}

/// 要扣除的洞口面积（㎡）：单个 ≤ 0.3 ㎡ 的孔洞并入墙体，不扣除。
double deductedOpening(double area) => area > kMasonryHoleThreshold ? area : 0;

/// 砖基础体积（折加高度法，m³）：V = t × (H + 折加高度) × (L中 + L内)。
///
/// [addedHeight] 是大放脚折算来的增加高度；图纸直接给出大放脚体积时用
/// [brickFoundationWithStepVolume]。
double brickFoundationVolume({
  required double thickness,
  required double height,
  required double addedHeight,
  required double centerlineLength,
  required double netLength,
}) => thickness * (height + addedHeight) * (centerlineLength + netLength);

/// 砖基础体积（大放脚体积法，m³）：
/// V = t × H × (L中 + L内) + 大放脚增加体积。
double brickFoundationWithStepVolume({
  required double thickness,
  required double height,
  required double centerlineLength,
  required double netLength,
  required double stepVolume,
}) => thickness * height * (centerlineLength + netLength) + stepVolume;

/// 特殊墙体的外形体积（m³）：V = L × H × t − 应扣除的孔洞体积。
///
/// 空斗墙、空花墙按外形体积计算，**不扣除**空洞（[holeVolume] 传 0）；
/// 多孔砖墙按设计图示尺寸以体积计算，要扣除孔洞体积。
double specialWallVolume({
  required double length,
  required double height,
  required double thickness,
  double holeVolume = 0,
}) => math.max(0, length * height * thickness - holeVolume);
