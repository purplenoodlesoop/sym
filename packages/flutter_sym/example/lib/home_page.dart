import 'random_user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sym/flutter_sym.dart';

final homeScreen = Module(name: 'homeScreen', ($) {
  final showCounter = $.signal(($) => false);

  return (showCounter: showCounter,);
});

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final $ = context.$;
    final (:showCounter) = $.use(homeScreen);

    final shouldShow = $.use(showCounter.get);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: shouldShow,
              onChanged: (value) => showCounter.set($, value),
            ),
            if (shouldShow) ...[
              // const CounterWidget(),
              const RandomUserPage()
            ],
          ],
        ),
      ),
    );
  }
}
