import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_assistant/core/angle_mode.dart';
import 'package:engineering_assistant/core/calc_error.dart';
import 'package:engineering_assistant/core/builtins.dart';
import 'package:engineering_assistant/l10n/app_i18n.dart';
import 'package:engineering_assistant/l10n/calc_errors.dart';
import 'package:engineering_assistant/l10n/calc_strings.dart';
import 'package:engineering_assistant/l10n/app_language.dart';

void main() {
  group('计算器页面文案', () {
    test('五种语言都齐全', () {
      for (final language in AppLanguage.values) {
        expect(
          kCalcStrings.containsKey(language),
          isTrue,
          reason: language.code,
        );
      }
    });

    test('除简体外的语言翻全了 48 个内置函数说明', () {
      // 简体直接用 core/builtins.dart 的中文，其余语言必须自己覆盖
      for (final language in AppLanguage.values) {
        if (language == AppLanguage.zhHans) continue;
        final descriptions = kCalcStrings[language]!.functionDescriptions;
        for (final name in builtinFunctions.keys) {
          expect(
            descriptions.containsKey(name),
            isTrue,
            reason: '${language.code} 缺少 $name 的说明',
          );
          expect(descriptions[name], isNotEmpty);
        }
      }
    });

    test('取不到的说明回落数据层中文', () {
      const strings = CalcStrings(
        keyboardHint: '',
        historyShort: '',
        clear: '',
        historyTitle: '',
        historyEmpty: '',
        copyEntryTooltip: '',
        copyLatex: '',
        copyResult: '',
        latexCopied: '',
        resultCopied: '',
        latexWithResultCopied: '',
        latexFailed: '',
        angleTooltip: '',
        memoryClearTooltip: '',
        insertAnsTooltip: '',
        functionLibrary: '',
        copyTooltip: '',
        copyLatexWithResult: '',
        inputHint: '',
        previewHint: '',
        functionsIntro: '',
        angleDegrees: '',
        angleRadians: '',
        categoryTrig: '',
        categoryHyperbolic: '',
        categoryExpLog: '',
        categoryPowerRoot: '',
        categoryRounding: '',
        categoryCombinatorics: '',
        categoryCalculus: '',
        categoryMisc: '',
        functionDescriptions: <String, String>{'sin': 'sine'},
        sumDescription: '',
        prodDescription: '',
        integrateDescription: '',
        diffDescription: '',
      );
      expect(strings.functionDescription('sin', '正弦'), 'sine');
      expect(strings.functionDescription('cos', '余弦'), '余弦');
    });

    test('角度单位名称跟语言走', () {
      expect(
        kCalcStrings[AppLanguage.en]!.angleLabel(AngleMode.degrees),
        'degrees',
      );
      expect(
        kCalcStrings[AppLanguage.ja]!.angleLabel(AngleMode.radians),
        'ラジアン',
      );
      expect(
        kCalcStrings[AppLanguage.es]!.angleLabel(AngleMode.degrees),
        'grados',
      );
    });
  });

  group('计算错误文案', () {
    test('除简体外的四种语言翻全了所有错误', () {
      for (final language in AppLanguage.values) {
        if (language == AppLanguage.zhHans) continue;
        final pack = kCalcErrorStrings[language]!;
        for (final code in CalcError.values) {
          expect(
            pack[code],
            isNotNull,
            reason: '${language.code} 缺 ${code.name}',
          );
          expect(pack[code]!.trim(), isNotEmpty);
        }
      }
    });

    test('简体直接用数据层模板并附上位置', () {
      applyAppLanguage(AppLanguage.zhHans);
      addTearDown(() => applyAppLanguage(AppLanguage.zhHans));
      expect(
        calcErrorMessage(const CalcException(CalcError.incompleteExpression)),
        '表达式不完整',
      );
      expect(
        calcErrorMessage(
          const CalcException(
            CalcError.undefinedVariable,
            position: 2,
            args: ['x'],
          ),
        ),
        '未定义变量 "x"（位置 3）',
      );
    });

    test('切换语言后同一异常换文案', () {
      addTearDown(() => applyAppLanguage(AppLanguage.zhHans));
      const error = CalcException(
        CalcError.undefinedVariable,
        position: 0,
        args: ['x'],
      );
      applyAppLanguage(AppLanguage.en);
      expect(calcErrorMessage(error), 'Undefined variable "x" (position 1)');
      applyAppLanguage(AppLanguage.ja);
      expect(calcErrorMessage(error), '未定義の変数「x」（位置 1）');
      applyAppLanguage(AppLanguage.es);
      expect(calcErrorMessage(error), 'Variable no definida «x» (posición 1)');
      applyAppLanguage(AppLanguage.zhHant);
      expect(calcErrorMessage(error), '未定義的變數「x」（位置 1）');
    });

    test('非本地的异常回落 toString', () {
      final error = StateError('boom');
      expect(
        calcErrorMessage(const CalcException(CalcError.nesting)),
        isNotEmpty,
      );
      expect(calcErrorText(error), contains('boom'));
    });
  });
}
