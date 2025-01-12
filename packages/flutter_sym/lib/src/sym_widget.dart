import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sym/src/module_manager_state_mixin.dart';
import 'package:flutter_sym/src/sym_build_context.dart';
import 'package:sym/sym.dart';

abstract class SymWidgetState<W extends StatefulWidget> extends State<W>
    with ModuleManagerStateMixin<W, Store<Widget>> {
  SymBuildContextImplementation? _debugSymContext;
  Widget? _debugHotReloadAwareChild;

  Widget buildWidget(SymBuildContext context);

  @override
  @nonVirtual
  void reassemble() {
    super.reassemble();
    if (patchHotReload) {
      _debugHotReloadAwareChild = buildWidget(_debugSymContext!);
    }
  }

  bool get patchHotReload => true;

  @override
  @nonVirtual
  Module<Store<Widget>> createModule() => Module(name: 'SymWidget($W)', ($) {
        final result = $.value((valueSym) {
          final symContext = SymBuildContextImplementation(
            runtime,
            $,
            valueSym,
            context,
          );
          final built = buildWidget(symContext);

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
  @nonVirtual
  Widget build(BuildContext context) {
    final use = runtime.use;
    final output = use(use(module));

    return patchHotReload ? _debugHotReloadAwareChild! : output;
  }
}
