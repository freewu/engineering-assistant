/// 混凝土构件工程量：按设计图示尺寸以体积计算。
///
/// 通用规则：不扣除钢筋、螺栓、预埋铁件，以及单个 ≤ 300 mm × 300 mm 的孔洞。
/// 纯逻辑，不依赖 Flutter，方便单测。
library;

/// 单个孔洞面积 ≤ 300 mm × 300 mm（= 0.09 ㎡）一律不扣除。
const double kIgnoredHoleArea = 0.3 * 0.3;

/// 现浇板单个孔洞面积超过 0.3 ㎡ 才从板面积里扣除。
const double kDeductHoleArea = 0.3;

/// 楼梯折算厚度常见取值范围（按定额取）。
const double kStairThicknessMin = 0.2;
const double kStairThicknessMax = 0.3;

/// 楼梯折算厚度常用值。
const double kDefaultStairThickness = 0.25;

/// 页面上的构件 tab 数量（柱 / 梁 / 板 / 墙 / 楼梯）。
const int kConcreteTabCount = 5;

/// 矩形柱：V = a × b × H（H 多用基础顶面至梁底）。
double columnVolume({
  required double sectionA,
  required double sectionB,
  required double height,
}) => sectionA * sectionB * height;

/// 矩形梁：V = a × b × L（L 取柱间净距）。
double beamVolume({
  required double sectionA,
  required double sectionB,
  required double length,
}) => sectionA * sectionB * length;

/// 单个孔洞要不要扣除：≤ 0.3 ㎡ 不扣，> 0.3 ㎡ 才扣。
bool holeDeducted(double holeArea) => holeArea > kDeductHoleArea;

/// 现浇板：V = （净长 × 净宽 − 扣除孔洞）× 板厚。
///
/// [holeArea] 是单个孔洞面积，按 [holeDeducted] 判断要不要扣；孔洞比板面还大
/// 时按 0 算，避免出现负数。
double slabVolume({
  required double length,
  required double width,
  required double thickness,
  double holeArea = 0,
}) {
  final deductible = holeDeducted(holeArea) ? holeArea : 0.0;
  final net = length * width - deductible;
  return (net > 0 ? net : 0.0) * thickness;
}

/// 混凝土墙：V = 墙长 × 墙高 × 墙厚。
double wallVolume({
  required double length,
  required double height,
  required double thickness,
}) => length * height * thickness;

/// 楼梯：V = 水平投影面积 × 折算厚度。
double stairVolume({
  required double planArea,
  required double equivalentThickness,
}) => planArea * equivalentThickness;
