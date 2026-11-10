import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_assistant/app.dart';
import 'package:engineering_assistant/l10n/app_language.dart';
import 'package:engineering_assistant/services/settings_store.dart';
import 'package:engineering_assistant/state/settings_controller.dart';
import 'package:engineering_assistant/theme/app_theme.dart';
import 'package:engineering_assistant/ui/settings_page.dart';
import 'package:engineering_assistant/ui/tools/tool_catalog.dart';
import 'package:engineering_assistant/ui/widgets/calc_display.dart';
import 'package:engineering_assistant/ui/tools/area/area_page.dart';
import 'package:engineering_assistant/ui/tools/distance/distance_page.dart';
import 'package:engineering_assistant/ui/tools/energy/energy_page.dart';
import 'package:engineering_assistant/ui/tools/pressure/pressure_page.dart';
import 'package:engineering_assistant/ui/tools/speed/speed_page.dart';
import 'package:engineering_assistant/ui/tools/temperature/temperature_page.dart';
import 'package:engineering_assistant/ui/tools/volume/volume_page.dart';
import 'package:engineering_assistant/ui/tools/weight/weight_page.dart';
import 'package:engineering_assistant/ui/widgets/keypad.dart';

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

  testWidgets('手机尺寸：布局不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    expect(find.byType(Keypad), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    expect(find.text('长度换算'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('设置页：深链打开、切浅色主题后配色与保存都变了', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 2),
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
      EngineeringAssistantApp(settings: settings, initialTab: 2),
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
    final distance = toolById('distance')!;
    expect(distance.color, kLightPalette.tertiary);
    expect(distance.color, isNot(kDarkPalette.tertiary));
  });

  testWidgets('设置页：温度默认单位改成华氏度后，温度换算页按 ℉ 打开', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 2),
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
        initialTab: 1,
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
      EngineeringAssistantApp(settings: settings, initialTab: 2),
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
        initialTab: 1,
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
        initialTab: 1,
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
      EngineeringAssistantApp(settings: settings, initialTab: 2),
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
    expect(find.text('15 個のアプリ'), findsOneWidget);
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
          initialTab: 1,
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

  testWidgets('换算页打开着切语言：标题、字段与单位名一起换', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 1),
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
        initialTab: 1,
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
        initialTab: 1,
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
    expect(find.text('设置'), findsOneWidget);

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

    // 清空是会被记住的：退出再进来仍是空的，不会填回默认值
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(find.text('填入数值并选好单位后自动换算'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '',
    );
    // 重新填数值就照常换算（单位还是上次选的尺）
    await tester.enterText(find.byType(TextField).first, '5');
    await tester.pumpAndSettle();
    expect(find.text('5 尺'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
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
          initialTab: 1,
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
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'weight'),
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
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'temperature'),
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
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'energy'),
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
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'pressure'),
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
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'speed'),
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
          initialTab: 1,
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
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'distance'),
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
      EngineeringAssistantApp(initialTab: 1, settings: settings),
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
      EngineeringAssistantApp(initialTab: 1, settings: settings),
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

  testWidgets('工具页搜索：按名称与卖点过滤，搜不到给空态，点叉清空恢复', (tester) async {
    await pumpApp(tester, const Size(1440, 1000));
    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();

    final search = find.byKey(const Key('tools-search'));
    expect(search, findsOneWidget);
    expect(find.text('长度换算'), findsOneWidget);
    expect(find.text('混凝土构件'), findsOneWidget);

    // 按名称搜：只剩温度换算，列表换成「搜索结果」分区
    await tester.enterText(search, '温度');
    await tester.pumpAndSettle();
    expect(find.text('温度换算'), findsOneWidget);
    expect(find.text('长度换算'), findsNothing);
    expect(find.text('搜索结果'), findsOneWidget);

    // 按卖点搜：材料用量的卖点是「砖块水泥砂子，一算就有」
    await tester.enterText(search, '水泥');
    await tester.pumpAndSettle();
    expect(find.text('材料用量'), findsOneWidget);
    expect(find.text('温度换算'), findsNothing);

    // 只有空格等于没搜，恢复全部工具
    await tester.enterText(search, '   ');
    await tester.pumpAndSettle();
    expect(find.text('长度换算'), findsOneWidget);
    expect(find.text('搜索结果'), findsNothing);

    // 搜不到：空态说明 + 清空按钮
    await tester.enterText(search, 'zzz');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tools-search-empty')), findsOneWidget);
    expect(find.text('没有匹配的工具'), findsOneWidget);
    expect(find.text('长度换算'), findsNothing);

    // 点叉清空：搜索框清掉，工具全部回来
    await tester.tap(find.byKey(const Key('tools-search-clear')));
    await tester.pumpAndSettle();
    expect(find.text('长度换算'), findsOneWidget);
    expect(find.text('混凝土构件'), findsOneWidget);
    expect(find.text('没有匹配的工具'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页搜索：手机上也不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('tools-search')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('没有匹配的工具'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byKey(const Key('tools-search')), '换算');
    await tester.pumpAndSettle();
    expect(find.text('长度换算'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 搜索结果里也能点开工具
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
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
        initialTab: 1,
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

  testWidgets('材料用量：四个 tab 各算各的，空着不算，重进后数值与 tab 都还在', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(
        settings: settings,
        initialTab: 1,
        initialTool: 'material',
      ),
    );
    await tester.pumpAndSettle();

    // 四个 tab
    for (final label in <String>['砖块', '混凝土', '水泥', '砂子']) {
      expect(find.widgetWithText(Tab, label), findsOneWidget);
    }

    Future<void> input(String section, String value, {int index = 0}) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byKey(Key(section)),
              matching: find.byType(TextField),
            )
            .at(index),
        value,
      );
      await tester.pumpAndSettle();
    }

    // 默认值直接出结果：10 m³ × 512 = 5120 块；每平方米砖数照常给出参考值
    expect(find.text('5120 块'), findsOneWidget);
    expect(find.text('砖数 = 10 m³ × 512 = 5120 块'), findsOneWidget);
    expect(find.text('12 墙（120 mm）'), findsOneWidget);
    expect(find.text('128 块/㎡'), findsOneWidget);

    // 砖块：150 m³ × 512 = 76800 块
    await input('material-bricks', '150');
    expect(find.text('76800 块'), findsOneWidget);
    expect(find.text('砖数 = 150 m³ × 512 = 76800 块'), findsOneWidget);
    // 清空就不算
    await input('material-bricks', '');
    expect(find.text('—'), findsOneWidget);
    await input('material-bricks', '150');

    // 混凝土：20 ㎡ × 0.1 m = 2 m³（厚度默认 0.1），改成 1200 ㎡ → 120 m³
    await tester.tap(find.widgetWithText(Tab, '混凝土'));
    await tester.pumpAndSettle();
    expect(find.text('2 m³'), findsOneWidget);
    await input('material-concrete', '1200');
    expect(find.text('120 m³'), findsOneWidget);

    // 水泥：20 ㎡ × 0.05 = 1 吨，改成 10000 ㎡ → 500 吨，单耗换成 0.03 后重算
    await tester.tap(find.widgetWithText(Tab, '水泥'));
    await tester.pumpAndSettle();
    expect(find.text('1 吨'), findsOneWidget);
    await input('material-cement', '10000');
    expect(find.text('500 吨'), findsOneWidget);
    await tester.tap(find.byKey(const Key('material-cement-rate')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0.03 吨/㎡').last);
    await tester.pumpAndSettle();
    expect(find.text('300 吨'), findsOneWidget);

    // 砂子：20 ㎡ × 0.05 = 1 m³，改成 1000 ㎡ → 50 m³
    await tester.tap(find.widgetWithText(Tab, '砂子'));
    await tester.pumpAndSettle();
    expect(find.text('1 m³'), findsOneWidget);
    await input('material-sand', '1000');
    expect(find.text('50 m³'), findsOneWidget);
    expect(find.text('砂子 = 1000 ㎡ × 0.05 = 50 m³'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 退出再进来：停在砂子 tab，填过的数值也都还在
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('材料用量'));
    await tester.pumpAndSettle();
    expect(find.text('50 m³'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, '砖块'));
    await tester.pumpAndSettle();
    expect(find.text('76800 块'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('建筑面积：六个 tab 分项计算并合计，空项不计入', (tester) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(
        settings: settings,
        initialTab: 1,
        initialTool: 'building_area',
      ),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['单层', '多层', '阳台', '雨篷', '门斗', '车棚']) {
      expect(find.widgetWithText(Tab, label), findsOneWidget);
    }

    Future<void> input(String section, String value, {int index = 0}) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byKey(Key(section)),
              matching: find.byType(TextField),
            )
            .at(index),
        value,
      );
      await tester.pumpAndSettle();
    }

    // 默认值直接出结果：单层 10 × 8 = 80 ㎡，其余五项也都有默认值，合计 341 ㎡
    expect(find.text('80 ㎡'), findsOneWidget);
    expect(find.text('S = 10 m × 8 m × 1 = 80 m²'), findsOneWidget);
    expect(find.text('341 ㎡'), findsOneWidget);

    // 高度降到 2 m 只算一半 → 40 ㎡，合计 301 ㎡
    await input('building-single', '2', index: 2);
    expect(find.text('40 ㎡'), findsOneWidget);
    expect(find.text('S = 10 m × 8 m × 1/2 = 40 m²'), findsOneWidget);
    expect(find.text('301 ㎡'), findsOneWidget);

    // 清空长度：这一项不计入，单层显示「—」，合计减掉这 40 ㎡
    await input('building-single', '', index: 0);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('261 ㎡'), findsOneWidget);
    await input('building-single', '10', index: 0);
    await input('building-single', '3.6', index: 2);
    expect(find.text('341 ㎡'), findsOneWidget);

    // 多层：默认 3 层 × 80 ㎡ = 240 ㎡，改成 100 ㎡ → 300 ㎡，合计 401 ㎡
    await tester.tap(find.widgetWithText(Tab, '多层'));
    await tester.pumpAndSettle();
    expect(find.text('S = 3 层 × 80 m² = 240 m²'), findsOneWidget);
    expect(find.text('341 ㎡'), findsOneWidget);
    await input('building-multi', '100', index: 1);
    expect(find.text('S = 3 层 × 100 m² = 300 m²'), findsOneWidget);
    expect(find.text('401 ㎡'), findsOneWidget);

    // 阳台：默认 4 ㎡ 只算一半 → 2 ㎡，改成 10 ㎡ → 5 ㎡，合计 404 ㎡
    await tester.tap(find.widgetWithText(Tab, '阳台'));
    await tester.pumpAndSettle();
    expect(find.text('S = 4 m² × 1/2 = 2 m²'), findsOneWidget);
    expect(find.text('401 ㎡'), findsOneWidget);
    await input('building-balcony', '10');
    expect(find.text('S = 10 m² × 1/2 = 5 m²'), findsOneWidget);
    expect(find.text('404 ㎡'), findsOneWidget);

    // 雨篷：默认 6 ㎡、外挑 2.4 m、无柱 → 全面积 6 ㎡，合计 404 ㎡
    await tester.tap(find.widgetWithText(Tab, '雨篷'));
    await tester.pumpAndSettle();
    expect(find.text('S = 6 m² = 6 m²'), findsOneWidget);
    expect(find.text('404 ㎡'), findsOneWidget);

    // 宽度改成 2 m：无柱不计入，合计回到 398 ㎡
    await input('building-canopy', '2', index: 1);
    expect(find.text('0 ㎡'), findsOneWidget);
    expect(find.text('无柱且宽度 ≤ 2.1 m，不计算建筑面积。'), findsOneWidget);
    expect(find.text('398 ㎡'), findsOneWidget);

    // 改成有柱，2 m 宽也按全面积算
    await tester.tap(find.byKey(const Key('building-canopy-columns')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('有柱').last);
    await tester.pumpAndSettle();
    expect(find.text('S = 6 m² = 6 m²'), findsOneWidget);
    expect(find.text('404 ㎡'), findsOneWidget);

    // 门斗：默认 3 ㎡、层高 2.4 m 全面积 → 3 ㎡，改成 4 ㎡ → 4 ㎡，合计 405 ㎡
    await tester.tap(find.widgetWithText(Tab, '门斗'));
    await tester.pumpAndSettle();
    expect(find.text('S = 3 m² × 1 = 3 m²'), findsOneWidget);
    expect(find.text('404 ㎡'), findsOneWidget);
    await input('building-vestibule', '4', index: 0);
    expect(find.text('S = 4 m² × 1 = 4 m²'), findsOneWidget);
    expect(find.text('405 ㎡'), findsOneWidget);

    // 层高降到 2 m 只算一半 → 2 ㎡，合计 403 ㎡
    await input('building-vestibule', '2', index: 1);
    expect(find.text('S = 4 m² × 1/2 = 2 m²'), findsOneWidget);
    expect(find.text('403 ㎡'), findsOneWidget);

    // 车棚：默认顶盖投影 20 ㎡ 只算一半 → 10 ㎡，合计仍是 403 ㎡
    await tester.tap(find.widgetWithText(Tab, '车棚'));
    await tester.pumpAndSettle();
    expect(find.text('S = 20 m² × 1/2 = 10 m²'), findsOneWidget);
    expect(find.text('403 ㎡'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 退出再进来：还停在车棚 tab，填过的数值也都还在
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('建筑面积'));
    await tester.pumpAndSettle();
    expect(find.text('10 ㎡'), findsOneWidget);
    expect(find.text('403 ㎡'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, '单层'));
    await tester.pumpAndSettle();
    expect(find.text('80 ㎡'), findsOneWidget);
    expect(find.text('403 ㎡'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('混凝土构件：五个 tab 按体积计算，孔洞按 0.3 ㎡ 判断', (tester) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(
        settings: settings,
        initialTab: 1,
        initialTool: 'concrete',
      ),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['柱', '梁', '板', '墙', '楼梯']) {
      expect(find.widgetWithText(Tab, label), findsOneWidget);
    }

    Future<void> input(String section, String value, {int index = 0}) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byKey(Key(section)),
              matching: find.byType(TextField),
            )
            .at(index),
        value,
      );
      await tester.pumpAndSettle();
    }

    // 默认值直接出结果：柱 0.5 × 0.5 × 3 = 0.75 m³
    expect(find.text('0.75 m³'), findsOneWidget);
    expect(find.text('V = 0.5 m × 0.5 m × 3 m = 0.75 m³'), findsOneWidget);

    // 清空柱高：不计算
    await input('concrete-column', '', index: 2);
    expect(find.text('—'), findsOneWidget);
    await input('concrete-column', '4', index: 2);
    expect(find.text('V = 0.5 m × 0.5 m × 4 m = 1 m³'), findsOneWidget);
    await input('concrete-column', '3', index: 2);

    // 梁：默认 0.25 × 0.5 × 6 = 0.75 m³
    await tester.tap(find.widgetWithText(Tab, '梁'));
    await tester.pumpAndSettle();
    expect(find.text('V = 0.25 m × 0.5 m × 6 m = 0.75 m³'), findsOneWidget);

    // 板：默认 6 × 4 × 0.12 = 2.88 m³，没有孔洞时不带扣减项
    await tester.tap(find.widgetWithText(Tab, '板'));
    await tester.pumpAndSettle();
    expect(find.text('2.88 m³'), findsOneWidget);
    expect(find.text('V = 6 m × 4 m × 0.12 m = 2.88 m³'), findsOneWidget);

    // 孔洞 0.2 ㎡ ≤ 0.3 ㎡：不扣，公式不变
    await input('concrete-slab', '0.2', index: 3);
    expect(find.text('2.88 m³'), findsOneWidget);
    expect(find.text('V = 6 m × 4 m × 0.12 m = 2.88 m³'), findsOneWidget);

    // 孔洞 0.5 ㎡ > 0.3 ㎡：扣除后 2.82 m³
    await input('concrete-slab', '0.5', index: 3);
    expect(find.text('2.82 m³'), findsOneWidget);
    expect(
      find.text('V = （6 m × 4 m − 0.5 ㎡）× 0.12 m = 2.82 m³'),
      findsOneWidget,
    );

    // 墙：默认 5 × 3 × 0.2 = 3 m³
    await tester.tap(find.widgetWithText(Tab, '墙'));
    await tester.pumpAndSettle();
    expect(find.text('V = 5 m × 3 m × 0.2 m = 3 m³'), findsOneWidget);

    // 楼梯：默认 12 ㎡ × 0.25 m = 3 m³，清空后不算
    await tester.tap(find.widgetWithText(Tab, '楼梯'));
    await tester.pumpAndSettle();
    expect(find.text('V = 12 ㎡ × 0.25 m = 3 m³'), findsOneWidget);
    await input('concrete-stair', '', index: 1);
    expect(find.text('—'), findsOneWidget);
    await input('concrete-stair', '0.25', index: 1);
    expect(tester.takeException(), isNull);

    // 退出再进来：还停在楼梯 tab，各 tab 的数值都还在
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('混凝土构件'));
    await tester.pumpAndSettle();
    expect(find.text('3 m³'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, '板'));
    await tester.pumpAndSettle();
    expect(find.text('2.82 m³'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('土石方工程：三个 tab 按清单规则算，默认值直接出结果', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(
      EngineeringAssistantApp(
        settings: settings,
        initialTab: 1,
        initialTool: 'earthwork',
      ),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['场地平整', '基坑基槽', '管沟土方']) {
      expect(find.widgetWithText(Tab, label), findsOneWidget);
    }

    Future<void> input(String section, String value, {int index = 0}) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byKey(Key(section)),
              matching: find.byType(TextField),
            )
            .at(index),
        value,
      );
      await tester.pumpAndSettle();
    }

    // 场地平整：30 m × 20 m = 600 ㎡
    expect(find.text('600 m²'), findsOneWidget);
    expect(find.text('S = 30 m × 20 m = 600 m²'), findsOneWidget);
    await input('earthwork-leveling', '25', index: 0);
    expect(find.text('S = 25 m × 20 m = 500 m²'), findsOneWidget);
    // 清空就不算
    await input('earthwork-leveling', '', index: 0);
    expect(find.text('—'), findsOneWidget);
    await input('earthwork-leveling', '30', index: 0);

    // 基坑：默认工作面 600 mm，(6 + 1.2) × (4 + 1.2) × 3 = 112.32 m³
    await tester.tap(find.widgetWithText(Tab, '基坑基槽'));
    await tester.pumpAndSettle();
    expect(find.text('112.32 m³'), findsOneWidget);
    expect(
      find.text('V = (6 m + 2 × 0.6 m) × (4 m + 2 × 0.6 m) × 3 m = 112.32 m³'),
      findsOneWidget,
    );
    // 工作面留空按清单默认 600 mm 算，结果不变
    await input('earthwork-excavation', '', index: 2);
    expect(find.text('112.32 m³'), findsOneWidget);
    // 图纸要求工作面 1 m → (8) × (6) × 3 = 144 m³
    await input('earthwork-excavation', '1', index: 2);
    expect(find.text('144 m³'), findsOneWidget);
    expect(
      find.text('V = (6 m + 2 × 1 m) × (4 m + 2 × 1 m) × 3 m = 144 m³'),
      findsOneWidget,
    );
    // 挖深清空 → 不计算
    await input('earthwork-excavation', '', index: 3);
    expect(find.text('—'), findsOneWidget);
    await input('earthwork-excavation', '3', index: 3);
    await input('earthwork-excavation', '0.6', index: 2);
    expect(find.text('112.32 m³'), findsOneWidget);

    // 管沟：默认 (0.5 + 1.2) × 1.5 × 50 = 127.5 m³
    await tester.tap(find.widgetWithText(Tab, '管沟土方'));
    await tester.pumpAndSettle();
    expect(find.text('127.5 m³'), findsOneWidget);
    expect(
      find.text('V = (0.5 m + 2 × 0.6 m) × 1.5 m × 50 m = 127.5 m³'),
      findsOneWidget,
    );
    // 管外径清空 → 不计算；长度加到 100 m 翻倍
    await input('earthwork-trench', '', index: 0);
    expect(find.text('—'), findsOneWidget);
    await input('earthwork-trench', '0.5', index: 0);
    await input('earthwork-trench', '100', index: 1);
    expect(find.text('255 m³'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 退出再进来：还停在管沟 tab，填过的数值都在
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('土石方工程'));
    await tester.pumpAndSettle();
    expect(find.text('255 m³'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, '场地平整'));
    await tester.pumpAndSettle();
    expect(find.text('600 m²'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('土石方工程：手机尺寸下三个 tab 都不溢出', (tester) async {
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'earthwork'),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in <String>['管沟土方', '基坑基槽', '场地平整']) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('钢筋工程：直钢筋 / 箍筋 / 弯起钢筋按公式算，速查表有五个常用直径', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'rebar'),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['直钢筋', '箍筋', '弯起钢筋', '速查表']) {
      expect(find.widgetWithText(Tab, label), findsOneWidget);
    }

    // 直钢筋：6000 − 2 × 25 = 5950 mm，质量 5.95 × 0.00617 × 20² = 14.6846 kg
    expect(find.text('5950 mm'), findsOneWidget);
    expect(find.text('L = 6000 − 2 × 25 + 2 × 0 = 5950 mm'), findsOneWidget);
    expect(find.text('14.6846 kg'), findsOneWidget);
    expect(
      find.text('W = 1 × 5.95 × 0.00617 × 20² = 14.6846 kg'),
      findsOneWidget,
    );

    // 箍筋：2 × (300 + 600) − 8 × 25 + 2 × 11.9 × 8 = 1790.4 mm
    await tester.tap(find.widgetWithText(Tab, '箍筋'));
    await tester.pumpAndSettle();
    expect(find.text('1790.4 mm'), findsOneWidget);
    expect(
      find.text('L = 2 × (300 + 600) − 8 × 25 + 2 × 11.9 × 8 = 1790.4 mm'),
      findsOneWidget,
    );

    // 弯起钢筋：4000 + 500 − 0 + 0 = 4500 mm
    await tester.tap(find.widgetWithText(Tab, '弯起钢筋'));
    await tester.pumpAndSettle();
    expect(find.text('4500 mm'), findsOneWidget);

    // 速查表：常用直径的理论质量
    await tester.tap(find.widgetWithText(Tab, '速查表'));
    await tester.pumpAndSettle();
    expect(find.text('φ10'), findsOneWidget);
    expect(find.text('0.617 kg/m'), findsOneWidget);
    expect(find.text('2.47 kg/m'), findsOneWidget);
    expect(find.text('3.85 kg/m'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('钢筋工程：手机尺寸下四个 tab 都不溢出', (tester) async {
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'rebar'),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in <String>['速查表', '弯起钢筋', '箍筋', '直钢筋']) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('砌筑工程：砖墙 / 砖基础 / 特殊墙体按清单规则算体积', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'masonry'),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['砖墙', '砖基础', '特殊墙体']) {
      expect(find.widgetWithText(Tab, label), findsOneWidget);
    }

    // 砖墙：(10 × 3 − 6) × 0.24 − 0 = 5.76 m³
    expect(find.text('5.76 m³'), findsOneWidget);
    expect(find.text('V = (10 × 3 − 6) × 0.24 − 0 = 5.76 m³'), findsOneWidget);

    // 砖基础：0.24 × (1.2 + 0.197) × (30 + 20) = 16.764 m³
    await tester.tap(find.widgetWithText(Tab, '砖基础'));
    await tester.pumpAndSettle();
    expect(find.text('16.764 m³'), findsOneWidget);

    // 特殊墙体：空斗墙按外形体积 10 × 3 × 0.24 = 7.2 m³
    await tester.tap(find.widgetWithText(Tab, '特殊墙体'));
    await tester.pumpAndSettle();
    expect(find.text('7.2 m³'), findsOneWidget);
    expect(find.text('V = 10 × 3 × 0.24 = 7.2 m³'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('砌筑工程：多孔砖墙扣孔洞，空斗墙不扣', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'masonry'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, '特殊墙体'));
    await tester.pumpAndSettle();

    // 默认空斗墙：没有「孔洞体积」输入框，也不扣空洞
    expect(find.text('孔洞体积'), findsNothing);

    await tester.tap(find.byKey(const Key('masonry-special-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('多孔砖墙').last);
    await tester.pumpAndSettle();

    expect(find.text('孔洞体积'), findsOneWidget);
    expect(find.text('V = 10 × 3 × 0.24 − 0 = 7.2 m³'), findsOneWidget);

    await tester.enterText(find.text('0').last, '0.6');
    await tester.pumpAndSettle();
    expect(find.text('6.6 m³'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('砌筑工程：手机尺寸下三个 tab 都不溢出', (tester) async {
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'masonry'),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in <String>['特殊墙体', '砖基础', '砖墙']) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('模板工程：柱 / 梁 / 墙 / 楼梯按接触面积算', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'formwork'),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['柱', '梁', '墙', '楼梯']) {
      expect(find.widgetWithText(Tab, label), findsOneWidget);
    }

    // 柱：2 × (0.5 + 0.5) × 3 = 6 ㎡
    expect(find.text('6 m²'), findsOneWidget);
    expect(find.text('S = 2 × (0.5 + 0.5) × 3 = 6 m²'), findsOneWidget);

    // 梁：(0.3 + 2 × 0.6) × 6 = 9 ㎡
    await tester.tap(find.widgetWithText(Tab, '梁'));
    await tester.pumpAndSettle();
    expect(find.text('9 m²'), findsOneWidget);
    expect(find.text('S = (0.3 + 2 × 0.6) × 6 = 9 m²'), findsOneWidget);

    // 墙：(10 × 3 − 6) + 0.5 = 24.5 ㎡
    await tester.tap(find.widgetWithText(Tab, '墙'));
    await tester.pumpAndSettle();
    expect(find.text('24.5 m²'), findsOneWidget);

    // 楼梯：(10 × √(0.28² + 0.15²) + 1.2) × 1.2 ≈ 5.25 ㎡
    await tester.tap(find.widgetWithText(Tab, '楼梯'));
    await tester.pumpAndSettle();
    expect(find.textContaining('m²'), findsWidgets);
    expect(find.textContaining('× 1.2 = 5.25'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('模板工程：构造柱带马牙槎，改类型后面积变大', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'formwork'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('formwork-column-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('构造柱').last);
    await tester.pumpAndSettle();

    // (2 × (0.5 + 0.5) + 2 × 0.06 × 5) × 3 = (2 + 0.6) × 3 = 7.8 ㎡
    expect(find.text('7.8 m²'), findsOneWidget);
    expect(find.textContaining('2 × 0.06 × 5'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('模板工程：手机尺寸下四个 tab 都不溢出', (tester) async {
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'formwork'),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in <String>['楼梯', '墙', '梁', '柱']) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('设置里可以改材料用量 / 建筑面积 / 混凝土构件 / 土石方 / 钢筋 / 砌筑 / 模板的默认 tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(
      EngineeringAssistantApp(settings: settings, initialTab: 2),
    );
    await tester.pumpAndSettle();

    Future<void> pick(String toolId, String label) async {
      final select = find.byKey(Key('settings-$toolId-tab'));
      await tester.scrollUntilVisible(
        select,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(select);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    await pick('material', '水泥');
    await pick('building_area', '车棚');
    await pick('concrete', '板');
    await pick('earthwork', '管沟土方');
    await pick('rebar', '速查表');
    await pick('masonry', '特殊墙体');
    await pick('formwork', '楼梯');
    expect(store.values['material.tab'], '2');
    expect(store.values['building_area.tab'], '5');
    expect(store.values['concrete.tab'], '2');
    expect(store.values['earthwork.tab'], '2');
    expect(store.values['rebar.tab'], '3');
    expect(store.values['masonry.tab'], '2');
    expect(store.values['formwork.tab'], '3');

    // 打开三个工具：各自停在设置里选的 tab，默认值已经算好
    Future<void> open(String toolId) async {
      await tester.pumpWidget(
        EngineeringAssistantApp(
          settings: settings,
          key: UniqueKey(),
          initialTab: 1,
          initialTool: toolId,
        ),
      );
      await tester.pumpAndSettle();
    }

    await open('material');
    expect(find.text('1 吨'), findsOneWidget);
    await open('building_area');
    expect(find.text('S = 20 m² × 1/2 = 10 m²'), findsOneWidget);
    await open('concrete');
    expect(find.text('2.88 m³'), findsOneWidget);
    expect(find.text('V = 6 m × 4 m × 0.12 m = 2.88 m³'), findsOneWidget);
    await open('earthwork');
    expect(find.text('127.5 m³'), findsOneWidget);
    await open('rebar');
    expect(find.text('3.85 kg/m'), findsOneWidget);
    await open('masonry');
    expect(find.text('V = 10 × 3 × 0.24 = 7.2 m³'), findsOneWidget);
    await open('formwork');
    expect(find.textContaining('m²'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('混凝土构件：手机尺寸下五个 tab 都不溢出', (tester) async {
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'concrete'),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in <String>['梁', '板', '墙', '楼梯']) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('建筑面积：手机尺寸下六个 tab 都不溢出', (tester) async {
    await tester.pumpWidget(
      const EngineeringAssistantApp(
        initialTab: 1,
        initialTool: 'building_area',
      ),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in <String>['多层', '阳台', '雨篷', '门斗', '车棚']) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('材料用量：手机尺寸下四个 tab 都不溢出', (tester) async {
    await tester.pumpWidget(
      const EngineeringAssistantApp(initialTab: 1, initialTool: 'material'),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in <String>['混凝土', '水泥', '砂子', '砖块']) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    // 手机上打开工具后底部菜单仍在
    expect(find.byType(NavigationBar), findsOneWidget);
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

/// 内存版设置存储，Widget 测试里替代文件 / localStorage。
class _MemoryStore implements SettingsStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<Map<String, String>> readAll() async => Map<String, String>.of(values);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
