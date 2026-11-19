import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Scaffold, ScrollableState, Text, TextButton;
import 'package:morph_expressive/morph_expressive.dart';

import 'context_menu_support.dart';

Finder get _surface => panelFinder;

void main() {
  group('placement', () {
    testWidgets('right click opens with its top-left at the pointer', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(200, 150));
      expect(_surface, findsOneWidget);
      final Rect surface = surfaceRect(tester);
      expect(surface.left, closeTo(200, 1));
      expect(surface.top, closeTo(150, 1));
    });

    testWidgets('flips left and up near the right/bottom edges', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(790, 590));
      final Rect surface = surfaceRect(tester);
      expect(surface.right, closeTo(790, 1), reason: 'right edge at pointer');
      expect(surface.bottom, closeTo(590, 1), reason: 'bottom edge at pointer');
      expect(surface.left, greaterThanOrEqualTo(0));
      expect(surface.top, greaterThanOrEqualTo(0));
      expect(kContextViewport.contains(surface.topLeft), isTrue);
      expect(kContextViewport.contains(surface.bottomRight), isTrue);
    });

    testWidgets('flips only horizontally when there is room below', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(780, 100));
      final Rect surface = surfaceRect(tester);
      expect(surface.right, closeTo(780, 1));
      expect(surface.top, closeTo(100, 1));
    });

    testWidgets('a tiny window keeps the menu inside and scrollable', (
      tester,
    ) async {
      const Size tiny = Size(300, 140);
      setContextViewport(tester, tiny);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(150, 70));
      final Rect surface = surfaceRect(tester);
      expect(surface.top, greaterThanOrEqualTo(7.5));
      expect(surface.bottom, lessThanOrEqualTo(tiny.height - 7.5));
      expect(surface.left, greaterThanOrEqualTo(7.5));
      expect(surface.right, lessThanOrEqualTo(tiny.width - 7.5));
      final ScrollableState scrollable = tester.state<ScrollableState>(
        find.descendant(of: _surface, matching: find.byType(Scrollable)),
      );
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
    });

    testWidgets('many items fit the viewport and scroll internally', (
      tester,
    ) async {
      const Size size = Size(800, 400);
      setContextViewport(tester, size);
      final List<MorphMenuNode> many = <MorphMenuNode>[
        for (var i = 0; i < 60; i++)
          MorphMenuEntry(label: 'Item $i', value: 'item$i'),
      ];
      await tester.pumpWidget(contextHost(children: many));
      await rightClick(tester, const Offset(100, 50));
      final Rect surface = surfaceRect(tester);
      expect(surface.height, lessThanOrEqualTo(size.height - 15));
      expect(surface.bottom, lessThanOrEqualTo(size.height - 7.5));
      final ScrollableState scrollable = tester.state<ScrollableState>(
        find.descendant(of: _surface, matching: find.byType(Scrollable)),
      );
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      await tester.drag(find.text('Item 3'), const Offset(0, -2000));
      await tester.pump();
      expect(scrollable.position.pixels, scrollable.position.maxScrollExtent);
      expect(
        tester.getRect(find.text('Item 59')).bottom,
        lessThan(size.height),
      );
    });

    testWidgets('RTL mirrors the horizontal preference', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost(direction: TextDirection.rtl));
      await rightClick(tester, const Offset(500, 150));
      final Rect surface = surfaceRect(tester);
      expect(surface.right, closeTo(500, 1));
      expect(surface.top, closeTo(150, 1));
    });
  });

  group('metrics', () {
    Future<double> itemHeight(WidgetTester tester, MorphDensity d) async {
      await tester.pumpWidget(contextHost(density: d));
      await rightClick(tester, const Offset(100, 100));
      final double h = rowRect(tester, 'Rename').height;
      await tester.tapAt(const Offset(700, 500));
      await settleMenu(tester);
      return h;
    }

    testWidgets('item height per density is 28 / 32 / 40 and monotonic', (
      tester,
    ) async {
      setContextViewport(tester);
      final double compact = await itemHeight(tester, MorphDensity.compact);
      final double standard = await itemHeight(tester, MorphDensity.standard);
      final double comfortable = await itemHeight(
        tester,
        MorphDensity.comfortable,
      );
      expect(compact, 28);
      expect(standard, 32);
      expect(comfortable, 40);
      expect(compact, lessThan(standard));
      expect(standard, lessThan(comfortable));
    });

    testWidgets('row pitch equals the item height (no 52 px pitch)', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(100, 100));
      final double pitch =
          rowRect(tester, 'Rename').top - rowRect(tester, 'Open').top;
      expect(pitch, 32);
    });

    testWidgets('container padding, radius and icon size follow the table', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost(density: MorphDensity.standard));
      await rightClick(tester, const Offset(100, 100));
      final Rect surface = surfaceRect(tester);
      expect(rowRect(tester, 'Open').top - surface.top, 4);
      final Icon icon = tester.widget<Icon>(
        find.byIcon(MorphIcons.check_rounded),
      );
      expect(
        icon.size ??
            IconTheme.of(tester.element(find.byIcon(MorphIcons.check_rounded)))
                .size,
        16,
      );
    });

    testWidgets('width fits content between 180 and 320 px', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        contextHost(
          children: const <MorphMenuNode>[
            MorphMenuEntry(label: 'A', value: 'a'),
          ],
        ),
      );
      await rightClick(tester, const Offset(100, 100));
      expect(surfaceRect(tester).width, 180);
      await tester.tapAt(const Offset(700, 500));
      await settleMenu(tester);

      await tester.pumpWidget(
        contextHost(
          children: const <MorphMenuNode>[
            MorphMenuEntry(
              label: 'Open Workspace Alpha in a new window',
              value: 'a',
              trailingText: 'Ctrl+Shift+N',
            ),
          ],
        ),
      );
      await rightClick(tester, const Offset(100, 100));
      final double fitted = surfaceRect(tester).width;
      expect(fitted, greaterThan(180));
      expect(fitted, lessThanOrEqualTo(320));
      // Fits without truncating.
      expect(find.text('Open Workspace Alpha in a new window'), findsOneWidget);
    });

    testWidgets('long labels ellipsize inside the 320 px maximum', (
      tester,
    ) async {
      setContextViewport(tester);
      final String long = 'An extremely long menu label ' * 8;
      await tester.pumpWidget(
        contextHost(
          children: <MorphMenuNode>[MorphMenuEntry(label: long, value: 'x')],
        ),
      );
      await rightClick(tester, const Offset(100, 100));
      expect(surfaceRect(tester).width, 320);
      final Text text = tester.widget<Text>(find.text(long));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
      expect(
        tester.getRect(find.text(long)).right,
        lessThanOrEqualTo(100 + 320),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('labels share one x with and without a leading icon', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(100, 100));
      final double withIcon = tester.getTopLeft(find.text('Open')).dx;
      final double without = tester.getTopLeft(find.text('Rename')).dx;
      final double submenu = tester.getTopLeft(find.text('Move to')).dx;
      expect(without, withIcon);
      expect(submenu, withIcon);
    });

    testWidgets('without any leading the labels start at the row padding', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost(children: sampleMenu(icons: false)));
      await rightClick(tester, const Offset(100, 100));
      // inset 4 + row padding 10, no reserved slot.
      expect(tester.getTopLeft(find.text('Open')).dx, 100 + 14);
    });

    testWidgets('shortcut is right-aligned in a fixed gap, chevron in a slot', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        contextHost(
          children: const <MorphMenuNode>[
            MorphMenuEntry(label: 'Copy', value: 'c', trailingText: 'Ctrl+C'),
            MorphMenuEntry(
              label: 'Paste special',
              value: 'p',
              trailingText: 'Ctrl+Shift+V',
            ),
            MorphMenuSubmenu(
              label: 'Share',
              children: <MorphMenuNode>[
                MorphMenuEntry(label: 'Mail', value: 'm'),
              ],
            ),
          ],
        ),
      );
      await rightClick(tester, const Offset(100, 100));
      expect(find.text('Ctrl+C'), findsOneWidget);
      // Shortcuts share the same right edge.
      expect(
        tester.getRect(find.text('Ctrl+C')).right,
        closeTo(tester.getRect(find.text('Ctrl+Shift+V')).right, 0.5),
      );
      // Label to shortcut gap is at least the fixed gap (widest row == gap).
      final double gap =
          tester.getRect(find.text('Ctrl+Shift+V')).left -
          tester.getRect(find.text('Paste special')).right;
      expect(gap, greaterThanOrEqualTo(24 - 1));
      // Small chevron in the trailing slot, not a full arrow.
      expect(find.byIcon(MorphIcons.chevron_right), findsOneWidget);
      expect(find.byIcon(MorphIcons.arrow_right_rounded), findsNothing);
      final Rect chevron = tester.getRect(
        find.byIcon(MorphIcons.chevron_right),
      );
      expect(chevron.width, 16);
      final Rect shortcut = tester.getRect(find.text('Ctrl+C'));
      expect(shortcut.right, lessThanOrEqualTo(chevron.left));
      final Rect surface = surfaceRect(tester);
      expect(surface.right - chevron.right, closeTo(14, 0.5));
    });

    testWidgets('destructive rows use the error role', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(100, 100));
      final BuildContext context = tester.element(find.text('Delete'));
      final Color error = MorphTheme.of(context).colorScheme.error;
      final Text label = tester.widget<Text>(find.text('Delete'));
      expect(label.style!.color, error);
    });

    testWidgets('disabled rows are dimmed to 0.38', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(100, 100));
      final BuildContext context = tester.element(find.text('Disabled'));
      final Color on = MorphTheme.of(context).colorScheme.onSurface;
      final Text label = tester.widget<Text>(find.text('Disabled'));
      expect(label.style!.color!.a, closeTo(on.a * 0.38, 0.02));
    });

    testWidgets('glass menus render frosted', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        contextHost(glass: const MorphSurfaceGlass(blurX: 12, blurY: 12)),
      );
      await rightClick(tester, const Offset(100, 100));
      expect(
        find.descendant(of: _surface, matching: find.byType(BackdropFilter)),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('light and dark both render', (tester) async {
      setContextViewport(tester);
      for (final bool dark in <bool>[false, true]) {
        await tester.pumpWidget(contextHost(dark: dark));
        await rightClick(tester, const Offset(100, 100));
        expect(_surface, findsOneWidget);
        await tester.tapAt(const Offset(700, 500));
        await settleMenu(tester);
        expect(_surface, findsNothing);
      }
    });
  });

  group('standard presentation is untouched', () {
    testWidgets('showMorphMenu default keeps 48 px rows and its anchoring', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => showMorphMenu<String>(
                    context: context,
                    anchor: const Offset(300, 100) & const Size(1, 1),
                    children: sampleMenu(),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await settleMenu(tester);
      expect(_surface, findsNothing, reason: 'no desktop surface');
      expect(rowRect(tester, 'Rename').height, 48);
      expect(find.byIcon(MorphIcons.arrow_right_rounded), findsOneWidget);
    });

    test('desktop metrics table is monotonic', () {
      const List<MorphMenuDesktopMetrics> table = <MorphMenuDesktopMetrics>[
        MorphMenuDesktopMetrics.compact,
        MorphMenuDesktopMetrics.standard,
        MorphMenuDesktopMetrics.comfortable,
      ];
      for (var i = 1; i < table.length; i++) {
        expect(
          table[i].itemHeight,
          greaterThanOrEqualTo(table[i - 1].itemHeight),
        );
        expect(table[i].iconSize, greaterThanOrEqualTo(table[i - 1].iconSize));
        expect(
          table[i].horizontalPadding,
          greaterThanOrEqualTo(table[i - 1].horizontalPadding),
        );
        expect(
          table[i].containerVerticalPadding,
          greaterThanOrEqualTo(table[i - 1].containerVerticalPadding),
        );
        expect(table[i].iconGap, greaterThanOrEqualTo(table[i - 1].iconGap));
        expect(
          table[i].shortcutGap,
          greaterThanOrEqualTo(table[i - 1].shortcutGap),
        );
        expect(table[i].itemGap, greaterThanOrEqualTo(table[i - 1].itemGap));
        expect(
          table[i].containerRadius,
          greaterThanOrEqualTo(table[i - 1].containerRadius),
        );
      }
      expect(MorphMenuDesktopMetrics.of(MorphDensity.compact).itemHeight, 28);
    });
  });
}
