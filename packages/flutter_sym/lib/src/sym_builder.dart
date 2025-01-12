import 'package:flutter/widgets.dart';
import 'package:flutter_sym/src/sym_build_context.dart';
import 'package:flutter_sym/src/sym_widget.dart';

class SymBuilder extends StatefulWidget {
  final Widget Function(SymBuildContext context) builder;

  const SymBuilder({
    required this.builder,
    super.key,
  });

  @override
  SymWidgetState createState() => _SymBuilderState();
}

class _SymBuilderState extends SymWidgetState<SymBuilder> {
  @override
  Widget buildWidget(SymBuildContext context) => widget.builder(context);
}
