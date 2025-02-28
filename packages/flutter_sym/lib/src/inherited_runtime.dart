import 'package:flutter/widgets.dart';
import 'package:sym/sym.dart';

class InheritedRuntime extends InheritedWidget {
  final Runtime runtime;

  const InheritedRuntime({
    super.key,
    required this.runtime,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedRuntime oldWidget) => false;
}
