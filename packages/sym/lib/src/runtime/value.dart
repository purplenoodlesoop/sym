import 'package:sym/src/interfaces.dart';

class ValueRuntime implements StoreConsumer {
  final StoreConsumer _storeRefOp;

  ValueRuntime(this._storeRefOp);

  late final Set<Store> stores = {};

  @override
  A use<A extends Object?>(Store<A> store) {
    stores.add(store);

    return _storeRefOp.use(store);
  }
}
