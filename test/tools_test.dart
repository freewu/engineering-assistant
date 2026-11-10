import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_assistant/l10n/app_i18n.dart';
import 'package:engineering_assistant/l10n/app_language.dart';
import 'package:engineering_assistant/l10n/app_strings.dart';
import 'package:engineering_assistant/services/settings_store.dart';
import 'package:engineering_assistant/state/settings_controller.dart';
import 'package:engineering_assistant/theme/app_theme.dart';
import 'package:engineering_assistant/ui/tools/area/area.dart';
import 'package:engineering_assistant/ui/tools/building/building_area.dart';
import 'package:engineering_assistant/ui/tools/building/building_area_strings.dart';
import 'package:engineering_assistant/ui/tools/concrete/concrete_member.dart';
import 'package:engineering_assistant/ui/tools/concrete/concrete_strings.dart';
import 'package:engineering_assistant/ui/tools/formwork/formwork.dart';
import 'package:engineering_assistant/ui/tools/formwork/formwork_strings.dart';
import 'package:engineering_assistant/ui/tools/insulation/insulation.dart';
import 'package:engineering_assistant/ui/tools/insulation/insulation_strings.dart';
import 'package:engineering_assistant/ui/tools/masonry/masonry.dart';
import 'package:engineering_assistant/ui/tools/masonry/masonry_strings.dart';
import 'package:engineering_assistant/ui/tools/material/material.dart';
import 'package:engineering_assistant/ui/tools/distance/distance.dart';
import 'package:engineering_assistant/ui/tools/earthwork/earthwork.dart';
import 'package:engineering_assistant/ui/tools/earthwork/earthwork_strings.dart';
import 'package:engineering_assistant/ui/tools/energy/energy.dart';
import 'package:engineering_assistant/ui/tools/tool_tabs.dart';
import 'package:engineering_assistant/ui/tools/pressure/pressure.dart';
import 'package:engineering_assistant/ui/tools/rebar/rebar.dart';
import 'package:engineering_assistant/ui/tools/roof/roof.dart';
import 'package:engineering_assistant/ui/tools/roof/roof_strings.dart';
import 'package:engineering_assistant/ui/tools/rebar/rebar_strings.dart';
import 'package:engineering_assistant/ui/tools/speed/speed.dart';
import 'package:engineering_assistant/ui/tools/temperature/temperature.dart';
import 'package:engineering_assistant/ui/tools/conversion_catalogs.dart';
import 'package:engineering_assistant/ui/tools/unit_catalog.dart';
import 'package:engineering_assistant/ui/tools/volume/volume.dart';
import 'package:engineering_assistant/ui/tools/weight/weight.dart';
import 'package:engineering_assistant/ui/tools/tool_catalog.dart';
import 'package:engineering_assistant/ui/tools/material/material_strings.dart';

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
      // 空串是「用户把输入框清空了」，要存下来；null 才是删掉字段
      settings.setToolDraftValue('distance', 'weight', '');
      settings.setToolDraftValue('distance', 'note', null);
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
        'weight': '',
      });
      expect(reloaded.toolDraftOf('weight'), <String, String>{
        'amount': '500000',
      });
      expect(reloaded.toolDraftOf('nope'), isEmpty);
    });

    test('清空输入框（空串）会被记住，重进还是空的', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      settings.setToolDraftValue('energy', 'age', '40');
      await settings.flushDrafts();
      settings.setToolDraftValue('energy', 'age', '');
      await settings.flushDrafts();

      // 空值留着，不再回落到页面默认值
      expect(settings.toolDraftOf('energy'), <String, String>{'age': ''});
      expect(store.values['tool.energy'], '{"age":""}');

      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.toolDraftOf('energy'), <String, String>{'age': ''});
    });

    test('传 null 才真的删字段，删光后整条草稿也删掉', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      settings.setToolDraftValue('energy', 'age', '40');
      await settings.flushDrafts();
      settings.setToolDraftValue('energy', 'age', null);
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

    test('工具默认 tab：按工具各存一份，越界按边界收，改完清掉草稿里的 tab', () async {
      final store = _MemoryStore();
      final settings = SettingsController(store: store);
      expect(kToolTabCounts, <String, int>{
        'material': kMaterialTabCount,
        'building_area': kBuildingTabCount,
        'concrete': kConcreteTabCount,
        'earthwork': kEarthworkTabCount,
        'rebar': kRebarTabCount,
        'masonry': kMasonryTabCount,
        'formwork': kFormworkTabCount,
        'roof': kRoofTabCount,
        'insulation': kInsulationTabCount,
      });
      for (final id in kToolTabCounts.keys) {
        expect(settings.toolTabFor(id), 0, reason: id);
      }
      // 不带 tab 的工具没有默认 tab
      expect(settings.toolTabFor('distance'), 0);

      // 先让草稿记住用户停在了「墙」，再改默认值：草稿的 tab 会被清掉
      settings.setToolDraftValue('concrete', 'tab', '3');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await settings.setToolTab('concrete', 2);
      expect(settings.toolTabFor('concrete'), 2);
      expect(store.values['concrete.tab'], '2');
      expect(settings.toolDraftOf('concrete').containsKey('tab'), isFalse);

      // 三个工具互不影响，越界按边界收
      await settings.setToolTab('material', 3);
      await settings.setToolTab('building_area', 9);
      expect(settings.toolTabFor('material'), kMaterialTabCount - 1);
      expect(settings.toolTabFor('building_area'), kBuildingTabCount - 1);
      await settings.setToolTab('concrete', -3);
      expect(settings.toolTabFor('concrete'), 0);
      // 不带 tab 的工具直接忽略
      await settings.setToolTab('distance', 2);
      expect(store.values.containsKey('distance.tab'), isFalse);

      await settings.setToolTab('building_area', 4);
      final reloaded = SettingsController(store: store);
      await reloaded.load();
      expect(reloaded.toolTabFor('material'), 3);
      expect(reloaded.toolTabFor('building_area'), 4);
      expect(reloaded.toolTabFor('concrete'), 0);

      // 存了脏数据时回到 0
      store.values['concrete.tab'] = 'wall';
      final fallback = SettingsController(store: store);
      await fallback.load();
      expect(fallback.toolTabFor('concrete'), 0);
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

  group('材料用量估算', () {
    test('砖块数量：标准红砖 512 块/m³、多孔砖 320 块/m³', () {
      expect(BrickType.standard.perCubicMeter, 512);
      expect(BrickType.perforated.perCubicMeter, 320);
      expect(brickCount(150, BrickType.standard), 76800);
      expect(brickCount(150, BrickType.perforated), 48000);
    });

    test('每平方米砖数：12 / 24 / 37 墙分别是 64 / 128 / 192', () {
      expect(WallThickness.thin.millimeters, 120);
      expect(WallThickness.standard.millimeters, 240);
      expect(WallThickness.thick.millimeters, 370);
      expect(WallThickness.thin.perSquareMeter, 64);
      expect(WallThickness.standard.perSquareMeter, 128);
      expect(WallThickness.thick.perSquareMeter, 192);
      expect(bricksByWall(10, WallThickness.standard), 1280);
    });

    test('混凝土：面积 × 厚度', () {
      expect(concreteVolume(1200, kCushionThickness), closeTo(120, 1e-9));
      expect(concreteVolume(100, kSlabThickness), closeTo(12, 1e-9));
      expect(concreteVolume(0, 0.1), 0);
    });

    test('水泥与砂子：建筑面积 × 单耗', () {
      expect(kCementRates, <double>[0.03, 0.04, 0.05]);
      expect(cementTons(10000, 0.05), 500);
      expect(cementTons(10000, 0.03), closeTo(300, 1e-9));
      expect(sandVolume(1000), closeTo(50, 1e-9));
      expect(sandVolume(1000, rate: 0.04), closeTo(40, 1e-9));
    });

    test('五种语言的「材料用量」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kMaterialStrings, language);
        for (final text in <String>[
          s.tabBricks,
          s.tabConcrete,
          s.tabCement,
          s.tabSand,
          s.brickFormula,
          s.concreteFormula,
          s.cementFormula,
          s.sandFormula,
          s.concreteHint,
          s.cementHint,
          s.sandHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        for (final wall in WallThickness.values) {
          expect(
            s.wallName(wall),
            isNotEmpty,
            reason: '${language.code} ${wall.name}',
          );
        }
      }
    });
  });

  group('建筑面积计算', () {
    test('单层建筑：L × B，结构高度不足 2.2 m 只算一半', () {
      expect(singleStoreyArea(30, 15, 3), 450);
      expect(singleStoreyArea(30, 15, kFullAreaHeight), 450);
      expect(singleStoreyArea(30, 15, 2), 225);
    });

    test('多层建筑：层数 × 每层面积', () {
      expect(multiStoreyArea(3, 500), 1500);
      expect(multiStoreyArea(1, 80), 80);
      expect(multiStoreyArea(0, 80), 0);
    });

    test('阳台按 1/2 计算，与封闭与否无关', () {
      expect(balconyArea(10), 5);
      expect(balconyArea(1.5), closeTo(0.75, 1e-9));
    });

    test('雨篷：有柱全面积，无柱宽度超过 2.1 m 才算', () {
      expect(canopyArea(6, width: 3, hasColumns: false), 6);
      expect(canopyArea(6, width: 2.1, hasColumns: false), 0);
      expect(canopyArea(6, width: 2, hasColumns: false), 0);
      expect(canopyArea(6, width: 1, hasColumns: true), 6);
      expect(kCanopyMinWidth, 2.1);
    });

    test('门斗：结构层高 ≥ 2.2 m 全面积，不足算 1/2', () {
      expect(vestibuleArea(4, 2.4), 4);
      expect(vestibuleArea(4, kFullAreaHeight), 4);
      expect(vestibuleArea(4, 2), 2);
    });

    test('车棚按顶盖投影面积 1/2 计算，合计时忽略未填项', () {
      expect(shedArea(20), 10);
      expect(totalArea(<double?>[450, null, 5]), 455);
      expect(totalArea(<double?>[]), 0);
    });

    test('五种语言的「建筑面积」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kBuildingAreaStrings, language);
        for (final text in <String>[
          s.tabSingle,
          s.tabMulti,
          s.tabBalcony,
          s.tabCanopy,
          s.tabVestibule,
          s.tabShed,
          s.length,
          s.width,
          s.height,
          s.floors,
          s.perFloorArea,
          s.storeyHeight,
          s.withColumns,
          s.withoutColumns,
          s.squareMeter,
          s.floorUnit,
          s.singleSection,
          s.singleResult,
          s.singleFormula,
          s.singleHint,
          s.multiSection,
          s.multiResult,
          s.multiFormula,
          s.multiHint,
          s.balconySection,
          s.balconyArea,
          s.balconyResult,
          s.balconyFormula,
          s.balconyHint,
          s.canopySection,
          s.canopyArea,
          s.canopyWidth,
          s.canopyResult,
          s.canopyFormula,
          s.canopySkipped,
          s.canopyHint,
          s.vestibuleSection,
          s.vestibuleArea,
          s.vestibuleResult,
          s.vestibuleFormula,
          s.vestibuleHint,
          s.shedSection,
          s.shedArea,
          s.shedResult,
          s.shedFormula,
          s.shedHint,
          s.total,
          s.totalHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 模板里的占位数量要对得上，日语 / 西语最容易漏
        expect(
          RegExp(r'\{\d\}').allMatches(s.singleFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.vestibuleFormula).length,
          3,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.multiFormula).length,
          3,
          reason: language.code,
        );
      }
    });
  });

  group('混凝土构件工程量', () {
    test('矩形柱 / 矩形梁：截面 × 截面 × 长度', () {
      expect(columnVolume(sectionA: 0.5, sectionB: 0.5, height: 3), 0.75);
      expect(beamVolume(sectionA: 0.25, sectionB: 0.5, length: 6), 0.75);
    });

    test('现浇板：净长 × 净宽 × 板厚，孔洞超过 0.3 ㎡ 才扣', () {
      expect(
        slabVolume(length: 6, width: 4, thickness: 0.12),
        closeTo(2.88, 1e-9),
      );
      // ≤ 0.3 ㎡ 的孔洞不扣（含 300 × 300 mm）
      expect(
        slabVolume(length: 6, width: 4, thickness: 0.12, holeArea: 0.3),
        closeTo(2.88, 1e-9),
      );
      expect(
        slabVolume(length: 6, width: 4, thickness: 0.12, holeArea: 0.09),
        closeTo(2.88, 1e-9),
      );
      // 超过 0.3 ㎡ 才从板面积里扣
      expect(
        slabVolume(length: 6, width: 4, thickness: 0.12, holeArea: 0.5),
        closeTo(2.82, 1e-9),
      );
      expect(holeDeducted(0.3), isFalse);
      expect(holeDeducted(0.3001), isTrue);
      expect(kIgnoredHoleArea, closeTo(0.09, 1e-9));
      expect(kDeductHoleArea, 0.3);
    });

    test('孔洞比板面还大时按 0 算，不出负数', () {
      expect(slabVolume(length: 2, width: 2, thickness: 0.1, holeArea: 9), 0);
    });

    test('混凝土墙：墙长 × 墙高 × 墙厚', () {
      expect(
        wallVolume(length: 5, height: 3, thickness: 0.2),
        closeTo(3, 1e-9),
      );
    });

    test('楼梯：水平投影面积 × 折算厚度', () {
      expect(
        stairVolume(planArea: 12, equivalentThickness: kDefaultStairThickness),
        3,
      );
      expect(kStairThicknessMin, 0.2);
      expect(kStairThicknessMax, 0.3);
    });

    test('五种语言的「混凝土构件」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kConcreteStrings, language);
        for (final text in <String>[
          s.tabColumn,
          s.tabBeam,
          s.tabSlab,
          s.tabWall,
          s.tabStair,
          s.columnSection,
          s.beamSection,
          s.slabSection,
          s.wallSection,
          s.stairSection,
          s.sectionA,
          s.sectionB,
          s.columnHeight,
          s.beamLength,
          s.netLength,
          s.netWidth,
          s.slabThickness,
          s.holeArea,
          s.wallLength,
          s.wallHeight,
          s.wallThickness,
          s.planArea,
          s.equivalentThickness,
          s.meterUnit,
          s.squareMeter,
          s.cubicMeter,
          s.columnResult,
          s.beamResult,
          s.slabResult,
          s.wallResult,
          s.stairResult,
          s.columnFormula,
          s.beamFormula,
          s.slabFormula,
          s.slabHoleFormula,
          s.wallFormula,
          s.stairFormula,
          s.columnHint,
          s.beamHint,
          s.slabHint,
          s.wallHint,
          s.stairHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 模板占位数量要对得上：带孔洞的板公式是 5 个，其余 3 ~ 4 个
        expect(
          RegExp(r'\{\d\}').allMatches(s.slabHoleFormula).length,
          5,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.columnFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.stairFormula).length,
          3,
          reason: language.code,
        );
      }
    });
  });

  group('土石方工程量', () {
    test('场地平整：首层外围长 × 宽，±30 cm 以内才算平整', () {
      expect(siteLevelingArea(30, 20), 600);
      expect(siteLevelingArea(12.5, 8), 100);
      expect(siteLevelingArea(0, 20), 0);
      expect(kLevelingTolerance, 0.3);
    });

    test('基坑 / 基槽：V = (a + 2c) × (b + 2c) × H，清单不加放坡', () {
      // 默认工作面 600 mm：垫层 6 × 4 m、挖深 3 m
      expect(kDefaultWorkFace, 0.6);
      expect(
        excavationVolume(length: 6, width: 4, depth: 3),
        closeTo(112.32, 1e-9),
      );
      // 工作面留空（c = 0）时就是垫层面积 × 挖深
      expect(
        excavationVolume(length: 6, width: 4, depth: 3, workFace: 0),
        closeTo(72, 1e-9),
      );
      // 工作面按图纸放大到 1 m
      expect(
        excavationVolume(length: 6, width: 4, depth: 3, workFace: 1),
        closeTo(8 * 6 * 3, 1e-9),
      );
      // 基槽：长 20 m、宽 1.2 m、深 2 m
      expect(
        excavationVolume(length: 20, width: 1.2, depth: 2),
        closeTo(21.2 * 2.4 * 2, 1e-9),
      );
    });

    test('管沟土方：V =（管外径 + 2c）× H × L，有 / 无垫层同一个式子', () {
      expect(
        pipeTrenchVolume(pipeDiameter: 0.5, depth: 1.5, length: 50),
        closeTo(127.5, 1e-9),
      );
      expect(
        pipeTrenchVolume(
          pipeDiameter: 0.5,
          depth: 1.5,
          length: 50,
          workFace: 0,
        ),
        closeTo(37.5, 1e-9),
      );
      // 工作面放大到 1 m：管沟净宽 2.5 m
      expect(
        pipeTrenchVolume(
          pipeDiameter: 0.5,
          depth: 1.5,
          length: 50,
          workFace: 1,
        ),
        closeTo(187.5, 1e-9),
      );
      // 长度按 0 算不出负数
      expect(pipeTrenchVolume(pipeDiameter: 0.5, depth: 1.5, length: 0), 0);
    });

    test('五种语言的「土石方工程」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kEarthworkStrings, language);
        for (final text in <String>[
          s.tabLeveling,
          s.tabExcavation,
          s.tabTrench,
          s.levelingSection,
          s.buildingLength,
          s.buildingWidth,
          s.levelingResult,
          s.levelingFormula,
          s.levelingHint,
          s.excavationSection,
          s.baseLength,
          s.baseWidth,
          s.workFace,
          s.depth,
          s.excavationResult,
          s.excavationFormula,
          s.excavationHint,
          s.trenchSection,
          s.pipeDiameter,
          s.pipeLength,
          s.trenchResult,
          s.trenchFormula,
          s.trenchHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 模板占位数量要对得上：场地平整 3 个；基坑 6 个（工作面 `{1}` 出现
        // 两次）；管沟 5 个。两者最后一个是体积。
        expect(
          RegExp(r'\{\d\}').allMatches(s.levelingFormula).length,
          3,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.excavationFormula).length,
          6,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.trenchFormula).length,
          5,
          reason: language.code,
        );
      }
    });
  });

  group('钢筋工程量', () {
    test('直钢筋：L = l - 2c + 2 × 弯钩', () {
      expect(kCoverBeam, 25);
      expect(kCoverSlab, 20);
      expect(kCoverColumn, 30);
      // 6 m 梁、保护层 25 mm、无弯钩
      expect(
        straightRebarLength(memberLength: 6000, cover: kCoverBeam),
        closeTo(5950, 1e-9),
      );
      // 两端各加 6.25d 的 180° 弯钩（d = 20）
      expect(
        straightRebarLength(
          memberLength: 6000,
          cover: kCoverBeam,
          hookLength: 6.25 * 20,
        ),
        closeTo(5950 + 250, 1e-9),
      );
      // 保护层比构件还长时不出现负数
      expect(straightRebarLength(memberLength: 40, cover: 25), 0);
    });

    test('抗震箍筋：L = 2(a + b) - 8c + 2 × 11.9d', () {
      expect(kStirrupHookFactor, 11.9);
      // 300 × 600 梁、保护层 25、φ8 箍筋
      expect(
        stirrupRebarLength(
          sectionA: 300,
          sectionB: 600,
          cover: 25,
          diameter: 8,
        ),
        closeTo(2 * 900 - 200 + 2 * 11.9 * 8, 1e-9),
      );
      expect(
        stirrupRebarLength(sectionA: 0, sectionB: 0, cover: 0, diameter: 0),
        0,
      );
    });

    test('弯起钢筋：L = 直段 + 斜段 - 弯曲调整值 + 弯钩', () {
      expect(
        bentRebarLength(
          straightPart: 4000,
          inclinedPart: 500,
          bendAdjustment: 40,
          hookLength: 100,
        ),
        closeTo(4560, 1e-9),
      );
      expect(bentRebarLength(straightPart: 1000, inclinedPart: 200), 1200);
    });

    test('理论质量：W = 0.00617 d²，速查表数值对得上', () {
      expect(kRebarMassFactor, 0.00617);
      expect(kCommonDiameters.first, 6);
      expect(kCommonDiameters.last, 32);
      expect(kReferenceMassPerMeter.length, kCommonDiameters.length);
      for (final (diameter, expected) in <(int, double)>[
        (10, 0.617),
        (12, 0.888),
        (16, 1.58),
        (20, 2.47),
        (25, 3.85),
      ]) {
        // 速查表按规范取整值显示
        expect(
          kReferenceMassPerMeter[diameter],
          expected,
          reason: 'φ$diameter',
        );
        // 公式算出来的值与表值只差四舍五入
        expect(
          rebarMassPerMeter(diameter.toDouble()),
          closeTo(expected, 0.01),
          reason: 'φ$diameter',
        );
      }
      // 6 m 的 φ20 钢筋：5.95 m × 2.468 = 14.68 kg，两根翻倍
      final single = rebarMass(length: 5950, diameter: 20);
      expect(single, closeTo(5.95 * 2.468, 1e-3));
      expect(rebarMass(length: 5950, diameter: 20, count: 2), single * 2);
      expect(rebarMass(length: 0, diameter: 25), 0);
    });

    test('五种语言的「钢筋工程」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kRebarStrings, language);
        for (final text in <String>[
          s.tabStraight,
          s.tabStirrup,
          s.tabBent,
          s.tabTable,
          s.straightSection,
          s.memberLength,
          s.cover,
          s.hookLength,
          s.diameter,
          s.count,
          s.lengthResult,
          s.massResult,
          s.straightFormula,
          s.straightHint,
          s.stirrupSection,
          s.sectionA,
          s.sectionB,
          s.stirrupFormula,
          s.stirrupHint,
          s.bentSection,
          s.straightPart,
          s.inclinedPart,
          s.bendAdjustment,
          s.bentFormula,
          s.bentHint,
          s.massFormula,
          s.tableSection,
          s.tableDiameter,
          s.tableMass,
          s.tableHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 直钢筋 4 个、箍筋 5 个、弯起 5 个、质量 4 个占位符
        expect(
          RegExp(r'\{\d\}').allMatches(s.straightFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.stirrupFormula).length,
          5,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.bentFormula).length,
          5,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.massFormula).length,
          4,
          reason: language.code,
        );
      }
    });
  });

  group('砌筑工程量', () {
    test('砖墙：V =（墙长 × 墙高 − 洞口）× 墙厚 − 混凝土构件', () {
      expect(
        brickWallVolume(length: 10, height: 3, thickness: 0.24),
        closeTo(7.2, 1e-9),
      );
      // 洞口 6 ㎡、圈梁等 0.5 m³：24 × 0.24 − 0.5 = 5.26 m³
      expect(
        brickWallVolume(
          length: 10,
          height: 3,
          thickness: 0.24,
          openingArea: 6,
          concreteVolume: 0.5,
        ),
        closeTo(5.26, 1e-9),
      );
      // 扣得太多时不出负数
      expect(
        brickWallVolume(
          length: 2,
          height: 2,
          thickness: 0.24,
          concreteVolume: 10,
        ),
        0,
      );
    });

    test('单个 ≤ 0.3 ㎡ 的孔洞不扣除', () {
      expect(kMasonryHoleThreshold, 0.3);
      expect(deductedOpening(0.3), 0);
      expect(deductedOpening(0.29), 0);
      expect(deductedOpening(0.31), closeTo(0.31, 1e-9));
      // 门洞 0.8 × 2.1 = 1.68 ㎡ 才扣
      expect(deductedOpening(0.8 * 2.1), closeTo(1.68, 1e-9));
    });

    test('砖基础：折加高度法与大放脚体积法', () {
      expect(kWallThickness240, 0.24);
      expect(kWallThickness120, 0.115);
      // 0.24 × (1.2 + 0.197) × (30 + 20) = 16.764 m³
      expect(
        brickFoundationVolume(
          thickness: 0.24,
          height: 1.2,
          addedHeight: 0.197,
          centerlineLength: 30,
          netLength: 20,
        ),
        closeTo(16.764, 1e-9),
      );
      // 折加高度为 0 时退化成 0.24 × 1.2 × 50 = 14.4 m³
      expect(
        brickFoundationVolume(
          thickness: 0.24,
          height: 1.2,
          addedHeight: 0,
          centerlineLength: 30,
          netLength: 20,
        ),
        closeTo(14.4, 1e-9),
      );
      // 大放脚体积法：14.4 + 2.364 = 16.764 m³，与折加高度法对得上
      expect(
        brickFoundationWithStepVolume(
          thickness: 0.24,
          height: 1.2,
          centerlineLength: 30,
          netLength: 20,
          stepVolume: 2.364,
        ),
        closeTo(16.764, 1e-9),
      );
    });

    test('特殊墙体：空斗墙 / 空花墙按外形体积，多孔砖墙扣孔洞', () {
      expect(
        specialWallVolume(length: 10, height: 3, thickness: 0.24),
        closeTo(7.2, 1e-9),
      );
      // 多孔砖墙扣 0.6 m³ 孔洞
      expect(
        specialWallVolume(
          length: 10,
          height: 3,
          thickness: 0.24,
          holeVolume: 0.6,
        ),
        closeTo(6.6, 1e-9),
      );
      // 孔洞比墙体还大时按 0 算
      expect(
        specialWallVolume(
          length: 1,
          height: 1,
          thickness: 0.115,
          holeVolume: 9,
        ),
        0,
      );
    });

    test('五种语言的「砌筑工程」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kMasonryStrings, language);
        for (final text in <String>[
          s.tabWall,
          s.tabFoundation,
          s.tabSpecial,
          s.wallSection,
          s.wallLength,
          s.wallHeight,
          s.wallThickness,
          s.openingArea,
          s.concreteVolume,
          s.wallResult,
          s.wallFormula,
          s.wallHint,
          s.foundationSection,
          s.foundationMode,
          s.modeAddedHeight,
          s.modeStepVolume,
          s.foundationThickness,
          s.foundationHeight,
          s.addedHeight,
          s.centerlineLength,
          s.netLength,
          s.stepVolume,
          s.foundationResult,
          s.foundationFormula,
          s.foundationStepFormula,
          s.foundationHint,
          s.specialSection,
          s.specialType,
          s.typeHollow,
          s.typeOpenwork,
          s.typePerforated,
          s.holeVolume,
          s.specialResult,
          s.specialFormula,
          s.specialHoleFormula,
          s.specialHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 砖墙 6 个、折加高度 6 个、大放脚 6 个、特殊墙体 4 个 / 5 个占位符
        expect(
          RegExp(r'\{\d\}').allMatches(s.wallFormula).length,
          6,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.foundationFormula).length,
          6,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.foundationStepFormula).length,
          6,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.specialFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.specialHoleFormula).length,
          5,
          reason: language.code,
        );
      }
    });
  });

  group('模板工程量', () {
    test('矩形柱：S = 截面周长 × 柱高', () {
      // 500 × 500 柱、高 3 m：2 × (0.5 + 0.5) × 3 = 6 ㎡
      expect(columnFormworkArea(a: 0.5, b: 0.5, height: 3), closeTo(6, 1e-9));
      expect(columnFormworkArea(a: 0.4, b: 0.6, height: 2), closeTo(4, 1e-9));
    });

    test('构造柱：截面周长 + 马牙槎展开，240 × 240 每米 1.56 ㎡', () {
      expect(kToothProtrusion, 0.06);
      expect(kToothCountPerMeter, 5);
      // 0.96 + 2 × 0.06 × 5 = 1.56 ㎡/m
      expect(
        tieColumnFormworkArea(a: 0.24, b: 0.24, height: 1),
        closeTo(1.56, 1e-9),
      );
      // 3 m 高 → 4.68 ㎡
      expect(
        tieColumnFormworkArea(a: 0.24, b: 0.24, height: 3),
        closeTo(4.68, 1e-9),
      );
      // 马牙槎为 0 时退化成矩形柱
      expect(
        tieColumnFormworkArea(a: 0.24, b: 0.24, height: 3, protrusion: 0),
        closeTo(columnFormworkArea(a: 0.24, b: 0.24, height: 3), 1e-9),
      );
    });

    test('矩形梁：S =（梁底宽 + 2 × 梁高）× 梁长', () {
      // 300 × 600 梁、长 6 m：(0.3 + 1.2) × 6 = 9 ㎡
      expect(
        beamFormworkArea(bottomWidth: 0.3, height: 0.6, length: 6),
        closeTo(9, 1e-9),
      );
      // 梁板连接处侧模不扣板厚，按全高算
      expect(
        beamFormworkArea(bottomWidth: 0.2, height: 0.5, length: 4),
        closeTo(4.8, 1e-9),
      );
    });

    test('墙：S = 墙长 × 墙高 − 洞口 + 侧壁，≤ 0.3 ㎡ 洞口不扣', () {
      expect(kFormworkHoleThreshold, 0.3);
      // 10 × 3 − 6 + 0.5 = 24.5 ㎡
      expect(
        wallFormworkArea(length: 10, height: 3, openingArea: 6, sideArea: 0.5),
        closeTo(24.5, 1e-9),
      );
      // 洞口 0.3 ㎡ 不扣
      expect(
        wallFormworkArea(length: 10, height: 3, openingArea: 0.3),
        closeTo(30, 1e-9),
      );
      // 洞口 0.31 ㎡ 要扣
      expect(
        wallFormworkArea(length: 10, height: 3, openingArea: 0.31),
        closeTo(29.69, 1e-9),
      );
    });

    test('楼梯：侧面展开面积 =（展开斜长 + 平台长）× 梯段宽', () {
      // 踏步 300 × 150：斜长 = 10 × √(0.09 + 0.0225) = 3.3541 m
      expect(
        stairSlopeLength(steps: 10, treadWidth: 0.3, riserHeight: 0.15),
        closeTo(10 * 0.33541, 1e-4),
      );
      // （3.3541 + 1.2）× 1.2 = 5.465 ㎡
      expect(
        stairFormworkArea(
          steps: 10,
          treadWidth: 0.3,
          riserHeight: 0.15,
          flightWidth: 1.2,
          landingLength: 1.2,
        ),
        closeTo(5.4649, 1e-4),
      );
      // 没有平台、0 级踏步时面积为 0
      expect(
        stairFormworkArea(
          steps: 0,
          treadWidth: 0.28,
          riserHeight: 0.15,
          flightWidth: 1.2,
        ),
        0,
      );
    });

    test('五种语言的「模板工程」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kFormworkStrings, language);
        for (final text in <String>[
          s.tabColumn,
          s.tabBeam,
          s.tabWall,
          s.tabStair,
          s.columnSection,
          s.columnMode,
          s.modeRectangle,
          s.modeTie,
          s.columnA,
          s.columnB,
          s.columnHeight,
          s.columnResult,
          s.columnFormula,
          s.tieFormula,
          s.tieHint,
          s.columnHint,
          s.beamSection,
          s.beamBottomWidth,
          s.beamHeight,
          s.beamLength,
          s.beamResult,
          s.beamFormula,
          s.beamHint,
          s.wallSection,
          s.wallLength,
          s.wallHeight,
          s.wallOpening,
          s.wallSide,
          s.wallResult,
          s.wallFormula,
          s.wallHint,
          s.stairSection,
          s.stairSteps,
          s.stairTreadWidth,
          s.stairRiser,
          s.stairFlightWidth,
          s.stairLanding,
          s.stairResult,
          s.stairFormula,
          s.stairHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 矩形柱 4 个、构造柱 6 个、梁 4 个、墙 5 个、楼梯 4 个占位符
        expect(
          RegExp(r'\{\d\}').allMatches(s.columnFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.tieFormula).length,
          6,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.beamFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.wallFormula).length,
          5,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.stairFormula).length,
          4,
          reason: language.code,
        );
      }
    });
  });

  group('屋面及防水工程量', () {
    test('翻边：高度 ≥ 300 mm 才按展开面积并入', () {
      expect(kUpturnThreshold, 0.3);
      expect(upturnArea(length: 60, height: 0.3), closeTo(18, 1e-9));
      expect(upturnArea(length: 60, height: 0.5), closeTo(30, 1e-9));
      // 不足 300 mm 不另计
      expect(upturnArea(length: 60, height: 0.2), 0);
      expect(upturnArea(length: 60, height: 0.29), 0);
    });

    test('平屋面：S = 主墙间净面积 + 翻边展开面积', () {
      // 100 + 60 × 0.3 = 118 ㎡
      expect(
        flatRoofArea(netArea: 100, upturnLength: 60, upturnHeight: 0.3),
        closeTo(118, 1e-9),
      );
      // 没有翻边时就是净面积
      expect(flatRoofArea(netArea: 100), closeTo(100, 1e-9));
    });

    test('坡屋面：S = 水平投影面积 × 延尺系数 C', () {
      // C = 1 / cos30° ≈ 1.1547
      expect(slopeFactor(30), closeTo(1.154700538, 1e-9));
      expect(slopeFactor(0), closeTo(1, 1e-9));
      expect(slopeFactor(45), closeTo(1.414213562, 1e-9));
      expect(
        pitchedRoofArea(projectedArea: 100, angleDegrees: 30),
        closeTo(115.4700538, 1e-6),
      );
    });

    test('楼地面防水与墙基防水', () {
      // 80 + 40 × 0.3 = 92 ㎡
      expect(
        floorWaterproofArea(netArea: 80, upturnLength: 40, upturnHeight: 0.3),
        closeTo(92, 1e-9),
      );
      // 翻边只有 200 mm 时不另计
      expect(
        floorWaterproofArea(netArea: 80, upturnLength: 40, upturnHeight: 0.2),
        closeTo(80, 1e-9),
      );
      // （30 + 20）× 0.24 = 12 ㎡
      expect(
        wallBaseWaterproofArea(
          centerlineLength: 30,
          netLength: 20,
          width: 0.24,
        ),
        closeTo(12, 1e-9),
      );
    });

    test('五种语言的「屋面及防水」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kRoofStrings, language);
        for (final text in <String>[
          s.tabFlat,
          s.tabSlope,
          s.tabFloor,
          s.tabBase,
          s.flatSection,
          s.netArea,
          s.upturnLength,
          s.upturnHeight,
          s.flatResult,
          s.flatFormula,
          s.upturnIgnored,
          s.flatHint,
          s.slopeSection,
          s.projectedArea,
          s.slopeAngle,
          s.slopeResult,
          s.slopeFormula,
          s.slopeHint,
          s.floorSection,
          s.floorNetArea,
          s.floorUpturnLength,
          s.floorResult,
          s.floorFormula,
          s.floorHint,
          s.baseSection,
          s.centerlineLength,
          s.netLength,
          s.baseWidth,
          s.baseResult,
          s.baseFormula,
          s.baseHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 平屋面 / 楼地面 4 个、坡屋面 3 个、墙基 4 个占位符
        expect(
          RegExp(r'\{\d\}').allMatches(s.flatFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.floorFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.slopeFormula).length,
          3,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.baseFormula).length,
          4,
          reason: language.code,
        );
        expect(
          RegExp(r'\{\d\}').allMatches(s.upturnIgnored).length,
          0,
          reason: language.code,
        );
      }
    });
  });

  group('保温隔热工程量', () {
    test('孔洞：只有大于 0.3 ㎡ 的才扣除', () {
      expect(kInsulationHoleThreshold, 0.3);
      expect(deductedArea(0.3), 0);
      expect(deductedArea(0.31), closeTo(0.31, 1e-9));
      expect(deductedArea(2.4), closeTo(2.4, 1e-9));
    });

    test('屋面：S = 投影面积 − 孔洞，V = S × 平均厚度', () {
      expect(roofInsulationArea(projectedArea: 100), closeTo(100, 1e-9));
      expect(
        roofInsulationArea(projectedArea: 100, holeArea: 0.2),
        closeTo(100, 1e-9),
      );
      expect(
        roofInsulationArea(projectedArea: 100, holeArea: 2),
        closeTo(98, 1e-9),
      );
      expect(insulationVolume(area: 98, thickness: 0.1), closeTo(9.8, 1e-9));
    });

    test('墙面：S = 墙长 × 墙高 − 洞口 + 侧壁', () {
      // 10 × 3 − 6 + 0 = 24 ㎡
      expect(
        wallInsulationArea(length: 10, height: 3, openingArea: 6),
        closeTo(24, 1e-9),
      );
      // 侧壁并入
      expect(
        wallInsulationArea(
          length: 10,
          height: 3,
          openingArea: 6,
          sideArea: 1.2,
        ),
        closeTo(25.2, 1e-9),
      );
      // 洞口不足 0.3 ㎡ 不扣
      expect(
        wallInsulationArea(length: 10, height: 3, openingArea: 0.3),
        closeTo(30, 1e-9),
      );
      expect(insulationVolume(area: 24, thickness: 0.05), closeTo(1.2, 1e-9));
    });

    test('柱：S = 中心线展开长度 × 柱高 − 梁所占面积', () {
      // 1.2 × 3 − 0.5 = 3.1 ㎡
      expect(
        columnInsulationArea(
          perimeterCenterline: 1.2,
          height: 3,
          beamArea: 0.5,
        ),
        closeTo(3.1, 1e-9),
      );
      // 梁所占面积正好 0.3 ㎡ 时不扣
      expect(
        columnInsulationArea(
          perimeterCenterline: 1.2,
          height: 3,
          beamArea: 0.3,
        ),
        closeTo(3.6, 1e-9),
      );
      expect(
        insulationVolume(area: 3.1, thickness: 0.05),
        closeTo(0.155, 1e-9),
      );
    });

    test('五种语言的「保温隔热」文案齐全', () {
      for (final language in AppLanguage.values) {
        final s = toolTextFor(kInsulationStrings, language);
        for (final text in <String>[
          s.tabRoof,
          s.tabWall,
          s.tabColumn,
          s.roofSection,
          s.projectedArea,
          s.holeArea,
          s.avgThickness,
          s.roofAreaResult,
          s.roofAreaFormula,
          s.volumeResult,
          s.volumeFormula,
          s.roofHint,
          s.wallSection,
          s.wallLength,
          s.wallHeight,
          s.openingArea,
          s.sideArea,
          s.thickness,
          s.wallAreaResult,
          s.wallAreaFormula,
          s.wallHint,
          s.columnSection,
          s.columnPerimeter,
          s.columnHeight,
          s.beamArea,
          s.columnAreaResult,
          s.columnAreaFormula,
          s.columnHint,
          s.note,
        ]) {
          expect(text, isNotEmpty, reason: language.code);
        }
        // 屋面 3 个、墙面 5 个、柱 4 个、体积 3 个占位符
        for (final formula in <String>[
          s.roofAreaFormula,
          s.wallAreaFormula,
          s.columnAreaFormula,
          s.volumeFormula,
        ]) {
          final expected = formula == s.wallAreaFormula
              ? 5
              : formula == s.volumeFormula
              ? 3
              : formula == s.columnAreaFormula
              ? 4
              : 3;
          expect(
            RegExp(r'\{\d\}').allMatches(formula).length,
            expected,
            reason: '${language.code} $formula',
          );
        }
      }
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

    test('八个换算工具 + 九个工程工具在所有界面语言下都展示', () {
      for (final language in AppLanguage.values) {
        applyAppLanguage(language);
        expect(visibleTools.length, 17, reason: language.code);
        for (final id in <String>[
          'material',
          'building_area',
          'concrete',
          'earthwork',
          'rebar',
          'masonry',
          'formwork',
          'roof',
          'insulation',
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
      expect(kTools.length, 17);
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
      expect(kTools.length, 17);
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
