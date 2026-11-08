import 'package:flutter/foundation.dart';

import 'angle_mode.dart';
import 'ast.dart';
import 'eval_context.dart';
import 'evaluator.dart';
import 'number_format.dart';
import 'parser.dart';
import 'token.dart';

/// 一次计算的返回值。
class EngineResult {
  const EngineResult({
    this.value,
    this.error,
    this.exception,
    this.expression,
    this.node,
  });

  final double? value;

  /// 简体中文错误消息（[exception] 为 null 时才用它）。
  final String? error;

  /// 结构化错误，界面用 `calcErrorMessage()` 取当前语言的文案。
  final CalcException? exception;
  final String? expression;
  final Expr? node;

  bool get isError => error != null;

  String get display => error ?? formatNumber(value ?? double.nan);
}

/// 计算引擎：负责解析缓存、求值、数字格式化。
class MathEngine extends ChangeNotifier {
  MathEngine({AngleMode angleMode = AngleMode.degrees}) {
    _angleMode = angleMode;
  }

  static const int _cacheLimit = 256;
  static const Evaluator _evaluator = Evaluator();

  final Map<String, Expr> _cache = <String, Expr>{};

  late AngleMode _angleMode;
  AngleMode get angleMode => _angleMode;
  set angleMode(AngleMode mode) {
    if (mode == _angleMode) return;
    _angleMode = mode;
    _cache.clear();
    notifyListeners();
  }

  /// 解析（带缓存）。
  Expr compile(String source) {
    final key = source.trim();
    final cached = _cache[key];
    if (cached != null) return cached;
    final node = Parser(key).parse();
    if (_cache.length >= _cacheLimit) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = node;
    return node;
  }

  /// 解析并求值，异常统一转换成 [EngineResult.error]。
  EngineResult evaluate(String source, {Map<String, double>? variables}) {
    try {
      final node = compile(source);
      final context = EvalContext(
        angleMode: _angleMode,
        variables: <String, double>{...?variables},
      );
      final value = _evaluator.evaluate(node, context);
      return EngineResult(value: value, expression: source.trim(), node: node);
    } on CalcException catch (error) {
      return EngineResult(
        error: error.toString(),
        exception: error,
        expression: source.trim(),
      );
    } catch (error) {
      return EngineResult(
        error: '计算失败：$error',
        exception: CalcException(CalcError.generic, args: [error]),
        expression: source.trim(),
      );
    }
  }
}
