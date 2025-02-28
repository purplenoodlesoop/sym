// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_sym/flutter_sym.dart';

final counter = Module(($) {
  final increment = $.trigger<()>();

  return (
    increment: increment,
    value: $.store<int>(($) {
      $.on(increment, (_) => $.self + 1);

      return 0;
    })
  );
});

class CounterWidget extends StatelessWidget {
  const CounterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final $ = context.$;
    final (:increment, :value) = $.use(counter);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            $.use(value).toString(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ElevatedButton(
            onPressed: () => increment($),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
