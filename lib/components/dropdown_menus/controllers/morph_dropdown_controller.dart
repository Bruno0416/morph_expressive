import 'package:flutter/foundation.dart';
import 'package:morph_expressive/components/dropdown_menus/morph_dropdown_menus.dart'
    show MorphDropdownMenu;
import 'package:morph_expressive/morph_components.dart' show MorphDropdownMenu;

import '../models/morph_dropdown_item.dart';

/// Controls an [MorphDropdownMenu] programmatically.
///
/// Provides methods to open/close the dropdown, select/deselect items,
/// set items dynamically, and listen for changes.
///
/// Items are managed as **immutable** [MorphDropdownItem] instances. All
/// mutations go through [MorphDropdownItem.copyWith], which ensures the controller properly
/// detects changes and notifies listeners.
///
/// Search filtering is handled internally — [items] returns either the
/// full list or the filtered list depending on the active search query.
///
/// ```dart
/// final controller = MorphDropdownController<String>();
///
/// Select items matching a condition
/// controller.selectWhere((item) => item.value == 'dart');
///
/// Clear all selections
/// controller.clearAll();
/// ```
class MorphDropdownController<T> extends ChangeNotifier {
  /// Creates a new [MorphDropdownController].
  MorphDropdownController();

  // ── Internal state ──

  bool _initialized = false;

  final List<MorphDropdownItem<T>> _items = [];
  List<MorphDropdownItem<T>> _filteredItems = [];
  String _searchQuery = '';

  /// Cached selected items — invalidated on every [notifyListeners].
  List<MorphDropdownItem<T>>? _cachedSelectedItems;

  bool _isOpen = false;
  bool _isDisposed = false;

  /// onSelectionChange.

  // Callbacks wired by the widget
  ValueChanged<List<MorphDropdownItem<T>>>? onSelectionChange;

  /// onSearchChange.
  ValueChanged<String>? onSearchChange;

  // ── Public getters ──

  /// Whether [initialize] has been called by the widget.
  bool get initialized => _initialized;

  /// Whether the controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// Whether the dropdown is currently open.
  bool get isOpen => _isOpen;

  /// The current search query (empty string when inactive).
  String get searchQuery => _searchQuery;

  /// The items visible to the dropdown list.
  ///
  /// Returns the filtered subset when a search query is active, otherwise
  /// returns all items.
  List<MorphDropdownItem<T>> get items => _searchQuery.isEmpty
      ? List.unmodifiable(_items)
      : List.unmodifiable(_filteredItems);

  /// The currently selected items.
  List<MorphDropdownItem<T>> get selectedItems {
    return _cachedSelectedItems ??= _items.where((i) => i.selected).toList();
  }

  /// Convenience — the [T] values of the currently selected items.
  List<T> get selectedValues => selectedItems.map((i) => i.value).toList();

  /// The currently disabled items.
  List<MorphDropdownItem<T>> get disabledItems =>
      _items.where((i) => i.disabled).toList();

  // ── Lifecycle (called by the widget) ──

  /// Marks the controller as initialized. Called once by the widget.
  void initialize() {
    _initialized = true;
  }

  @override
  void notifyListeners() {
    _cachedSelectedItems = null;
    super.notifyListeners();
  }

  // ── Search ──

  /// Re-applies the current search filter after items are modified.
  void _reapplySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredItems = _items
          .where((i) => i.label.toLowerCase().contains(q))
          .toList();
    }
  }

  /// Updates the search query, re-filters items, and fires the callback.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _reapplySearchFilter();
    onSearchChange?.call(query);
    notifyListeners();
  }

  /// Clears the search query. If [notify] is true, listeners are notified.
  void clearSearchQuery({bool notify = false}) {
    _searchQuery = '';
    _filteredItems = List.from(_items);
    if (notify) {
      notifyListeners();
    }
  }

  /// Clears the current search query and shows all items.
  ///
  /// This is the public API; always notifies listeners.
  void clearSearch() {
    clearSearchQuery(notify: true);
  }

  // ── Item management ──

  /// Replaces the entire item list, resetting the search query.
  void setItems(
    List<MorphDropdownItem<T>> items, {
    bool notifySelection = false,
  }) {
    _items
      ..clear()
      ..addAll(items);
    _searchQuery = '';
    _filteredItems = List.from(_items);
    notifyListeners();
    if (notifySelection) {
      onSelectionChange?.call(selectedItems);
    }
  }

  /// Adds a single item. If [index] is provided, inserts at that position.
  void addItem(MorphDropdownItem<T> item, {int index = -1}) {
    if (index == -1) {
      _items.add(item);
    } else {
      _items.insert(index, item);
    }
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// Adds multiple items at the end of the list.
  void addItems(List<MorphDropdownItem<T>> items) {
    _items.addAll(items);
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  // ── Selection ──

  /// Selects all non-disabled items.
  void selectAll() {
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].selected && !_items[i].disabled) {
        _items[i] = _items[i].copyWith(selected: true);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// De-selects every item.
  void clearAll() {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].selected) {
        _items[i] = _items[i].copyWith(selected: false);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// Selects the item at the given [index].
  ///
  /// Does nothing if [index] is out of range, or the item is already
  /// selected or disabled.
  void selectAtIndex(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }
    final item = _items[index];
    if (item.disabled || item.selected) {
      return;
    }
    _items[index] = item.copyWith(selected: true);
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// Selects items matching [predicate].
  void selectWhere(bool Function(MorphDropdownItem<T>) predicate) {
    for (var i = 0; i < _items.length; i++) {
      if (predicate(_items[i]) && !_items[i].selected && !_items[i].disabled) {
        _items[i] = _items[i].copyWith(selected: true);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// De-selects items matching [predicate].
  void unselectWhere(bool Function(MorphDropdownItem<T>) predicate) {
    for (var i = 0; i < _items.length; i++) {
      if (predicate(_items[i]) && _items[i].selected) {
        _items[i] = _items[i].copyWith(selected: false);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// Toggles items matching [predicate].
  void toggleWhere(bool Function(MorphDropdownItem<T>) predicate) {
    for (var i = 0; i < _items.length; i++) {
      if (predicate(_items[i]) && !_items[i].disabled) {
        _items[i] = _items[i].copyWith(selected: !_items[i].selected);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// Selects only [item], deselecting all others (single-select helper).
  void toggleOnly(MorphDropdownItem<T> item) {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i] == item) {
        _items[i] = _items[i].copyWith(selected: !_items[i].selected);
      } else if (_items[i].selected) {
        _items[i] = _items[i].copyWith(selected: false);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
    onSelectionChange?.call(selectedItems);
  }

  /// Disables items matching [predicate].
  ///
  /// Disabled items cannot be selected or deselected by the user.
  void disableWhere(bool Function(MorphDropdownItem<T>) predicate) {
    for (var i = 0; i < _items.length; i++) {
      if (predicate(_items[i]) && !_items[i].disabled) {
        _items[i] = _items[i].copyWith(disabled: true);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
  }

  /// Enables items matching [predicate].
  void enableWhere(bool Function(MorphDropdownItem<T>) predicate) {
    for (var i = 0; i < _items.length; i++) {
      if (predicate(_items[i]) && _items[i].disabled) {
        _items[i] = _items[i].copyWith(disabled: false);
      }
    }
    _reapplySearchFilter();
    notifyListeners();
  }

  // ── Open / close ──

  /// Opens the dropdown overlay.
  void openDropdown() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  /// Closes the dropdown overlay and clears the search query.
  void closeDropdown() {
    if (_isOpen) {
      _isOpen = false;
      clearSearchQuery();
      notifyListeners();
    }
  }

  /// Toggles the dropdown open/close state.
  void toggleDropdown() {
    _isOpen ? closeDropdown() : openDropdown();
  }

  /// Sets the open state directly (used by the widget internally).
  void setOpen({required bool open}) {
    if (_isOpen != open) {
      _isOpen = open;
      if (!open) {
        clearSearchQuery();
      }
      notifyListeners();
    }
  }

  // ── Dispose ──

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    super.dispose();
  }

  @override
  String toString() =>
      'MorphDropdownController(items: $_items, open: $_isOpen)';
}
