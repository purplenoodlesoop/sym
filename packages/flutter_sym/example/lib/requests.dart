import 'dart:convert';

import 'package:http/http.dart';
import 'package:sym/sym.dart';

final requests = Module(($) {
  final self = $.self;
  final client = $.value(($) => Client());

  $.on(self.dispose, ($, _) {
    $.use(client).close();
  });

  return $.value(
    ($) => (
      get: (Uri uri) => $
          .use(client)
          .get(uri)
          .then((response) => response.body)
          .then(jsonDecode),
    ),
  );
});
