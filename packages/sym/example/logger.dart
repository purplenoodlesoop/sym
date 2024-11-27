import 'dart:io';

import 'package:sym/sym.dart';

final logger = Module(($) {
  final intents = (
    info: $.trigger<Object?>(),
    debug: $.trigger<Object?>(),
  );
  final levels = {
    intents.info: 'Info',
    intents.debug: 'Debug',
  };
  levels.forEach((event, level) {
    $.on(event, ($, msg) {
      stdout.write('[$level] $msg');
    });
  });

  return intents;
});
