/// 建筑面积计算：按常用条款把各部分的面积算出来再相加。
///
/// 规则取自「单层 / 多层 / 阳台 / 雨篷 / 门斗 / 车棚货棚」六类常见构件，
/// 只做快速估算，正式报建以现行《建筑工程建筑面积计算规范》与图纸为准。
/// 本文件不依赖 Flutter，便于单独做单元测试。
library;

/// 算全面积的结构高度门槛（m）：≥ 2.2 m 算全面积，不足算 1/2。
const double kFullAreaHeight = 2.2;

/// 页面上的 tab 数量（单层 / 多层 / 阳台 / 雨篷 / 门斗 / 车棚货棚）。
const int kBuildingTabCount = 6;

/// 无柱雨篷需要达到的宽度（m）：宽度 > 2.1 m 才计算建筑面积。
const double kCanopyMinWidth = 2.1;

/// 单层建筑：S = L × B，结构高度不足 2.2 m 时只算一半。
double singleStoreyArea(double length, double width, double height) =>
    length * width * (height >= kFullAreaHeight ? 1 : 0.5);

/// 多层建筑：S = 各层面积之和。
///
/// 各层一样大时就是「层数 × 每层面积」；首层与标准层不同就分开算再加。
double multiStoreyArea(int floors, double areaPerFloor) =>
    floors * areaPerFloor;

/// 阳台：按围护结构外围水平面积的 1/2 计算，与封闭与否无关。
double balconyArea(double area) => area / 2;

/// 雨篷：有柱按结构底板水平投影面积计算；无柱时宽度超过 2.1 m 才算。
double canopyArea(
  double area, {
  required double width,
  required bool hasColumns,
}) {
  if (hasColumns) return area;
  return width > kCanopyMinWidth ? area : 0;
}

/// 门斗：结构层高 ≥ 2.2 m 算全面积，不足算 1/2。
double vestibuleArea(double area, double storeyHeight) =>
    area * (storeyHeight >= kFullAreaHeight ? 1 : 0.5);

/// 车棚 / 货棚：有顶盖无围护结构，按顶盖水平投影面积的 1/2 计算。
double shedArea(double area) => area / 2;

/// 把各部分面积加起来；空着的项（null）按 0 处理。
double totalArea(Iterable<double?> parts) =>
    parts.fold(0, (sum, part) => sum + (part ?? 0));
