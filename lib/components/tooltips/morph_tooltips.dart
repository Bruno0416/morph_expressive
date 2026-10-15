import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import 'components/morph_tooltip_plain_surface.dart';
import 'controllers/morph_tooltip_controller.dart';
import 'enums/morph_tooltip_placement.dart';
import 'styles/morph_tooltip_theme.dart';
import 'utils/morph_tooltip_position_delegate.dart';

export 'controllers/morph_tooltip_controller.dart';
export 'enums/morph_tooltip_placement.dart';
export 'styles/morph_tooltip_theme.dart';

/// Ensures only one [MorphTooltip] overlay is visible at a time.
final Set<_MorphTooltipState> _openTooltips = <_MorphTooltipState>{};

/// A Material 3 Expressive tooltip.
///
/// **Plain** ([message]): hover, focus, or long-press; dismisses immediately
/// after leaving the target by default (themable). Default placement: above.
///
/// **Rich** ([richMessage]): optional [richTitle] and up to two [actions]
/// (prefer text buttons such as `MorphButton.text`). Transient rich uses the
/// same triggers as plain and dismisses **1.5s** after leave by default;
/// [persistent] rich shows on tap / [controller] only and stays until an
/// outside interaction. Default placement: bottom-end.
class MorphTooltip extends StatefulWidget {
  /// MorphTooltip.
  const MorphTooltip({
    required this.child,
    this.message,
    this.richTitle,
    this.richMessage,
    this.actions = const <Widget>[],
    this.persistent = false,
    this.preferredPlacement,
    this.dismissDelay,
    this.shape,
    this.controller,
    super.key,
  }) : assert(
         message != null || richMessage != null,
         'Provide a plain message or a rich message.',
       ),
       assert(
         !persistent || richMessage != null,
         'persistent is only supported for rich tooltips.',
       );

  /// Anchor widget.
  final Widget child;

  /// Plain supporting text.
  final String? message;

  /// Rich subhead (optional).
  final String? richTitle;

  /// Rich supporting text. Presence selects rich mode.
  final String? richMessage;

  /// Rich action widgets (max 2). Prefer text buttons.
  final List<Widget> actions;

  /// When true (rich only), show on tap/controller — not hover/focus.
  final bool persistent;

  /// Overrides default placement (plain: above, rich: bottom-end).
  final MorphTooltipPlacement? preferredPlacement;

  /// Override for delay after leaving the target before hiding.
  ///
  /// When null, uses [MorphTooltipTheme.plainDismissDelay] for plain tooltips
  /// and [MorphTooltipTheme.richDismissDelay] for rich tooltips.
  final Duration? dismissDelay;

  /// Forma particular de este tooltip; tiene prioridad sobre [MorphTooltipTheme].
  final ShapeBorder? shape;

  /// Optional programmatic show/hide.
  final MorphTooltipController? controller;

  bool get _isRich => richMessage != null;

  @override
  State<MorphTooltip> createState() => _MorphTooltipState();
}

class _MorphTooltipState extends State<MorphTooltip>
    implements MorphTooltipControllerClient {
  final GlobalKey _targetKey = GlobalKey();
  final OverlayPortalController _portal = OverlayPortalController();
  Timer? _timer;
  bool _showing = false;

  bool get _isRich => widget._isRich;
  bool get _isPersistent => widget.persistent && _isRich;
  bool get _isTransient => !_isPersistent;

  @override
  void initState() {
    super.initState();
    widget.controller?.attachClient(this);
  }

  @override
  void didUpdateWidget(MorphTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachClient(this);
      widget.controller?.attachClient(this);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _openTooltips.remove(this);
    widget.controller?.detachClient(this);
    super.dispose();
  }

  @override
  void onShowRequested() => _show();

  @override
  void onHideRequested() => _hide();

  void _show() {
    if (!mounted) {
      return;
    }
    _timer?.cancel();
    for (final other in List<_MorphTooltipState>.of(_openTooltips)) {
      if (!identical(other, this)) {
        other._hide();
      }
    }
    _openTooltips.add(this);
    if (!_portal.isShowing) {
      _portal.show();
    }
    if (!_showing) {
      _showing = true;
      widget.controller?.updateShowing(showing: true);
    }
  }

  void _hide() {
    _timer?.cancel();
    _openTooltips.remove(this);
    if (_portal.isShowing) {
      _portal.hide();
    }
    if (_showing) {
      _showing = false;
      widget.controller?.updateShowing(showing: false);
    }
  }

  void _scheduleHide() {
    if (!mounted || _isPersistent) {
      return;
    }
    final tooltipTheme = MorphTheme.of(context).tooltipTheme;
    final Duration delay =
        widget.dismissDelay ??
        (_isRich
            ? tooltipTheme.richDismissDelay
            : tooltipTheme.plainDismissDelay);
    _timer?.cancel();
    if (delay == Duration.zero) {
      _hide();
      return;
    }
    _timer = Timer(delay, () {
      if (mounted) {
        _hide();
      }
    });
  }

  void _cancelHide() {
    _timer?.cancel();
  }

  void _onChildFocusChange(bool focused) {
    if (!_isTransient) {
      return;
    }
    if (focused) {
      // Touch/tap focuses the child but must not open the tooltip; only
      // keyboard-driven focus (traditional highlight) should.
      if (FocusManager.instance.highlightMode ==
          FocusHighlightMode.traditional) {
        _show();
      }
    } else {
      _scheduleHide();
    }
  }

  MorphTooltipPlacement _resolvedPlacement() {
    if (widget.preferredPlacement != null) {
      return widget.preferredPlacement!;
    }
    return _isRich ? MorphTooltipPlacement.bottomEnd : MorphTooltipPlacement.above;
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (BuildContext context) {
        Widget target = KeyedSubtree(key: _targetKey, child: widget.child);
        if (_isTransient) {
          // Listen for descendant focus without adding a Tab stop. Using
          // FocusableActionDetector would insert an extra focusable node.
          target = Focus(
            canRequestFocus: false,
            skipTraversal: true,
            includeSemantics: false,
            onFocusChange: _onChildFocusChange,
            child: MouseRegion(
              onEnter: (_) => _show(),
              onExit: (_) => _scheduleHide(),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: _show,
                onLongPressEnd: (_) => _scheduleHide(),
                child: target,
              ),
            ),
          );
        } else {
          target = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _show,
            child: target,
          );
        }
        return OverlayPortal(
          controller: _portal,
          overlayChildBuilder: _buildOverlay,
          child: target,
        );
      },
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = MorphTheme.of(context);
    final tooltipTheme = theme.tooltipTheme;
    final targetBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    final OverlayState? overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;

    // Plain bubbles must not hit-test. Covering the icon steals the pointer
    // cursor, the button exits, and the tooltip hides and shows in a loop.
    final Widget bubble = _isRich
        ? MouseRegion(
            onEnter: (_) => _cancelHide(),
            onExit: (_) {
              if (_isTransient) {
                _scheduleHide();
              }
            },
            child: _buildRich(theme, tooltipTheme),
          )
        : IgnorePointer(child: _buildPlain());

    if (targetBox == null ||
        overlayBox == null ||
        !targetBox.hasSize ||
        !overlayBox.hasSize) {
      return const SizedBox.shrink();
    }

    final Offset targetOrigin = targetBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final Rect targetRect = targetOrigin & targetBox.size;

    return Stack(
      children: <Widget>[
        if (_isRich || _isPersistent)
          Positioned.fill(
            child: GestureDetector(
              onTap: _hide,
              behavior: HitTestBehavior.translucent,
            ),
          ),
        CustomSingleChildLayout(
          delegate: MorphTooltipPositionDelegate(
            target: targetRect,
            preferred: _resolvedPlacement(),
            gap: tooltipTheme.anchorOffset,
            step: tooltipTheme.placementStep,
            overlaySize: overlayBox.size,
            textDirection: Directionality.of(context),
          ),
          child: bubble,
        ),
      ],
    );
  }

  Widget _buildPlain() {
    final message = widget.message!;
    return _fade(Semantics(
      container: true,
      tooltip: message,
      child: MorphTooltipPlainSurface(message: message, shape: widget.shape),
    ));
  }

  Widget _buildRich(MorphThemeData theme, MorphTooltipTheme tooltipTheme) {
    final scheme = theme.colorScheme;
    final String body = widget.richMessage!;
    final String label = <String>[
      if (widget.richTitle != null) widget.richTitle!,
      body,
    ].join('. ');
    return _fade(
      Semantics(
        container: true,
        tooltip: label,
        child: Container(
          constraints: BoxConstraints(maxWidth: tooltipTheme.richMaxWidth),
          padding: tooltipTheme.richPadding,
          decoration: ShapeDecoration(
            color: tooltipTheme.richContainerColor(scheme),
            shape: widget.shape ?? tooltipTheme.richShape,
            shadows: MorphElevation.shadows(
              tooltipTheme.richElevation,
              shadowColor: scheme.shadow,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.richTitle != null) ...<Widget>[
                Text(
                  widget.richTitle!,
                  style: tooltipTheme.richTitleStyle(theme.typeScale, scheme),
                ),
                SizedBox(height: tooltipTheme.richTitleGap),
              ],
              Text(
                body,
                style: tooltipTheme.richBodyStyle(theme.typeScale, scheme),
              ),
              if (widget.actions.isNotEmpty) ...<Widget>[
                SizedBox(height: tooltipTheme.richActionsGap),
                Row(children: widget.actions),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _fade(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: MorphMotion.short3,
      curve: MorphMotion.standard,
      builder: (BuildContext context, double value, Widget? built) {
        return Opacity(opacity: value, child: built);
      },
      child: child,
    );
  }
}
