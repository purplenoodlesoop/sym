import 'package:sym/sym.dart';

final counter = Module(($) {
  final intents = (
    changeBy: $.trigger<int>(),
    reset: $.trigger<()>(),
  );

  return (
    intents: intents,
    value: $.store<int>((store) {
      const initial = 0;
      store
        ..on(intents.changeBy, (amount) => store.self + amount)
        ..on(intents.reset, (_) => initial);

      return initial;
    }),
  );
});
