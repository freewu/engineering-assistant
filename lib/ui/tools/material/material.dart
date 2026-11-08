/// 材料用量估算：砖块、混凝土、水泥与砂子的快速估算公式。
///
/// 全部是施工方案阶段的经验值，用来快速校核工程量；正式下料仍以图纸、
/// 配合比与当地定额为准。本文件不依赖 Flutter，便于单独做单元测试。
library;

/// 砖型：每立方米砌体约用多少块砖。
enum BrickType {
  /// 标准红砖 240×115×53 mm，每立方米砌体约 512 块。
  standard(512, '标准红砖 240×115×53'),

  /// 多孔砖，每立方米砌体约 320 块。
  perforated(320, '多孔砖');

  const BrickType(this.perCubicMeter, this.spec);

  /// 每立方米砌体的砖数。
  final int perCubicMeter;

  /// 规格说明（中文兜底，界面文案另走多语言）。
  final String spec;
}

/// 墙厚档位：每平方米砌体的砖数，用来快速校核砖砌体估算是否合理。
enum WallThickness {
  /// 12 墙（120 mm）：约 64 块/m²。
  thin(120, 64),

  /// 24 墙（240 mm）：约 128 块/m²。
  standard(240, 128),

  /// 37 墙（370 mm）：约 192 块/m²。
  thick(370, 192);

  const WallThickness(this.millimeters, this.perSquareMeter);

  /// 墙厚（mm）。
  final int millimeters;

  /// 每平方米砌体的砖数。
  final int perSquareMeter;
}

/// 基础垫层的常用厚度（m）。
const double kCushionThickness = 0.1;

/// 楼板的常用厚度（m）。
const double kSlabThickness = 0.12;

/// 水泥单耗的经验区间（吨/㎡）：0.03 ~ 0.05。
const List<double> kCementRates = <double>[0.03, 0.04, 0.05];

/// 砂子单耗（m³/㎡）。
const double kSandRate = 0.05;

/// 砖块数量（块）：墙体体积（m³）× 每立方米砖数。
double brickCount(double volume, BrickType type) => volume * type.perCubicMeter;

/// 每平方米砖数校核（块）：砌体面积（㎡）× 该墙厚的每平方米砖数。
double bricksByWall(double area, WallThickness wall) =>
    area * wall.perSquareMeter;

/// 混凝土用量（m³）：面积（㎡）× 厚度（m）。
double concreteVolume(double area, double thickness) => area * thickness;

/// 水泥用量（吨）：建筑面积（㎡）× 单耗（吨/㎡）。
double cementTons(double area, double rate) => area * rate;

/// 砂子用量（m³）：建筑面积（㎡）× 单耗（默认 0.05 m³/㎡）。
double sandVolume(double area, {double rate = kSandRate}) => area * rate;
