import 'building/building_area.dart';
import 'concrete/concrete_member.dart';
import 'earthwork/earthwork.dart';
import 'formwork/formwork.dart';
import 'masonry/masonry.dart';
import 'material/material.dart';
import 'paint/paint.dart';
import 'rebar/rebar.dart';
import 'decoration/decoration.dart';
import 'insulation/insulation.dart';
import 'roof/roof.dart';

/// 带 tab 的工具各自有几个 tab。
///
/// 设置页存「默认 tab」时用它兜住越界值（键 `<工具 id>.tab`），新增带 tab 的
/// 工具时在这里加一行即可。
const Map<String, int> kToolTabCounts = <String, int>{
  'material': kMaterialTabCount,
  'building_area': kBuildingTabCount,
  'concrete': kConcreteTabCount,
  'earthwork': kEarthworkTabCount,
  'rebar': kRebarTabCount,
  'masonry': kMasonryTabCount,
  'formwork': kFormworkTabCount,
  'roof': kRoofTabCount,
  'insulation': kInsulationTabCount,
  'decoration': kDecorationTabCount,
  'paint': kPaintTabCount,
};
