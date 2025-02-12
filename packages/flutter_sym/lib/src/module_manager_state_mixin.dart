import 'package:flutter/widgets.dart';
import 'package:flutter_sym/src/sym_runtime_scope.dart';
import 'package:sym/sym.dart';

mixin ModuleManagerStateMixin<T extends StatefulWidget, A extends Object?>
    on State<T> {
  Runtime? _runtime;

  late final Module<A> module = createModule();

  Runtime get runtime => _runtime!;

  Module<A> createModule();

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
}
