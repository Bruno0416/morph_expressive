import 'package:flutter/widgets.dart';

/// Implemented by the card that owns an open container transform.
abstract class MorphCardControllerClient {
  /// Whether the container transform route is open.
  bool get isTransformOpen;

  /// Morphs the card into [builder], or the card's open builder.
  Future<T?> openTransform<T extends Object?>({WidgetBuilder? builder});

  /// Reverses the container transform.
  void closeTransform();
}

/// Opens and closes a card's container transform.
class MorphCardController extends ChangeNotifier {
  MorphCardControllerClient? _client;

  /// Whether a container transform is open.
  bool get isOpen => _client?.isTransformOpen ?? false;

  /// Binds the owning card.
  void attach(MorphCardControllerClient client) {
    _client = client;
    notifyListeners();
  }

  /// Releases [client] without disposing this controller.
  void detach(MorphCardControllerClient client) {
    if (identical(_client, client)) {
      _client = null;
      notifyListeners();
    }
  }

  /// Opens the container transform.
  Future<T?> open<T extends Object?>({WidgetBuilder? builder}) {
    final MorphCardControllerClient? client = _client;
    if (client == null) {
      return Future<T?>.value();
    }
    return client.openTransform<T>(builder: builder);
  }

  /// Closes the container transform.
  void close() => _client?.closeTransform();

  /// Asks listeners to read [isOpen] again.
  void refresh() => notifyListeners();
}
