import 'dart:async';
import 'dart:html';

import 'package:react/react.dart' as react;

class _RedrawScheduler implements Function {
  Set<BatchedRedraws> _components = new Set();

  void call(BatchedRedraws component) {
    if (_components.isEmpty) {
      _tick();
    }
    _components.add(component);
  }

  Future _tick() async {
    await window.animationFrame;
    for (var c in _components) {
      if (c.shouldRedraw) {
        (c as react.Component)?.setState({});
      }
    }
    _components.clear();
  }
}

_RedrawScheduler _scheduleRedraw = new _RedrawScheduler();

/// A mixin that overrides the [Component.redraw] method of a React
/// [Component] (including a [FluxComponent]) and prevents the component
/// from being redrawn more than once per animation frame.
///
/// Example:
///
///     class MyComponent extends react.Component
///         with BatchedRedraws {
///       render() {...}
///     }
///
class BatchedRedraws {
  bool get shouldRedraw => true;
  void redraw() => _scheduleRedraw(this);
}
