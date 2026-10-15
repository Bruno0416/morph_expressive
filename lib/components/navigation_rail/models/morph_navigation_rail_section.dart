import 'package:material_ui/material_ui.dart';

import 'morph_navigation_rail_destination.dart';

/// Section groups a header and a list of destinations. One class per file.
class MorphNavigationRailSection {
  /// Creates a [MorphNavigationRailSection].
  const MorphNavigationRailSection({required this.destinations, this.header});

  /// Destinations shown in this section.
  final List<MorphNavigationRailDestination> destinations;

  /// Optional header widget displayed above the destinations.
  final Widget? header;
}
