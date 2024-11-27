import 'package:sym/sym.dart';

final pingPong = Module(($) {
  final ping = $.trigger<int>();
  final pong = $.trigger<int>();
  final total = $.store<int>(($) {
    $
      ..on(ping, (value) => $.self + value)
      ..on(pong, (value) => $.self + value);

    return 0;
  });

  $
    ..on(total, ($, event) {
      print('Total: $event');
    })
    ..on($.self.init, ($, _) {
      ping($, 1);
    })
    ..on(ping, ($, value) async {
      await Future.delayed(Duration(seconds: value));
      print('Ping: $value');
      pong($, value - 1);
    })
    ..on(pong, ($, value) async {
      await Future.delayed(Duration(seconds: value));
      print('Pong: $value');
      ping($, value + 2);
    });
});

void main() {
  Runtime().use(pingPong);
}
