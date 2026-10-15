import 'morph_navigation_destination.dart';

/// A labeled group of destinations below the drawer's primary list.
class MorphNavigationDrawerSection {
  /// Creates a section. A divider is painted before the group.
  const MorphNavigationDrawerSection({required this.destinations, this.header});

  /// Destinations in this group. Indices continue after earlier groups.
  final List<MorphNavigationDestination> destinations;

  /// Optional subhead, such as `Labels`.
  final String? header;
}
