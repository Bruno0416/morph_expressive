import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/motion_audit_binding.dart';

void main() {
  testWidgets('motion audit profile reaches the platform and MediaQuery', (
    tester,
  ) async {
    if (motionAuditProfile == 'system') return;
    await tester.pumpWidget(
      MediaQuery.fromView(
        view: tester.view,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Text('Probe'),
        ),
      ),
    );
    final features = tester.binding.platformDispatcher.accessibilityFeatures;
    final query = MediaQuery.of(tester.element(find.text('Probe')));
    final expectedDisable = motionAuditProfile == 'reduced';
    final expectedReduce = motionAuditProfile != 'full';
    expect(features.disableAnimations, expectedDisable);
    expect(features.reduceMotion, expectedReduce);
    expect(query.disableAnimations, expectedDisable);
    expect(tester.binding.disableAnimations, expectedDisable);
  });
}
