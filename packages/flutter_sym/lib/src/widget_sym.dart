import 'package:flutter/widgets.dart';
import 'package:flutter_sym/src/sym_runtime_scope.dart';
import 'package:flutter_sym/src/widget_sym_implementation.dart';
import 'package:sym/sym.dart';

abstract interface class WidgetSym implements MultiConsumer, EventSource {
  @override
  T use<T>(Ref<T> wrapped, {bool listen = true});
}

extension WidgetSymX on BuildContext {
  WidgetSym get $ => WidgetSymImplementation(
        this,
        SymRuntimeScope.of(this),
      );
}
