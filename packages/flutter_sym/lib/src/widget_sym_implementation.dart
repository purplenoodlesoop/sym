// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_sym/src/widget_sym.dart';
import 'package:sym/sym.dart';

typedef _Subscriptions = Map<Store<Object?>, StreamSubscription<Object?>>;

final class WidgetSymImplementation implements WidgetSym {
  static final _finalizer = Finalizer<_Subscriptions>((subscriptions) {
    subscriptions.values.forEach((subscription) {
      subscription.cancel();
    });
  });
  static final _state = Expando<_Subscriptions>();

  final BuildContext _context;
  final Runtime _runtime;

  WidgetSymImplementation(
    this._context,
    this._runtime,
  );

  void _considerSubscribing<T>(Store<T> store) {
    if (_state[_context] == null) {
      _finalizer.attach(
        _context,
        _state[_context] ??= {},
      );
    }
    _state[_context]![store] ??= store.asStream().listen((_) {
      if (_context.mounted) (_context as Element).markNeedsBuild();
    });
  }

  @override
  void emit<T>(Trigger<T> trigger, T event) {
    _runtime.emit(trigger, event);
  }

  @override
  T use<T>(Ref<T> wrapped, {bool listen = true}) {
    if (wrapped is Store<T> && listen) _considerSubscribing(wrapped);

    return _runtime.use(wrapped);
  }
}
