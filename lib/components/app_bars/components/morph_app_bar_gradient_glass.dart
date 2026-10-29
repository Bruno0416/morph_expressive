part of '../morph_app_bars.dart';

/// Gradient tint over fixed-cost clipped backdrop filters.
///
/// A short clear bottom edge is followed by increasingly tall blur strips.
/// The first filter above that edge has a nearly-zero sigma, avoiding a hard
/// jump from the completely sharp bottom to an entire full-height strip.
/// There are no animations or scroll listeners on this layer.
class _MorphAppBarGradientGlass extends StatelessWidget {
  const _MorphAppBarGradientGlass({required this.config, required this.color});

  final MorphAppBarGlass config;
  final Color color;

  // Keep the 50% midpoint on an exact stop while interpolating the
  // exponential upper half without visible color banding.
  static final List<double> _tintStops = List<double>.generate(
    65,
    (index) => index / 64,
    growable: false,
  );

  double _tintOpacityForPosition(double position) {
    final progress = (1 - position).clamp(0.0, 1.0);
    // The bottom half is strictly linear; the upper half accelerates
    // exponentially. Resolve the midpoint from the rate so the slopes match
    // exactly at 50%, rather than leaving a visible kink in the gradient.
    final rate = math.min(8.0, 1.2 + config.tintCurvePower);
    final growth = math.exp(rate) - 1;
    final midpoint = rate / (growth + rate);
    if (progress <= 0.5) {
      return config.topOpacity * (2 * midpoint * progress);
    }
    final upperProgress = (progress - 0.5) * 2;
    final upperGrowth = (math.exp(rate * upperProgress) - 1) / growth;
    return config.topOpacity * (midpoint + (1 - midpoint) * upperGrowth);
  }

  ImageFilter _filterForBand(int index) {
    final count = config.blurBands - 1;
    final fromBottom = count - 1 - index;
    // Sample the middle of each band to keep the first blur just above the
    // clear edge almost imperceptible. The highest band uses the full sigma.
    final progress = fromBottom == count - 1 ? 1.0 : (fromBottom + 0.5) / count;
    final sigma =
        config.maxBlurSigma *
        math.pow(progress, config.blurCurvePower).toDouble();
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }

  // A quadratic spacing curve concentrates the weakest, narrowest filters
  // immediately above the clear edge without increasing the filter count.
  double _bandTop(int bandsFromBottom, double filteredHeight) {
    final progress = bandsFromBottom / (config.blurBands - 1);
    return filteredHeight * (1 - progress * progress);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.maxHeight;
      if (!height.isFinite || height <= 0) {
        return const SizedBox.shrink();
      }
      final filterCount = config.blurBands - 1;
      final filteredHeight = math.max(0.0, height - config.blurClearExtent);
      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (config.maxBlurSigma > 0 && filteredHeight > 0)
              for (var i = 0; i < filterCount; i++)
                // Quadratic band boundaries: the strips nearest the clear
                // edge are only a few pixels tall. Higher, stronger strips
                // occupy more space where the surface tint masks transitions.
                Positioned(
                  top: _bandTop(filterCount - i, filteredHeight),
                  left: 0,
                  right: 0,
                  height:
                      _bandTop(filterCount - i - 1, filteredHeight) -
                      _bandTop(filterCount - i, filteredHeight),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: _filterForBand(i),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      for (final position in _tintStops)
                        color.withValues(
                          alpha: _tintOpacityForPosition(position),
                        ),
                    ],
                    stops: _tintStops,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
