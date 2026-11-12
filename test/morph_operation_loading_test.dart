import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

Widget host(Widget child, {bool reduced = false}) => MorphMaterialApp(
  data: MorphThemeData.light().copyWith(reduceMotion: reduced),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('operation is controlled; busy is not disabled', (tester) async {
    var taps = 0;
    var state = MorphOperationState.idle;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) {
            update = set;
            return MorphAsyncButton(
              label: 'Save',
              state: state,
              onPressed: () => taps++,
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(taps, 1);
    final width = tester.getSize(find.byType(MorphAsyncButton)).width;
    update(() => state = MorphOperationState.loading);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      tester.widget<MorphButton>(find.byType(MorphButton)).enabled,
      isTrue,
    );
    expect(tester.getSize(find.byType(MorphAsyncButton)).width, width);
    await tester.tapAt(tester.getCenter(find.byType(MorphAsyncButton)));
    await tester.pump(const Duration(seconds: 2));
    expect(taps, 1);
    expect(state, MorphOperationState.loading);
    final buttonDecoration = tester
        .widget<MorphButton>(find.byType(MorphButton))
        .decoration!;
    expect(
      tester
          .widget<MorphLoadingIndicator>(find.byType(MorphLoadingIndicator))
          .color,
      buttonDecoration.foregroundColor!.resolve({}),
      reason: 'loader must contrast with filled surface',
    );
    update(() => state = MorphOperationState.error);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    expect(taps, 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('compact reverses continuously and respects tight width', (
    tester,
  ) async {
    var state = MorphOperationState.idle;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) {
            update = set;
            return MorphAsyncButton(
              label: 'Save the document',
              state: state,
              presentation: MorphOperationPresentation.compact,
              onPressed: () {},
            );
          },
        ),
      ),
    );
    final button = find.byType(MorphButton);
    final element = tester.element(button);
    final idle = tester.getSize(button).width;
    update(() => state = MorphOperationState.loading);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = tester.getSize(button).width;
    expect(mid, lessThan(idle));
    update(() => state = MorphOperationState.success);
    await tester.pump();
    expect(tester.getSize(button).width, closeTo(mid, 1));
    expect(tester.element(button), same(element));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 240,
          child: MorphAsyncButton(
            label: 'Save',
            state: MorphOperationState.loading,
            presentation: MorphOperationPresentation.compact,
            onPressed: () {},
          ),
        ),
        reduced: true,
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(MorphAsyncButton)).width, 240);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard and explicit disabled keep normal button contract', (
    tester,
  ) async {
    final focus = FocusNode();
    var taps = 0;
    await tester.pumpWidget(
      host(
        MorphAsyncButton(
          label: 'Run',
          focusNode: focus,
          onPressed: () => taps++,
        ),
        reduced: true,
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
    await tester.pumpWidget(
      host(
        MorphAsyncButton(label: 'Run', enabled: false, onPressed: () => taps++),
      ),
    );
    await tester.tap(find.text('Run'));
    expect(taps, 1);
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
  });

  testWidgets('skeleton group hides real interaction and reverses', (
    tester,
  ) async {
    var loading = true;
    var taps = 0;
    late StateSetter update;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) {
            update = set;
            return MorphSkeletonGroup(
              loading: loading,
              semanticLabel: 'Loading profile',
              placeholder: const MorphSkeleton(width: 160, height: 48),
              child: MorphButton(
                onPressed: () => taps++,
                child: const Text('Real action'),
              ),
            );
          },
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(MorphSkeletonGroup)).toStringDeep(),
      isNot(contains('Real action')),
    );
    await tester.tapAt(tester.getCenter(find.byType(MorphSkeletonGroup)));
    expect(taps, 0);
    update(() => loading = false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    update(() => loading = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      tester.getSemantics(find.byType(MorphSkeletonGroup)).toStringDeep(),
      isNot(contains('Real action')),
    );
    update(() => loading = false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Real action'));
    expect(taps, 1);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
