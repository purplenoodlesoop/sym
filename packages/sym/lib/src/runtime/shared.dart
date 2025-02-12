import 'dart:async';

import 'package:sym/src/interfaces.dart';

typedef Message<T extends Object?> = ({
  Event<T> event,
  T message,
});

base class SelfPredicateMessage<T> implements Trigger<T> {
  final String type;
  @override
  final String? name;
  final Stream<Message<Object?>> _messages;

  SelfPredicateMessage(this.type, this.name, this._messages);

  @override
  Stream<T> asStream() => _messages.transform(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            if (data.event == this) sink.add(data.message as T);
          },
        ),
      );

  @override
  String toString() => '$type<$T>(${name ?? 'unnamed'})';
}

final class DelegateStore<T> extends SelfPredicateMessage<T>
    implements Store<T> {
  @override
  final Module module;
  final T Function(Store<T> self, StoreConsumer $) _describe;

  DelegateStore(
    super.type,
    super.name,
    super.messages,
    this.module,
    this._describe,
  );

  @override
  T describe(StoreConsumer $) => _describe(this, $);
}
