import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  _registerSnackbarLayoutTests();
  _registerSnackbarBehaviorTests();
}

void _registerSnackbarLayoutTests() {
  testWidgets(
    'single-line snackbar with action stays at min height',
    _singleLineSnackbarWithActionStaysAtMinHeight,
  );
  testWidgets(
    'close icon is 12dp from the action and the trailing edge',
    _closeIconIs12dpFromTheActionAndTheTrailingEdge,
  );
  test(
    'theme defaults match the snackbar spec',
    _themeDefaultsMatchTheSnackbarSpec,
  );
  testWidgets(
    'MorphSnackbar positions above system navigation inset',
    _morphsnackbarPositionsAboveSystemNavigationInset,
  );
}

void _registerSnackbarBehaviorTests() {
  testWidgets(
    'actionable snackbar does not auto-dismiss',
    _actionableSnackbarDoesNotAutoDismiss,
  );
  testWidgets('close button dismisses snackbar', _closeButtonDismissesSnackbar);
  testWidgets(
    'one snackbar at a time replaces the previous',
    _oneSnackbarAtATimeReplacesThePrevious,
  );
  testWidgets(
    'plain snackbar auto-dismisses after default duration',
    _plainSnackbarAutoDismissesAfterDefaultDuration,
  );
}

Future<void> _singleLineSnackbarWithActionStaysAtMinHeight(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphSnackbar(message: 'Draft saved', actionLabel: 'Undo', onAction: () {}),
    ),
  );

  expect(tester.getSize(find.byType(MorphSnackbar)).height, 48);
}

Future<void> _closeIconIs12dpFromTheActionAndTheTrailingEdge(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphSnackbar(
        message: 'Draft saved',
        actionLabel: 'Undo',
        onAction: () {},
        showCloseButton: true,
      ),
    ),
  );

  final Rect action = tester.getRect(find.byType(MorphButton));
  final Rect icon = tester.getRect(find.byIcon(MorphIcons.close));
  final Rect bar = tester.getRect(find.byType(MorphSnackbar));

  expect(icon.left - action.right, 12);
  expect(bar.right - icon.right, 12);
  expect(bar.height, 48);
}

void _themeDefaultsMatchTheSnackbarSpec() {
  const theme = MorphSnackbarTheme.defaults;
  expect(theme.singleLineMinHeight, 48);
  expect(theme.twoLineMinHeight, 68);
  expect(theme.startPadding, 16);
  expect(theme.endPaddingWithTrailing, 8);
  expect(theme.closeIconSize, 24);
  expect(theme.closePadding, 12);
  expect(theme.elevation, MorphElevation.level3);
  expect(theme.defaultDuration, const Duration(seconds: 4));
  expect(theme.hoverStateOpacity, 0.08);
  expect(theme.focusStateOpacity, 0.1);
  expect(theme.pressedStateOpacity, 0.1);

  final scheme = MorphThemeData.light().colorScheme;
  final type = MorphThemeData.light().typeScale;
  expect(theme.containerColor(scheme), scheme.surfaceContainerHigh);
  expect(theme.messageStyle(type, scheme).color, scheme.onSurface);
  expect(theme.actionStyle(type, scheme).color, scheme.primary);
  expect(theme.closeIconColor(scheme), scheme.onSurfaceVariant);
  final dark = MorphThemeData.dark(seedColor: const Color(0xFF6750A4)).colorScheme;
  expect(theme.containerColor(dark), dark.surfaceContainerHigh);
  expect(theme.messageStyle(type, dark).color, dark.onSurface);
}

Future<void> _morphsnackbarPositionsAboveSystemNavigationInset(
  WidgetTester tester,
) async {
  const double navigationInset = 34;
  tester.view.viewPadding = const FakeViewPadding(bottom: navigationInset);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      drawUnderSystemBars: true,
      home: Builder(
        builder: (BuildContext context) {
          return Center(
            child: MorphButton(
              onPressed: () =>
                  MorphSnackbar.show(context, message: 'Draft saved'),
              child: const Text('Show snackbar'),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Show snackbar'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  final Positioned positioned = tester.widget<Positioned>(
    find.descendant(
      of: find.byType(MorphSnackbarHost),
      matching: find.byType(Positioned),
    ),
  );

  final BuildContext hostContext = tester.element(find.byType(MorphSnackbarHost));
  final MediaQueryData media = MediaQuery.of(hostContext);
  final MorphSnackbarTheme snackTheme = MorphTheme.of(hostContext).snackBarTheme;

  expect(
    positioned.bottom,
    snackTheme.overlayBottomInset +
        media.viewPadding.bottom +
        media.viewInsets.bottom,
  );
}

Future<void> _actionableSnackbarDoesNotAutoDismiss(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      Builder(
        builder: (BuildContext context) {
          return MorphButton(
            onPressed: () => MorphSnackbar.show(
              context,
              message: 'Photo deleted',
              actionLabel: 'Undo',
              onAction: () {},
            ),
            child: const Text('Show'),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Show'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  expect(find.text('Photo deleted'), findsOneWidget);

  await tester.pump(const Duration(seconds: 5));
  expect(find.text('Photo deleted'), findsOneWidget);
}

Future<void> _closeButtonDismissesSnackbar(WidgetTester tester) async {
  var closed = false;
  await tester.pumpWidget(
    _host(
      Builder(
        builder: (BuildContext context) {
          return MorphButton(
            onPressed: () => MorphSnackbar.show(
              context,
              message: 'Saved to drafts',
              showCloseButton: true,
              onClose: () => closed = true,
            ),
            child: const Text('Show'),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Show'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  expect(find.text('Saved to drafts'), findsOneWidget);

  await tester.tap(find.byIcon(MorphIcons.close));
  await tester.pump();
  await tester.pumpAndSettle();
  expect(closed, isTrue);
  expect(find.text('Saved to drafts'), findsNothing);
}

Future<void> _oneSnackbarAtATimeReplacesThePrevious(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      Builder(
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MorphButton(
                onPressed: () =>
                    MorphSnackbar.show(context, message: 'First message'),
                child: const Text('Show first'),
              ),
              MorphButton(
                onPressed: () =>
                    MorphSnackbar.show(context, message: 'Second message'),
                child: const Text('Show second'),
              ),
            ],
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Show first'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  expect(find.text('First message'), findsOneWidget);

  await tester.tap(find.text('Show second'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  expect(find.text('Second message'), findsOneWidget);
  expect(find.text('First message'), findsNothing);
  expect(find.byType(MorphSnackbarHost), findsOneWidget);
}

Future<void> _plainSnackbarAutoDismissesAfterDefaultDuration(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      Builder(
        builder: (BuildContext context) {
          return MorphButton(
            onPressed: () => MorphSnackbar.show(context, message: 'Draft saved'),
            child: const Text('Show'),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Show'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  expect(find.text('Draft saved'), findsOneWidget);

  await tester.pump(const Duration(seconds: 4));
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.text('Draft saved'), findsNothing);
}
