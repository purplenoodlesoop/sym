import 'dart:async';

import 'package:sym/sym.dart';

final appStatusM = Module(($) {
  final intent = (
    toBackground: $.trigger<()>(),
    toForeground: $.trigger<()>(),
  );
  final completerChanged = $.trigger<Completer<void>?>();
  final completer$ = completerChanged.toStore($, (ctx) => null);
  $
    ..on(intent.toBackground, ($, _) => completerChanged($, Completer()))
    ..on(intent.toForeground, ($, event) {
      $.use(completer$)?.complete();
      completerChanged($, null);
    });

  return (
    intent: intent,
    future: $.value(($) => $.use(completer$)?.future),
  );
});
