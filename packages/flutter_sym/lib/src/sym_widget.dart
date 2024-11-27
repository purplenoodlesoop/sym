import 'package:flutter/widgets.dart';
import 'package:flutter_sym/src/module_manager_state_mixin.dart';
import 'package:flutter_sym/src/sym_build_context.dart';
import 'package:sym/sym.dart';

abstract class SymWidget extends StatefulWidget {
  const SymWidget({super.key});

  Widget build(SymBuildContext context);

  @override
  State<SymWidget> createState() => _SymWidgetState();
}

class _SymWidgetState extends State<SymWidget>
    with ModuleManagerStateMixin<SymWidget, Store<Widget>> {
  SymBuildContextImplementation? _debugSymContext;
  Widget? _debugHotReloadAwareChild;

  @override
  void reassemble() {
    super.reassemble();
    if (patchHotReload) {
      _debugHotReloadAwareChild = widget.build(_debugSymContext!);
    }
  }

  bool get patchHotReload => true;

  @override
  Module<Store<Widget>> createModule() => Module(name: 'SymWidget', ($) {
        final result = $.value((valueSym) {
          final symContext = SymBuildContextImplementation(
            runtime,
            $,
            valueSym,
            context,
          );
          final built = widget.build(symContext);

          if (patchHotReload) {
            _debugSymContext = symContext;
            _debugHotReloadAwareChild = built;
          }

          return built;
        });
        $.on(result, ($, _) {
          if (context.mounted) setState(() {});
        });

        return result;
      });

  @override
  Widget build(BuildContext context) {
    final use = runtime.use;
    final output = use(use(module));

    return patchHotReload ? _debugHotReloadAwareChild! : output;
  }
}
