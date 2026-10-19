import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

/// Tokens de movimiento de Morph Expressive con curvas y resortes propios.
///
/// Los valores de spring se centralizan aqui. Los widgets pueden sobrescribirlos
/// desde sus propios temas sin depender de curvas originales de MD3E.
abstract final class MorphMotion {
  const MorphMotion._();

  /// 50ms duration token.
  static const Duration short1 = Duration(milliseconds: 50);

  /// 100ms duration token.
  static const Duration short2 = Duration(milliseconds: 100);

  /// 150ms duration token.
  static const Duration short3 = Duration(milliseconds: 150);

  /// 200ms duration token.
  static const Duration short4 = Duration(milliseconds: 200);

  /// 250ms duration token.
  static const Duration medium1 = Duration(milliseconds: 250);

  /// 300ms duration token.
  static const Duration medium2 = Duration(milliseconds: 300);

  /// 350ms duration token.
  static const Duration medium3 = Duration(milliseconds: 350);

  /// 400ms duration token.
  static const Duration medium4 = Duration(milliseconds: 400);

  /// 450ms duration token.
  static const Duration long1 = Duration(milliseconds: 450);

  /// 500ms duration token.
  static const Duration long2 = Duration(milliseconds: 500);

  /// 550ms duration token.
  static const Duration long3 = Duration(milliseconds: 550);

  /// 600ms duration token.
  static const Duration long4 = Duration(milliseconds: 600);

  /// 700ms duration token.
  static const Duration extraLong1 = Duration(milliseconds: 700);

  /// 800ms duration token.
  static const Duration extraLong2 = Duration(milliseconds: 800);

  /// 900ms duration token.
  static const Duration extraLong3 = Duration(milliseconds: 900);

  /// 1000ms duration token.
  static const Duration extraLong4 = Duration(milliseconds: 1000);

  // ---------- curvas seguras para efectos y movimiento ----------

  /// Entrada suave sin overshoot; apta para opacidad, scrims y colores.
  static const Curve enter = Cubic(0.12, 0.75, 0.12, 1.0);

  /// Salida acelerada sin overshoot; apta para opacidad y scrims.
  static const Curve exit = Cubic(0.62, 0.0, 0.96, 0.25);

  /// Movimiento espacial expresivo con un overshoot controlado.
  /// No usar para opacidades ni valores que deban mantenerse en [0, 1].
  static const Curve spatial = subtleOvershoot;

  /// Curva fluida de Morph Expressive, sin overshoot para opacidad y colores.
  static const Curve standard = Cubic(0.72, 0.0, 0.17, 1.0);

  /// Curva espacial con overshoot moderado para escala y posicion.
  static const Curve subtleOvershoot = Cubic(0.18, 0.0, 0.20, 1.085);

  /// Chip motion only: 15% faster than the previous 340ms default.
  static const Duration chipDuration = Duration(milliseconds: 289);

  /// Chip trailing-edge dwell, scaled with the faster motion.
  static const Duration chipStretchDelay = Duration(milliseconds: 77);

  /// Composable position/size tween for a spatial (overshooting) motion.
  /// Use on geometry, never on alpha or color channels.
  static Animatable<double> spatialTween({
    required double begin,
    required double end,
  }) => Tween<double>(begin: begin, end: end).chain(CurveTween(curve: spatial));

  /// Composable, bounded effect tween for opacity and other [0, 1] values.
  static Animatable<double> effectsTween({
    required double begin,
    required double end,
  }) =>
      Tween<double>(begin: begin, end: end).chain(CurveTween(curve: standard));

  /// Choreographed two-stage edge movement: hold, then follow the leading
  /// edge. Each stage is a tween rather than an independently timed Timer.
  static Animatable<double> staggeredTween({
    required double begin,
    required double end,
    required double delayFraction,
  }) {
    final delay = delayFraction.clamp(0.0, 0.85).toDouble();
    if (delay <= 0) return spatialTween(begin: begin, end: end);
    return TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(begin),
        weight: delay,
      ),
      TweenSequenceItem<double>(
        tween: spatialTween(begin: begin, end: end),
        weight: 1 - delay,
      ),
    ]);
  }

  /// Duracion base de los controles de seleccion de Morph Expressive.
  static const Duration selectionDuration = Duration(milliseconds: 340);

  /// Duracion de cambio de estado para listas y controles de seleccion.
  static const Duration selectionFlip = Duration(milliseconds: 220);

  /// Duracion de salida corta para una seleccion.
  static const Duration selectionExit = Duration(milliseconds: 90);

  /// Duracion del pulso de un carrusel.
  static const Duration carouselPulse = Duration(milliseconds: 180);

  /// Duracion del retroceso de un carrusel.
  static const Duration carouselReturn = Duration(milliseconds: 220);

  /// Retardo para el movimiento secuencial de indicadores.
  static const Duration selectionStretchDelay = Duration(milliseconds: 90);

  // ---------- adaptador unico para motor ----------

  /// Convierte un resorte Morph a motor sin usar presets MaterialSpringMotion.
  /// Cada widget puede mantener su propio MorphSpring desde el tema.
  static SpringMotion springMotion(MorphSpring spring) =>
      SpringMotion(spring.toDescription());

  /// Resorte corto de entrada/salida para dialogos sin retardo visible.
  static const MorphSpring dialogSpatial = MorphSpring(
    stiffness: 1800,
    damping: 0.98,
  );

  /// Efectos de dialogo acotados y mas rapidos que el movimiento espacial.
  static const MorphSpring dialogEffects = MorphSpring(
    stiffness: 2100,
    damping: 1,
  );

  /// Apertura progresiva con elasticidad tenue para el panel desplegable.
  static const MorphSpring dropdownOpen = MorphSpring(
    stiffness: 650,
    damping: 0.94,
  );

  /// Cierre perceptible y estable, sin rebote residual.
  static const MorphSpring dropdownClose = MorphSpring(
    stiffness: 420,
    damping: 1,
  );

  /// Redondeo y desplazamiento de seleccion en grupos conectados.
  /// Mantiene un desplazamiento tranquilo sin rebotes bruscos.
  static const MorphSpring connectedSelection = MorphSpring(
    stiffness: 350,
    damping: 0.89,
  );

  /// Pildora de navegacion: movimiento estable, sin expansion instantanea.
  static const MorphSpring navigationSelection = MorphSpring(
    stiffness: 320,
    damping: 0.92,
  );

  /// Transicion cromatica de la pildora, algo mas breve que la espacial.
  static const MorphSpring navigationEffects = MorphSpring(
    stiffness: 480,
    damping: 1,
  );

  /// Morph de botones con overshoot ligeramente mas expresivo.
  static const MorphSpring buttonMorph = MorphSpring(
    stiffness: 1150,
    damping: 0.82,
  );

  /// Standard accelerate easing curve.
  static const Curve standardAccelerate = Cubic(0.45, 0.0, 0.92, 0.22);

  /// Standard decelerate easing curve.
  static const Curve standardDecelerate = Cubic(0.08, 0.74, 0.1, 1);

  /// Emphasized easing curve.
  static const Curve emphasized = Cubic(0.22, 0, 0.06, 1);

  /// Emphasized accelerate easing curve.
  static const Curve emphasizedAccelerate = Cubic(0.44, 0, 0.84, 0.16);

  /// Emphasized decelerate easing curve.
  static const Curve emphasizedDecelerate = Cubic(0.045, 0.82, 0.09, 1);

  /// Linear easing curve.
  static const Curve linear = Cubic(0, 0, 1, 1);

  /// Fast spatial spring for size, position, and shape morphs.
  static const MorphSpring spatialFast = MorphSpring(
    stiffness: 1400,
    damping: 0.86,
  );

  /// Default spatial spring for size, position, and shape morphs.
  static const MorphSpring spatialDefault = MorphSpring(
    stiffness: 700,
    damping: 0.86,
  );

  /// Slow spatial spring for size, position, and shape morphs.
  static const MorphSpring spatialSlow = MorphSpring(
    stiffness: 300,
    damping: 0.91,
  );

  /// AOSP spatial spring (stiffness: 380, damping: 1.0).
  ///
  /// Matches AOSP notification-list expansion — no overshoot.
  static const MorphSpring aospSpatial = MorphSpring(
    stiffness: 380,
    damping: 1,
  );

  /// Fast expressive spatial spring with slight overshoot.
  static const MorphSpring expressiveSpatialFast = MorphSpring(
    stiffness: 1150,
    damping: 0.82,
  );

  /// Default expressive spatial spring with slight overshoot.
  static const MorphSpring expressiveSpatialDefault = MorphSpring(
    stiffness: 720,
    damping: 0.84,
  );

  /// Interactive press scale — same recipe as floating toolbar / button morph.
  static const MorphSpring expressiveSpatialPress = MorphSpring(
    stiffness: 1050,
    damping: 0.81,
  );

  /// Slow expressive spatial spring with slight overshoot.
  static const MorphSpring expressiveSpatialSlow = MorphSpring(
    stiffness: 300,
    damping: 0.94,
  );

  /// Fast effects spring for color and opacity (no overshoot).
  static const MorphSpring effectsFast = MorphSpring(
    stiffness: 3800,
    damping: 1,
  );

  /// Default effects spring for color and opacity (no overshoot).
  static const MorphSpring effectsDefault = MorphSpring(
    stiffness: 1600,
    damping: 1,
  );

  /// Slow effects spring for color and opacity (no overshoot).
  static const MorphSpring effectsSlow = MorphSpring(
    stiffness: 800,
    damping: 1,
  );
}

/// A serialisable description of a Material 3 Expressive spring.
///
/// [damping] is expressed as a damping ratio where `1.0` is critically damped
/// (no overshoot) and values below `1.0` produce an expressive overshoot.
@immutable
class MorphSpring {
  /// Creates a spring with [stiffness] and [damping] ratio.
  const MorphSpring({required this.stiffness, required this.damping});

  /// Spring stiffness. Higher values settle faster.
  final double stiffness;

  /// Damping ratio. `1.0` is critically damped; lower values overshoot.
  final double damping;

  /// Builds a [SpringDescription] for a unit mass.
  SpringDescription toDescription() {
    return SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: stiffness,
      ratio: damping,
    );
  }

  @override
  /// Equality based on public fields.
  bool operator ==(Object other) {
    return other is MorphSpring &&
        other.stiffness == stiffness &&
        other.damping == damping;
  }

  @override
  /// Hash code for this spring.
  int get hashCode => Object.hash(stiffness, damping);
}
