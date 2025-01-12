// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_sym/flutter_sym.dart';

final counter = Module(name: 'counter', ($) {
  final increment = $.trigger<()>();

  return (
    increment: increment,
    value: $.store<int>(($) {
      $.on(increment, (_) => $.self + 1);

      return 0;
    })
  );
});

class CounterWidget extends StatefulWidget {
  const CounterWidget({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends SymWidgetState<CounterWidget> {
  @override
  Widget buildWidget(SymBuildContext context) {
    final (:increment, :value) = context.use(counter);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.use(value).toString(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ElevatedButton(
            onPressed: () => increment(context),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
