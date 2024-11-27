import 'package:sym/src/interfaces.dart';

A _id<A>(A a) => a;

extension UnitTriggerCallX on Trigger<()> {
  void call(EventSource $) {
    $.emit(this, ());
  }
}

extension TriggerCallX<T> on Trigger<T> {
  void call(EventSource $, T event) {
    $.emit(this, event);
  }
}

extension ToStoreX<A> on Event<A> {
  Store<A> toStore(
    ModuleSym $,
    A Function(StoreSym<A> $) initial, {
    String? name,
  }) =>
      $.store(name: name, ($) {
        $.on(this, _id);

        return initial($);
      });

  Store<A?> toStoreNullable(
    ModuleSym $,
    A? Function(StoreSym<A?> $) initial, {
    String? name,
  }) =>
      $.store(name: name, ($) {
        $.on(this, _id);

        return initial($);
      });
}

typedef Signal<A> = ({
  Store<A> get,
  Trigger<A> set,
});

extension SignalX on ModuleSym {
  Signal<A> signal<A>(
    A Function(StoreConsumer $) initial, {
    String? name,
  }) {
    final set = trigger<A>(name: name);

    /// TODO: – make stores sync so deriving data would work in the same event
    /// loop tick
    return (
      get: set.toStore(
        this,
        initial,
        name: name,
      ),
      set: set,
    );
  }
}

extension ContravariantX<A> on Trigger<A> {
  Trigger<B> contramap<B>(
    ModuleSym $,
    A Function(StoreConsumer $, B b) f,
  ) {
    final result = $.trigger<B>(name: 'contramap ($this)');

    $.on(
      result,
      ($, event) => this($, f($, event)),
    );

    return result;
  }
}

extension ModuleOverrideX<R extends Object> on Module<R> {
  Override<R> override(ModuleBody<R> body) => Override(
        module: this,
        body: body,
      );
}
