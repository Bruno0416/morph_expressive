import 'package:flutter/widgets.dart';

import '../components/morph_snackbar_host.dart';

/// Programmatic show / dismiss for snackbars (one at a time).
///
/// New [present] calls replace any currently visible snackbar. Prefer
/// `MorphSnackbar.show` which routes through this controller (or a custom one).
class MorphSnackbarController extends ChangeNotifier {
  /// Creates a snackbar controller.
  MorphSnackbarController();

  OverlayEntry? _entry;
  MorphSnackbarHostState? _host;
  bool _disposed = false;

  /// Whether a snackbar overlay is currently mounted.
  bool get isShowing => _entry != null;

  /// Binds the active host (called by [MorphSnackbarHost]).
  void attachHost(MorphSnackbarHostState host) {
    if (_disposed) {
      return;
    }
    _host = host;
  }

  /// Releases the host without disposing this controller.
  void detachHost(MorphSnackbarHostState host) {
    if (identical(_host, host)) {
      _host = null;
    }
  }

  /// Inserts [child] in a snackbar host, replacing any current bar.
  ///
  /// When [duration] is null, the bar stays until [dismiss], close, action, or
  /// Escape.
  void present(
    BuildContext context, {
    required Widget child,
    Duration? duration,
    bool swipeDismissible = false,
  }) {
    if (_disposed) {
      return;
    }
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    dismiss(immediate: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return MorphSnackbarHost(
          duration: duration,
          swipeDismissible: swipeDismissible,
          entry: entry,
          controller: this,
          child: child,
        );
      },
    );
    _entry = entry;
    overlay.insert(entry);
    _notify();
  }

  /// Dismisses the current snackbar.
  ///
  /// When [immediate] is true, removes the overlay without exit animation.
  void dismiss({bool immediate = false}) {
    final OverlayEntry? entry = _entry;
    final MorphSnackbarHostState? host = _host;
    if (entry == null) {
      return;
    }
    if (immediate || host == null || _disposed) {
      _clearEntry(entry);
      entry.remove();
      return;
    }
    host.dismiss();
  }

  /// Called by the host after exit animation completes.
  void notifyClosed(OverlayEntry entry) {
    _clearEntry(entry);
  }

  void _clearEntry(OverlayEntry entry) {
    if (!identical(_entry, entry)) {
      return;
    }
    _entry = null;
    _host = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Drop the overlay before marking disposed so exit animations cannot
    // notify this controller after [super.dispose].
    final OverlayEntry? entry = _entry;
    _entry = null;
    _host = null;
    entry?.remove();
    _disposed = true;
    super.dispose();
  }
}
