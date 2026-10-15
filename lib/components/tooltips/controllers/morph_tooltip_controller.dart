import 'package:flutter/foundation.dart';

/// Programmatic show / hide for an Morph tooltip.
///
/// Attach via `MorphTooltip.controller`. Useful for persistent rich tooltips that
/// appear on page load.
class MorphTooltipController extends ChangeNotifier {
  /// Creates a tooltip controller.
  MorphTooltipController();

  MorphTooltipControllerClient? _client;
  bool _showing = false;

  /// Whether the tooltip is currently shown.
  bool get isShowing => _showing;

  /// Binds the owning tooltip state.
  // ignore: use_setters_to_change_properties -- attach/detach pair.
  void attachClient(MorphTooltipControllerClient client) {
    _client = client;
  }

  /// Releases the owning tooltip state without disposing this controller.
  void detachClient(MorphTooltipControllerClient client) {
    if (identical(_client, client)) {
      _client = null;
    }
  }

  /// Updates showing state from the tooltip (does not drive the portal).
  void updateShowing({required bool showing}) {
    if (_showing == showing) {
      return;
    }
    _showing = showing;
    notifyListeners();
  }

  /// Shows the tooltip.
  void show() {
    _client?.onShowRequested();
  }

  /// Hides the tooltip.
  void hide() {
    _client?.onHideRequested();
  }
}

/// Client API implemented by the tooltip state.
abstract class MorphTooltipControllerClient {
  /// Shows the overlay.
  void onShowRequested();

  /// Hides the overlay.
  void onHideRequested();
}
