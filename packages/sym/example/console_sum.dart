// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:io';

import 'package:sym/sym.dart';

final consoleSum = Module(name: 'main', ($) {
  final incrementBy = $.trigger<int>(name: 'incrementBy');
  final requestValue = $.trigger<()>(name: 'requestValue');

  final state = $.store<int>(name: 'state', ($) {
    $.on(incrementBy, (amount) => $.self + amount);

    return 10;
  });

  $
    ..on($.self.init, ($, _) {
      requestValue($);
    })
    ..on(requestValue, ($, _) {
      stdout.write('Increment by: ');
      final value = stdin.readLineSync()!;
      incrementBy($, int.parse(value));
    })
    ..on(state, ($, value) {
      stdout.writeln('Value: $value');
      requestValue($);
    });
});

Future<void> main() async {
  Runtime().use(consoleSum);
}
