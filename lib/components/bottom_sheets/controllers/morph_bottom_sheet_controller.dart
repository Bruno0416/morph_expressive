import 'package:flutter/foundation.dart';

import '../enums/morph_bottom_sheet_enums.dart';

/// Host that an [MorphBottomSheetController] drives.
abstract class MorphBottomSheetControllerClient {
  /// Current resting value.
  MorphBottomSheetValue get value;

  /// Preset heights the sheet can rest at, lowest first.
  List<MorphBottomSheetValue> get availableValues;

  /// Visible height in dp.
  double get extent;

  /// Springs to [value]. Hidden closes a modal sheet.
  Future<void> animateTo(MorphBottomSheetValue value);

  /// Moves to the next taller height, wrapping to the lowest.
  Future<void> cycle();

  /// Closes the sheet; a modal sheet pops with [result].
  void close([Object? result]);
}

/// Drives a bottom sheet without dragging.
///
/// It is the single-pointer alternative to the drag handle. Pass it to
/// `MorphBottomSheet.show` or `MorphBottomSheet.standard`.
class MorphBottomSheetController extends ChangeNotifier {
  /// MorphBottomSheetController.
  MorphBottomSheetController();

  MorphBottomSheetControllerClient? _client;
  MorphBottomSheetValue _value = MorphBottomSheetValue.hidden;
  bool _disposed = false;

  /// Whether a sheet is attached.
  bool get isAttached => _client != null;

  /// Current resting value; hidden when detached.
  MorphBottomSheetValue get value => _value;

  /// Preset heights of the attached sheet, lowest first.
  List<MorphBottomSheetValue> get availableValues =>
      _client?.availableValues ?? const <MorphBottomSheetValue>[];

  /// Visible height in dp; 0 when detached.
  double get extent => _client?.extent ?? 0;

  /// Springs to [value] when it is available.
  Future<void> animateTo(MorphBottomSheetValue value) async =>
      _client?.animateTo(value);

  /// Springs to the tallest height.
  Future<void> expand() async {
    final List<MorphBottomSheetValue> values = availableValues;
    if (values.isNotEmpty) {
      await animateTo(values.last);
    }
  }

  /// Springs back to the initial (collapsed) height.
  Future<void> collapse() async {
    final List<MorphBottomSheetValue> values = availableValues;
    if (values.isEmpty) {
      return;
    }
    await animateTo(
      values.contains(MorphBottomSheetValue.collapsed)
          ? MorphBottomSheetValue.collapsed
          : values.first,
    );
  }

  /// Moves to the next taller height, wrapping to the lowest.
  Future<void> cycle() async => _client?.cycle();

  /// Shows a hidden standard sheet at its collapsed height.
  Future<void> show() => collapse();

  /// Hides a standard sheet, or closes a modal one.
  Future<void> hide() => animateTo(MorphBottomSheetValue.hidden);

  /// Closes the sheet; a modal sheet pops with [result].
  void close([Object? result]) => _client?.close(result);

  /// Binds [client]. Called by the sheet.
  void attach(MorphBottomSheetControllerClient client) {
    _client = client;
    _value = client.value;
    _notify();
  }

  /// Unbinds [client]. Called by the sheet.
  void detach(MorphBottomSheetControllerClient client) {
    if (_client != client) {
      return;
    }
    _client = null;
    _value = MorphBottomSheetValue.hidden;
    _notify();
  }

  /// Reports a new resting value. Called by the sheet.
  void updateValue(MorphBottomSheetValue value) {
    if (_value == value) {
      return;
    }
    _value = value;
    _notify();
  }

  // The sheet can unmount after the owner disposed this controller.
  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _client = null;
    super.dispose();
  }
}
