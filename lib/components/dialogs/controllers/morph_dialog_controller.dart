import 'package:flutter/foundation.dart';

import '../enums/morph_dialog_enums.dart';
import '../models/morph_dialog_discard_labels.dart';

/// Host that an [MorphDialogController] drives.
abstract class MorphDialogControllerClient {
  /// Pops the dialog with [result], skipping dismiss guards.
  void closeDialog([Object? result]);

  /// Runs the dismiss path (guards, discard confirm). True when it closed.
  Future<bool> requestDismiss();
}

/// Drives an open dialog programmatically.
///
/// Pass to `MorphDialog.show`, `showFullScreen` or `showAdaptive`. Set
/// [hasUnsavedChanges] so dismissing shows a discard confirmation.
class MorphDialogController extends ChangeNotifier {
  /// MorphDialogController.
  MorphDialogController({
    this._hasUnsavedChanges = false,
    this.discardLabels = const MorphDialogDiscardLabels(),
  });

  /// Copy for the discard confirmation.
  final MorphDialogDiscardLabels discardLabels;

  MorphDialogControllerClient? _client;
  bool _hasUnsavedChanges;
  MorphDialogVariant? _variant;
  bool _disposed = false;

  /// Whether a dialog is attached and showing.
  bool get isOpen => _client != null;

  /// Current layout of the open dialog, or null when closed.
  MorphDialogVariant? get variant => _variant;

  /// Whether dismissing must confirm discarding changes.
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  set hasUnsavedChanges(bool value) {
    if (_hasUnsavedChanges == value) {
      return;
    }
    _hasUnsavedChanges = value;
    _notify();
  }

  /// Closes the dialog with [result], skipping guards.
  void close([Object? result]) => _client?.closeDialog(result);

  /// Dismisses through guards and discard confirmation.
  Future<bool> dismiss() async => await _client?.requestDismiss() ?? false;

  /// Binds [client]. Called by the dialog host.
  void attach(MorphDialogControllerClient client) {
    _client = client;
    _notify();
  }

  /// Unbinds [client]. Called by the dialog host.
  void detach(MorphDialogControllerClient client) {
    if (_client != client) {
      return;
    }
    _client = null;
    _variant = null;
    _notify();
  }

  /// Reports the layout in use. Called by the dialog host.
  void updateVariant(MorphDialogVariant? value) {
    if (_variant == value) {
      return;
    }
    _variant = value;
    _notify();
  }

  // The host can unmount after the owner disposed this controller (e.g. on
  // the route future), so late host updates are dropped.
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
