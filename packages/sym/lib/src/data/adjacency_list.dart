import 'dart:collection';

extension type AdjacencyList<T>._(Map<T, Set<T>> _connections) {
  AdjacencyList() : this._(HashMap());

  bool contains(T node) => _connections.containsKey(node);

  bool link(T from, T to) =>
      _connections.putIfAbsent(from, LinkedHashSet.new).add(to);

  bool unlink(T from, T to) => _connections[from]?.remove(to) ?? false;

  Set<T>? adjacent(T node) => _connections[node];

  /// Removes all references to [node] from the adjacency list, but does not
  /// remove references to [node] from other nodes.
  void partialRemove(T node) {
    _connections.remove(node);
  }

  String toMermaid() {
    final buffer = StringBuffer('graph TD;')..writeln();

    for (final entry in _connections.entries) {
      for (final adjacent in entry.value) {
        buffer
          ..write('  ')
          ..writeAll(
            [entry.key, '-->', adjacent].map(
              (e) => e.toString().replaceAll(' ', '-'),
            ),
            ' ',
          )
          ..writeln();
      }
    }

    return buffer.toString();
  }
}
