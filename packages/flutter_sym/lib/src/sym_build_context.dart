import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sym/sym.dart';

abstract interface class SymBuildContext
    implements BuildContext, MultiConsumer, EventSource {
  @override
  T use<T>(Ref<T> wrapped, {bool listen = true});
}

class SymBuildContextImplementation implements SymBuildContext {
  final Runtime _runtime;
  final ModuleConsumer _moduleConsumer;
  final StoreConsumer _storeConsumer;
  final BuildContext _context;

  SymBuildContextImplementation(
    this._runtime,
    this._moduleConsumer,
    this._storeConsumer,
    this._context,
  );

  @override
  bool get debugDoingBuild => _context.debugDoingBuild;

  @override
  InheritedWidget dependOnInheritedElement(
    InheritedElement ancestor, {
    Object? aspect,
  }) =>
      _context.dependOnInheritedElement(ancestor, aspect: aspect);

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) =>
      _context.dependOnInheritedWidgetOfExactType(
        aspect: aspect,
      );

  @override
  DiagnosticsNode describeElement(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) =>
      _context.describeElement(name, style: style);

  @override
  List<DiagnosticsNode> describeMissingAncestor({
    required Type expectedAncestorType,
  }) =>
      _context.describeMissingAncestor(
        expectedAncestorType: expectedAncestorType,
      );

  @override
  DiagnosticsNode describeOwnershipChain(String name) =>
      _context.describeOwnershipChain(name);

  @override
  DiagnosticsNode describeWidget(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) =>
      _context.describeWidget(name, style: style);

  @override
  void dispatchNotification(Notification notification) {
    _context.dispatchNotification(notification);
  }

  @override
  void emit<T>(Trigger<T> emitter, T event) {
    _runtime.emit(emitter, event);
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() =>
      _context.findAncestorRenderObjectOfType<T>();

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() =>
      _context.findAncestorStateOfType<T>();

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() =>
      _context.findAncestorWidgetOfExactType<T>();

  @override
  RenderObject? findRenderObject() => _context.findRenderObject();

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() =>
      _context.findRootAncestorStateOfType<T>();

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() =>
          _context.getElementForInheritedWidgetOfExactType<T>();

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() =>
      _context.getInheritedWidgetOfExactType<T>();

  @override
  bool get mounted => _context.mounted;

  @override
  BuildOwner? get owner => _context.owner;

  @override
  Size? get size => _context.size;

  @override
  T use<T>(Ref<T> wrapped, {bool listen = true}) => switch (wrapped) {
        Store<T>() when listen => _storeConsumer.use(wrapped),
        Module<T>() => _moduleConsumer.use(wrapped),
        _ => _runtime.use(wrapped),
      };

  @override
  void visitAncestorElements(ConditionalElementVisitor visitor) {
    _context.visitAncestorElements(visitor);
  }

  @override
  void visitChildElements(ElementVisitor visitor) {
    _context.visitChildElements(visitor);
  }

  @override
  Widget get widget => _context.widget;
}
