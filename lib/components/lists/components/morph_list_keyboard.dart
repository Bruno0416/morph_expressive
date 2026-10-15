import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'morph_expandable_nest_scope.dart';
import 'morph_list_feature_scope.dart';

/// One focusable list row or trailing action registered with
/// [MorphListKeyboardGroup].
class MorphListKeyboardRegistration {
  MorphListKeyboardRegistration._(this._state, this.node, this.index, this.slot);

  final _MorphListKeyboardGroupState _state;

  /// Focus node owned by the group.
  final FocusNode node;

  /// Row index.
  final int index;

  /// `0` is the row. Higher slots are trailing actions.
  final int slot;

  /// Whether this target can be focused.
  bool enabled = true;

  /// Whether Tab should land on this node.
  bool get tabStop => _state._isTabStop(node);

  bool _disposed = false;

  /// Drops this target.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _state._remove(this);
  }
}

/// Arrow-key list navigation.
///
/// The list, including nested sublists, is a single Tab stop: Tab enters on
/// the last-focused row, else the selected row, else the first row, and Tab
/// or Shift+Tab from any row leaves the list. Arrows move between rows, row
/// actions, and sublist rows, and wrap. Space and Enter activate the focused
/// target.
class MorphListKeyboardGroup extends StatefulWidget {
  /// Creates a list keyboard group.
  const MorphListKeyboardGroup({
    required this.itemCount,
    required this.child,
    this.semanticsLabel,
    this.sliver = false,
    super.key,
  });

  /// Whether [child] is a sliver. Uses sliver-safe semantics.
  final bool sliver;

  /// Number of rows. Used to clamp the entry index.
  final int itemCount;

  /// List box description for assistive tech.
  final String? semanticsLabel;

  /// List body.
  final Widget child;

  /// Nearest group, if any.
  static MorphListKeyboardBinding? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_MorphListKeyboardScope>()
        ?.binding;
  }

  @override
  State<MorphListKeyboardGroup> createState() => _MorphListKeyboardGroupState();
}

/// Focus registration for one [MorphListKeyboardGroup].
class MorphListKeyboardBinding {
  MorphListKeyboardBinding._(this._state);

  final _MorphListKeyboardGroupState _state;

  /// Registers a row (`slot` 0) or a trailing action.
  MorphListKeyboardRegistration register({required int index, int slot = 0}) {
    return _state.register(index: index, slot: slot);
  }
}

class _MorphListKeyboardScope extends InheritedWidget {
  const _MorphListKeyboardScope({
    required this._state,
    required this.binding,
    required super.child,
  });

  final _MorphListKeyboardGroupState _state;

  final MorphListKeyboardBinding binding;

  @override
  bool updateShouldNotify(_MorphListKeyboardScope oldWidget) =>
      _state != oldWidget._state;
}

class _MorphListKeyboardGroupState extends State<MorphListKeyboardGroup> {
  final List<MorphListKeyboardRegistration> _members =
      <MorphListKeyboardRegistration>[];
  final Map<int, _MorphListKeyboardGroupState> _nests =
      <int, _MorphListKeyboardGroupState>{};

  /// Last-focused member anywhere in this tree. Only used on the root group.
  FocusNode? _roving;
  bool _syncQueued = false;
  bool _syncSoonQueued = false;
  _MorphListKeyboardGroupState? _parent;
  int? _nestIndex;
  late final MorphListKeyboardBinding _binding = MorphListKeyboardBinding._(this);
  late final _MorphListTraversalPolicy _policy = _MorphListTraversalPolicy(this);
  late final _MorphListShortcutManager _shortcuts = _MorphListShortcutManager(
    state: this,
    shortcuts: <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowDown): VoidCallbackIntent(
        _moveNext,
      ),
      const SingleActivator(LogicalKeyboardKey.arrowRight): VoidCallbackIntent(
        _moveNext,
      ),
      const SingleActivator(LogicalKeyboardKey.arrowUp): VoidCallbackIntent(
        _movePrevious,
      ),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): VoidCallbackIntent(
        _movePrevious,
      ),
    },
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncNestLink();
  }

  @override
  void dispose() {
    _parent?._nests.remove(_nestIndex);
    _parent = null;
    _shortcuts.dispose();
    for (final member in List<MorphListKeyboardRegistration>.of(_members)) {
      member.dispose();
    }
    super.dispose();
  }

  void _syncNestLink() {
    final _MorphListKeyboardScope? parentScope = context
        .dependOnInheritedWidgetOfExactType<_MorphListKeyboardScope>();
    final int? index = MorphExpandableNestScope.maybeOf(context)?.rowIndex;
    final _MorphListKeyboardGroupState? parent = parentScope?._state;
    if (identical(_parent, parent) && _nestIndex == index) {
      return;
    }
    _parent?._nests.remove(_nestIndex);
    _parent = null;
    _nestIndex = null;
    if (parent == null || index == null) {
      return;
    }
    _parent = parent;
    _nestIndex = index;
    parent._nests[index] = this;
  }

  /// Registers a row or trailing action and returns its focus node.
  MorphListKeyboardRegistration register({required int index, int slot = 0}) {
    final node = FocusNode(debugLabel: 'list $index.$slot')
      ..addListener(_onMemberFocus);
    final registration = MorphListKeyboardRegistration._(this, node, index, slot);
    _members.add(registration);
    _root._queueTabStopSync();
    return registration;
  }

  void _remove(MorphListKeyboardRegistration registration) {
    registration.node.removeListener(_onMemberFocus);
    _members.remove(registration);
    final _MorphListKeyboardGroupState root = _root;
    if (root._roving == registration.node) {
      root._roving = null;
    }
    registration.node.dispose();
    root._queueTabStopSync();
  }

  void _onMemberFocus() {
    for (final MorphListKeyboardRegistration member in _members) {
      if (member.node.hasPrimaryFocus) {
        _root._roving = member.node;
        break;
      }
    }
    // Runs inside FocusManager's change pass; flipping skipTraversal there
    // would mutate the set it is iterating.
    _root._queueTabStopSyncSoon();
  }

  /// Outermost group of this list tree.
  _MorphListKeyboardGroupState get _root {
    var group = this;
    while (group._parent != null) {
      group = group._parent!;
    }
    return group;
  }

  /// This group and every nested group below it.
  Iterable<_MorphListKeyboardGroupState> _tree() sync* {
    yield this;
    for (final _MorphListKeyboardGroupState nest in _nests.values) {
      yield* nest._tree();
    }
  }

  void _queueTabStopSyncSoon() {
    if (_syncSoonQueued) {
      return;
    }
    _syncSoonQueued = true;
    scheduleMicrotask(() {
      _syncSoonQueued = false;
      if (mounted) {
        _syncTabStops();
      }
    });
  }

  void _queueTabStopSync() {
    if (_syncQueued) {
      return;
    }
    _syncQueued = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _syncQueued = false;
      if (mounted) {
        _syncTabStops();
      }
    });
  }

  /// Leaves only the entry node in Tab order across the whole tree.
  void _syncTabStops() {
    final FocusNode? entry = _entryNode();
    for (final _MorphListKeyboardGroupState group in _tree()) {
      for (final MorphListKeyboardRegistration member in group._members) {
        member.node.skipTraversal = member.node != entry;
      }
    }
  }

  bool _owns(FocusNode node) {
    for (final MorphListKeyboardRegistration member in _members) {
      if (member.node == node) {
        return true;
      }
    }
    return false;
  }

  bool _memberHasFocus() {
    for (final MorphListKeyboardRegistration member in _members) {
      if (member.node.hasPrimaryFocus) {
        return true;
      }
    }
    return false;
  }

  bool _isTabStop(FocusNode node) => _root._entryNode() == node;

  List<MorphListKeyboardRegistration> _ordered() {
    final List<MorphListKeyboardRegistration> rows =
        _members.where((MorphListKeyboardRegistration member) {
          // Skip registrations whose node is not mounted in a Focus widget.
          return member.enabled && member.node.context != null;
        }).toList()..sort((
          MorphListKeyboardRegistration a,
          MorphListKeyboardRegistration b,
        ) {
          final int byIndex = a.index.compareTo(b.index);
          if (byIndex != 0) {
            return byIndex;
          }
          return a.slot.compareTo(b.slot);
        });
    return rows;
  }

  int? _selectedIndex() {
    final MorphListFeatureScope? features = MorphListFeatureScope.maybeOf(context);
    final Set<int>? selected = features?.controller?.selectedIndices;
    if (selected == null || selected.isEmpty) {
      return null;
    }
    final List<int> sorted = selected.toList()..sort();
    return sorted.first;
  }

  /// The tree's single Tab stop: the last-focused member while it can still
  /// take focus, else the selected row, else the first row. Root group only.
  FocusNode? _entryNode() {
    final FocusNode? roving = _roving;
    if (roving != null &&
        roving.canRequestFocus &&
        _tree().any(
          (_MorphListKeyboardGroupState group) => group._ordered().any(
            (MorphListKeyboardRegistration member) => member.node == roving,
          ),
        )) {
      return roving;
    }
    final List<MorphListKeyboardRegistration> ordered = _ordered();
    if (ordered.isEmpty) {
      return null;
    }
    final FocusNode? selected = _selectedEntry(ordered);
    if (selected != null) {
      return selected;
    }
    return ordered.first.node;
  }

  FocusNode? _selectedEntry(List<MorphListKeyboardRegistration> ordered) {
    final int? selected = _selectedIndex();
    if (selected == null) {
      return null;
    }
    for (final member in ordered) {
      if (member.index == selected && member.slot == 0) {
        return member.node;
      }
    }
    return null;
  }

  void _moveNext() => _move(1);

  void _movePrevious() => _move(-1);

  void _focusMember(MorphListKeyboardRegistration member) {
    _root
      .._roving = member.node
      .._syncTabStops();
    member.node.requestFocus();
  }

  bool _focusEdge({required bool first}) {
    if (!mounted) {
      return false;
    }
    final List<MorphListKeyboardRegistration> ordered = _ordered();
    if (ordered.isEmpty) {
      return false;
    }
    final FocusNode node = (first ? ordered.first : ordered.last).node;
    if (!node.canRequestFocus) {
      return false;
    }
    _focusMember(first ? ordered.first : ordered.last);
    return true;
  }

  bool _moveFromNest(int nestIndex, int delta) {
    final List<MorphListKeyboardRegistration> ordered = _ordered();
    final int header = ordered.indexWhere(
      (MorphListKeyboardRegistration member) =>
          member.index == nestIndex && member.slot == 0,
    );
    if (header < 0) {
      return false;
    }
    if (delta < 0) {
      _focusMember(ordered[header]);
      return true;
    }
    final int next = header + 1;
    if (next >= ordered.length) {
      if (_parent != null && _nestIndex != null) {
        return _parent!._moveFromNest(_nestIndex!, delta);
      }
      _focusMember(ordered.first);
      return true;
    }
    _focusMember(ordered[next]);
    return true;
  }

  void _move(int delta) {
    final List<MorphListKeyboardRegistration> ordered = _ordered();
    if (ordered.isEmpty) {
      return;
    }
    final int index = _focusedIndex(ordered, delta);
    if (_tryEnterNestAtRowEnd(ordered, index, delta)) {
      return;
    }
    final int? next = _resolveNextIndex(ordered, index, delta);
    if (next == null) {
      return;
    }
    _focusMember(ordered[next]);
  }

  int _focusedIndex(List<MorphListKeyboardRegistration> ordered, int delta) {
    final int index = ordered.indexWhere(
      (MorphListKeyboardRegistration member) => member.node.hasPrimaryFocus,
    );
    if (index >= 0) {
      return index;
    }
    return delta > 0 ? -1 : 0;
  }

  /// True when the focused row is the last of a nested-list header and the
  /// nested list swallowed the move by focusing its own edge.
  bool _tryEnterNestAtRowEnd(
    List<MorphListKeyboardRegistration> ordered,
    int index,
    int delta,
  ) {
    if (delta <= 0 || index < 0) {
      return false;
    }
    final MorphListKeyboardRegistration current = ordered[index];
    final bool endOfRow =
        index == ordered.length - 1 ||
        ordered[index + 1].index != current.index;
    if (!endOfRow) {
      return false;
    }
    final _MorphListKeyboardGroupState? nest = _nests[current.index];
    return nest != null && nest._focusEdge(first: true);
  }

  /// The target index to focus, or null when a nested/parent group already
  /// handled the move.
  int? _resolveNextIndex(
    List<MorphListKeyboardRegistration> ordered,
    int index,
    int delta,
  ) {
    final int next = index + delta;
    if (next < 0 || next >= ordered.length) {
      return _resolveWrappedIndex(ordered, next, delta);
    }
    if (delta < 0 && ordered[next].index != ordered[index].index) {
      final _MorphListKeyboardGroupState? nest = _nests[ordered[next].index];
      if (nest != null && nest._focusEdge(first: false)) {
        return null;
      }
    }
    return next;
  }

  int? _resolveWrappedIndex(
    List<MorphListKeyboardRegistration> ordered,
    int next,
    int delta,
  ) {
    if (_parent != null &&
        _nestIndex != null &&
        _parent!._moveFromNest(_nestIndex!, delta)) {
      return null;
    }
    if (next < 0) {
      final _MorphListKeyboardGroupState? nest = _nests[ordered.last.index];
      if (delta < 0 && nest != null && nest._focusEdge(first: false)) {
        return null;
      }
      return ordered.length - 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = Shortcuts.manager(
      manager: _shortcuts,
      // Shortcuts' own Semantics is a box; slivers need SliverSemantics.
      includeSemantics: !widget.sliver,
      child: FocusTraversalGroup(policy: _policy, child: widget.child),
    );
    return _MorphListKeyboardScope(
      state: this,
      binding: _binding,
      child: widget.sliver
          ? SliverSemantics(
              container: true,
              explicitChildNodes: true,
              label: widget.semanticsLabel,
              sliver: body,
            )
          : Semantics(
              container: true,
              explicitChildNodes: true,
              label: widget.semanticsLabel,
              child: body,
            ),
    );
  }
}

class _MorphListShortcutManager extends ShortcutManager {
  _MorphListShortcutManager({required super.shortcuts, required this.state});

  final _MorphListKeyboardGroupState state;

  @override
  KeyEventResult handleKeypress(BuildContext context, KeyEvent event) {
    if (!state._memberHasFocus()) {
      return KeyEventResult.ignored;
    }
    return super.handleKeypress(context, event);
  }
}

class _MorphListTraversalPolicy extends ReadingOrderTraversalPolicy {
  _MorphListTraversalPolicy(this._group);

  final _MorphListKeyboardGroupState _group;

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
