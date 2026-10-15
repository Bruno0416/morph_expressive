part of 'morph_radio_button.dart';

/// Groups radio controls so keyboard focus matches the radio spec.
///
/// Tab and Shift+Tab enter the group on the selected radio, or the first or
/// last radio when nothing is selected. Arrow keys move and select, wrapping
/// at the ends. The parent still owns [groupValue].
class MorphRadioGroup<T> extends StatefulWidget {
  /// Creates a radio group.
  const MorphRadioGroup({
    required this.groupValue,
    required this.onChanged,
    required this.child,
    this.groupLabel,
    super.key,
  });

  /// The selected value, or null when nothing is selected.
  final T? groupValue;

  /// Called when arrow keys select a radio. Null disables keyboard selection.
  final ValueChanged<T>? onChanged;

  /// Accessibility label for the group, usually the category title.
  final String? groupLabel;

  /// Radios and the layout around them.
  final Widget child;

  @override
  State<MorphRadioGroup<T>> createState() => _MorphRadioGroupState<T>();
}

/// Registration handle for one radio inside [MorphRadioGroup].
class _MorphRadioGroupRegistration<T> {
  _MorphRadioGroupRegistration._(this._state, this.focusNode);

  final _MorphRadioGroupState<T> _state;
  final FocusNode focusNode;

  T? _value;
  bool _enabled = false;
  bool _selected = false;
  bool _focusable = true;
  VoidCallback? _onSelect;

  /// Updates the radio's value and interaction flags.
  void sync({
    required T value,
    required bool enabled,
    required bool selected,
    required bool focusable,
    required VoidCallback onSelect,
  }) {
    _value = value;
    _enabled = enabled;
    _selected = selected;
    _focusable = focusable;
    _onSelect = onSelect;
    _state._scheduleSkip();
  }

  void _dispose() {
    focusNode.removeListener(_state._onMemberFocus);
    _state._members.remove(this);
    _state._scheduleSkip();
  }
}

/// Exposes [MorphRadioGroup] registration to descendant radios.
class _MorphRadioGroupScope<T> extends InheritedWidget {
  /// Creates a scope for one radio group.
  const _MorphRadioGroupScope({
    required this._state,
    required super.child,
    super.key,
  });

  final _MorphRadioGroupState<T> _state;

  /// The nearest group of type [T], if any.
  static _MorphRadioGroupScope<T>? maybeOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MorphRadioGroupScope<T>>();
  }

  /// Registers [focusNode] and returns a handle the radio keeps updated.
  _MorphRadioGroupRegistration<T> attach(FocusNode focusNode) {
    return _state._attach(focusNode);
  }

  @override
  bool updateShouldNotify(_MorphRadioGroupScope<T> oldWidget) =>
      _state != oldWidget._state;
}

class _MorphRadioGroupState<T> extends State<MorphRadioGroup<T>> {
  final List<_MorphRadioGroupRegistration<T>> _members =
      <_MorphRadioGroupRegistration<T>>[];
  late final _RadioGroupTraversalPolicy _policy = _RadioGroupTraversalPolicy(
    this,
  );
  late final _RadioGroupShortcutManager<T> _shortcuts =
      _RadioGroupShortcutManager<T>(
        state: this,
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.arrowDown):
              VoidCallbackIntent(_moveNext),
          const SingleActivator(LogicalKeyboardKey.arrowRight):
              VoidCallbackIntent(_moveNext),
          const SingleActivator(LogicalKeyboardKey.arrowUp): VoidCallbackIntent(
            _movePrevious,
          ),
          const SingleActivator(LogicalKeyboardKey.arrowLeft):
              VoidCallbackIntent(_movePrevious),
        },
      );
  bool _skipScheduled = false;

  @override
  void dispose() {
    _shortcuts.dispose();
    super.dispose();
  }

  void _moveNext() => _move(1);

  void _movePrevious() => _move(-1);

  _MorphRadioGroupRegistration<T> _attach(FocusNode focusNode) {
    final registration = _MorphRadioGroupRegistration<T>._(this, focusNode);
    focusNode.addListener(_onMemberFocus);
    _members.add(registration);
    _scheduleSkip();
    return registration;
  }

  void _onMemberFocus() {
    _scheduleSkip();
  }

  void _scheduleSkip() {
    if (_skipScheduled) {
      return;
    }
    _skipScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _skipScheduled = false;
      if (!mounted) {
        return;
      }
      _applyRestingSkip();
    });
  }

  List<_MorphRadioGroupRegistration<T>> _traversable() {
    final members =
        _members
            .where(
              (_MorphRadioGroupRegistration<T> member) =>
                  member._enabled && member._focusable,
            )
            .toList()
          ..sort((
            _MorphRadioGroupRegistration<T> a,
            _MorphRadioGroupRegistration<T> b,
          ) {
            final ao = a.focusNode.offset;
            final bo = b.focusNode.offset;
            final dy = ao.dy.compareTo(bo.dy);
            if (dy != 0) {
              return dy;
            }
            return ao.dx.compareTo(bo.dx);
          });
    return members;
  }

  bool _owns(FocusNode node) {
    for (final _MorphRadioGroupRegistration<T> member in _members) {
      if (member.focusNode == node) {
        return true;
      }
    }
    return false;
  }

  void _applyRestingSkip() {
    final ordered = _traversable();
    if (ordered.isEmpty) {
      return;
    }
    final focused = ordered
        .where(
          (_MorphRadioGroupRegistration<T> member) => member.focusNode.hasFocus,
        )
        .toList();
    if (focused.isNotEmpty) {
      for (final member in ordered) {
        member.focusNode.skipTraversal = !member.focusNode.hasFocus;
      }
      return;
    }
    final selected = ordered
        .where((_MorphRadioGroupRegistration<T> member) => member._selected)
        .toList();
    if (selected.isNotEmpty) {
      for (final member in ordered) {
        member.focusNode.skipTraversal = !member._selected;
      }
      return;
    }
    final first = ordered.first;
    final last = ordered.last;
    for (final member in ordered) {
      member.focusNode.skipTraversal = member != first && member != last;
    }
  }

  void _move(int delta) {
    final ordered = _traversable();
    if (ordered.isEmpty) {
      return;
    }
    var index = ordered.indexWhere(
      (_MorphRadioGroupRegistration<T> member) => member.focusNode.hasFocus,
    );
    if (index < 0) {
      index = delta > 0 ? -1 : 0;
    }
    var next = index + delta;
    if (next < 0) {
      next = ordered.length - 1;
    } else if (next >= ordered.length) {
      next = 0;
    }
    final member = ordered[next];
    member.focusNode.skipTraversal = false;
    member.focusNode.requestFocus();
    if (!member._selected) {
      final ValueChanged<T>? onChanged = widget.onChanged;
      final T? value = member._value;
      if (onChanged != null && value != null) {
        onChanged(value);
      } else {
        member._onSelect?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _MorphRadioGroupScope<T>(
      state: this,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        role: SemanticsRole.radioGroup,
        label: widget.groupLabel,
        child: Shortcuts.manager(
          manager: _shortcuts,
          child: FocusTraversalGroup(policy: _policy, child: widget.child),
        ),
      ),
    );
  }
}

class _RadioGroupShortcutManager<T> extends ShortcutManager {
  _RadioGroupShortcutManager({required super.shortcuts, required this.state});

  final _MorphRadioGroupState<T> state;

  @override
  KeyEventResult handleKeypress(BuildContext context, KeyEvent event) {
    final bool radioHasFocus = state._members.any(
      (_MorphRadioGroupRegistration<T> member) => member.focusNode.hasFocus,
    );
    if (!radioHasFocus) {
      return KeyEventResult.ignored;
    }
    return super.handleKeypress(context, event);
  }
}

class _RadioGroupTraversalPolicy extends ReadingOrderTraversalPolicy {
  _RadioGroupTraversalPolicy(this._group);

  final _MorphRadioGroupState<dynamic> _group;

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    if (!_group._owns(currentNode)) {
      return super.inDirection(currentNode, direction);
    }
    switch (direction) {
      case TraversalDirection.down:
      case TraversalDirection.right:
        _group._move(1);
        return true;
      case TraversalDirection.up:
      case TraversalDirection.left:
        _group._move(-1);
        return true;
    }
  }
}
