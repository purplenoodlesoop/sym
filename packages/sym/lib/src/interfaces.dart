import 'dart:async';

import 'package:sym/src/runtime/implementation.dart';

abstract interface class CanHaveName {
  String? get name;
}

sealed class Ref<T extends Object?> {}

abstract interface class Consumer {
  T use<T>(covariant Ref<T> value);
}

abstract interface class HasIdentity<T extends Object?> {
  T get self;
}

abstract interface class Event<T extends Object?> implements CanHaveName {
  Stream<T> asStream();
}

abstract interface class Trigger<T extends Object?> implements Event<T> {}

abstract interface class EventSource {
  void emit<T>(Trigger<T> trigger, T event);
}

abstract interface class Store<T extends Object?> implements Event<T>, Ref<T> {
  Module get module;

  T describe(StoreConsumer $);
}

abstract interface class StoreConsumer implements Consumer {
  @override
  T use<T extends Object?>(Store<T> store);
}

abstract class StoreSym<S> implements HasIdentity<S>, StoreConsumer {
  void on<A extends Object?>(
    Event<A> event,
    S Function(A event) reduce,
  );
}

typedef Effect<I extends Object?> = FutureOr<void> Function(
  EffectSym $,
  I event,
);

abstract class EffectSym implements StoreConsumer, EventSource {}

typedef StoreBody<T> = T Function(StoreSym<T> $);

typedef ValueBody<T> = T Function(StoreConsumer $);

typedef Transformer = Stream<B> Function<A, B>(
  Stream<A> source,
  Stream<B> Function(A value) process,
);

typedef ModuleMeta = ({
  Event<()> init,
  Event<()> dispose,
  String? name,
});

abstract interface class ModuleConsumer implements Consumer {
  @override
  T use<T extends Object?>(Module<T> module);
}

abstract interface class ModuleHooks
    implements HasIdentity<ModuleMeta>, ModuleConsumer {
  void on<A extends Object?>(
    Event<A> event,
    Effect<A> body, {
    Store<Transformer>? transformer,
  });
}

abstract interface class ModuleSym implements ModuleHooks {
  Trigger<T> trigger<T extends Object?>({
    String? name,
  });

  Store<T> store<T extends Object?>(
    StoreBody<T> body, {
    String? name,
  });

  Store<T> value<T extends Object?>(
    ValueBody<T> body, {
    String? name,
  });
}

typedef ModuleBody<T> = T Function(ModuleSym $);

abstract interface class ModuleDescription<R extends Object?> {
  Module<R> get source;

  ModuleBody<R> get body;
}

final class NullPointerModuleException<R> implements Exception {
  final Module<R> module;

  NullPointerModuleException(this.module);
}

final class Module<R extends Object?>
    implements ModuleDescription<R>, Ref<R>, CanHaveName {
  @override
  final ModuleBody<R> body;

  final bool keepAlive;
  @override
  final String? name;

  Module(
    this.body, {
    this.keepAlive = false,
    this.name,
  });

  factory Module.override({
    String? name,
  }) {
    Module<R>? module;

    module = Module<R>(
      keepAlive: true,
      name: name,
      ($) => throw NullPointerModuleException(module!),
    );

    return module;
  }

  @override
  Module<R> get source => this;

  @override
  String toString() => 'Module($name)';
}

final class Override<R extends Object?> implements ModuleDescription<R> {
  final Module<R> module;

  @override
  final ModuleBody<R> body;

  Override({required this.module, required this.body});

  @override
  Module<R> get source => module;
}

typedef ModuleOverrides = Set<ModuleDescription>;

abstract interface class MultiConsumer
    implements StoreConsumer, ModuleConsumer {
  @override
  T use<T>(Ref<T> wrapped);
}

abstract interface class Runtime implements MultiConsumer, EventSource {
  factory Runtime() = RuntimeImplementation;

  Future<bool> detachModule<R extends Object?>(Module<R> module);

  Future<void> dispose();

  Runtime fork({
    ModuleOverrides overrides = const {},
  });
}
