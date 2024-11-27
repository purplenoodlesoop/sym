import 'package:flutter/material.dart';
import 'package:flutter_sym/src/module_manager_state_mixin.dart';
import 'package:sym/sym.dart';

typedef ReactionBuilderBody = void Function(BuildContext context, ModuleSym $);

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

class _SymReactionBuilderState extends State<SymReactionBuilder>
    with ModuleManagerStateMixin<SymReactionBuilder, ()> {
  @override
  Module<()> createModule() => Module(name: 'SymReactionBuilder', ($) {
        widget.body(context, $);

        return const ();
      });

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
