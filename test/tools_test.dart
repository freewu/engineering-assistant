import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_assistant/l10n/app_i18n.dart';
import 'package:engineering_assistant/l10n/app_language.dart';
import 'package:engineering_assistant/l10n/app_strings.dart';
import 'package:engineering_assistant/services/settings_store.dart';
import 'package:engineering_assistant/state/settings_controller.dart';
import 'package:engineering_assistant/theme/app_theme.dart';
import 'package:engineering_assistant/ui/tools/area/area.dart';
import 'package:engineering_assistant/ui/tools/distance/distance.dart';
import 'package:engineering_assistant/ui/tools/energy/energy.dart';
import 'package:engineering_assistant/ui/tools/pressure/pressure.dart';
import 'package:engineering_assistant/ui/tools/speed/speed.dart';
import 'package:engineering_assistant/ui/tools/temperature/temperature.dart';
import 'package:engineering_assistant/ui/tools/conversion_catalogs.dart';
import 'package:engineering_assistant/ui/tools/unit_catalog.dart';
import 'package:engineering_assistant/ui/tools/volume/volume.dart';
import 'package:engineering_assistant/ui/tools/weight/weight.dart';
import 'package:engineering_assistant/ui/tools/tool_catalog.dart';

void main() {
  group('换算单位的多语言名称', () {
    MeasureUnit unitOf(String id) =>
        kLengthCatalog.units.firstWhere((unit) => unit.id == id);
    MeasureSample sampleOf(String label) =>
        kLengthCatalog.samples.firstWhere((sample) => sample.label == label);

    test('名称按语言取，缺中文项时回落中文原名', () {
      final foot = unitOf('foot');
      expect(foot.labelIn(AppLanguage.en), 'foot');
      expect(foot.labelIn(AppLanguage.ja), 'フィート');
      expect(foot.labelIn(AppLanguage.es), 'pie');
      // names 里没有中文，简繁中文都用 label（简体原文）
      expect(foot.labelIn(AppLanguage.zhHans), '英尺');
      expect(foot.labelIn(AppLanguage.zhHant), '英尺');
    });

    test('说明按语言取，中文回落原文', () {
      final foot = unitOf('foot');
      expect(foot.noteIn(AppLanguage.zhHans), '1 英尺 = 12 英寸 = 0.3048 米');
      expect(foot.noteIn(AppLanguage.zhHant), '1 英尺 = 12 英寸 = 0.3048 米');
      expect(foot.noteIn(AppLanguage.en), '1 foot = 12 inches = 0.3048 m');
      expect(foot.noteIn(AppLanguage.ja), '1 フィート = 12 インチ = 0.3048 m');
      expect(foot.noteIn(AppLanguage.es), '1 pie = 12 pulgadas = 0,3048 m');
    });

    test('说明缺 en 时回落到中文原文', () {
      const unit = MeasureUnit(
        id: 'test',
        label: '测试',
        symbol: 't',
        system: MeasureSystem.metric,
        baseNumerator: 1,
        baseDenominator: 1,
      );
      expect(unit.noteIn(AppLanguage.en), '');
      expect(unit.noteIn(AppLanguage.ja), '');
    });

    test('参照物名称同样按语言取', () {
      final marathon = sampleOf('马拉松');
      expect(marathon.labelIn(AppLanguage.en), 'Marathon');
      expect(marathon.labelIn(AppLanguage.ja), 'マラソン');
      expect(marathon.labelIn(AppLanguage.es), 'Maratón');
      expect(marathon.labelIn(AppLanguage.zhHans), '马拉松');
    });

    test('六个换算工具的单位都补齐了 en / ja / es', () {
      for (final catalog in [
        kLengthCatalog,
        kAreaCatalog,
        kVolumeCatalog,
        kWeightCatalog,
        kTemperatureCatalog,
        kSpeedCatalog,
      ]) {
        for (final unit in catalog.units) {
          for (final language in [
            AppLanguage.en,
            AppLanguage.ja,
            AppLanguage.es,
          ]) {
            expect(
              unit.names[language],
              isNotNull,
              reason: '${catalog.id}.${unit.id} 缺少 ${language.code}',
            );
          }
        }
        // 只有带说明的单位需要三份翻译（大部分单位没有说明）
        for (final unit in catalog.units.where(
          (unit) => unit.note.isNotEmpty,
        )) {
          for (final language in [
            AppLanguage.en,
            AppLanguage.ja,
            AppLanguage.es,
          ]) {
            expect(
              unit.notes[language],
              isNotNull,
              reason: '${catalog.id}.${unit.id} 缺少 ${language.code} 说明',
            );
          }
        }
        for (final sample in catalog.samples) {
          for (final language in [
            AppLanguage.en,
            AppLanguage.ja,
            AppLanguage.es,
          ]) {
            expect(
              sample.names[language],
              isNotNull,
              reason: '${catalog.id}.${sample.label} 缺少 ${language.code}',
            );
          }
        }
      }
    });
  });

  group('长度：公制 / 英制 / 市制换算', () {
    DistanceUnit unit(String id) => distanceUnitById(id)!;

    double? convert(double value, String from, String to) =>
        convertDistance(value, from: unit(from), to: unit(to));

    test('单位表：三个体系共 25 个单位，id 唯一', () {
      expect(kDistanceUnits.length, 25);
      expect(distanceUnitsOf(DistanceSystem.metric).length, 9);
      expect(distanceUnitsOf(DistanceSystem.imperial).length, 7);
      expect(distanceUnitsOf(DistanceSystem.chinese).length, 9);
      expect(
        kDistanceUnits.map((item) => item.id).toSet().length,
        kDistanceUnits.length,
      );
      expect(distanceUnitById('nope'), isNull);
      for (final item in kDistanceUnits) {
        expect(item.meters.isFinite && item.meters > 0, isTrue);
      }
    });

    test('公制内部换算', () {
      expect(convert(1, 'km', 'm'), closeTo(1000, 1e-12));
      expect(convert(1, 'm', 'cm'), closeTo(100, 1e-12));
      expect(convert(1, 'm', 'mm'), closeTo(1000, 1e-12));
      expect(convert(1, 'mm', 'um'), closeTo(1000, 1e-12));
      expect(convert(1, 'um', 'nm'), closeTo(1000, 1e-12));
      expect(convert(1, 'nm', 'pm'), closeTo(1000, 1e-12));
      expect(convert(1, 'm', 'dm'), closeTo(10, 1e-12));
      // 海里归在公制里（1852 米）
      expect(convert(1, 'nmile', 'm'), closeTo(1852, 1e-12));
    });

    test('英制内部与跨体系换算', () {
      expect(convert(1, 'foot', 'inch'), closeTo(12, 1e-12));
      expect(convert(1, 'yard', 'foot'), closeTo(3, 1e-12));
      expect(convert(1, 'mile', 'yard'), closeTo(1760, 1e-12));
      expect(convert(1, 'chain', 'foot'), closeTo(66, 1e-12));
      expect(convert(1, 'furlong', 'chain'), closeTo(10, 1e-12));
      expect(convert(1, 'mile', 'm'), closeTo(1609.344, 1e-9));
      expect(convert(1, 'inch', 'cm'), closeTo(2.54, 1e-12));
      expect(convert(1, 'foot', 'm'), closeTo(0.3048, 1e-12));
    });

    test('市制：1 尺 = 1/3 米', () {
      expect(convert(1, 'li', 'm'), closeTo(500, 1e-12));
      expect(convert(1, 'li', 'chi'), closeTo(1500, 1e-9));
      expect(convert(1, 'yin', 'm'), closeTo(500 / 15, 1e-12));
      expect(convert(1, 'zhang', 'chi'), closeTo(10, 1e-12));
      expect(convert(1, 'chi', 'm'), closeTo(1 / 3, 1e-12));
      expect(convert(1, 'cun', 'chi'), closeTo(0.1, 1e-12));
      expect(convert(1, 'fen', 'cun'), closeTo(0.1, 1e-12));
      expect(convert(1, 'li2', 'fen'), closeTo(0.1, 1e-12));
      expect(convert(1, 'hao', 'li2'), closeTo(0.1, 1e-12));
      expect(convert(1, 'si', 'hao'), closeTo(0.1, 1e-12));
      // 市制 ↔ 公制：3 尺 = 1 米
      expect(convert(3, 'chi', 'm'), closeTo(1, 1e-12));
      expect(convert(1, 'm', 'cun'), closeTo(30, 1e-9));
    });

    test('任意两个单位互为反函数', () {
      for (final from in kDistanceUnits) {
        for (final to in kDistanceUnits) {
          final forward = convertDistance(2.5, from: from, to: to)!;
          final back = convertDistance(forward, from: to, to: from)!;
          expect(back, closeTo(2.5, 1e-9), reason: '$from -> $to');
        }
      }
    });

    test('非法输入', () {
      expect(convert(double.nan, 'm', 'cm'), isNull);
      expect(convert(double.infinity, 'm', 'cm'), isNull);
      expect(convert(double.negativeInfinity, 'm', 'cm'), isNull);
    });

    test('参照物都指向真实单位', () {
      expect(kDistanceSamples, isNotEmpty);
      for (final sample in kDistanceSamples) {
        expect(
          kLengthCatalog.unitOfSample(sample),
          isNotNull,
          reason: sample.label,
        );
        expect(sample.value > 0, isTrue);
      }
      // 1 光年按 9.46 万亿千米
      final lightYear = kDistanceSamples.firstWhere(
        (sample) => sample.label == '1 光年',
      );
      expect(
        convertDistance(
          lightYear.value,
          from: kLengthCatalog.unitOfSample(lightYear)!,
          to: unit('m'),
        ),
        closeTo(9.4607304725808e15, 1e9),
      );
    });
  });
  group('单位换算：面积 / 容量 / 重量 / 温度 / 速度', () {
    /// 用单位 id 换算，测试里少写样板。
    double? swap(
      MeasureCatalog catalog,
      double value,
      String from,
      String to,
    ) => catalog.convert(
      value,
      from: catalog.unitById(from)!,
      to: catalog.unitById(to)!,
    );

    test('面积：1 公顷 = 15 亩，1 英亩 ≈ 4046.86 平方米', () {
      expect(swap(kAreaCatalog, 1, 'ha', 'sqm'), closeTo(10000, 1e-9));
      expect(swap(kAreaCatalog, 1, 'ha', 'mu'), closeTo(15, 1e-9));
      expect(swap(kAreaCatalog, 1, 'mu', 'sqm'), closeTo(2000 / 3, 1e-9));
      expect(swap(kAreaCatalog, 1, 'qing', 'mu'), closeTo(100, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqzhang', 'sqchi'), closeTo(100, 1e-9));
      expect(swap(kAreaCatalog, 1, 'acre', 'sqm'), closeTo(4046.8564224, 1e-6));
      expect(swap(kAreaCatalog, 1, 'sqmi', 'acre'), closeTo(640, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqft', 'sqin'), closeTo(144, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqm', 'sqcm'), closeTo(10000, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqkm', 'ha'), closeTo(100, 1e-9));
      // A4 纸 0.06237 平方米 = 623.7 平方厘米
      expect(swap(kAreaCatalog, 0.06237, 'sqm', 'sqcm'), closeTo(623.7, 1e-9));
    });

    test('容量：1 英制加仑 = 4.54609 升，1 石 = 100 升', () {
      expect(swap(kVolumeCatalog, 1, 'm3', 'l'), closeTo(1000, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'm3', 'ml'), closeTo(1e6, 1e-6));
      expect(swap(kVolumeCatalog, 1, 'l', 'ml'), closeTo(1000, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'gal', 'l'), closeTo(4.54609, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'gal', 'pt'), closeTo(8, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'gal', 'floz'), closeTo(160, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'pt', 'floz'), closeTo(20, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'bu', 'gal'), closeTo(8, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'dan', 'dou'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'dou', 'sheng'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'ge', 'shao'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'shao', 'ml'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 550, 'ml', 'l'), closeTo(0.55, 1e-12));
    });

    test('重量：1 磅 = 0.45359237 千克，1 斤 = 500 克', () {
      expect(swap(kWeightCatalog, 1, 't', 'kg'), closeTo(1000, 1e-9));
      expect(swap(kWeightCatalog, 1, 'kg', 'mg'), closeTo(1e6, 1e-6));
      expect(swap(kWeightCatalog, 1, 'lb', 'kg'), closeTo(0.45359237, 1e-12));
      expect(swap(kWeightCatalog, 1, 'lb', 'oz'), closeTo(16, 1e-9));
      expect(swap(kWeightCatalog, 1, 'st', 'lb'), closeTo(14, 1e-9));
      expect(swap(kWeightCatalog, 1, 'longton', 'lb'), closeTo(2240, 1e-6));
      expect(swap(kWeightCatalog, 1, 'shortton', 'lb'), closeTo(2000, 1e-6));
      expect(swap(kWeightCatalog, 1, 'jin', 'g'), closeTo(500, 1e-9));
      expect(swap(kWeightCatalog, 1, 'jin', 'lb'), closeTo(1.1023113109, 1e-9));
      expect(swap(kWeightCatalog, 1, 'dan', 'jin'), closeTo(100, 1e-9));
      expect(swap(kWeightCatalog, 1, 'liang', 'qian'), closeTo(10, 1e-9));
      expect(swap(kWeightCatalog, 65, 'kg', 'jin'), closeTo(130, 1e-9));
    });

    test('温度：仿射换算（含零点偏移）', () {
      expect(swap(kTemperatureCatalog, 0, 'c', 'f'), closeTo(32, 1e-9));
      expect(swap(kTemperatureCatalog, 100, 'c', 'f'), closeTo(212, 1e-9));
      expect(swap(kTemperatureCatalog, 32, 'f', 'c'), closeTo(0, 1e-9));
      expect(swap(kTemperatureCatalog, -40, 'c', 'f'), closeTo(-40, 1e-9));
      expect(swap(kTemperatureCatalog, 37, 'c', 'f'), closeTo(98.6, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'c', 'k'), closeTo(273.15, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'k', 'c'), closeTo(-273.15, 1e-9));
      expect(swap(kTemperatureCatalog, 273.15, 'k', 'f'), closeTo(32, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'r', 'k'), closeTo(0, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'r', 'c'), closeTo(-273.15, 1e-9));
      // 摄氏与开尔文同刻度，华氏与兰氏同刻度
      expect(swap(kTemperatureCatalog, 10, 'c', 'k'), closeTo(283.15, 1e-9));
      expect(swap(kTemperatureCatalog, 9, 'f', 'r'), closeTo(468.67, 1e-9));
      // 温度只有公制 / 英制两套体系
      expect(kTemperatureCatalog.systems, <MeasureSystem>[
        MeasureSystem.metric,
        MeasureSystem.imperial,
      ]);
      expect(kTemperatureCatalog.unitsOf(MeasureSystem.chinese), isEmpty);
    });

    test('速度：1 节 = 1.852 千米/小时，1 马赫 = 340.3 米/秒', () {
      expect(swap(kSpeedCatalog, 1, 'kmh', 'ms'), closeTo(1 / 3.6, 1e-12));
      expect(swap(kSpeedCatalog, 36, 'kmh', 'ms'), closeTo(10, 1e-12));
      expect(swap(kSpeedCatalog, 1, 'mph', 'kmh'), closeTo(1.609344, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'kn', 'kmh'), closeTo(1.852, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'mach', 'ms'), closeTo(340.3, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'kms', 'kmh'), closeTo(3600, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'fts', 'ms'), closeTo(0.3048, 1e-12));
      expect(swap(kSpeedCatalog, 3600, 'lishi', 'ms'), closeTo(500, 1e-9));
      expect(swap(kSpeedCatalog, 100, 'kmh', 'mach'), closeTo(0.081627, 1e-6));
    });

    test('五张单位表：id 唯一、体系自洽、参照物都落到真实单位', () {
      for (final catalog in <MeasureCatalog>[
        kAreaCatalog,
        kVolumeCatalog,
        kWeightCatalog,
        kTemperatureCatalog,
        kSpeedCatalog,
      ]) {
        final ids = catalog.units.map((unit) => unit.id).toList();
        expect(ids.toSet().length, ids.length, reason: catalog.name);
        expect(
          catalog.unitById(catalog.defaultUnitId),
          isNotNull,
          reason: catalog.name,
        );
        for (final unit in catalog.units) {
          expect(
            unit.baseValue.isFinite && unit.baseValue > 0,
            isTrue,
            reason: '${catalog.name} ${unit.id}',
          );
          expect(
            catalog.systems.contains(unit.system),
            isTrue,
            reason: '${catalog.name} ${unit.id}',
          );
        }
        expect(catalog.samples, isNotEmpty, reason: catalog.name);
        for (final sample in catalog.samples) {
          expect(
            catalog.unitOfSample(sample),
            isNotNull,
            reason: '${catalog.name} ${sample.label}',
          );
        }
        // 任意两个单位互为反函数
        for (final from in catalog.units) {
          for (final to in catalog.units) {
            final forward = catalog.convert(7.5, from: from, to: to)!;
            final back = catalog.convert(forward, from: to, to: from)!;
            expect(
              back,
              closeTo(7.5, 1e-6),
              reason: '${catalog.name} ${from.id} → ${to.id}',
            );
          }
        }
      }
    });
  });

  group('工具置顶', () {
    test('默认 3 个上限、没有置顶项，置顶后写回本地', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      await settings.load();
      expect(settings.pinnedLimit, 3);
      expect(settings.pinnedTools, isEmpty);
      expect(settings.isPinned('distance'), isFalse);

      expect(await settings.togglePinned('distance'), isTrue);
      expect(await settings.togglePinned('weight'), isTrue);
      expect(store.values['pinned_tools'], 'distance,weight');

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.pinnedTools, <String>['distance', 'weight']);
      expect(reloaded.isPinned('weight'), isTrue);
    });

    test('顶满上限后不再添加，取消置顶总是成功', () async {
      final settings = SettingsController(store: _MemoryStore());
      for (final id in <String>['distance', 'energy', 'volume']) {
        expect(await settings.togglePinned(id), isTrue);
      }
      expect(settings.pinnedFull, isTrue);
      expect(settings.pinnedSlotsLeft, 0);

      // 第四个放不进去
      expect(await settings.togglePinned('weight'), isFalse);
      expect(settings.pinnedTools, hasLength(3));
      expect(settings.isPinned('weight'), isFalse);

      // 取消置顶不受上限影响
      expect(await settings.togglePinned('distance'), isTrue);
      expect(settings.isPinned('distance'), isFalse);
      expect(await settings.togglePinned('weight'), isTrue);
      expect(settings.isPinned('weight'), isTrue);
    });

    test('上限只在 2 ~ 5 之间，调小时丢掉多出来的置顶项', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      for (final id in <String>['distance', 'energy', 'volume', 'weight']) {
        await settings.togglePinned(id);
      }
      await settings.setPinnedLimit(1);
      expect(settings.pinnedLimit, 2);
      expect(settings.pinnedTools, <String>['distance', 'energy']);
      expect(store.values['pinned_limit'], '2');
      expect(store.values['pinned_tools'], 'distance,energy');

      await settings.setPinnedLimit(9);
      expect(settings.pinnedLimit, 5);

      // 存了越界的值时按范围夹回
      final reloaded = SettingsController(
        store: _MemoryStore()..values['pinned_limit'] = '10',
      );
      await reloaded.load();
      expect(reloaded.pinnedLimit, 5);
    });

    test('读不到或写坏了的置顶项不影响加载', () async {
      final settings = SettingsController(
        store: _MemoryStore()..values['pinned_tools'] = 'distance,,  ,weight',
      );
      await settings.load();
      expect(settings.pinnedTools, <String>['distance', 'weight']);
    });
  });

  group('工具页输入草稿（ToolDraft）', () {
    test('写入后合并成一条 JSON，重建设置能读回', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      await settings.load();
      expect(settings.toolDraftOf('distance'), isEmpty);

      settings.setToolDraftValue('distance', 'height', '180');
      settings.setToolDraftValue('distance', 'unit', 'imperial');
      // 空串表示清掉该字段（输入框被清空时）
      settings.setToolDraftValue('distance', 'weight', '');
      settings.setToolDraftValue('weight', 'amount', '500000');
      await settings.flushDrafts();

      // 每个工具只占一个键，值是 JSON
      expect(store.values.keys.toSet(), <String>{
        'tool.distance',
        'tool.weight',
      });

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.toolDraftOf('distance'), <String, String>{
        'height': '180',
        'unit': 'imperial',
      });
      expect(reloaded.toolDraftOf('weight'), <String, String>{
        'amount': '500000',
      });
      expect(reloaded.toolDraftOf('nope'), isEmpty);
    });

    test('清空最后一个字段时整条草稿也删掉', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      settings.setToolDraftValue('energy', 'age', '40');
      await settings.flushDrafts();
      settings.setToolDraftValue('energy', 'age', '');
      await settings.flushDrafts();

      expect(settings.toolDraftOf('energy'), isEmpty);
      expect(store.values['tool.energy'], '');

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.toolDraftOf('energy'), isEmpty);
    });

    test('损坏的草稿内容不会让设置加载失败', () async {
      final store = _MemoryStore()
        ..values['tool.distance'] = '{不是 JSON'
        ..values['tool.weight'] = '["数组"]'
        ..values['tool.temperature'] = '{"salary": 20000}';
      final settings = SettingsController(store: store);
      await settings.load();
      // 三种都不是「字段 → 字符串」的表，直接忽略
      expect(settings.toolDrafts, isEmpty);
    });
  });

  group('工具历史记录（toolHistory）', () {
    test('新的排在最前，按上限裁掉最旧的，重建设置能读回', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      await settings.load();
      expect(settings.toolHistoryOf('pressure'), isEmpty);

      await settings.addToolHistory('pressure', '第一条', limit: 3);
      await settings.addToolHistory('pressure', '第二条', limit: 3);
      await settings.addToolHistory('pressure', '第三条', limit: 3);
      expect(settings.toolHistoryOf('pressure'), <String>['第三条', '第二条', '第一条']);
      // 每个工具只占一个键，值是 JSON 数组
      expect(store.values.keys.toSet(), <String>{'history.pressure'});

      await settings.addToolHistory('pressure', '第四条', limit: 3);
      expect(settings.toolHistoryOf('pressure'), <String>['第四条', '第三条', '第二条']);

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.toolHistoryOf('pressure'), <String>['第四条', '第三条', '第二条']);
      // 没存过的工具是空表，且不能改到内部列表
      expect(reloaded.toolHistoryOf('nope'), isEmpty);
      expect(
        () => reloaded.toolHistoryOf('pressure').add('x'),
        throwsUnsupportedError,
      );
    });

    test('删单条与清空都写回本地', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      await settings.addToolHistory('pressure', 'a');
      await settings.addToolHistory('pressure', 'b');
      await settings.addToolHistory('pressure', 'c');

      await settings.removeToolHistory('pressure', 1);
      expect(settings.toolHistoryOf('pressure'), <String>['c', 'a']);
      // 越界下标直接忽略
      await settings.removeToolHistory('pressure', 9);
      expect(settings.toolHistoryOf('pressure'), <String>['c', 'a']);

      await settings.clearToolHistory('pressure');
      expect(settings.toolHistoryOf('pressure'), isEmpty);
      expect(store.values['history.pressure'], '');

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.toolHistoryOf('pressure'), isEmpty);
    });

    test('损坏的历史记录不会让设置加载失败', () async {
      final store = _MemoryStore()
        ..values['history.pressure'] = '{不是 JSON'
        ..values['history.weight'] = '["只有一条"]'
        ..values['history.distance'] = '{"a": 1}';
      final settings = SettingsController(store: store);
      await settings.load();
      expect(settings.toolHistoryOf('pressure'), isEmpty);
      // 数组里的非字符串项被跳过，剩下的照常读回
      expect(settings.toolHistoryOf('weight'), <String>['只有一条']);
      expect(settings.toolHistoryOf('distance'), isEmpty);
    });
  });

  group('设置：主题模式与本地存储', () {
    test('默认跟随系统：按系统明暗给深色或浅色配色', () {
      final settings = SettingsController(store: _MemoryStore());
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.language, AppLanguage.zhHans);
      expect(settings.paletteFor(Brightness.dark), same(kDarkPalette));
      expect(settings.paletteFor(Brightness.light), same(kLightPalette));
    });

    test('切主题写回本地，重建后能读回来', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      await settings.setThemeMode(AppThemeMode.light);
      expect(store.values['theme_mode'], 'light');
      expect(settings.paletteFor(Brightness.dark), same(kLightPalette));

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.themeMode, AppThemeMode.light);
      expect(reloaded.paletteFor(Brightness.dark), same(kLightPalette));
    });

    test('切语言写回本地，重建后能读回来', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      await settings.setLanguage(AppLanguage.es);
      expect(store.values['language'], 'es');

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.language, AppLanguage.es);
    });

    test('存了无法识别的值时保持默认', () async {
      final store = _MemoryStore()
        ..values['theme_mode'] = 'neon'
        ..values['language'] = 'ko';
      final settings = SettingsController(store: store);
      await settings.load();
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.language, AppLanguage.zhHans);
      expect(AppThemeMode.fromCode('neon'), isNull);
      expect(AppLanguage.fromCode('ko'), isNull);
    });

    test('换算工具默认体系与结果 tab：各工具分别保存，默认公制', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      for (final catalog in kConversionCatalogs) {
        expect(settings.convertSystemFor(catalog.id), MeasureSystem.metric);
        expect(settings.convertTabFor(catalog.id), MeasureSystem.metric);
      }
      expect(MeasureSystem.fromCode(null), isNull);
      expect(MeasureSystem.fromCode('chinese'), MeasureSystem.chinese);
      expect(MeasureSystem.fromCode('stone'), isNull);

      await settings.setConvertSystem('distance', MeasureSystem.chinese);
      await settings.setConvertTab('distance', MeasureSystem.imperial);
      await settings.setConvertSystem('area', MeasureSystem.imperial);
      expect(store.values['convert.distance.system'], 'chinese');
      expect(store.values['convert.distance.tab'], 'imperial');

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.convertSystemFor('distance'), MeasureSystem.chinese);
      expect(reloaded.convertTabFor('distance'), MeasureSystem.imperial);
      expect(reloaded.convertSystemFor('area'), MeasureSystem.imperial);
      // 没设置过的工具仍按公制
      expect(reloaded.convertSystemFor('volume'), MeasureSystem.metric);
      expect(reloaded.convertTabFor('temperature'), MeasureSystem.metric);
    });

    test('温度 / 热量 / 压力不分体系，其余换算工具仍按公制 / 英制 / 市制分组', () {
      // 这三种是「一种量、几套并列单位」，套公制 / 英制反而多一层点击
      const ungrouped = <String>{'temperature', 'energy', 'pressure'};
      for (final catalog in kConversionCatalogs) {
        if (ungrouped.contains(catalog.id)) {
          expect(catalog.groupedBySystem, isFalse, reason: catalog.id);
          expect(catalog.splitsBySystem, isFalse, reason: catalog.id);
        } else {
          expect(catalog.splitsBySystem, isTrue, reason: catalog.id);
        }
      }
      // 三种温标放在同一张单位表里，页面不分体系也能一次列全
      expect(
        kTemperatureCatalog.units.map((unit) => unit.id).toList(),
        <String>['c', 'k', 'f', 'r'],
      );
    });

    test('热量：瓦时 / 焦耳 / 卡路里都换算到焦耳', () {
      expect(kEnergyCatalog.units.map((unit) => unit.id).toList(), <String>[
        'milliwh',
        'wh',
        'kwh',
        'mwh',
        'j',
        'kj',
        'cal',
        'kcal',
      ]);
      EnergyUnit unit(String id) => energyUnitById(id)!;
      expect(convertEnergy(1, from: unit('wh'), to: unit('j')), 3600);
      expect(convertEnergy(1, from: unit('kwh'), to: unit('j')), 3600000);
      expect(convertEnergy(1, from: unit('mwh'), to: unit('kwh')), 1000);
      expect(convertEnergy(1, from: unit('milliwh'), to: unit('j')), 3.6);
      expect(convertEnergy(1, from: unit('kj'), to: unit('j')), 1000);
      // 1 卡 = 4.184 焦，1 千卡 = 4184 焦，都是精确分数
      expect(convertEnergy(1, from: unit('cal'), to: unit('j')), 4.184);
      expect(convertEnergy(1, from: unit('kcal'), to: unit('j')), 4184);
      expect(convertEnergy(1, from: unit('kcal'), to: unit('cal')), 1000);
      // 来回换算可逆
      final back = convertEnergy(
        convertEnergy(123.456, from: unit('kcal'), to: unit('kwh'))!,
        from: unit('kwh'),
        to: unit('kcal'),
      );
      expect(back, closeTo(123.456, 1e-9));
      // 每单位都有中文说明与三种外语说明
      for (final u in kEnergyUnits) {
        expect(u.note, isNotEmpty, reason: u.id);
        for (final language in [
          AppLanguage.en,
          AppLanguage.ja,
          AppLanguage.es,
        ]) {
          expect(
            u.noteIn(language),
            isNotEmpty,
            reason: '${u.id} ${language.code}',
          );
          expect(u.label, isNotEmpty);
          expect(
            u.labelIn(language),
            isNotEmpty,
            reason: '${u.id} ${language.code}',
          );
        }
      }
      expect(kEnergySamples, isNotEmpty);
    });

    test('压力：帕 / 巴 / 托 / psi 都换算到帕斯卡', () {
      expect(kPressureCatalog.units.map((unit) => unit.id).toList(), <String>[
        'pa',
        'hpa',
        'kpa',
        'mpa',
        'bar',
        'torr',
        'psi',
      ]);
      PressureUnit unit(String id) => pressureUnitById(id)!;
      expect(convertPressure(1, from: unit('hpa'), to: unit('pa')), 100);
      expect(convertPressure(1, from: unit('kpa'), to: unit('pa')), 1000);
      expect(convertPressure(1, from: unit('mpa'), to: unit('kpa')), 1000);
      expect(convertPressure(1, from: unit('bar'), to: unit('kpa')), 100);
      // 1 托 = 101325/760 帕（即 1 毫米汞柱）
      expect(
        convertPressure(1, from: unit('torr'), to: unit('pa')),
        closeTo(101325 / 760, 1e-9),
      );
      expect(
        convertPressure(760, from: unit('torr'), to: unit('pa')),
        closeTo(101325, 1e-6),
      );
      // 1 psi ≈ 6894.757 帕（1 lbf = 4.4482216152605 N 精确值推出）
      expect(
        convertPressure(1, from: unit('psi'), to: unit('pa')),
        closeTo(6894.757293168, 1e-6),
      );
      expect(
        convertPressure(14.6959, from: unit('psi'), to: unit('kpa')),
        closeTo(101.325, 0.01),
      );
      for (final u in kPressureUnits) {
        expect(u.note, isNotEmpty, reason: u.id);
        for (final language in [
          AppLanguage.en,
          AppLanguage.ja,
          AppLanguage.es,
        ]) {
          expect(
            u.noteIn(language),
            isNotEmpty,
            reason: '${u.id} ${language.code}',
          );
          expect(
            u.labelIn(language),
            isNotEmpty,
            reason: '${u.id} ${language.code}',
          );
        }
      }
      expect(kPressureSamples, isNotEmpty);
    });

    test('温度 / 热量 / 压力不分体系：默认单位单独存一份', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      expect(settings.convertUnitFor('temperature'), isNull);

      await settings.setConvertUnit('temperature', 'f');
      expect(store.values['convert.temperature.unit'], 'f');
      await settings.setConvertUnit('energy', 'kcal');
      await settings.setConvertUnit('pressure', 'bar');

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.convertUnitFor('temperature'), 'f');
      expect(reloaded.convertUnitFor('energy'), 'kcal');
      expect(reloaded.convertUnitFor('pressure'), 'bar');
      // 别的工具没有默认单位
      expect(reloaded.convertUnitFor('distance'), isNull);
    });

    test('按系统语言判断首次启动的语言', () {
      expect(
        AppLanguage.fromLocale(const Locale('zh', 'CN')),
        AppLanguage.zhHans,
      );
      expect(
        AppLanguage.fromLocale(const Locale('zh', 'TW')),
        AppLanguage.zhHant,
      );
      expect(
        AppLanguage.fromLocale(const Locale('zh', 'HK')),
        AppLanguage.zhHant,
      );
      expect(AppLanguage.fromLocale(const Locale('ja', 'JP')), AppLanguage.ja);
      expect(AppLanguage.fromLocale(const Locale('es', 'ES')), AppLanguage.es);
      expect(AppLanguage.fromLocale(const Locale('en', 'US')), AppLanguage.en);
      // 认不出或拿不到系统语言时默认英文
      expect(AppLanguage.fromLocale(const Locale('de', 'DE')), AppLanguage.en);
      expect(AppLanguage.fromLocale(const Locale('ko')), AppLanguage.en);
      expect(AppLanguage.fromLocale(const Locale('und')), AppLanguage.en);
      expect(AppLanguage.fromLocale(null), AppLanguage.en);
    });
  });

  group('多语言：五种语言的文案表', () {
    test('每种语言都有完整且互不相同的界面文案', () {
      final titles = <String>{};
      for (final language in AppLanguage.values) {
        final strings = AppStrings.of(language);
        expect(strings.appTitle, isNotEmpty, reason: language.code);
        for (final text in [
          strings.navCalculator,
          strings.navTools,
          strings.navSettings,
          strings.toolsTitle,
          strings.toolsOffline,
          strings.settingsTitle,
          strings.settingsAppearance,
          strings.themeSystem,
          strings.themeLight,
          strings.themeDark,
          strings.settingsLanguage,
          strings.settingsAbout,
        ]) {
          expect(text, isNotEmpty, reason: '${language.code} 有空文案');
        }
        expect(strings.toolsCount(12), contains('12'));
        titles.add(strings.navSettings);
      }
      // 五种语言的「设置」写法互不相同（简繁算两种写法）
      expect(titles.length, greaterThanOrEqualTo(4));
    });

    test('八种单位换算工具在所有界面语言下都展示', () {
      for (final language in AppLanguage.values) {
        applyAppLanguage(language);
        expect(visibleTools.length, 8, reason: language.code);
        for (final id in <String>[
          'distance',
          'area',
          'volume',
          'weight',
          'temperature',
          'energy',
          'pressure',
          'speed',
        ]) {
          expect(toolById(id), isNotNull, reason: '${language.code} 缺 $id');
        }
      }
      applyAppLanguage(AppLanguage.zhHans);
      expect(kTools.length, 8);
    });

    test('每个工具的语言包都有五种语言，且 id 唯一', () {
      final ids = <String>{};
      for (final tool in kTools) {
        expect(ids.add(tool.id), isTrue, reason: '重复的工具 id：${tool.id}');
        for (final language in AppLanguage.values) {
          final text = tool.lang[language];
          expect(text, isNotNull, reason: '${tool.id} 缺 ${language.code}');
          expect(text!.name, isNotEmpty);
          expect(text.tagline, isNotEmpty);
        }
      }
      expect(kTools.length, 8);
    });

    test('工具名称随语言变化，缺翻译时回落简体中文', () {
      final distance = kTools.firstWhere((tool) => tool.id == 'distance');
      expect(distance.lang[AppLanguage.en]!.name, 'Length');
      expect(distance.lang[AppLanguage.es]!.name, 'Longitud');
      const fallback = <AppLanguage, String>{AppLanguage.zhHans: '只有中文'};
      expect(toolTextFor(fallback, AppLanguage.ja), '只有中文');
      expect(toolTextFor(fallback, AppLanguage.en), '只有中文');
    });
  });
}

/// 内存版设置存储，测试里替代文件 / localStorage。
class _MemoryStore implements SettingsStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<Map<String, String>> readAll() async => Map<String, String>.of(values);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
