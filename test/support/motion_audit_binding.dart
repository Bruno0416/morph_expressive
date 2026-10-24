import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'motion_component_owners.dart';

const motionAuditProfile = String.fromEnvironment(
  'MORPH_MOTION_AUDIT_PROFILE',
  defaultValue: 'system',
);

void installMotionAuditBinding() {
  if (motionAuditProfile == 'system') return;
  if (!const {'full', 'reduced', 'reduce-only'}.contains(motionAuditProfile)) {
    throw ArgumentError('Unknown motion audit profile: $motionAuditProfile');
  }
  MotionAuditBinding();
}

/// Measures observable animations without touching production widgets.
///
/// Samples only frames the test already requested. It never schedules a frame,
/// changes timeDilation, or turns off TickerMode. Merged/private listenables and
/// transitions entirely between two pumps can escape observation; no observation
/// therefore means "not observed", never "compliant".
class MotionAuditBinding extends AutomatedTestWidgetsFlutterBinding {
  MotionAuditBinding() {
    addPersistentFrameCallback((_) => _sample());
  }

  String? _description;
  int _frames = 0;
  final Map<String, Set<String>> _mounted = {};
  final Map<Animation<Object?>, _AnimationObservation> _observations =
      HashMap.identity();

  @override
  Future<void> runTest(
    Future<void> Function() testBody,
    VoidCallback invariantTester, {
    String description = '',
  }) => super.runTest(
    () async {
      _description = description;
      _frames = 0;
      _mounted.clear();
      _observations.clear();
      platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(
            disableAnimations: motionAuditProfile == 'reduced',
            reduceMotion: motionAuditProfile != 'full',
          );
      try {
        await testBody();
      } finally {
        debugPrintSynchronously(
          'MORPH_MOTION_TRACE ${jsonEncode({'test': description, 'profile': motionAuditProfile, 'frames': _frames, 'mounted': _mounted.map((key, value) => MapEntry(key, value.toList()..sort())), 'animations': _observations.values.map((value) => value.toJson()).toList()})}',
        );
        _description = null;
        _observations.clear();
        platformDispatcher.clearAccessibilityFeaturesTestValue();
      }
    },
    invariantTester,
    description: description,
  );

  void _sample() {
    if (_description == null || rootElement == null) return;
    _frames++;
    final seen = HashSet<Animation<Object?>>.identity();
    void visit(Element element, String? owner, String? family) {
      final widget = element.widget;
      final name = widget.runtimeType.toString().split('<').first;
      final componentFamily = motionComponentOwners[name];
      if (componentFamily != null) {
        owner = name;
        family = componentFamily;
        (_mounted[family] ??= {}).add(name);
      }
      if (owner != null && family != null) {
        Listenable? listenable;
        if (widget is AnimatedWidget) listenable = widget.listenable;
        if (listenable is Animation<Object?> && seen.add(listenable)) {
          var observation = _observations[listenable];
          if (observation == null && _observations.length < 1000) {
            observation = _AnimationObservation(
              family: family,
              owner: owner,
              kind: listenable.runtimeType.toString(),
            );
            _observations[listenable] = observation;
          }
          final query = MediaQuery.maybeOf(element);
          observation?.sample(
            animation: listenable,
            timestamp: currentFrameTimeStamp,
            disableAnimations: query?.disableAnimations,
            reduceMotion: platformDispatcher.accessibilityFeatures.reduceMotion,
          );
        }
      }
      element.visitChildren((child) => visit(child, owner, family));
    }

    visit(rootElement!, null, null);
  }
}

class _AnimationObservation {
  _AnimationObservation({
    required this.family,
    required this.owner,
    required this.kind,
  });
  final String family;
  final String owner;
  final String kind;
  int samples = 0;
  int activeSamples = 0;
  int activeReducedSamples = 0;
  int maxActiveAgeMs = 0;
  Duration? _activeSince;
  String? _previous;
  int valueChanges = 0;
  final Set<String> flags = {};

  void sample({
    required Animation<Object?> animation,
    required Duration timestamp,
    required bool? disableAnimations,
    required bool? reduceMotion,
  }) {
    samples++;
    final value = animation.value.toString();
    if (_previous != null && value != _previous) valueChanges++;
    _previous = value;
    flags.add('$disableAnimations/$reduceMotion');
    if (!animation.isAnimating) {
      _activeSince = null;
      return;
    }
    activeSamples++;
    if (disableAnimations == true || reduceMotion == true) {
      activeReducedSamples++;
    }
    _activeSince ??= timestamp;
    final age = (timestamp - _activeSince!).inMilliseconds;
    if (age > maxActiveAgeMs) maxActiveAgeMs = age;
  }

  Map<String, Object?> toJson() => {
    'family': family,
    'owner': owner,
    'kind': kind,
    'samples': samples,
    'activeSamples': activeSamples,
    'activeReducedSamples': activeReducedSamples,
    'maxActiveAgeMs': maxActiveAgeMs,
    'valueChanges': valueChanges,
    'queryDisable_engineReduce': flags.toList()..sort(),
  };
}
