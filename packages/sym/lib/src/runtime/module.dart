// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:async/async.dart';
import 'package:sym/src/interfaces.dart';
import 'package:sym/src/runtime/implementation.dart';
import 'package:sym/src/runtime/shared.dart';
import 'package:sym/src/runtime/store.dart';
import 'package:sym/src/runtime/value.dart';
import 'package:sym/src/transformers.dart';

typedef Handler = dynamic;

class ModuleRuntime<A> implements ModuleSym {
  final RuntimeImplementation _runtime;
  @override
  final ModuleMeta self;
  final Module<A> _module;

  ModuleRuntime(
    this._runtime,
    this.self,
    this._module,
  );

  late final Map<Store<Transformer>, Map<Event, List<Handler>>> _effects = {};
  late final ModuleSubscriptions subscriptions = {};
  late final Set<Store> createdStores = {};

  void _logCreate(Object object) {
    Debug.create('$_module.$object');
  }

  @override
  T use<T extends Object?>(Module<T> module) {
    _runtime.addModuleDependency(_module, dependsOn: module);

    return _runtime.useModule(module);
  }

  @override
  Trigger<T> trigger<T extends Object?>({
    String? name,
  }) =>
      _runtime.trigger(name: name, source: _module);

  @override
  Store<T> store<T extends Object?>(StoreBody<T> body, {String? name}) {
    final outputStore = DelegateStore<T>(
        'store', name, _runtime.messagesStream, _module, (self, $) {
      final runtime = StoreRuntime(_runtime, self);
      final initialState = body(runtime);

      final states = runtime.reducer.entries.map(
        (e) => e.key
            .asStream()
            // ignore: avoid_dynamic_calls
            .expand((event) => e.value.map((e) => e.handler(event) as T)),
      );
      subscriptions.add(
        StreamGroup.merge(states).listen(
          (state) => _runtime.setState(_module, self, state),
        ),
      );

      return initialState;
    });
    createdStores.add(outputStore);
    _logCreate(outputStore);

    return outputStore;
  }

  @override
  Store<T> value<T extends Object?>(ValueBody<T> body, {String? name}) {
    final runtime = ValueRuntime(_runtime);
    final store = DelegateStore('value', name, _runtime.messagesStream, _module,
        (self, $) {
      final value = body(runtime);
      runtime.stores.forEach(
        (dependency) => _runtime.addStoreDependency(
          _module,
          self,
          dependsOn: dependency,
        ),
      );

      return value;
    });
    createdStores.add(store);
    _logCreate(store);

    return store;
  }

  @override
  void on<T extends Object?>(
    Event<T> event,
    Effect<T> body, {
    Store<Transformer>? transformer,
  }) {
    Debug.subscribe.arrow('$_module.$event', _module);
    if (event is Store<T>) _runtime.useStore(event);
    _effects
        .putIfAbsent(
          transformer ?? use(defaultTransformer),
          () => {},
        )
        .putIfAbsent(
          event,
          () => [],
        )
        .add(body);
  }

  void setupEventHandlers() {
    for (final MapEntry(key: transformer$, value: streams)
        in _effects.entries) {
      final transitions = StreamGroup.merge(
        streams.entries.expand((e) {
          final MapEntry(key: event, value: handlers) = e;
          final stream = event.asStream();

          return handlers.map(
            (handler) => stream.map(
              (event) => (
                handler: handler,
                event: event,
              ),
            ),
          );
        }),
      );
      final subscription = _runtime
          .use(transformer$)(transitions, (transition) async* {
            await transition.handler(_runtime, transition.event);
          })
          .listen(null);
      subscriptions.add(subscription);
    }
  }
}
