import 'dart:math';

import 'package:sym/sym.dart';

final device = Module(($) {
  final shake = $.trigger<()>();
  return (shake: shake,);
});

final complexCounter = Module(($) {
  final device$ = $.use(device);
  final add = $.trigger<int>();
  final increment = $.trigger<()>();
  final random = $.value(($) => Random());

  $.on(increment, ($, _) async {
    final amount = $.use(random).nextInt(10);
    await Future<void>.delayed(Duration(seconds: amount));
    add($, amount);
  });

  return (
    increment: increment,
    value: $.store<int>(($) {
      const initial = 0;
      $
        ..on(add, (amount) => $.self + amount)
        ..on(device$.shake, (_) => initial);

      return initial;
    }),
  );
});
