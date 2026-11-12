import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import '../loading_indicator/morph_loading_indicator.dart';
import 'morph_buttons.dart';
import 'morph_operation_state.dart';
import 'components/morph_operation_glyph.dart';
import 'components/morph_operation_surface.dart';
export 'components/morph_operation_glyph.dart'
    show MorphOperationIconTransition;
export 'morph_operation_state.dart';
export 'styles/morph_async_button_theme.dart';

/// A controlled operation presentation around one persistent [MorphButton].
/// Tight parent constraints and decoration sizes take precedence over compact
/// width. Labels may ellipsize, never scale. Busy is separate from disabled.
class MorphAsyncButton extends StatelessWidget {
  const MorphAsyncButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.state = MorphOperationState.idle,
    this.presentation = MorphOperationPresentation.preserveWidth,
    this.style = MorphButtonStyle.filled,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.enabled = true,
    this.blockWhileLoading = true,
    this.showLoadingLabel = true,
    this.labels = const {},
    this.icon,
    this.successIcon,
    this.errorIcon,
    this.loading,
    this.decoration,
    this.stateDecorations = const {},
    this.transitionDuration,
    this.iconTransition,
    this.constraints,
    this.focusNode,
    this.tooltip,
    this.semanticLabel,
    this.semanticValue,
    this.renderer = MorphShapeRenderer.auto,
    this.onRendererChanged,
  });
  final String label;
  final VoidCallback? onPressed;
  final MorphOperationState state;
  final MorphOperationPresentation presentation;
  final MorphButtonStyle style;
  final MorphButtonSize size;
  final MorphButtonShape shape;
  final bool enabled, blockWhileLoading, showLoadingLabel;
  final Map<MorphOperationState, String> labels;
  final Widget? icon, successIcon, errorIcon, loading;
  final MorphButtonDecoration? decoration;
  final Map<MorphOperationState, MorphButtonDecoration> stateDecorations;
  final Duration? transitionDuration;

  /// Glyph entry for loader/success/error. Null → theme. `.none` disables it.
  final MorphOperationIconTransition? iconTransition;
  final BoxConstraints? constraints;
  final FocusNode? focusNode;
  final String? tooltip, semanticLabel, semanticValue;
  final MorphShapeRenderer renderer;
  final ValueChanged<MorphShapeRenderStatus>? onRendererChanged;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final buttonTheme = theme.buttonTheme;
    final operationTheme = theme.asyncButtonTheme;
    final reduced = MorphMotion.reduceMotionOf(context);
    final busy = state == MorphOperationState.loading;
    final active = enabled && onPressed != null;
    final blocked = busy && blockWhileLoading;
    final m = buttonTheme.measurements(size);
    final type = theme.typeScale;
    final baseText = switch (size.name) {
      'xs' => type.labelSmall,
      'sm' => type.labelMedium,
      'lg' => type.titleMedium,
      'xl' => type.titleLarge,
      _ => type.labelLarge,
    };
    final scoped = MorphButtonDecorationScope.maybeOf(context, style);
    final base = (scoped ?? const MorphButtonDecoration()).merge(decoration);
    // Error defaults sit above scope/local decorations (so the state cannot be
    // confused with idle) but below theme/stateDecorations for `error`.
    final errorDefaults = state == MorphOperationState.error && active
        ? _errorDecoration(theme.colorScheme, style, m.outlineWidth)
        : null;
    final dec = base
        .merge(errorDefaults)
        .merge(operationTheme.decorations[state])
        .merge(stateDecorations[state]);
    if (dec.backgroundBuilder != null && onRendererChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          onRendererChanged!(
            const MorphShapeRenderStatus(
              MorphShapeRenderer.canvas,
              'Custom backgroundBuilder owns rendering',
            ),
          );
        }
      });
    }
    final states = <WidgetState>{if (!active) WidgetState.disabled};
    final bg =
        dec.backgroundColor?.resolve(states) ??
        (!active
            ? theme.colorScheme.onSurface.withValues(alpha: .12)
            : style == MorphButtonStyle.outlined ||
                  style == MorphButtonStyle.text
            ? const Color(0x00000000)
            : buttonTheme.container(theme.colorScheme, style));
    final fg =
        dec.foregroundColor?.resolve(states) ??
        (!active
            ? theme.colorScheme.onSurface.withValues(alpha: .38)
            : buttonTheme.foreground(theme.colorScheme, style));
    final textStyle = baseText.merge(dec.textStyle);
    final painter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final padding =
        (dec.padding ?? EdgeInsets.symmetric(horizontal: m.hPadding)).resolve(
          Directionality.of(context),
        );
    // Preserved width = idle content, but never narrower than glyph + gap +
    // the (idle-width capped) label of a state that shows both; otherwise the
    // status glyph squeezes the label to nothing and clips it in small buttons.
    var naturalWidth = math.max(
      48.0,
      painter.width +
          padding.horizontal +
          (icon == null ? 0 : m.iconSize + m.iconGap),
    );
    for (final s in MorphOperationState.values) {
      if (s == MorphOperationState.idle) continue;
      if (s == MorphOperationState.loading && !showLoadingLabel) continue;
      final text = labels[s] ?? label;
      final p = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      naturalWidth = math.max(
        naturalWidth,
        math.min(p.width, painter.width) +
            padding.horizontal +
            m.iconSize +
            m.iconGap,
      );
      p.dispose();
    }
    painter.dispose();
    final height = math.max(
      48.0,
      math.max(
        m.height,
        MediaQuery.textScalerOf(context).scale(textStyle.fontSize ?? 14) + 16,
      ),
    );
    final compact = busy && presentation == MorphOperationPresentation.compact;
    final duration = reduced
        ? Duration.zero
        : transitionDuration ?? operationTheme.transitionDuration;
    assert(!duration.isNegative);
    final glyphTransition = reduced
        ? MorphOperationIconTransition.none
        : iconTransition ?? operationTheme.iconTransition;
    Widget result = LayoutBuilder(
      builder: (context, parent) {
        final limits = constraints == null
            ? parent
            : constraints!.enforce(parent);
        final decoratedLimits = BoxConstraints(
          minWidth: dec.minimumSize?.width ?? 0,
          maxWidth: dec.maximumSize?.width ?? double.infinity,
        ).enforce(limits);
        final targetWidth = decoratedLimits.constrainWidth(
          dec.fixedSize?.width ??
              size.width ??
              (compact ? height : naturalWidth),
        );
        final radius = compact
            ? height / 2
            : dec.borderRadius ??
                  (shape == MorphButtonShape.round
                      ? height / 2
                      : buttonTheme.squareRadius(size));
        return TweenAnimationBuilder<_OperationVisual>(
          tween: _OperationTween(
            end: _OperationVisual(targetWidth, radius, bg, fg),
          ),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, visual, _) {
            final labelText = labels[state] ?? label;
            final glyph = switch (state) {
              MorphOperationState.idle => icon,
              MorphOperationState.loading =>
                loading ??
                    SizedBox.square(
                      dimension: m.iconSize,
                      child: TickerMode(
                        enabled: active,
                        child: MorphLoadingIndicator(color: visual.foreground),
                      ),
                    ),
              MorphOperationState.success =>
                successIcon ?? Icon(MorphIcons.check_rounded, size: m.iconSize),
              MorphOperationState.error =>
                errorIcon ?? Icon(MorphIcons.error, size: m.iconSize),
            };
            final hasGlyph = glyph != null;
            final showLabel = !busy || (showLoadingLabel && !compact);
            final content = Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasGlyph)
                  ExcludeSemantics(
                    child: MorphOperationGlyphSlot(
                      state: state,
                      glyph: glyph,
                      dimension: m.iconSize,
                      transition: glyphTransition,
                    ),
                  ),
                if (hasGlyph && showLabel) SizedBox(width: m.iconGap),
                if (showLabel)
                  Flexible(
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(state),
                      tween: Tween(begin: .65, end: 1),
                      duration: duration,
                      builder: (context, opacity, child) =>
                          Opacity(opacity: opacity, child: child),
                      child: Text(
                        labelText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            );
            return SizedBox(
              width: visual.width,
              height: dec.fixedSize?.height ?? height,
              child: Semantics(
                button: true,
                enabled: active,
                liveRegion: true,
                onTap: active && !blocked
                    ? () {
                        MorphHaptics.triggerFor(
                          context,
                          dec.haptic ?? MorphHapticFeedback.inherit,
                        );
                        onPressed?.call();
                      }
                    : null,
                label: semanticLabel ?? labelText,
                value: semanticValue ?? state.name,
                child: ExcludeSemantics(
                  child: MorphOperationSurface(
                    renderer: renderer,
                    onRendererChanged: onRendererChanged,
                    child: MorphButton(
                      onPressed: !active
                          ? null
                          : () {
                              if (!(state == MorphOperationState.loading &&
                                  blockWhileLoading)) {
                                onPressed?.call();
                              }
                            },
                      enabled: active,
                      enableFeedback: !blocked,
                      style: style,
                      size: size,
                      shape: shape,
                      focusNode: focusNode,
                      tooltip: tooltip,
                      decoration: dec.copyWith(
                        fixedSize: Size(
                          visual.width,
                          dec.fixedSize?.height ?? height,
                        ),
                        minimumSize: Size(0, height),
                        // Leaving compact: padding grows with the width so the content row
                        // never overflows while the surface is still narrow.
                        padding: compact
                            ? EdgeInsets.zero
                            : presentation == MorphOperationPresentation.compact
                            ? padding *
                                  ((visual.width - height) /
                                          math.max(1.0, naturalWidth - height))
                                      .clamp(0.0, 1.0)
                            : padding,
                        borderRadius: visual.radius,
                        backgroundColor: WidgetStatePropertyAll(
                          visual.background,
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          visual.foreground,
                        ),
                        animationDuration: Duration.zero,
                      ),
                      child: content,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    return result;
  }
}

/// Semantic error colors per style. Elevated keeps its raised surface (tinted)
/// and takes error content; outlined keeps its transparent surface.
MorphButtonDecoration _errorDecoration(
  MorphColorScheme c,
  MorphButtonStyle style,
  double outlineWidth,
) {
  Color bg, fg;
  switch (style) {
    case MorphButtonStyle.filled:
      bg = c.error;
      fg = c.onError;
    case MorphButtonStyle.tonal:
      bg = c.errorContainer;
      fg = c.onErrorContainer;
    case MorphButtonStyle.elevated:
      bg = Color.alphaBlend(
        c.error.withValues(alpha: .08),
        c.surfaceContainerLow,
      );
      fg = c.error;
    case MorphButtonStyle.outlined:
      bg = const Color(0x00000000);
      fg = c.error;
    case MorphButtonStyle.text:
      bg = const Color(0x00000000);
      fg = c.error;
  }
  return MorphButtonDecoration(
    backgroundColor: WidgetStatePropertyAll(bg),
    foregroundColor: WidgetStatePropertyAll(fg),
    side: style == MorphButtonStyle.outlined
        ? WidgetStatePropertyAll(
            BorderSide(color: c.error, width: outlineWidth),
          )
        : null,
  );
}

class _OperationVisual {
  const _OperationVisual(
    this.width,
    this.radius,
    this.background,
    this.foreground,
  );
  final double width, radius;
  final Color background, foreground;
}

class _OperationTween extends Tween<_OperationVisual> {
  _OperationTween({required super.end});
  @override
  _OperationVisual lerp(double t) => _OperationVisual(
    lerpDouble(begin!.width, end!.width, t)!,
    lerpDouble(begin!.radius, end!.radius, t)!,
    Color.lerp(begin!.background, end!.background, t)!,
    Color.lerp(begin!.foreground, end!.foreground, t)!,
  );
}
