// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:sym/src/data/adjacency_list.dart';

typedef State<T> = ({
  AdjacencyList<T> dependents,
  AdjacencyList<T> dependencies,
});

/// Represents a directed graph of dependencies between values.
///
/// Rejects cycles in debug.
extension type DependencyGraph<T>._(State<T> _state) {
  DependencyGraph()
      : this._((
          dependencies: AdjacencyList(),
          dependents: AdjacencyList(),
        ));

  AdjacencyList<T> get _dependents => _state.dependents;
  AdjacencyList<T> get _dependencies => _state.dependencies;

  bool _hasCycle(T node) => _hasCycleUtil(node, {}, {});

  bool _hasCycleUtil(T currentNode, Set<T> visited, Set<T> recursionStack) {
    if (recursionStack.contains(currentNode)) return true;
    if (visited.contains(currentNode)) return false;
    visited.add(currentNode);
    recursionStack.add(currentNode);
    for (T nextNode in _dependencies.adjacent(currentNode) ?? {}) {
      if (_hasCycleUtil(nextNode, visited, recursionStack)) return true;
    }
    recursionStack.remove(currentNode);
    return false;
  }

  Set<T> _adjacentOf(AdjacencyList<T> list, T node) =>
      list.adjacent(node) ?? {};

  Set<T> dependentsOf(T node) => _adjacentOf(_dependents, node);

  Set<T> dependenciesOf(T node) => _adjacentOf(_dependencies, node);

  void addDependency(T node, {required T dependsOn}) {
    final alreadyEstablished = dependentsOf(dependsOn).contains(node);
    if (!alreadyEstablished) {
      _dependencies.link(node, dependsOn);
      _dependents.link(dependsOn, node);
      assert(
        !_hasCycle(node),
        'Dependency cycle detected while linking $dependsOn -> $node.',
      );
    }
  }

  void removeDependency({required T from, required T to}) {
    _dependencies.unlink(from, to);
    _dependents.unlink(to, from);
  }

  /// Removes all references to [node] from both adjacency lists
  /// (leaving the graph in incomplete state), but does not remove references
  /// to [node] from other nodes.
  void partialHotRemove(T node) {
    [_dependencies, _dependents].forEach((list) {
      list.partialRemove(node);
    });
  }

  Iterable<T> sortReachableDependents(T root) {
    final queue = Queue<T>();
    final levels = HashMap<T, int>();

    void processDependents(T source) {
      queue.addAll(dependentsOf(source));
    }

    processDependents(root);

    while (queue.isNotEmpty) {
      final cfx = queue.removeFirst();
      levels[cfx] = (levels[cfx] ?? 0) + 1;
      processDependents(cfx);
    }

    return levels.entries
        //
        .sortedBy((e) => e.value as num)
        .map((e) => e.key);
  }
}
