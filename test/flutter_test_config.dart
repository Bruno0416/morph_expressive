import 'dart:async';

import 'support/motion_audit_binding.dart';

/// Opt-in only: ordinary `flutter test` keeps Flutter's standard binding.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  installMotionAuditBinding();
  await testMain();
}
