import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/navigation_drawer/components/morph_drawer_destination_button.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_nav_selection_indicator.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        BuildContext,
        ButtonStyleButton,
        Center,
        Color,
        Column,
        DefaultTextStyle,
        EditableText,
        Icon,
        MainAxisSize,
        Scaffold,
        Size,
        State,
        SizedBox,
        StatefulBuilder,
        StateSetter,
        Text,
        TextEditingController,
        ValueKey,
        Widget;
import 'package:morph_expressive/morph_components.dart';

const Color _seed = Color(0xFF6750A4);

MorphThemeData _theme(MorphDensity d) =>
    MorphThemeData.light(seedColor: _seed, density: d);

Widget _app(MorphDensity d, Widget child) {
  return MorphMaterialApp(
    data: _theme(d),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 400, child: child),
      ),
    ),
  );
}

Future<Size> _size(
  WidgetTester tester,
  Widget child,
  MorphDensity d,
  Finder finder,
) async {
  await tester.pumpWidget(_app(d, child));
  await tester.pumpAndSettle();
  return tester.getSize(finder.first);
}

/// Compact < standard < comfortable heights of [build] measured by [finder].
Future<List<double>> _heights(
  WidgetTester tester,
  Widget Function() build,
  Finder finder,
) async {
  final List<double> out = <double>[];
  for (final MorphDensity d in MorphDensity.values) {
    out.add((await _size(tester, build(), d, finder)).height);
  }
  return out; // compact, standard, comfortable
}

const List<MorphButtonSize> _buttonSizes = <MorphButtonSize>[
  MorphButtonSize.xs,
  MorphButtonSize.sm,
  MorphButtonSize.md,
  MorphButtonSize.lg,
  MorphButtonSize.xl,
];

Finder get _materialButton =>
    find.byWidgetPredicate((Widget w) => w is ButtonStyleButton);

void main() {
  group('standard geometry is unchanged', () {
    test('button measurements keep the historical heights', () {
      const MorphButtonTheme theme = MorphButtonTheme.defaults;
      expect(
        _buttonSizes
            .map((MorphButtonSize s) => theme.measurements(s).height)
            .toList(),
        <double>[32, 40, 56, 96, 136],
      );
      expect(
        _buttonSizes
            .map((MorphButtonSize s) => theme.measurements(s).hPadding)
            .toList(),
        <double>[12, 16, 24, 48, 64],
      );
      expect(
        _buttonSizes
            .map(
              (MorphButtonSize s) =>
                  theme.measurements(s, density: MorphDensity.standard).iconGap,
            )
            .toList(),
        <double>[4, 8, 8, 12, 16],
      );
    });

    test('icon button visual and target sizes keep the table', () {
      const MorphIconButtonTheme theme = MorphIconButtonTheme.defaults;
      expect(
        MorphIconButtonSize.values
            .map(
              (MorphIconButtonSize s) =>
                  theme.visual(s, MorphIconButtonWidth.defaultWidth).height,
            )
            .toList(),
        <double>[32, 40, 56, 96, 136],
      );
      expect(
        MorphIconButtonSize.values
            .map(
              (MorphIconButtonSize s) =>
                  theme.target(s, MorphIconButtonWidth.defaultWidth).height,
            )
            .toList(),
        <double>[48, 48, 56, 96, 136],
      );
    });

    testWidgets('widgets render the historical standard heights', (
      WidgetTester tester,
    ) async {
      expect(
        (await _size(
          tester,
          MorphChip(label: 'Assist', onPressed: () {}),
          MorphDensity.standard,
          find.byType(MorphChip),
        )).height,
        32,
      );
      expect(
        (await _size(
          tester,
          MorphTabs(
            selectedIndex: 0,
            onTabSelected: (_) {},
            tabs: const <MorphTab>[
              MorphTab(label: 'One'),
              MorphTab(label: 'Two'),
            ],
          ),
          MorphDensity.standard,
          find.byType(MorphTabs),
        )).height,
        48,
      );
      for (final MapEntry<MorphButtonSize, double> e
          in <MorphButtonSize, double>{
            MorphButtonSize.md: 56,
            MorphButtonSize.lg: 96,
            MorphButtonSize.xl: 136,
          }.entries) {
        expect(
          (await _size(
            tester,
            MorphButton(onPressed: () {}, size: e.key, child: const Text('Go')),
            MorphDensity.standard,
            find.byType(MorphButton),
          )).height,
          e.value,
        );
      }
    });
  });

  group('heights are monotonic across densities', () {
    testWidgets('buttons, every size', (WidgetTester tester) async {
      for (final MorphButtonSize size in _buttonSizes) {
        final List<double> h = await _heights(
          tester,
          () => MorphButton(
            onPressed: () {},
            size: size,
            child: const Text('Go'),
          ),
          _materialButton,
        );
        // xs and sm keep the 48dp padded target around a smaller visual box,
        // so their laid-out height may not move; it must never invert.
        final bool padded =
            size == MorphButtonSize.xs || size == MorphButtonSize.sm;
        expect(
          h[0],
          padded ? lessThanOrEqualTo(h[1]) : lessThan(h[1]),
          reason: '${size.name} compact < standard',
        );
        expect(
          h[1],
          padded ? lessThanOrEqualTo(h[2]) : lessThan(h[2]),
          reason: '${size.name} standard < comfortable',
        );
        if (padded) {
          expect(h, everyElement(greaterThanOrEqualTo(48)));
        }
      }
    });

    testWidgets('button measurements: deltas are applied exactly once', (
      WidgetTester tester,
    ) async {
      const MorphButtonTheme theme = MorphButtonTheme.defaults;
      for (final MorphButtonSize size in _buttonSizes) {
        final double standard = theme.measurements(size).height;
        final int step = MorphButtonTheme.sizeStep(size);
        expect(
          theme.measurements(size, density: MorphDensity.compact).height,
          standard + MorphDensity.compact.metrics.controlHeightFor(step),
        );
        expect(
          theme.measurements(size, density: MorphDensity.comfortable).height,
          standard + MorphDensity.comfortable.metrics.controlHeightFor(step),
        );
      }
      // The rendered visual box equals the measurement (no second scaling).
      final List<double> md = await _heights(
        tester,
        () => MorphButton(
          onPressed: () {},
          size: MorphButtonSize.md,
          child: const Text('Go'),
        ),
        _materialButton,
      );
      expect(md, <double>[48, 56, 60]);
    });

    testWidgets('size stays independent of density', (
      WidgetTester tester,
    ) async {
      const MorphButtonTheme theme = MorphButtonTheme.defaults;
      for (final MorphDensity d in MorphDensity.values) {
        double? previous;
        for (final MorphButtonSize s in _buttonSizes) {
          final double h = theme.measurements(s, density: d).height;
          if (previous != null) {
            expect(h, greaterThan(previous), reason: '${s.name} in $d');
          }
          previous = h;
        }
      }
      final double smCompact = theme
          .measurements(MorphButtonSize.sm, density: MorphDensity.compact)
          .height;
      final double mdCompact = theme
          .measurements(MorphButtonSize.md, density: MorphDensity.compact)
          .height;
      expect(smCompact, isNot(mdCompact));
      // Smaller sizes lose less than larger ones.
      expect(
        smCompact - theme.measurements(MorphButtonSize.sm).height,
        greaterThan(mdCompact - theme.measurements(MorphButtonSize.md).height),
      );
    });

    testWidgets('icon buttons keep size order and move their visual box', (
      WidgetTester tester,
    ) async {
      const MorphIconButtonTheme theme = MorphIconButtonTheme.defaults;
      for (final MorphIconButtonSize s in MorphIconButtonSize.values) {
        final double c = theme
            .visual(
              s,
              MorphIconButtonWidth.defaultWidth,
              density: MorphDensity.compact,
            )
            .height;
        final double n = theme
            .visual(s, MorphIconButtonWidth.defaultWidth)
            .height;
        final double f = theme
            .visual(
              s,
              MorphIconButtonWidth.defaultWidth,
              density: MorphDensity.comfortable,
            )
            .height;
        expect(c, lessThan(n));
        expect(n, lessThan(f));
      }
      final List<double> md = await _heights(
        tester,
        () => MorphIconButton(
          icon: const Icon(MorphIcons.star),
          size: MorphIconButtonSize.md,
          onPressed: () {},
        ),
        find.byType(MorphIconButton),
      );
      expect(md, <double>[48, 56, 60]);
    });

    testWidgets('chip', (WidgetTester tester) async {
      final List<double> h = await _heights(
        tester,
        () => MorphChip(label: 'Assist', onPressed: () {}),
        find.byType(MorphChip),
      );
      expect(h, <double>[28, 32, 36]);
    });

    testWidgets('text field', (WidgetTester tester) async {
      final List<double> h = await _heights(
        tester,
        () => const MorphTextField(label: 'Label'),
        find.byType(MorphTextField),
      );
      expect(h[0], lessThan(h[1]));
      expect(h[1], lessThan(h[2]));
      expect(h[1] - h[0], 8);
      expect(h[2] - h[1], 4);
    });

    testWidgets('list item rows', (WidgetTester tester) async {
      final List<double> h = <double>[];
      for (final MorphDensity d in MorphDensity.values) {
        await tester.pumpWidget(
          _app(
            d,
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[MorphListItem(headline: 'Row')],
            ),
          ),
        );
        await tester.pumpAndSettle();
        h.add(tester.getSize(find.byType(MorphListItem)).height);
      }
      expect(h[0], lessThan(h[1]));
      expect(h[1], lessThan(h[2]));
      expect(h[1], 56);
    });

    testWidgets('tabs', (WidgetTester tester) async {
      final List<double> h = await _heights(
        tester,
        () => MorphTabs(
          selectedIndex: 0,
          onTabSelected: (_) {},
          tabs: const <MorphTab>[
            MorphTab(label: 'One'),
            MorphTab(label: 'Two'),
          ],
        ),
        find.byType(MorphTabs),
      );
      expect(h, <double>[44, 48, 52]);
    });

    testWidgets('navigation bar', (WidgetTester tester) async {
      final List<double> h = await _heights(
        tester,
        () => MorphNavigationBar(
          selectedIndex: 0,
          autoLayout: false,
          safeArea: false,
          onDestinationSelected: (_) {},
          destinations: const <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
            MorphNavigationBarDestination(
              icon: MorphIcons.search,
              label: 'Search',
            ),
          ],
        ),
        find.byType(MorphNavigationBar),
      );
      expect(h[0], lessThan(h[1]));
      expect(h[1], lessThan(h[2]));
      expect(h, <double>[76, 80, 84]);
    });

    testWidgets('segmented button theme heights', (WidgetTester tester) async {
      const MorphSegmentedButtonTheme theme =
          MorphSegmentedButtonTheme.defaults;
      expect(theme.heightFor(null), 40);
      expect(theme.heightFor(null, global: MorphDensity.compact), 32);
      expect(theme.heightFor(null, global: MorphDensity.comfortable), 44);
      // Explicit per-widget density beats the global one.
      expect(
        theme.heightFor(
          MorphSegmentedButtonDensity.dense,
          global: MorphDensity.comfortable,
        ),
        28,
      );
      expect(
        theme.heightFor(
          MorphSegmentedButtonDensity.regular,
          global: MorphDensity.compact,
        ),
        40,
      );
    });

    testWidgets('button group follows the global density', (
      WidgetTester tester,
    ) async {
      Widget group({MorphButtonGroupDensity? density}) => MorphButtonGroup(
        size: MorphButtonSize.md,
        density: density,
        selectedIndex: 0,
        onSelectedIndexChanged: (_) {},
        actions: const <MorphButtonGroupAction>[
          MorphButtonGroupAction(label: Text('One')),
          MorphButtonGroupAction(label: Text('Two')),
        ],
      );
      final List<double> h = await _heights(
        tester,
        group,
        find.byType(MorphButtonGroup),
      );
      expect(h[0], lessThan(h[1]));
      expect(h[1], lessThan(h[2]));
      expect(h[1], 56);
      // Explicit density wins over the theme in every global density.
      for (final MorphDensity d in MorphDensity.values) {
        final Size s = await _size(
          tester,
          group(density: MorphButtonGroupDensity.regular),
          d,
          find.byType(MorphButtonGroup),
        );
        expect(s.height, 56, reason: 'explicit regular under $d');
      }
    });
  });

  group('rendered metrics per density', () {
    Future<List<double>> measure(
      WidgetTester tester,
      Widget Function() build,
      double Function() read,
    ) async {
      final List<double> out = <double>[];
      for (final MorphDensity d in MorphDensity.values) {
        await tester.pumpWidget(_app(d, build()));
        await tester.pumpAndSettle();
        out.add(read());
      }
      return out; // compact, standard, comfortable
    }

    testWidgets('app bar (small) band height', (WidgetTester tester) async {
      final List<double> h = await measure(
        tester,
        () => const MorphAppBar.top(titleText: 'Inbox'),
        () => tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(MorphAppBar),
                    matching: find.byType(SizedBox),
                  )
                  .first,
            )
            .height,
      );
      expect(h, <double>[56, 64, 68]);
    });

    testWidgets('drawer destination row and pill', (WidgetTester tester) async {
      Widget drawer() => MorphNavigationDrawer(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const <MorphNavigationDestination>[
          MorphNavigationDestination(icon: Icon(MorphIcons.inbox), label: 'In'),
          MorphNavigationDestination(icon: Icon(MorphIcons.send), label: 'Out'),
        ],
      );
      final List<double> pill = await measure(
        tester,
        () => SizedBox(height: 400, child: drawer()),
        () => tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(MorphDrawerDestinationButton).first,
                    matching: find.byType(MorphSelectionIndicator),
                  )
                  .first,
            )
            .height,
      );
      expect(pill, <double>[48, 56, 64]);
      final List<double> row = await measure(
        tester,
        () => SizedBox(height: 400, child: drawer()),
        () => tester
            .getSize(find.byType(MorphDrawerDestinationButton).first)
            .height,
      );
      expect(row, <double>[54, 64, 74]);
    });

    testWidgets('search bar height', (WidgetTester tester) async {
      final List<double> h = await measure(
        tester,
        () => const MorphSearchBar(hintText: 'Search'),
        () => tester.getSize(find.byType(MorphSearchBar)).height,
      );
      expect(h[0], lessThan(h[1]));
      expect(h[1], lessThan(h[2]));
      expect(h[1] - h[0], 8);
      expect(h[2] - h[1], 4);
    });

    testWidgets('card content padding', (WidgetTester tester) async {
      final List<double> inset = await measure(
        tester,
        () => const MorphCard(headline: 'Headline', supportingText: 'Body'),
        () =>
            tester.getTopLeft(find.text('Headline')).dx -
            tester.getTopLeft(find.byType(MorphCard)).dx,
      );
      expect(inset, <double>[14, 16, 18]);
    });
  });

  group('toggles, toolbars and expandables', () {
    testWidgets('chip toggle height follows density unless explicit', (
      WidgetTester tester,
    ) async {
      Widget toggle({double? height}) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MorphChipToggle<int>(
            selected: 0,
            onChanged: (_) {},
            height: height,
            options: const <MorphChipToggleOption<int>>[
              MorphChipToggleOption<int>(value: 0, label: 'One'),
              MorphChipToggleOption<int>(value: 1, label: 'Two'),
            ],
          ),
        ],
      );
      final List<double> implicit = <double>[];
      final List<double> explicit = <double>[];
      for (final MorphDensity d in MorphDensity.values) {
        await tester.pumpWidget(_app(d, toggle()));
        await tester.pumpAndSettle();
        implicit.add(tester.getSize(find.byType(MorphChipToggle<int>)).height);
        await tester.pumpWidget(_app(d, toggle(height: 40)));
        await tester.pumpAndSettle();
        explicit.add(tester.getSize(find.byType(MorphChipToggle<int>)).height);
      }
      expect(implicit.first, lessThan(implicit[1]));
      expect(implicit[1], lessThan(implicit.last));
      expect(implicit[1], explicit[1], reason: 'standard stays 40');
      expect(explicit.toSet().length, 1);
    });

    testWidgets('toolbar action gap follows density, bar size does not', (
      WidgetTester tester,
    ) async {
      final List<double> gap = <double>[];
      final List<double> bar = <double>[];
      for (final MorphDensity d in MorphDensity.values) {
        await tester.pumpWidget(
          _app(
            d,
            MorphToolbar(
              actions: <MorphToolbarItem>[
                MorphToolbarAction(icon: MorphIcons.edit, onPressed: () {}),
                MorphToolbarAction(icon: MorphIcons.share, onPressed: () {}),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final Finder buttons = find.byType(MorphIconButton);
        gap.add(
          tester.getTopLeft(buttons.at(1)).dx -
              tester.getTopRight(buttons.at(0)).dx,
        );
        bar.add(tester.getSize(find.byType(MorphToolbar)).height);
      }
      expect(gap.first, lessThan(gap[1]));
      expect(gap[1], lessThan(gap.last));
      expect(bar.toSet().length, 1, reason: 'container size is invariant');
    });
  });

  group('selection', () {
    testWidgets('contextual band follows the app bar, select-all keeps 48', (
      WidgetTester tester,
    ) async {
      final List<double> select = <double>[];
      final List<double> band = <double>[];
      for (final MorphDensity d in MorphDensity.values) {
        final MorphSelectionController controller = MorphSelectionController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MorphMaterialApp(
            data: _theme(d),
            home: MorphSelection(
              controller: controller,
              itemCount: 3,
              appBar: const MorphSelectionAppBar(idle: SizedBox(height: 32)),
              body: MorphList.scrollable(
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) =>
                    MorphListItem(headline: 'Item $index'),
              ),
            ),
          ),
        );
        controller.selectAll(3);
        await tester.pumpAndSettle();
        final Finder bar = find.descendant(
          of: find.byType(MorphSelectionAppBar),
          matching: find.byType(SizedBox),
        );
        final Iterable<double> heights = tester
            .widgetList<SizedBox>(bar)
            .map((SizedBox b) => b.height)
            .whereType<double>();
        band.add(heights.firstWhere((double h) => h >= 56 && h <= 72));
        select.add(
          heights
              .where((double h) => h >= 48 && h <= 52 && h != band.last)
              .reduce((double a, double b) => a > b ? a : b),
        );
      }
      expect(band, <double>[56, 64, 68]);
      expect(select, <double>[48, 48, 52]);
    });
  });

  group('precedence and policies', () {
    testWidgets('explicit text field density beats the theme', (
      WidgetTester tester,
    ) async {
      final Size standard = await _size(
        tester,
        const MorphTextField(label: 'Label', density: 0),
        MorphDensity.standard,
        find.byType(MorphTextField),
      );
      for (final MorphDensity d in MorphDensity.values) {
        final Size s = await _size(
          tester,
          const MorphTextField(label: 'Label', density: 0),
          d,
          find.byType(MorphTextField),
        );
        expect(s.height, standard.height, reason: 'explicit density 0 in $d');
      }
    });

    testWidgets('explicit nav bar density beats the theme', (
      WidgetTester tester,
    ) async {
      Widget bar(MorphNavBarDensity? density) => MorphNavigationBar(
        selectedIndex: 0,
        autoLayout: false,
        safeArea: false,
        density: density,
        onDestinationSelected: (_) {},
        destinations: const <MorphNavigationBarDestination>[
          MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
          MorphNavigationBarDestination(
            icon: MorphIcons.search,
            label: 'Search',
          ),
        ],
      );
      for (final MorphDensity d in MorphDensity.values) {
        final Size s = await _size(
          tester,
          bar(MorphNavBarDensity.regular),
          d,
          find.byType(MorphNavigationBar),
        );
        expect(s.height, 80, reason: 'explicit regular under $d');
      }
    });

    testWidgets('app bar metrics: explicit wins, null follows the theme', (
      WidgetTester tester,
    ) async {
      const MorphAppBarTheme theme = MorphAppBarTheme.defaults;
      final double regular = theme
          .metrics(MorphAppBarDensity.regular)
          .smallHeight;
      expect(theme.metrics(null).smallHeight, regular);
      expect(
        theme.metrics(null, global: MorphDensity.compact).smallHeight,
        lessThan(regular),
      );
      expect(
        theme.metrics(null, global: MorphDensity.comfortable).smallHeight,
        greaterThan(regular),
      );
      expect(
        theme
            .metrics(MorphAppBarDensity.regular, global: MorphDensity.compact)
            .smallHeight,
        regular,
      );
    });

    testWidgets('hit target of compact controls stays at least 48', (
      WidgetTester tester,
    ) async {
      const MorphIconButtonTheme theme = MorphIconButtonTheme.defaults;
      for (final MorphIconButtonSize s in <MorphIconButtonSize>[
        MorphIconButtonSize.xs,
        MorphIconButtonSize.sm,
        MorphIconButtonSize.md,
      ]) {
        final Size target = theme.target(
          s,
          MorphIconButtonWidth.defaultWidth,
          density: MorphDensity.compact,
        );
        expect(target.width, greaterThanOrEqualTo(48), reason: s.name);
        expect(target.height, greaterThanOrEqualTo(48), reason: s.name);
      }
      for (final MorphButtonSize s in <MorphButtonSize>[
        MorphButtonSize.xs,
        MorphButtonSize.sm,
      ]) {
        final Size layout = await _size(
          tester,
          MorphButton(onPressed: () {}, size: s, child: const Text('Go')),
          MorphDensity.compact,
          find.byType(MorphButton),
        );
        expect(layout.height, greaterThanOrEqualTo(48), reason: s.name);
      }
      final Size icon = await _size(
        tester,
        MorphIconButton(
          icon: const Icon(MorphIcons.star),
          size: MorphIconButtonSize.sm,
          onPressed: () {},
        ),
        MorphDensity.compact,
        find.byType(MorphIconButton),
      );
      expect(icon.width, greaterThanOrEqualTo(48));
      expect(icon.height, greaterThanOrEqualTo(48));
    });

    testWidgets('density never changes the text size', (
      WidgetTester tester,
    ) async {
      final List<double?> sizes = <double?>[];
      for (final MorphDensity d in MorphDensity.values) {
        await tester.pumpWidget(
          _app(
            d,
            MorphButton(
              onPressed: () {},
              size: MorphButtonSize.md,
              child: const Text('Label'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.text('Label'));
        sizes.add(DefaultTextStyle.of(context).style.fontSize);
      }
      expect(sizes.toSet().length, 1);
    });

    testWidgets('runtime switch keeps widget state and updates metrics', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController(
        text: 'keep me',
      );
      addTearDown(controller.dispose);
      late StateSetter setDensity;
      MorphDensity density = MorphDensity.standard;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: _theme(MorphDensity.standard),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                setDensity = setState;
                return MorphTheme(
                  data: _theme(density),
                  child: Center(
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MorphTextField(
                            key: const ValueKey<String>('field'),
                            controller: controller,
                            label: 'Label',
                          ),
                          MorphChip(label: 'Chip', onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      final State before = tester.state(find.byType(MorphTextField));
      final double fieldHeight = tester
          .getSize(find.byType(MorphTextField))
          .height;
      final double chipHeight = tester.getSize(find.byType(MorphChip)).height;

      setDensity(() => density = MorphDensity.compact);
      await tester.pumpAndSettle();

      expect(
        identical(tester.state(find.byType(MorphTextField)), before),
        isTrue,
      );
      expect(controller.text, 'keep me');
      expect(
        tester.getSize(find.byType(MorphTextField)).height,
        lessThan(fieldHeight),
      );
      expect(
        tester.getSize(find.byType(MorphChip)).height,
        lessThan(chipHeight),
      );
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );

      setDensity(() => density = MorphDensity.comfortable);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(MorphTextField)).height,
        greaterThan(fieldHeight),
      );
      expect(controller.text, 'keep me');
    });
  });
}
