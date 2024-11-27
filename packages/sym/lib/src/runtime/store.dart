import 'package:sym/src/interfaces.dart';
import 'package:sym/src/runtime/implementation.dart';
import 'package:sym/src/runtime/shared.dart';

final class StoreRuntime<T> implements StoreConsumer, StoreSym<T> {
  final RuntimeImplementation _runtime;
  final Store<T> _store;

  StoreRuntime(this._runtime, this._store);

  late final Map<Event, List<({dynamic handler})>> reducer = {};

  @override
  A use<A extends Object?>(Store<A> store) => _runtime.use(store);

  @override
  T get self => _runtime.useStore(_store);

  @override
  void on<A extends Object?>(Event<A> event, T Function(A value) reduce) {
    Debug.subscribe.arrow(event, _store);
    reducer.putIfAbsent(event, () => []).add((handler: reduce));
  }
}
