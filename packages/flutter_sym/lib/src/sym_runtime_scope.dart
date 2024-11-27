// ignore_for_file: avoid_print, prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:sym/sym.dart';

typedef CreateRuntime = Runtime Function(BuildContext context);

typedef ForkRuntime = Runtime Function(BuildContext context, Runtime parent);

class SymRuntimeScope extends StatefulWidget {
  final CreateRuntime? create;
  final ForkRuntime? fork;
  final Widget child;

  const SymRuntimeScope.create({
    required CreateRuntime create,
    required this.child,
    super.key,
  })  : fork = null,
        create = create;

  const SymRuntimeScope.fork({
    required ForkRuntime fork,
    required this.child,
    super.key,
  })  : create = null,
        fork = fork;

  static Runtime of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_InheritedRuntime>()!.runtime;

  @override
  State<SymRuntimeScope> createState() => _SymRuntimeScopeState();
}

class _SymRuntimeScopeState extends State<SymRuntimeScope> {
  late final Runtime runtime = create();

  Runtime create() {
    late final forkRuntime = widget.fork!(
      context,
      SymRuntimeScope.of(context),
    );
    final newRuntime = widget.create?.call(context);

    return newRuntime ?? forkRuntime;
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InheritedRuntime(
        runtime: runtime,
        child: widget.child,
      );
}

class _InheritedRuntime extends InheritedWidget {
  final Runtime runtime;

  const _InheritedRuntime({
    required this.runtime,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedRuntime oldWidget) => false;
}
