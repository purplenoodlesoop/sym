import 'package:flutter/widgets.dart';
import 'package:flutter_sym/src/sym_build_context.dart';
import 'package:flutter_sym/src/sym_widget.dart';

class SymBuilder extends SymWidget {
  final Widget Function(SymBuildContext context) builder;

  const SymBuilder({
    required this.builder,
    super.key,
  });

  @override
  Widget build(SymBuildContext context) => builder(context);
}
