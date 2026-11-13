import 'package:flutter/foundation.dart';

/// Transient visual position reported by a page view to a tab bar.
///
/// [value] is a fractional tab index (`1.0` = tab 1 exactly, `1.5` = half way
/// between tabs 1 and 2). It is visual progress, not a confirmed selection.
/// [from] and [to] are set while the page view travels programmatically
/// (a tap on a distant tab): only those two tabs take part in the colour
/// transition, so intermediate tabs never look selected.
@immutable
class MorphTabsPosition {
  /// Creates a position.
  const MorphTabsPosition(this.value, {this.from, this.to});

  /// Fractional tab index.
  final double value;

  /// Origin of a programmatic travel, or null while the user drags.
  final int? from;

  /// Destination of a programmatic travel, or null while the user drags.
  final int? to;

  @override
  bool operator ==(Object other) =>
      other is MorphTabsPosition &&
      other.value == value &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(value, from, to);
}

/// Connects a `MorphTabs` bar with a `MorphTabsView` and with the outside.
///
/// * [index] / [select] keep the existing contract: the confirmed selection.
///   [select] runs the bar's `onTabSelected`; [index] follows the bar.
/// * [position] is the visual position published by an attached
///   `MorphTabsView` while its pages move (drag, fling, animated change). It
///   is `null` at rest. The bar follows it directly, so bar and pages share one
///   progress. It never changes [index] and never notifies [addListener].
///
/// Who drives the indicator:
/// * tap or programmatic selection with an attached view: the view animates
///   the pages and publishes [position]; the bar follows it.
/// * tap without a view: the bar runs its own animation.
/// * drag, fling, interruption: the pages, through [position].
class MorphTabsController extends ChangeNotifier {
  /// Creates a controller at [index].
  MorphTabsController({this.index = 0});

  /// Selected tab index.
  int index;

  ValueChanged<int>? _select;
  final ValueNotifier<MorphTabsPosition?> _position =
      ValueNotifier<MorphTabsPosition?>(null);
  bool _pageDriving = false;

  /// Semantics identifier shared by the tab of [index] and its page, so
  /// assistive technology can relate a tab to the content it controls.
  String panelIdentifier(int index) => 'morph-tabs-$hashCode-panel-$index';

  /// Whether [attach] has been called.
  bool get isAttached => _select != null;

  /// Visual position published by an attached page view, `null` at rest.
  ValueListenable<MorphTabsPosition?> get position => _position;

  /// Whether an attached page view is moving the pages right now (or is about
  /// to). While true the bar does not run its own animation.
  bool get isPageDriven => _pageDriving || _position.value != null;

  /// Asks the attached bar to select [index].
  void select(int index) {
    final ValueChanged<int>? select = _select;
    if (select == null) {
      if (this.index == index) {
        return;
      }
      this.index = index;
      notifyListeners();
      return;
    }
    select(index);
  }

  /// Binds the bar. [select] is the bar's `onTabSelected`.
  void attach(ValueChanged<int> select, int index) {
    _select = select;
    this.index = index;
  }

  /// Drops the bar when [select] is still the bound callback.
  void detach(ValueChanged<int> select) {
    if (!identical(_select, select)) {
      return;
    }
    _select = null;
  }

  /// Stores the bar's current index.
  void updateIndex(int index) {
    if (this.index == index) {
      return;
    }
    this.index = index;
    notifyListeners();
  }

  /// Called by `MorphTabsView`: marks the pages as moving (or settled).
  ///
  /// Does not notify. Safe to call during build.
  void setPageDriving(bool value) => _pageDriving = value;

  /// Called by `MorphTabsView`: publishes the visual position, `null` at rest.
  void reportPosition(MorphTabsPosition? value) {
    if (_position.value == value) {
      return;
    }
    _position.value = value;
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }
}
