import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/rendering.dart'
    show
        BoxHitTestResult,
        FloatingHeaderSnapConfiguration,
        RenderProxyBox,
        RenderSliver,
        RenderSliverSingleBoxAdapter,
        ScrollDirection,
        SliverGeometry,
        TransformLayer;

import 'package:morph_expressive/components/toolbars/morph_toolbars.dart'
    show MorphToolbar;
import 'package:morph_expressive/morph_components.dart' show MorphToolbar;
import 'package:material_ui/material_ui.dart';

import '../../foundations/foundations.dart';
import '../search/controllers/morph_search_controller.dart';
import '../search/enums/morph_search_enums.dart';
import '../search/morph_search_anchor.dart';
import '../tooltips/morph_tooltips.dart';
import 'components/morph_app_bar_semantics.dart';
import 'controllers/morph_app_bar_controller.dart';
import 'enums/morph_app_bar_enums.dart';
import 'styles/morph_app_bar_theme.dart';

export 'controllers/morph_app_bar_controller.dart';
export 'enums/morph_app_bar_enums.dart';
export 'styles/morph_app_bar_theme.dart';

part 'components/morph_app_bar_docked.dart';
part 'components/morph_app_bar_docked_parts.dart';
part 'components/morph_app_bar_bottom.dart';
part 'components/morph_app_bar_sliver.dart';
part 'components/morph_app_bar_sliver_actions.dart';
part 'components/morph_app_bar_motion.dart';
part 'components/morph_app_bar_scroll.dart';
part 'components/morph_app_bar_body.dart';
part 'components/morph_app_bar_title.dart';

const Duration _kAppBarTravel = MorphMotion.medium1;

/// Which app bar layout an [MorphAppBar] renders.
enum _MorphAppBarKind { top, bottom, sliver }

/// Dock edge for single-sided system inset padding (toolbar-compatible).
enum _MorphAppBarDockEdge { top, bottom }

/// A Material 3 Expressive app bar with `top`, `bottom`, and `sliver` variants.
class MorphAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// A fixed top app bar for use in `Scaffold.appBar`.
  ///
  /// When [safeArea] is true, only the top [MorphSafeArea] inset is applied
  /// outside the content band (same model as [MorphToolbar.docked]).
  const MorphAppBar.top({
    super.key,
    this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shapeFamily = MorphAppBarShapeFamily.square,
    this.density = MorphAppBarDensity.regular,
    this.toolbarHeight,
    this.automaticallyImplyLeading = false,
    this.safeArea = true,
    this.clipBehavior = Clip.none,
    this.semanticLabel,
    this.controller,
    this.variant = MorphAppBarVariant.small,
    this.hideOnScroll = false,
    this.hideMode = MorphAppBarHideMode.none,
  }) : _kind = _MorphAppBarKind.top,
       _dockEdge = _MorphAppBarDockEdge.top,
       floatingActionButton = null,
       pinned = true,
       floating = false,
       snap = false;

  /// A top app bar whose title is a read-only anchored [MorphSearchAnchor.bar].
  ///
  /// Tapping the bar opens the fullscreen (or docked) search view. Below the
  /// search bar theme max width, the bar fills the space between [leading] and
  /// [actions] while keeping the existing action gaps. Above that width it is
  /// capped and positioned with [centerTitle].
  factory MorphAppBar.search({
    Key? key,
    required MorphSearchController searchController,
    required MorphSearchSuggestionsBuilder suggestionsBuilder,
    Widget? leading,
    List<Widget>? actions,
    bool centerTitle = false,
    String? barHintText,
    Widget? barLeading,
    Iterable<Widget>? barTrailing,
    WidgetStateProperty<Color?>? barBackgroundColor,
    bool isFullScreen = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    MorphAppBarShapeFamily shapeFamily = MorphAppBarShapeFamily.square,
    MorphAppBarDensity density = MorphAppBarDensity.regular,
    double? toolbarHeight,
    bool automaticallyImplyLeading = false,
    bool safeArea = true,
    Clip clipBehavior = Clip.none,
    String? semanticLabel,
    MorphAppBarController? controller,
    MorphAppBarVariant variant = MorphAppBarVariant.small,
    bool hideOnScroll = false,
    MorphAppBarHideMode hideMode = MorphAppBarHideMode.none,
    bool wrapActions = false,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
    VoidCallback? onClose,
    VoidCallback? onOpen,
    BoxConstraints? searchConstraints,
    AlignmentGeometry? barAlignment,
  }) {
    return MorphAppBar.top(
      key: key,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      shapeFamily: shapeFamily,
      density: density,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: automaticallyImplyLeading,
      safeArea: safeArea,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      controller: controller,
      variant: variant,
      hideOnScroll: hideOnScroll,
      hideMode: hideMode,
      title: _MorphAppBarSearchTitle(
        searchController: searchController,
        suggestionsBuilder: suggestionsBuilder,
        barHintText: barHintText,
        barLeading: barLeading,
        barTrailing: barTrailing,
        barBackgroundColor: barBackgroundColor,
        barAlignment:
            barAlignment ??
            (centerTitle ? Alignment.center : AlignmentDirectional.centerStart),
        wrapActions: wrapActions,
        isFullScreen: isFullScreen,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        onClose: onClose,
        onOpen: onOpen,
        searchConstraints: searchConstraints,
      ),
    );
  }

  /// A bottom app bar with actions and an optional floating action button.
  ///
  /// When [safeArea] is true, only the bottom [MorphSafeArea] inset is
  /// applied outside the content band.
  const MorphAppBar.bottom({
    super.key,
    this.actions = const <Widget>[],
    this.floatingActionButton,
    this.safeArea = true,
  }) : _kind = _MorphAppBarKind.bottom,
       _dockEdge = _MorphAppBarDockEdge.bottom,
       leading = null,
       title = null,
       titleText = null,
       subtitle = null,
       subtitleText = null,
       centerTitle = false,
       backgroundColor = null,
       foregroundColor = null,
       elevation = null,
       shapeFamily = MorphAppBarShapeFamily.square,
       density = MorphAppBarDensity.regular,
       toolbarHeight = null,
       automaticallyImplyLeading = true,
       clipBehavior = Clip.none,
       semanticLabel = null,
       pinned = true,
       floating = false,
       snap = false,
       hideOnScroll = false,
       hideMode = MorphAppBarHideMode.none,
       controller = null,
       variant = MorphAppBarVariant.medium;

  /// A scrolling sliver app bar for use in `CustomScrollView.slivers`.
  ///
  /// Flexible variants are pinned. They collapse to the small content height
  /// and stay there until the scroll offset returns to the top. [hideOnScroll]
  /// additionally moves that bar away while content scrolls forward and brings
  /// it back when the user scrolls back.
  const MorphAppBar.sliver({
    super.key,
    this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.hideOnScroll = false,
    this.hideMode = MorphAppBarHideMode.none,
    this.controller,
    this.shapeFamily = MorphAppBarShapeFamily.square,
    this.density = MorphAppBarDensity.regular,
    this.variant = MorphAppBarVariant.medium,
    this.semanticLabel,
  }) : _kind = _MorphAppBarKind.sliver,
       _dockEdge = _MorphAppBarDockEdge.top,
       elevation = null,
       toolbarHeight = null,
       automaticallyImplyLeading = true,
       safeArea = true,
       clipBehavior = Clip.none,
       floatingActionButton = null;

  final _MorphAppBarKind _kind;
  final _MorphAppBarDockEdge _dockEdge;

  /// leading.

  final Widget? leading;

  /// title.
  final Widget? title;

  /// titleText.
  final String? titleText;

  /// Optional subtitle widget. Shown under the headline.
  final Widget? subtitle;

  /// Optional subtitle string. Ignored when [subtitle] is set.
  final String? subtitleText;

  /// actions.
  final List<Widget>? actions;

  /// centerTitle.
  final bool centerTitle;

  /// backgroundColor.
  final Color? backgroundColor;

  /// foregroundColor.
  final Color? foregroundColor;

  /// elevation.
  final double? elevation;

  /// shapeFamily.
  final MorphAppBarShapeFamily shapeFamily;

  /// density.
  final MorphAppBarDensity density;

  /// toolbarHeight.
  final double? toolbarHeight;

  /// automaticallyImplyLeading.
  final bool automaticallyImplyLeading;

  /// When true, applies [MorphSafeArea] padding on the docked edge only
  /// (top for [MorphAppBar.top]/[MorphAppBar.search], bottom for [MorphAppBar.bottom]).
  final bool safeArea;

  /// clipBehavior.
  final Clip clipBehavior;

  /// semanticLabel.
  final String? semanticLabel;

  /// floatingActionButton.

  // Bottom-only.
  final Widget? floatingActionButton;

  /// pinned.

  // Sliver-only.
  final bool pinned;

  /// floating.
  final bool floating;

  /// snap.
  final bool snap;

  /// When true, the bar slides away as content scrolls forward and returns
  /// when the user scrolls back. Same as [hideMode] [MorphAppBarHideMode.entire].
  final bool hideOnScroll;

  /// Which parts slide away on scroll. [hideOnScroll] selects
  /// [MorphAppBarHideMode.entire] when this is [MorphAppBarHideMode.none].
  final MorphAppBarHideMode hideMode;

  /// Optional controller for expand, collapse, show, and hide.
  final MorphAppBarController? controller;

  /// variant.
  final MorphAppBarVariant variant;

  @override
  Size get preferredSize {
    if (_kind == _MorphAppBarKind.bottom) {
      return Size.fromHeight(MorphAppBarTheme.defaults.bottomHeight);
    }
    final double? live = _morphAppBarHeightOf(this);
    if (live != null) {
      return Size.fromHeight(math.max(0, live));
    }
    return Size.fromHeight(_fallbackContentHeight());
  }

  /// Content-band height before the first scroll frame.
  double _fallbackContentHeight() {
    if (toolbarHeight != null) {
      return toolbarHeight!;
    }
    final MorphAppBarMetrics metrics = MorphAppBarTheme.defaults.metrics(
      density,
    );
    if (variant == MorphAppBarVariant.small) {
      return metrics.smallHeight;
    }
    return metrics.expandedHeight(
      variant,
      hasSubtitle: subtitle != null || subtitleText != null,
    );
  }

  /// [hideOnScroll] means the whole bar when [hideMode] is [MorphAppBarHideMode.none].
  MorphAppBarHideMode get _effectiveHideMode {
    if (hideMode != MorphAppBarHideMode.none) {
      return hideMode;
    }
    if (hideOnScroll) {
      return MorphAppBarHideMode.entire;
    }
    return MorphAppBarHideMode.none;
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (context) => switch (_kind) {
        _MorphAppBarKind.top => _MorphDockedAppBar(bar: this),
        _MorphAppBarKind.bottom => _MorphBottomAppBar(bar: this),
        _MorphAppBarKind.sliver => _MorphSliverAppBar(bar: this),
      },
    );
  }

  /// System inset for the docked edge only — same recipe as docked toolbars.
  EdgeInsets _edgeSafeAreaInset(BuildContext context) {
    if (!safeArea) {
      return EdgeInsets.zero;
    }
    final EdgeInsets mq = MorphSafeArea.paddingOf(context);
    return EdgeInsets.only(
      top: _dockEdge == _MorphAppBarDockEdge.top ? mq.top : 0,
      bottom: _dockEdge == _MorphAppBarDockEdge.bottom ? mq.bottom : 0,
    );
  }
}

/// Live content-band height for [MorphAppBar.preferredSize].
final Expando<double> _morphAppBarHeights = Expando<double>();

double? _morphAppBarHeightOf(MorphAppBar bar) => _morphAppBarHeights[bar];

void _morphAppBarWriteHeight(MorphAppBar bar, double height) {
  _morphAppBarHeights[bar] = height;
}

void _morphAppBarClearHeight(MorphAppBar bar) {
  _morphAppBarHeights[bar] = null;
}
