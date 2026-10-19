import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/search/morph_search.dart'
    show MorphSearchAnchor;
import 'package:morph_expressive/components/search/morph_search_anchor.dart'
    show MorphSearchAnchor;
import 'package:morph_expressive/morph_components.dart' show MorphSearchAnchor;

/// Handle implemented by [MorphSearchAnchor] for [MorphSearchController].
abstract class MorphSearchAnchorHandle {
  /// The viewIsOpen.
  bool get viewIsOpen;

  /// Whether focus on the anchor bar should avoid reopening the view.
  bool get suppressFocusOpen;

  /// openView.

  void openView();

  /// closeView.

  void closeView(String? selectedText);
}

/// Controls a search view opened by [MorphSearchAnchor].
class MorphSearchController extends TextEditingController {
  MorphSearchAnchorHandle? _anchor;

  /// Whether this controller is attached to a search anchor.
  bool get isAttached => _anchor != null;

  /// Whether the associated search view is currently open.
  bool get isOpen {
    assert(isAttached, 'MorphSearchController is not attached to an anchor.');
    return _anchor!.viewIsOpen;
  }

  /// Whether the anchor should ignore focus-driven [openView] calls.
  bool get suppressFocusOpen {
    assert(isAttached, 'MorphSearchController is not attached to an anchor.');
    return _anchor!.suppressFocusOpen;
  }

  /// Opens the search view associated with this controller.
  void openView() {
    assert(isAttached, 'MorphSearchController is not attached to an anchor.');
    _anchor!.openView();
  }

  /// Closes the search view, optionally setting [selectedText].
  void closeView(String? selectedText) {
    assert(isAttached, 'MorphSearchController is not attached to an anchor.');
    _anchor!.closeView(selectedText);
  }

  /// The currently attached search anchor handle, if any.
  MorphSearchAnchorHandle? get anchor => _anchor;

  /// Attaches this controller to a search anchor handle.
  set anchor(MorphSearchAnchorHandle handle) {
    _anchor = handle;
  }

  /// Detaches this controller from [anchor] when it is the current handle.
  void detach(MorphSearchAnchorHandle anchor) {
    if (_anchor == anchor) {
      _anchor = null;
    }
  }
}

/// Signature for building the search anchor child.
typedef MorphSearchAnchorChildBuilder = Widget Function(
  BuildContext context,
  MorphSearchController controller,
);

/// Signature for building search suggestions from the current query.
typedef MorphSearchSuggestionsBuilder = FutureOr<Iterable<Widget>> Function(
  BuildContext context,
  MorphSearchController controller,
);

/// Signature for laying out suggestion widgets in the search view.
typedef MorphSearchViewBuilder = Widget Function(Iterable<Widget> suggestions);

/// Signature for the screen reader text sent when results change.
typedef MorphSearchAnnouncementBuilder = String Function(int count);
