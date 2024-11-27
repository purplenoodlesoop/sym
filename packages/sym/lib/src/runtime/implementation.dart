// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:sym/src/data/dependency_graph.dart';
import 'package:sym/src/interfaces.dart';
import 'package:sym/src/runtime/module.dart';
import 'package:sym/src/runtime/shared.dart';

extension on ModuleOverrides {
  ModuleDescription<R>? overrideOf<R extends Object?>(Module<R> module) {
    final value = firstWhereOrNull((element) => element.source == module);

    return value as ModuleDescription<R>?;
  }

  bool isOverriden<R extends Object?>(Module<R> module) =>
      overrideOf(module) != null;
}

typedef ModuleSubscriptions = Set<StreamSubscription<Object?>>;

typedef ModuleState<T extends Object?> = ({
  T module,
  ModuleSubscriptions subscriptions,
  Trigger<()> dispose,
  Set<Store> stores,
});

class RuntimeImplementation implements Runtime, EffectSym {
  final ModuleOverrides _overrides;
  final RuntimeImplementation? _parent;
  late final StreamController<Message> _eventsController;

  RuntimeImplementation._(
    this._parent,
    this._eventsController,
    this._overrides,
  );

  RuntimeImplementation({
    ModuleOverrides overrides = const {},
  }) : this._(null, StreamController.broadcast(), overrides);

  RuntimeImplementation._fork(
    RuntimeImplementation parent,
    ModuleOverrides overrides,
  ) : this._(
          parent,
          parent._eventsController,
          overrides,
        );

  late final Map<Module, ModuleState> _moduleStates = {};
  late final DependencyGraph<Module> _moduleDependencies = DependencyGraph();
  late final Map<Store, Object?> _storeStates = {};
  late final DependencyGraph<Store> _storeDependencies = DependencyGraph();

  Stream<Message> get messagesStream => _eventsController.stream;

  RuntimeImplementation _runtimeOf(Module module) {
    final currentParent = _parent;

    if (currentParent == null || _overrides.isOverriden(module)) {
      return this;
    } else {
      return currentParent._runtimeOf(module);
    }
  }

  void addStoreDependency(
    Module module,
    Store store, {
    required Store dependsOn,
  }) {
    _runtimeOf(module)
        ._storeDependencies
        .addDependency(store, dependsOn: dependsOn);
    Debug.dependency.arrow(dependsOn, store);
  }

  void addModuleDependency(
    Module module, {
    required Module dependsOn,
  }) {
    _runtimeOf(module)
        ._moduleDependencies
        .addDependency(module, dependsOn: dependsOn);
    Debug.dependency.arrow(dependsOn, module);
  }

  ({Store<T> store, bool Function() shouldUpdate}) _createUpdate<T>(
    Module module,
    Store<T> key,
  ) {
    Iterable<dynamic> getDependencies() => _runtimeOf(module)
        ._storeDependencies
        .dependenciesOf(key)
        .map<dynamic>(useStore);

    final currentDependencies = getDependencies().toList();

    return (
      store: key,
      shouldUpdate: () => !const DeepCollectionEquality().equals(
            currentDependencies,
            getDependencies(),
          ),
    );
  }

  void setState<T>(
    Module module,
    Store<T> store,
    T state,
  ) {
    if (useStore(store) != state) {
      final runtime = _runtimeOf(module);
      runtime._storeStates[store] = state;
      emit(store, state);
      runtime._storeDependencies
          .sortReachableDependents(store)
          .map((e) => _createUpdate(module, e))
          .toList()
          .forEach((u) {
        final (:store, :shouldUpdate) = u;
        if (shouldUpdate()) {
          setState<dynamic>(
            module,
            store,
            store.describe(this),
          );
        }
      });
    }
  }

  ModuleState<T> _createModule<T extends Object?>(
    RuntimeImplementation i,
    Module<T> module,
  ) {
    Debug.create(module);
    final init = trigger<()>(name: 'init', source: module);
    final dispose = trigger<()>(name: 'dispose', source: module);
    final runtime = ModuleRuntime<T>(
      this,
      (
        dispose: dispose,
        init: init,
        name: module.name,
      ),
      module,
    );
    final override = i._overrides.overrideOf(module) ?? module;
    final newModule = override.body(runtime);
    runtime.setupEventHandlers();
    emit(init, ());

    return (
      module: newModule,
      subscriptions: runtime.subscriptions,
      dispose: dispose,
      stores: runtime.createdStores,
    );
  }

  T useModule<T extends Object?>(Module<T> module) {
    final runtimeOf = _runtimeOf(module);

    return (runtimeOf._moduleStates[module] ??=
            _createModule(runtimeOf, module))
        .module as T;
  }

  T useStore<T extends Object?>(
    Store<T> store,
  ) =>
      (_runtimeOf(store.module)._storeStates[store] ??= store.describe(this))
          as T;

  @override
  T use<T>(Ref<T> wrapped) => switch (wrapped) {
        Store<T>() => useStore(wrapped),
        Module<T>() => useModule(wrapped),
      };

  @override
  void emit<T>(Event<T> emitter, T event) {
    _eventsController.add((
      event: emitter,
      message: event,
    ));
  }

  Trigger<T> trigger<T extends Object?>({
    String? name,
    Module? source,
  }) {
    final trigger = SelfPredicateMessage<T>(
      'trigger',
      name,
      _eventsController.stream,
    );
    Debug.create('${source ?? 'Runtime'}.$trigger');

    return trigger;
  }

  Future<void> _disposeModule<R extends Object?>(
    ModuleState<R> state,
    Module<R> module,
  ) {
    final runtime = _runtimeOf(module);
    emit(state.dispose, const ());

    return Future(() async {
      for (final subscription in state.subscriptions) {
        await subscription.cancel();
      }
      runtime._moduleStates.remove(module);
      state.stores.forEach((store) {
        runtime._storeStates.remove(store);
        runtime._storeDependencies.partialHotRemove(store);
      });
    });
  }

  @override
  Future<bool> detachModule<R extends Object?>(Module<R> module) async {
    final data = _runtimeOf(module);
    final state = data._moduleStates[module] as ModuleState<R>?;
    final moduleDependencies = data._moduleDependencies;

    if (state == null) return false;

    await _disposeModule(state, module);
    for (final dependent in moduleDependencies.dependentsOf(module)) {
      moduleDependencies.removeDependency(from: dependent, to: module);
      await detachModule(dependent);
    }
    for (final dependency in moduleDependencies.dependenciesOf(module)) {
      final inactive = moduleDependencies.dependentsOf(dependency).isEmpty;
      moduleDependencies.removeDependency(from: module, to: dependency);
      if (!dependency.keepAlive && inactive) await detachModule(dependency);
    }

    return true;
  }

  @override
  Runtime fork({
    ModuleOverrides overrides = const {},
  }) =>
      RuntimeImplementation._fork(this, overrides);

  @override
  Future<void> dispose() async {
    await _moduleStates.entries
        .map((state) => _disposeModule(state.value, state.key))
        .wait;
    if (_parent == null) await Future(_eventsController.close);
  }
}
