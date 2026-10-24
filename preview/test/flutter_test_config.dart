import 'dart:async';

import '../../test/support/motion_audit_binding.dart'
    if (dart.library.js_interop) 'support/web_motion_audit_binding.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  installMotionAuditBinding();
  await testMain();
}
