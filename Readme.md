# sym

A lightweight Dart library for describing self-contained, composable business logic through reactive units and effects.

## Table of Contents
- [Installation](#installation)
- [Core Concepts](#core-concepts)
  - [Modules](#modules)
  - [Events](#events)
  - [Effects](#effects)
  - [Symantic](#symantic)
- [Usage](#usage)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  sym: ^0.1.0
```

## Core Concepts

sym provides a way to describe business logic through composable, self-contained units called Modules that coordinate reactive Events and Effects.

### Modules

Modules are self-contained units that group related logic and state. They define their public API and internal behavior:

```dart
final counter = Module(($) {
  final increment = $.trigger<()>();
  
  return (
    increment: increment,
    value: $.store<int>(($) {
      $.on(increment, (_) => $.self + 1); 
      return 0;
    })
  );
});
```

### Events 

Events come in two flavors:

- **Triggers** - Stateless, callable events that signal something happened
- **Stores** - Stateful events that hold and update data

```dart
// Trigger example
final increment = $.trigger<()>();

// Store example 
final count = $.store<int>(($) => 0);
```

### Effects

Effects define relationships between events through reactions:

```dart
$.on(increment, ($, _) async {
  await Future.delayed(Duration(seconds: 1));
  count($, count.value + 1);
});
```

### Symantic

The `$` parameter provides a constrained API for defining acceptable operations in a given context:

```dart
Module(($) {
  // $ provides trigger(), store(), value(), on(), use()
});
```

## Usage

See the example directory for complete examples.

## Architecture

sym is built on a few key principles:

- Modules are the unit of composition and encapsulation
- Events model both state changes and side effects
- Effects coordinate reactivity between events
- The Symantic ($) constrains operations to maintain integrity

This provides a flexible foundation for describing complex business logic in a maintainable way.

## License

[MIT License](LICENSE)
