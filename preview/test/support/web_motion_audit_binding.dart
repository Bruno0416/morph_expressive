import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Web tests serve preview/ as their package root and cannot load the library's
// ../../test helper. Apply the same three preference profiles locally.
const _profile = String.fromEnvironment(
  'MORPH_MOTION_AUDIT_PROFILE',
  defaultValue: 'system',
);

void installMotionAuditBinding() {
  if (_profile == 'system') return;
  if (!const {'full', 'reduced', 'reduce-only'}.contains(_profile)) {
    throw ArgumentError('Unknown motion audit profile: $_profile');
  }
  _WebMotionAuditBinding();
}

class _WebMotionAuditBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  Future<void> runTest(
    Future<void> Function() testBody,
    VoidCallback invariantTester, {
    String description = '',
  }) => super.runTest(
    () async {
      platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(
            disableAnimations: _profile == 'reduced',
            reduceMotion: _profile != 'full',
          );
      try {
        await testBody();
      } finally {
        platformDispatcher.clearAccessibilityFeaturesTestValue();
      }
    },
    invariantTester,
    description: description,
  );
}
