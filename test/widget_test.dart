import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_assistant/app.dart';
import 'package:engineering_assistant/core/math_engine.dart';
import 'package:engineering_assistant/plot/plot_export.dart';
import 'package:engineering_assistant/l10n/app_language.dart';
import 'package:engineering_assistant/services/plot_file_saver.dart';
import 'package:engineering_assistant/services/settings_store.dart';
import 'package:engineering_assistant/state/plot_controller.dart';
import 'package:engineering_assistant/state/settings_controller.dart';
import 'package:engineering_assistant/theme/app_theme.dart';
import 'package:engineering_assistant/ui/settings_page.dart';
import 'package:engineering_assistant/ui/tools/tool_catalog.dart';
import 'package:engineering_assistant/ui/widgets/calc_display.dart';
import 'package:engineering_assistant/ui/widgets/plot_export_dialog.dart';
import 'package:engineering_assistant/ui/tools/area/area_page.dart';
import 'package:engineering_assistant/ui/tools/distance/distance_page.dart';
import 'package:engineering_assistant/ui/tools/energy/energy_page.dart';
import 'package:engineering_assistant/ui/tools/pressure/pressure_page.dart';
import 'package:engineering_assistant/ui/tools/speed/speed_page.dart';
import 'package:engineering_assistant/ui/tools/temperature/temperature_page.dart';
import 'package:engineering_assistant/ui/tools/volume/volume_page.dart';
import 'package:engineering_assistant/ui/tools/weight/weight_page.dart';
import 'package:engineering_assistant/ui/widgets/keypad.dart';
import 'package:engineering_assistant/plot/plot_painter.dart';
import 'package:engineering_assistant/ui/widgets/plot_canvas.dart';

void main() {
  // 默认的设置存储换成内存里的：测试不该读写开发机上的真实配置，
  // 工具页的输入草稿（ToolDraft）也会落到这里。
  setUp(() => SettingsController.defaultStore = _MemoryStore());
  tearDown(() => SettingsController.defaultStore = null);

  Future<void> tapKey(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(of: find.byType(Keypad), matching: find.text(label)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EngineeringAssistantApp());
    await tester.pumpAndSettle();
  }

  testWidgets('桌面尺寸：键盘输入并计算 30° 的正弦', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    expect(find.byType(Keypad), findsOneWidget);

    await tapKey(tester, 'sin');
    await tapKey(tester, '3');
    await tapKey(tester, '0');
    await tapKey(tester, ')');
    await tapKey(tester, '=');

    // 显示屏上的实时结果与历史记录都应出现 0.5
    expect(find.text('0.5'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('表达式错误时展示提示且不崩溃', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tapKey(tester, '7');
    await tapKey(tester, '+');
    expect(find.textContaining('表达式不完整'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('切换到绘图页并平移画布', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    expect(find.byType(PlotCanvas), findsOneWidget);

    // 拖拽平移
    await tester.drag(find.byType(PlotCanvas), const Offset(-80, 40));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // 缩放按钮
    await tester.tap(find.byTooltip('放大（+）'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图画布：方向按钮与键盘平移视图', (tester) async {
    final controller = PlotController(engine: MathEngine());
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PlotCanvas(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    final start = controller.viewport;

    // 上移视图：y 范围整体变大，比例不变
    await tester.tap(find.byTooltip('上移视图（↑）'));
    await tester.pumpAndSettle();
    expect(controller.viewport.minY, greaterThan(start.minY));
    expect(controller.viewport.spanY, closeTo(start.spanY, 1e-6));
    expect(controller.viewport.minX, closeTo(start.minX, 1e-6));

    // 右移视图：向右看，minX 变大
    final afterUp = controller.viewport;
    await tester.tap(find.byTooltip('右移视图（→）'));
    await tester.pumpAndSettle();
    expect(controller.viewport.minX, greaterThan(afterUp.minX));
    expect(controller.viewport.spanX, closeTo(afterUp.spanX, 1e-6));

    // 键盘 ← 向左看
    final afterButton = controller.viewport;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(controller.viewport.minX, lessThan(afterButton.minX));

    // 键盘 ↓ 向下看
    final afterLeft = controller.viewport;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(controller.viewport.minY, lessThan(afterLeft.minY));

    // 键盘 0 重置视图
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.pumpAndSettle();
    expect(controller.viewport.minX, closeTo(start.minX, 1e-6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机尺寸：布局不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    expect(find.byType(Keypad), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();
    expect(find.byType(PlotCanvas), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('设置页：深链打开、切浅色主题后配色与保存都变了', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 3),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
    // 语言是一个下拉框，默认显示当前语言
    expect(find.byKey(const Key('settings-language')), findsOneWidget);
    expect(find.text('简体中文 · Chinese (Simplified)'), findsOneWidget);
    // 默认跟随系统（测试里系统是浅色）
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).theme?.brightness,
      Brightness.light,
    );

    await tester.tap(find.byKey(const Key('settings-theme-dark')));
    await tester.pumpAndSettle();
    expect(settings.themeMode, AppThemeMode.dark);
    expect(store.values['theme_mode'], 'dark');
    final themed = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(themed.theme?.brightness, Brightness.dark);
    expect(themed.theme?.scaffoldBackgroundColor, const Color(0xFF0A0E14));
  });

  testWidgets('浅色模式：计算器按键、显示屏与工具卡片都跟着变浅', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 3),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-theme-light')));
    await tester.pumpAndSettle();

    // 切回计算器看按键：运算符键、强调键都不该再用深色配色的写死颜色
    await tester.tap(find.text('计算').last);
    await tester.pumpAndSettle();
    expect(AppColors.keyOperator, kLightPalette.keyOperator);

    DecoratedBox decoOf(String label) => tester.widget<DecoratedBox>(
      find
          .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
          .first,
    );

    final operatorKey = decoOf('÷').decoration as BoxDecoration;
    expect(operatorKey.color, kLightPalette.keyOperator);
    expect(operatorKey.color, isNot(kDarkPalette.keyOperator));

    final accentKey = decoOf('=').decoration as BoxDecoration;
    expect(accentKey.color, isNull);
    expect(
      (accentKey.gradient! as LinearGradient).colors.first,
      kLightPalette.primary,
    );

    // 显示屏渐变也不再是写死的深色
    final display = tester.widget<Container>(
      find.byKey(const Key('calc-display')),
    );
    final gradient = (display.decoration! as BoxDecoration).gradient!;
    expect((gradient as LinearGradient).colors, [
      kLightPalette.surface,
      kLightPalette.background,
    ]);

    // 工具卡片配色同样按当前主题取
    await tester.tap(find.text('工具').last);
    await tester.pumpAndSettle();
    expect(kTools.first.color, kLightPalette.tertiary);
    expect(kTools.first.color, isNot(kDarkPalette.tertiary));
  });

  testWidgets('设置页：温度默认单位改成华氏度后，温度换算页按 ℉ 打开', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 3),
    );
    await tester.pumpAndSettle();

    // 设置卡片里只有一项「默认单位」，没有体系 / 结果 tab
    expect(find.text('默认单位'), findsNWidgets(3));
    await tester.tap(
      find.byKey(const Key('settings-convert-temperature-unit')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('华氏度（°F）').last);
    await tester.pumpAndSettle();
    expect(store.values['convert.temperature.unit'], 'f');

    await tester.pumpWidget(
      EngineeringAssistantApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 2,
        initialTool: 'temperature',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 华氏度'), findsOneWidget);
    // 1 °F = −17.2222… °C = 255.928 K
    expect(find.text('-17.22222222'), findsOneWidget);
    expect(find.byType(Tab), findsNothing);
  });

  testWidgets('设置页：换算默认体系与结果 tab 生效且各工具互不影响', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 3),
    );
    await tester.pumpAndSettle();

    // 六个换算工具各有独立的一张卡片；温度不分体系，只有「默认单位」
    expect(find.text('单位换算默认值'), findsOneWidget);
    for (final id in ['distance', 'area', 'volume', 'weight', 'speed']) {
      expect(find.byKey(Key('settings-convert-$id-system')), findsOneWidget);
      expect(find.byKey(Key('settings-convert-$id-tab')), findsOneWidget);
    }
    // 温度 / 热量 / 压力不分体系，只有「默认单位」
    for (final id in ['temperature', 'energy', 'pressure']) {
      expect(
        find.byKey(Key('settings-convert-$id-system')),
        findsNothing,
        reason: id,
      );
      expect(find.byKey(Key('settings-convert-$id-tab')), findsNothing);
      expect(find.byKey(Key('settings-convert-$id-unit')), findsOneWidget);
    }
    expect(find.text('默认体系'), findsNWidgets(5));
    expect(find.text('长度换算'), findsOneWidget);
    expect(find.text('容量换算'), findsOneWidget);
    expect(find.text('温度换算'), findsOneWidget);
    expect(find.text('热量换算'), findsOneWidget);
    expect(find.text('压力换算'), findsOneWidget);

    // 长度换算：默认体系切市制、结果 tab 切英制
    await tester.tap(find.byKey(const Key('settings-convert-distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('市制').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-convert-distance-tab')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    expect(store.values['convert.distance.system'], 'chinese');
    expect(store.values['convert.distance.tab'], 'imperial');

    // 打开长度换算：体系是市制，结果 tab 停在英制
    // （换 key 让 HomePage 重新初始化，否则会沿用上一次的 tab 状态）
    await tester.pumpWidget(
      EngineeringAssistantApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 2,
        initialTool: 'distance',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.text('市制'), findsWidgets);
    final tabBar = tester.widget<TabBar>(find.byType(TabBar).last);
    expect(tabBar.controller?.index, 1);

    // 面积换算没设置过，仍是公制
    await tester.pumpWidget(
      EngineeringAssistantApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 2,
        initialTool: 'area',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AreaPage), findsOneWidget);
    final areaTabs = tester.widget<TabBar>(find.byType(TabBar).last);
    expect(areaTabs.controller?.index, 0);
  });

  testWidgets('设置页：切到日语后导航与工具卡片跟着变', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 3),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日本語 · Japanese').last);
    await tester.pumpAndSettle();
    expect(settings.language, AppLanguage.ja);
    expect(store.values['language'], 'ja');
    // 导航栏文案换成日语
    expect(find.text('設定'), findsWidgets);
    expect(find.text('計算'), findsWidgets);
    expect(find.text('设置'), findsNothing);

    // 工具页卡片名称也换成日语
    await tester.tap(find.text('ツール').last);
    await tester.pumpAndSettle();
    expect(find.text('長さ換算'), findsOneWidget);
    expect(find.text('面積換算'), findsOneWidget);
    expect(find.text('长度换算'), findsNothing);
    expect(find.text('8 個のアプリ'), findsOneWidget);
  });

  testWidgets('工具页内部文案：英文界面下标题、字段与说明都是英文', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(
      store: _MemoryStore(),
      language: AppLanguage.en,
    );

    Future<void> open(String tool) async {
      await tester.pumpWidget(
        EngineeringAssistantApp(
          key: UniqueKey(),
          settings: settings,
          initialTab: 2,
          initialTool: tool,
        ),
      );
      await tester.pumpAndSettle();
    }

    // 长度换算（六个换算工具共用一套外壳文案）
    await open('distance');
    expect(find.text('Unit system'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Common lengths'), findsOneWidget);
    expect(find.text('计量体系'), findsNothing);
    // 单位名称与参照物也跟着换语言（数据层 names）
    expect(find.text('metre'), findsOneWidget);
    expect(find.text('kilometre'), findsOneWidget);
    expect(find.text('Marathon'), findsOneWidget);
    expect(find.text('米'), findsNothing);
    expect(find.text('马拉松'), findsNothing);

    // 温度换算（不分体系的工具只有一张单位列表）
    await open('temperature');
    expect(find.text('Unit'), findsOneWidget);
    expect(find.text('单位'), findsNothing);

    // 速度换算
    await open('speed');
    expect(find.text('Common speeds'), findsOneWidget);
    expect(find.text('常见速度'), findsNothing);
  });

  testWidgets('计算器页：英文界面下提示、历史与函数库都是英文', (tester) async {
    // 窄屏才显示底部提示条与「历史」按钮，宽屏是右侧历史面板
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(
      store: _MemoryStore(),
      language: AppLanguage.en,
    );
    await tester.pumpWidget(
      EngineeringAssistantApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Keyboard works too: Enter evaluates, ↑↓ browse history'),
      findsOneWidget,
    );
    expect(find.text('History'), findsWidgets);
    expect(find.text('Clear'), findsWidgets);
    expect(find.textContaining('支持键盘输入'), findsNothing);
    expect(find.text('清空'), findsNothing);

    // 函数库：分类标题与函数说明（数据层只有中文，靠 functionDescriptions 覆盖）
    await tester.tap(find.byTooltip('Function library'));
    await tester.pumpAndSettle();
    expect(find.text('Trigonometry'), findsOneWidget);
    expect(find.text('Powers & roots'), findsOneWidget);
    // 函数说明是 chip 的 tooltip，不是可见文本
    expect(find.byTooltip('sin(x) — sine'), findsOneWidget);
    expect(find.byTooltip('cos(x) — cosine'), findsOneWidget);
    expect(find.text('三角'), findsNothing);
    expect(find.byTooltip('sin(x) — 正弦'), findsNothing);
  });

  testWidgets('计算器页：英文界面下报错提示也是英文（含位置）', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(
      store: _MemoryStore(),
      language: AppLanguage.en,
    );
    await tester.pumpWidget(
      EngineeringAssistantApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 0,
      ),
    );
    await tester.pumpAndSettle();

    await tapKey(tester, '7');
    await tapKey(tester, '+');
    expect(find.textContaining('Expression is incomplete'), findsWidgets);
    expect(find.textContaining('表达式不完整'), findsNothing);

    // 带占位符的模板：未定义变量会带出变量名
    await tapKey(tester, 'x');
    expect(
      find.textContaining('Undefined variable "x"'),
      findsWidgets,
      reason: '变量名要填进模板，而不是显示中文',
    );
  });

  testWidgets('绘图页：英文界面下标题、面板、空状态与示例都是英文', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(
      store: _MemoryStore(),
      language: AppLanguage.en,
    );
    await tester.pumpWidget(
      EngineeringAssistantApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 1,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Function plot'), findsOneWidget);
    expect(find.text('Curves'), findsOneWidget);
    expect(find.text('Cartesian'), findsWidgets);
    expect(
      find.text(
        'Tip: wheel / pinch to zoom, drag to pan, hover or long-press for values',
      ),
      findsOneWidget,
    );
    expect(find.text('函数绘图'), findsNothing);
    expect(find.text('曲线'), findsNothing);
    expect(find.text('直角坐标'), findsNothing);

    // 清空后画布的空状态提示
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    expect(
      find.text('No functions yet — tap “+” in the top right to add one'),
      findsOneWidget,
    );
    expect(find.textContaining('Tap + to add a curve'), findsOneWidget);

    // 示例曲线：名称与说明走 PlotPreset.names / descriptions
    await tester.tap(find.byTooltip('Sample curves'));
    await tester.pumpAndSettle();
    expect(find.text('Heart · polar'), findsOneWidget);
    expect(find.text('Rose curve'), findsOneWidget);
    expect(find.text('心形 · 极坐标'), findsNothing);
    expect(find.text('玫瑰线'), findsNothing);
    expect(find.textContaining('Source: Zhihu'), findsOneWidget);
    expect(find.textContaining('来源：知乎'), findsNothing);
  });

  testWidgets('换算页打开着切语言：标题、字段与单位名一起换', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 2),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(find.text('计量体系'), findsOneWidget);

    // 页面开着的时候切到英文：已压栈的页面也要跟着重建
    await settings.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('计量体系'), findsNothing);
    expect(find.text('Unit system'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('metre'), findsOneWidget);
    expect(find.text('米'), findsNothing);
  });

  testWidgets('深链 ?lang=en 覆盖本地设置，但不写回本地', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // 本机存的是简体，链接要能盖过它
    final store = _MemoryStore()..values['language'] = 'zh-Hans';
    final settings = SettingsController(
      store: store,
      language: AppLanguage.zhHans,
    );
    await tester.pumpWidget(
      EngineeringAssistantApp(
        settings: settings,
        initialTab: 2,
        initialTool: 'distance',
        deepLinkLanguage: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();
    // 链接里的语言生效
    expect(settings.language, AppLanguage.en);
    expect(find.text('Unit system'), findsOneWidget);
    // 没有写回本地，下次正常打开仍是简体
    expect(store.values['language'], 'zh-Hans');
  });

  testWidgets('设置页：切换语言后工具卡片的深链 id 不变', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(
      store: _MemoryStore(),
      language: AppLanguage.en,
    );
    await tester.pumpWidget(
      EngineeringAssistantApp(
        settings: settings,
        initialTab: 2,
        initialTool: 'distance',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.text('Unit system'), findsOneWidget);
    // 卡片文案已是英文，id 仍用于深链
    expect(
      kTools.map((tool) => tool.id),
      containsAll(<String>['distance', 'area', 'volume']),
    );
  });

  testWidgets('工具页：打开工具后可与其它 tab 来回切换', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();

    // 工具页内仍能看到导航菜单
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('计算'), findsOneWidget);
    expect(find.text('绘图'), findsOneWidget);

    // 切到计算器再切回工具，工具页面不丢
    await tester.tap(find.text('计算'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：长度换算用下拉框选体系单位，结果分三个 tab', (tester) async {
    // 结果行点击会写剪贴板，测试环境下不 mock 的话 Future 不会完成
    String? clipboard;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await pumpApp(tester, const Size(1440, 1600));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);

    // 「常见长度」在最上方，默认展开，点标题行可折叠隐藏
    final samplesY = tester
        .getTopLeft(find.byKey(const Key('distance-samples')))
        .dy;
    final inputY = tester.getTopLeft(find.text('输入')).dy;
    expect(samplesY, lessThan(inputY));
    expect(find.text('A4 纸厚'), findsOneWidget);
    expect(find.text('收起'), findsOneWidget);
    await tester.tap(find.text('收起'));
    await tester.pumpAndSettle();
    expect(find.text('A4 纸厚'), findsNothing);
    expect(find.text('展开'), findsOneWidget);
    // 折叠后输入区仍在原位（不因隐藏参照物而消失）
    expect(find.byKey(const Key('distance-system')), findsOneWidget);
    await tester.tap(find.text('展开'));
    await tester.pumpAndSettle();
    expect(find.text('A4 纸厚'), findsOneWidget);

    // 计量体系 / 单位都是下拉框，放在数值上方
    expect(find.byKey(const Key('distance-system')), findsOneWidget);
    expect(find.byKey(const Key('distance-unit')), findsOneWidget);
    final systemY = tester
        .getTopLeft(find.byKey(const Key('distance-system')))
        .dy;
    final fieldY = tester.getTopLeft(find.byType(TextField).first).dy;
    expect(systemY, lessThan(fieldY));

    // 默认 1 米：公制 tab 只列公制单位
    expect(find.text('1 米'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget); // 毫米
    expect(find.widgetWithText(Tab, '公制'), findsOneWidget);
    expect(find.widgetWithText(Tab, '英制'), findsOneWidget);
    expect(find.widgetWithText(Tab, '市制'), findsOneWidget);
    expect(find.text('英尺'), findsNothing);

    // 体系下拉切到英制：单位落到英寸，tab 跟着切到英制
    await tester.tap(find.byKey(const Key('distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    expect(find.text('英寸（in）'), findsOneWidget);
    expect(find.text('英尺'), findsOneWidget);
    expect(find.text('毫米'), findsNothing);

    // 单位下拉选英尺：1 英尺 = 12 英寸
    await tester.tap(find.byKey(const Key('distance-unit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英尺（ft）').last);
    await tester.pumpAndSettle();
    expect(find.text('1 英尺'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    // 5280 英尺 = 1 英里
    await tester.enterText(find.byType(TextField).first, '5280');
    await tester.pumpAndSettle();
    expect(find.text('5280 英尺'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // 点参照物「马拉松」代入 42.195 千米，tab 回到公制
    await tester.ensureVisible(find.text('马拉松'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('马拉松'));
    await tester.pumpAndSettle();
    expect(find.text('42.195 千米'), findsOneWidget);
    expect(find.text('42195'), findsOneWidget); // 米

    // 先只看市制 tab：输入仍是 42.195 千米，tab 一换就能看到市制结果
    await tester.tap(find.widgetWithText(Tab, '市制'));
    await tester.pumpAndSettle();
    expect(find.text('42.195 千米'), findsOneWidget);
    expect(find.text('126585'), findsOneWidget); // 42.195 千米 = 126585 尺
    expect(find.text('1 里 = 150 丈 = 500 米'), findsNothing);

    // 体系下拉切到市制：单位落到里，说明文案跟着变
    await tester.tap(find.byKey(const Key('distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('市制').last);
    await tester.pumpAndSettle();
    expect(find.text('42.195 里'), findsOneWidget);
    expect(find.text('63292.5'), findsOneWidget); // 尺
    expect(find.text('1 里 = 150 丈 = 500 米'), findsOneWidget);

    // 单位下拉里选「尺」
    await tester.tap(find.byKey(const Key('distance-unit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('尺').last);
    await tester.pumpAndSettle();
    expect(find.text('42.195 尺'), findsOneWidget);
    expect(find.text('1 尺 = 1/3 米 ≈ 33.33 厘米'), findsOneWidget);

    // 点结果行复制到剪贴板：42.195 尺 = 421.95 寸
    await tester.tap(find.text('421.95'));
    await tester.pumpAndSettle();
    expect(clipboard, '421.95 寸');
    expect(find.text('已复制 421.95 寸'), findsOneWidget);

    // 清空数值显示空状态
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.text('填入数值并选好单位后自动换算'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // (深链 id, 页面类型, 默认换算的标题, 结果里必须出现的一行)
  const convertCases = <(String, Type, String, String)>[
    ('area', AreaPage, '1 平方米', '10000'),
    ('volume', VolumePage, '1 升', '1000'),
    ('weight', WeightPage, '1 千克', '1000'),
  ];
  for (final (id, type, headline, row) in convertCases) {
    testWidgets('工具页：$id 深链打开并换算', (tester) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // 换 key 让 HomePage 重新挂载，否则会停在上一个工具的页面上
      await tester.pumpWidget(
        EngineeringAssistantApp(
          key: UniqueKey(),
          initialTab: 2,
          initialTool: id,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(type), findsOneWidget);
      expect(find.byKey(Key('$id-system')), findsOneWidget);
      expect(find.byKey(Key('$id-unit')), findsOneWidget);
      expect(find.byKey(Key('$id-samples')), findsOneWidget);
      expect(find.text(headline), findsOneWidget);
      expect(find.text(row), findsOneWidget);
      // 结果区三个体系 tab 齐全
      expect(find.widgetWithText(Tab, '公制'), findsOneWidget);
      expect(find.widgetWithText(Tab, '英制'), findsOneWidget);
      expect(find.widgetWithText(Tab, '市制'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('重量换算：切市制 tab、点参照物与复制整行', (tester) async {
    String? clipboard;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 2, initialTool: 'weight'),
    );
    await tester.pumpAndSettle();

    // 默认 1 千克：公制 tab 只有公制单位
    expect(find.text('克'), findsOneWidget);
    expect(find.text('斤'), findsNothing);

    // 点参照物「一袋大米」代入 10 千克
    await tester.ensureVisible(find.text('一袋大米'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('一袋大米'));
    await tester.pumpAndSettle();
    expect(find.text('10 千克'), findsOneWidget);

    // 切到市制 tab 才会出现斤两钱，输入不变
    await tester.tap(find.widgetWithText(Tab, '市制'));
    await tester.pumpAndSettle();
    expect(find.text('斤'), findsWidgets);
    expect(find.text('20'), findsOneWidget); // 10 千克 = 20 斤
    expect(find.text('克'), findsNothing);

    // 点「斤」那一行复制（结果区里最后一个「斤」）
    await tester.tap(find.text('斤').last);
    await tester.pumpAndSettle();
    expect(clipboard, '20 斤');
    expect(find.text('已复制 20 斤'), findsOneWidget);

    // 体系下拉切市制：单位落到该体系第一个（担），数值保持不变
    await tester.tap(find.byKey(const Key('weight-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('市制').last);
    await tester.pumpAndSettle();
    expect(find.text('10 担'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget); // 10 担 = 1000 斤
    expect(tester.takeException(), isNull);
  });

  testWidgets('温度换算：不分公制英制，一个下拉与一张结果列表', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 2, initialTool: 'temperature'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TemperaturePage), findsOneWidget);
    // 不再有「计量体系」下拉与结果 tab
    expect(find.byKey(const Key('temperature-system')), findsNothing);
    expect(find.byType(Tab), findsNothing);
    // 1 °C = 33.8 °F = 274.15 K 一次全列出来
    expect(find.text('1 摄氏度'), findsOneWidget);
    expect(find.text('33.8'), findsOneWidget);
    expect(find.text('274.15'), findsOneWidget);

    // 单位下拉里有三种温标，没有公制 / 英制 / 市制分组
    await tester.tap(find.byKey(const Key('temperature-unit')));
    await tester.pumpAndSettle();
    expect(find.text('摄氏度（°C）'), findsWidgets);
    expect(find.text('华氏度（°F）'), findsOneWidget);
    expect(find.text('开尔文（K）'), findsOneWidget);
    expect(find.text('公制'), findsNothing);
    expect(find.text('英制'), findsNothing);
    expect(find.text('市制'), findsNothing);

    // 改用华氏度输入：32 °F = 0 °C = 273.15 K
    await tester.tap(find.text('华氏度（°F）').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '32');
    await tester.pumpAndSettle();
    expect(find.text('32 华氏度'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('273.15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('热量换算：不分体系，瓦时与焦耳卡路里一次全列出来', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 2, initialTool: 'energy'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EnergyPage), findsOneWidget);
    // 没有「计量体系」下拉与结果 tab
    expect(find.byKey(const Key('energy-system')), findsNothing);
    expect(find.byType(Tab), findsNothing);
    // 默认 1 瓦时 = 3600 焦 = 3.6 千焦 = 1000 毫瓦时
    expect(find.text('1 瓦时'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
    expect(find.text('3600'), findsOneWidget);
    expect(find.text('3.6'), findsOneWidget);

    // 单位下拉一次列全八种，没有公制 / 英制 / 市制分组
    await tester.tap(find.byKey(const Key('energy-unit')));
    await tester.pumpAndSettle();
    for (final label in ['毫瓦时（mWh）', '瓦时（Wh）', '千瓦时（kWh）', '焦耳（J）']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('公制'), findsNothing);

    // 换成千卡输入：1 千卡 = 4184 焦 = 4.184 千焦
    await tester.scrollUntilVisible(
      find.text('千卡（kcal）'),
      60,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('兆瓦时（MWh）'), findsWidgets);
    expect(find.text('千卡（kcal）'), findsWidgets);
    await tester.tap(find.text('千卡（kcal）').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pumpAndSettle();
    expect(find.text('1 千卡'), findsOneWidget);
    expect(find.text('4184'), findsOneWidget);
    expect(find.text('4.184'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('压力换算：不分体系，帕与巴 psi 一次全列出来', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 2, initialTool: 'pressure'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PressurePage), findsOneWidget);
    expect(find.byKey(const Key('pressure-system')), findsNothing);
    expect(find.byType(Tab), findsNothing);
    // 默认 1 帕 = 0.01 百帕 = 0.001 千帕
    expect(find.text('1 帕'), findsOneWidget);
    expect(find.text('0.01'), findsOneWidget);
    expect(find.text('0.001'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pressure-unit')));
    await tester.pumpAndSettle();
    expect(find.text('磅力/平方英寸（psi）'), findsOneWidget);
    expect(find.text('托（torr）'), findsOneWidget);

    // 换成巴输入：1 巴 = 100 千帕 = 1000 百帕
    await tester.tap(find.text('巴（bar）').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pumpAndSettle();
    expect(find.text('1 巴'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('速度换算：千米每小时与米每秒互转', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 2, initialTool: 'speed'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SpeedPage), findsOneWidget);
    // 默认 1 千米/小时 ≈ 0.2778 米/秒
    expect(find.text('1 千米/小时'), findsOneWidget);
    expect(find.text('0.2777777778'), findsOneWidget);

    // 输入 36 千米/小时 = 10 米/秒
    await tester.enterText(find.byType(TextField).first, '36');
    await tester.pumpAndSettle();
    expect(find.text('36 千米/小时'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机尺寸：新换算工具页不溢出', (tester) async {
    for (final id in <String>[
      'area',
      'volume',
      'weight',
      'temperature',
      'energy',
      'pressure',
      'speed',
    ]) {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // 换 key 让 HomePage 重新挂载，否则会停在上一个工具的页面上
      await tester.pumpWidget(
        EngineeringAssistantApp(
          key: UniqueKey(),
          initialTab: 2,
          initialTool: id,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget, reason: id);
      if (const <String>{'temperature', 'energy', 'pressure'}.contains(id)) {
        // 温度 / 热量 / 压力不分体系，页面里没有 tab
        expect(find.byType(Tab), findsNothing, reason: id);
      } else {
        expect(find.widgetWithText(Tab, '公制'), findsOneWidget, reason: id);
      }
      expect(tester.takeException(), isNull, reason: id);
    }
  });

  testWidgets('工具页：手机尺寸下长度换算不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 两个下拉框并排、三个 tab 平分宽度，窄屏下都不能溢出
    await tester.tap(find.widgetWithText(Tab, '市制'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：深链 ?tool=distance 直接打开工具并可返回', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 2, initialTool: 'distance'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.text('长度换算'), findsOneWidget);
    // 深链打开工具时导航菜单同样保留
    expect(find.byType(NavigationRail), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsNothing);
    expect(find.text('容量换算'), findsOneWidget);
  });

  testWidgets('工具页：置顶的工具排在最前面，再点一次取消', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(initialTab: 2, settings: settings),
    );
    await tester.pumpAndSettle();

    // 一开始没有置顶分区
    expect(find.text('置顶工具'), findsNothing);
    expect(find.byKey(const Key('tool-pin-volume')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tool-pin-volume')));
    await tester.pumpAndSettle();

    expect(find.text('置顶工具'), findsOneWidget);
    expect(find.text('已置顶 1 / 3'), findsOneWidget);
    expect(settings.pinnedTools, <String>['volume']);
    expect(store.values['pinned_tools'], 'volume');
    // 置顶的容量换算跑到上面，长度换算换到「其他工具」分区
    expect(
      tester.getTopLeft(find.text('容量换算')).dy,
      lessThan(tester.getTopLeft(find.text('长度换算')).dy),
    );

    await tester.tap(find.byKey(const Key('tool-pin-volume')));
    await tester.pumpAndSettle();
    expect(find.text('置顶工具'), findsNothing);
    expect(settings.pinnedTools, isEmpty);
    expect(store.values['pinned_tools'], '');
  });

  testWidgets('工具页：顶满 3 个后再置顶会提示上限，设置里放宽后可以再置顶', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = SettingsController(store: _MemoryStore());
    for (final id in <String>['distance', 'area', 'volume']) {
      await settings.togglePinned(id);
    }
    await tester.pumpWidget(
      EngineeringAssistantApp(initialTab: 2, settings: settings),
    );
    await tester.pumpAndSettle();
    expect(find.text('已置顶 3 / 3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tool-pin-weight')));
    await tester.pumpAndSettle();
    expect(find.text('最多只能置顶 3 个工具，可在设置里调整'), findsOneWidget);
    expect(settings.isPinned('weight'), isFalse);

    // 设置页把上限改成 5 之后还能继续置顶
    await settings.setPinnedLimit(5);
    await tester.pumpAndSettle();
    expect(find.text('已置顶 3 / 5'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tool-pin-weight')));
    await tester.pumpAndSettle();
    expect(settings.isPinned('weight'), isTrue);
    expect(find.text('已置顶 4 / 5'), findsOneWidget);
  });

  testWidgets('手机尺寸：置顶后工具页卡片不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tool-pin-distance')));
    await tester.pumpAndSettle();
    expect(find.text('置顶工具'), findsOneWidget);
    expect(find.text('已置顶 1 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('设置页：置顶数量默认 3，可在 2 ~ 5 之间调整并写回本地', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('已置顶 0 / 3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-pinned-limit')));
    await tester.pumpAndSettle();
    // 选项只有 2 / 3 / 4 / 5
    expect(find.text('2'), findsWidgets);
    expect(find.text('4'), findsWidgets);
    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();

    expect(find.text('已置顶 0 / 5'), findsOneWidget);
    expect(currentSettings?.pinnedLimit, 5);
  });

  testWidgets('工具页：重新进入后保留上次填的数值与单位', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(
        initialTab: 2,
        initialTool: 'distance',
        settings: settings,
      ),
    );
    await tester.pumpAndSettle();

    // 体系切到英制、单位换成英尺、填 5280，然后返回工具列表
    await tester.tap(find.byKey(const Key('distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('distance-unit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英尺（ft）').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '5280');
    await tester.pumpAndSettle();
    expect(find.text('5280 英尺'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();

    // 数值与单位都还是上次的
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.text('5280 英尺'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      '5280',
    );
    // 结果也确实按英尺算（5280 ft = 1 英里）
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('工具页：手机尺寸下卡片与工具页不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    expect(find.text('长度换算'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // 手机上打开工具后底部菜单仍在
    expect(find.byType(NavigationBar), findsOneWidget);

    // 手机上英制输入也不溢出
    await tester.tap(find.text('英制'));
    await tester.pumpAndSettle();
    expect(find.text('ft'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('平板尺寸：绘图页切换导航不溢出', (tester) async {
    await pumpApp(tester, const Size(900, 1200));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('计算'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：添加曲线、编辑表达式、错误提示与删除', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    // 初始有两条默认曲线
    expect(find.byType(TextField), findsNWidgets(2));

    // 通过 + 菜单新增一条直角坐标曲线
    await tester.tap(find.byTooltip('添加曲线'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('直角坐标 y = f(x)').last);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));

    // 输入非法表达式应给出错误提示
    await tester.enterText(find.byType(TextField).last, 'x+');
    await tester.pumpAndSettle();
    expect(find.textContaining('不完整'), findsWidgets);

    // 改成合法表达式后错误消失
    await tester.enterText(find.byType(TextField).last, 'x^2 - 3');
    await tester.pumpAndSettle();
    expect(find.textContaining('不完整'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：切换到参数方程需要两个表达式', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('添加曲线'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('参数方程').last);
    await tester.pumpAndSettle();

    // 2 条默认 + 参数方程的两行
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('y ='), findsNWidgets(3));
    expect(find.text('x ='), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：添加隐式方程曲线并输入表达式', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('添加曲线'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('隐式方程 f(x, y) = 0').last);
    await tester.pumpAndSettle();

    // 2 条默认曲线 + 隐式方程的一行输入框
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('0 ='), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '(x^2+y^2-1)^3-x^2y^3');
    await tester.pumpAndSettle();
    expect(find.textContaining('不完整'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：追踪模式与纵向自适应', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('纵向自适应'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('显示全部'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('重置视图（0）'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('开启触摸追踪（拖动查看数值）'));
    await tester.pumpAndSettle();

    // 开启追踪后拖动应出现读数
    await tester.drag(find.byType(PlotCanvas), const Offset(-40, 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('乘号按键显示 * 并参与计算', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    expect(
      find.descendant(of: find.byType(Keypad), matching: find.text('*')),
      findsOneWidget,
    );

    await tapKey(tester, '7');
    await tapKey(tester, '*');
    await tapKey(tester, '8');
    await tapKey(tester, '=');

    expect(find.text('56'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：示例追加曲线且不把已有图形挤出视野', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    final canvasSize = tester.getSize(find.byType(PlotCanvas));
    final before = _plotPainter(tester);
    expect(before.samples.length, 2);
    final beforeViewport = before.viewport;

    await tester.tap(find.byTooltip('示例曲线'));
    await tester.pumpAndSettle();
    expect(find.text('示例曲线'), findsWidgets);
    expect(find.text('心形 · 参数方程'), findsOneWidget);

    await tester.tap(find.text('心形 · 参数方程'));
    await tester.pumpAndSettle();

    // 示例只追加曲线：默认两条 + 参数方程的两行输入
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.textContaining('16sin(t)^3'), findsWidgets);
    expect(find.textContaining('0.12x^2 - 2'), findsWidgets);
    expect(find.textContaining('已添加示例'), findsOneWidget);

    // 画布实际绘制的曲线条数增加，且原有曲线仍在视野内
    final after = _plotPainter(tester);
    // 默认两条 + 参数方程一条
    expect(after.samples.length, 3);
    expect(after.viewport.minX, lessThanOrEqualTo(beforeViewport.minX));
    expect(after.viewport.maxX, greaterThanOrEqualTo(beforeViewport.maxX));
    expect(after.viewport.minY, lessThanOrEqualTo(beforeViewport.minY));
    expect(after.viewport.maxY, greaterThanOrEqualTo(beforeViewport.maxY));
    for (final sample in after.samples.take(2)) {
      final visible = sample.curve.segments
          .expand((segment) => segment)
          .any(
            (point) => after.viewport.containsData(
              after.viewport.toData(point, canvasSize),
            ),
          );
      expect(visible, isTrue, reason: sample.function.expression);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：连续载入两个示例后曲线都还在视野内', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    for (final name in ['心形 · 极坐标', '玫瑰线']) {
      await tester.tap(find.byTooltip('示例曲线'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    final canvasSize = tester.getSize(find.byType(PlotCanvas));
    final painter = _plotPainter(tester);
    // 两条默认曲线 + 心形 + 玫瑰线
    expect(painter.samples.length, 4);
    for (final sample in painter.samples) {
      final visible = sample.curve.segments
          .expand((segment) => segment)
          .any(
            (point) => painter.viewport.containsData(
              painter.viewport.toData(point, canvasSize),
            ),
          );
      expect(visible, isTrue, reason: sample.function.expression);
    }
    expect(find.textContaining('已添加示例'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：导出对话框可打开并切换格式', (tester) async {
    await pumpApp(tester, const Size(1200, 800));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('导出图片（PNG / SVG / WebP）'));
    await tester.pumpAndSettle();

    expect(find.text('导出图片'), findsOneWidget);
    for (final format in ['PNG', 'WebP', 'SVG']) {
      expect(find.text(format), findsWidgets);
    }
    // 默认 PNG：位图尺寸按 2 倍图显示
    expect(find.textContaining('2 倍图'), findsOneWidget);
    // 「保存位置」要写真实落盘目录，不能只写笼统的「图片 / 下载」
    expect(find.text(plotSaveLocationNote()), findsOneWidget);

    await tester.tap(find.text('SVG'));
    await tester.pumpAndSettle();
    expect(find.textContaining('可无限缩放'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('导出图片'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('导出对话框：选 WebP 后保存，结果交给保存器', (tester) async {
    final controller = PlotController(engine: MathEngine());
    controller.reportCanvasSize(const Size(200, 150));
    PlotExportFile? captured;
    SavedPlotFile? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  saved = await showDialog<SavedPlotFile>(
                    context: context,
                    builder: (_) => PlotExportDialog(
                      controller: controller,
                      // 渲染位图依赖引擎线程，Widget 测试里换成固定字节
                      exporter: const _FakeExporter(),
                      saver: (file) async {
                        captured = file;
                        return SavedPlotFile(
                          location: '/tmp/${file.fileName}',
                          fileName: file.fileName,
                        );
                      },
                    ),
                  );
                },
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('WebP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.fileName, endsWith('.webp'));
    expect(captured!.mimeType, 'image/webp');
    expect(String.fromCharCodes(captured!.bytes.sublist(0, 4)), 'RIFF');
    expect(saved?.fileName, captured!.fileName);
    expect(find.text('导出图片'), findsNothing);
  });

  testWidgets('手机尺寸：示例面板可滚动且不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('示例曲线'));
    await tester.pumpAndSettle();
    expect(find.text('心形 · 极坐标'), findsOneWidget);

    // 列表可滚动到末尾，底部来源信息可见
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.textContaining('zhuanlan.zhihu.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机横屏：绘图页使用左右布局且不溢出', (tester) async {
    await pumpApp(tester, const Size(844, 390));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();
    expect(find.byType(PlotCanvas), findsOneWidget);

    // 画布应占据左侧大部分宽度
    final canvas = tester.getSize(find.byType(PlotCanvas));
    expect(canvas.width, greaterThan(400));
    expect(canvas.height, greaterThan(240));
    expect(tester.takeException(), isNull);
  });

  group('复制为 LaTeX', () {
    String? clipboard;

    setUp(() {
      clipboard = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboard = (call.arguments as Map)['text'] as String?;
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('显示屏：复制公式为 LaTeX', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tapKey(tester, 'sin');
      await tapKey(tester, '3');
      await tapKey(tester, '0');
      await tapKey(tester, ')');

      await tester.tap(find.byTooltip('复制'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('复制公式（LaTeX）'));
      await tester.pumpAndSettle();

      expect(clipboard, r'\sin\left(30\right)');
      expect(find.text('LaTeX 已复制'), findsOneWidget);
    });

    testWidgets('显示屏：复制公式与结果', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tapKey(tester, 'sin');
      await tapKey(tester, '3');
      await tapKey(tester, '0');
      await tapKey(tester, ')');

      await tester.tap(find.byTooltip('复制'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('复制公式与结果（LaTeX）'));
      await tester.pumpAndSettle();

      expect(clipboard, r'\sin\left(30\right) = 0.5');
    });

    testWidgets('绘图页：复制曲线 LaTeX', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tester.tap(find.text('绘图'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('复制 LaTeX').first);
      await tester.pumpAndSettle();

      expect(clipboard, r'y = \sin\left(x\right)');
      expect(find.text('LaTeX 已复制'), findsOneWidget);
    });

    testWidgets('历史记录：复制 LaTeX', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tapKey(tester, '1');
      await tapKey(tester, '+');
      await tapKey(tester, '2');
      await tapKey(tester, '=');

      await tester.tap(find.byTooltip('复制这条记录').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('复制公式（LaTeX）'));
      await tester.pumpAndSettle();

      expect(clipboard, '1 + 2');
      expect(find.text('LaTeX 已复制'), findsOneWidget);
    });
  });

  testWidgets('方向键翻阅历史记录', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tapKey(tester, '1');
    await tapKey(tester, '+');
    await tapKey(tester, '2');
    await tapKey(tester, '=');
    await tapKey(tester, 'AC');

    final field = find.descendant(
      of: find.byType(CalcDisplay),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);

    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, '1+2');
  });
}

/// 固定内容的导出器：避免 Widget 测试等待引擎渲染位图。
class _FakeExporter extends PlotExporter {
  const _FakeExporter();

  @override
  Future<PlotExportFile> export({
    required PlotController controller,
    required Size size,
    required PlotImageFormat format,
    String name = 'plot',
    String title = 'engineering-assistant 函数绘图',
    DateTime? now,
  }) async {
    return PlotExportFile(
      fileName: plotExportFileName(format, name: name, now: now),
      bytes: Uint8List.fromList(<int>[
        ...'RIFF'.codeUnits,
        0,
        0,
        0,
        0,
        ...'WEBP'.codeUnits,
      ]),
      mimeType: format.mimeType,
    );
  }
}

/// 取绘图画布当前使用的绘制器。
PlotPainter _plotPainter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((widget) => widget.painter)
    .whereType<PlotPainter>()
    .single;

/// 内存版设置存储，Widget 测试里替代文件 / localStorage。
class _MemoryStore implements SettingsStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<Map<String, String>> readAll() async => Map<String, String>.of(values);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
