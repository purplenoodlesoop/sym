import 'package:flutter/material.dart';
import 'package:flutter_sym/src/sym_runtime_scope.dart';
import 'package:sym/sym.dart';

typedef ReactionBuilderBody = void Function(
  BuildContext context,
  ModuleHooks $,
);

class SymReactionBuilder extends StatefulWidget {
  final ReactionBuilderBody body;
  final Widget child;

  const SymReactionBuilder({
    super.key,
    required this.body,
    required this.child,
  });

  @override
  State<SymReactionBuilder> createState() => _SymReactionBuilderState();
}

class _SymReactionBuilderState extends State<SymReactionBuilder> {
  late final Module<()> module = Module(name: 'SymReactionBuilder', ($) {
    widget.body(context, $);

    return const ();
  });

  Runtime? _runtime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final runtime = SymRuntimeScope.of(context);
    if (runtime != _runtime) {
      _runtime = runtime;
      runtime
        ..detachModule(module)
        ..use(module);
    }
  }

  @override
  void dispose() {
    _runtime?.detachModule(module);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
