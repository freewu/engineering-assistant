import 'area/defined.dart';
import 'building/defined.dart';
import 'concrete/defined.dart';
import 'distance/defined.dart';
import 'decoration/defined.dart';
import 'earthwork/defined.dart';
import 'formwork/defined.dart';
import 'energy/defined.dart';
import 'insulation/defined.dart';
import 'masonry/defined.dart';
import 'material/defined.dart';
import 'paint/defined.dart';
import 'pressure/defined.dart';
import 'rebar/defined.dart';
import 'roof/defined.dart';
import 'speed/defined.dart';
import 'temperature/defined.dart';
import 'volume/defined.dart';
import 'weight/defined.dart';
import 'tool_info.dart';

export 'tool_info.dart';

/// 全部内置工具，顺序即工具页展示顺序。
///
/// 每项元数据都在各自目录的 `defined.dart` 里声明，这里只负责汇总。
/// 目前是八个单位换算工具 + 材料用量估算 + 建筑面积 + 混凝土构件 + 土石方工程
/// + 钢筋工程 + 砌筑工程 + 模板工程 + 屋面及防水工程 + 保温隔热 + 装饰装修 + 油漆涂料，
/// 其余工程工具后续逐个补上。
///
/// 用 getter 而不是 `final` 变量：卡片配色取自 [AppColors]，而顶层 `final`
/// 只在首次访问时求值，切到浅色主题后颜色就会停在旧配色上。
List<ToolInfo> get kTools => List.unmodifiable(<ToolInfo>[
  materialTool,
  buildingAreaTool,
  concreteTool,
  earthworkTool,
  rebarTool,
  masonryTool,
  formworkTool,
  roofTool,
  insulationTool,
  decorationTool,
  paintTool,
  distanceTool,
  areaTool,
  volumeTool,
  weightTool,
  temperatureTool,
  energyTool,
  pressureTool,
  speedTool,
]);

/// 当前界面语言下应该展示的工具。
List<ToolInfo> get visibleTools =>
    List.unmodifiable(kTools.where((tool) => tool.isAvailable));

/// 按 id 查找当前语言下可见的工具，找不到返回 null。
ToolInfo? toolById(String id) {
  for (final tool in visibleTools) {
    if (tool.id == id) return tool;
  }
  return null;
}
