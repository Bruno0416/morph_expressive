import 'dart:math' as math;

/// How the reactive group derives resting widths from the parent constraints.
enum MorphReactiveGroupFit {
  /// Bounded width: the group spans it, slack shared in proportion to natural
  /// content widths. Expansion moves width between siblings (total constant).
  /// Unbounded width: natural widths; the pressed/active item simply grows.
  fill,

  /// Natural content widths (the group hugs its content). Expansion is taken
  /// only from slack left by the parent; siblings do not shrink.
  natural,

  /// Equal widths: the parent width split evenly when bounded, otherwise the
  /// widest natural width. Expansion moves width between siblings.
  uniform,
}

/// Pure width resolver shared by the render object and the tests.
///
/// All lists have one entry per item. [natural] already includes content,
/// padding, icons and per-item minimums. [fixed] entries are explicit widths
/// that never take part in the distribution. [expansion] holds the *current*
/// (possibly animating) growth ratio of each item (0 = resting, 0.2 = wants
/// 20 % more than its resting width); [maxExpansion] normalises donor
/// capacity. [available] may be infinite.
///
/// Guarantees: no negative width; flexible items are never reduced below
/// their natural width unless the parent cannot even hold the natural widths
/// (then everything is compressed proportionally and expansion is 0); the
/// total never exceeds a finite [available]; the result is deterministic.
List<double> resolveReactiveWidths({
  required List<double> natural,
  required List<double?> fixed,
  required List<double> expansion,
  required double maxExpansion,
  required double available,
  required double gap,
  required MorphReactiveGroupFit fit,
}) {
  final n = natural.length;
  if (n == 0) return const [];
  final out = List<double>.filled(n, 0);
  final flex = <int>[];
  var fixedTotal = 0.0;
  for (var i = 0; i < n; i++) {
    final f = fixed[i];
    if (f != null) {
      out[i] = math.max(0.0, f);
      fixedTotal += out[i];
    } else {
      flex.add(i);
    }
  }
  if (flex.isEmpty) return out;
  final finite = available.isFinite;
  final room = finite
      ? math.max(0.0, available - gap * (n - 1) - fixedTotal)
      : double.infinity;
  final floors = {for (final i in flex) i: math.max(0.0, natural[i])};
  final sumNat = floors.values.fold<double>(0, (a, b) => a + b);

  // Parent too small for the natural widths: compress, no expansion.
  if (finite && room < sumNat) {
    final k = sumNat == 0 ? 0.0 : room / sumNat;
    for (final i in flex) {
      out[i] = floors[i]! * k;
    }
    return out;
  }

  final base = <int, double>{};
  switch (fit) {
    case MorphReactiveGroupFit.fill when finite:
      final slack = room - sumNat;
      for (final i in flex) {
        base[i] = sumNat == 0
            ? room / flex.length
            : floors[i]! + slack * floors[i]! / sumNat;
      }
    case MorphReactiveGroupFit.uniform:
      final widest = floors.values.fold<double>(0, math.max);
      final w = finite ? room / flex.length : widest;
      for (final i in flex) {
        base[i] = w;
      }
    default:
      for (final i in flex) {
        base[i] = floors[i]!;
      }
  }

  final request = <int, double>{};
  var demand = 0.0;
  for (final i in flex) {
    final r = base[i]! * math.max(0.0, expansion[i]);
    request[i] = r;
    demand += r;
  }
  if (demand <= 0) {
    for (final i in flex) {
      out[i] = base[i]!;
    }
    return out;
  }

  final redistributes = finite && (fit != MorphReactiveGroupFit.natural);
  if (redistributes) {
    // Local compensation: every demanding item draws only from its adjacent
    // neighbours (split evenly; an end item draws from its single neighbour).
    // A neighbour without enough slack simply gives less: the unmet share is
    // NOT re-routed to the other side, since that made a saturating donor
    // kink the motion and ripple into far (selected) items. Donors give only the part above their natural floor,
    // scaled by how little they ask for themselves. Far items are untouched.
    final cap = List<double>.filled(n, 0);
    final req = List<double>.filled(n, 0);
    for (final i in flex) {
      final asking = maxExpansion <= 0
          ? 0.0
          : (expansion[i] / maxExpansion).clamp(0.0, 1.0);
      cap[i] = math.max(0.0, base[i]! - floors[i]!) * (1 - asking);
      req[i] = request[i]!;
    }
    // Even split, then scale each donor to its capacity.
    final want = List<List<double>>.generate(n, (_) => [0.0, 0.0]); // [L, R]
    final load = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      if (req[i] <= 0) continue;
      final hasL = i > 0, hasR = i < n - 1;
      final l = hasL && hasR ? req[i] / 2 : (hasL ? req[i] : 0.0);
      final r = hasL && hasR ? req[i] / 2 : (hasR ? req[i] : 0.0);
      want[i] = [l, r];
      if (hasL) load[i - 1] += l;
      if (hasR) load[i + 1] += r;
    }
    // Smooth (C-infinity) soft-min of load and capacity: a hard min() puts a
    // slope kink in the motion exactly when a donor starts to saturate.
    double soft(double load, double c) {
      if (load <= 0) return 1.0;
      if (c <= 0) return 0.0;
      final l2 = load * load, c2 = c * c;
      return c / math.sqrt(math.sqrt(l2 * l2 + c2 * c2));
    }

    final scale = [for (var j = 0; j < n; j++) soft(load[j], cap[j])];
    final left = List<double>.of(cap); // remaining donor capacity
    final gain = List<double>.filled(n, 0);
    final loss = List<double>.filled(n, 0);
    final unmet = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      if (req[i] <= 0) continue;
      var got = 0.0;
      if (i > 0) {
        final d = want[i][0] * scale[i - 1];
        loss[i - 1] += d;
        left[i - 1] -= d;
        got += d;
      }
      if (i < n - 1) {
        final d = want[i][1] * scale[i + 1];
        loss[i + 1] += d;
        left[i + 1] -= d;
        got += d;
      }
      gain[i] = got;
      unmet[i] = req[i] - got;
    }
    for (final i in flex) {
      out[i] = base[i]! + gain[i] - loss[i];
    }
  } else {
    // Natural / unbounded: grow into the slack the parent leaves.
    final slack = finite ? math.max(0.0, room - sumNat) : double.infinity;
    final k = math.min(1.0, slack / demand);
    for (final i in flex) {
      out[i] = base[i]! + k * request[i]!;
    }
  }
  return out;
}
