part of '../morph_app_bars.dart';

/// Bottom bar. Resting fill stays surface container; elevation follows scroll.
class _MorphBottomAppBar extends StatefulWidget {
  const _MorphBottomAppBar({required this.bar});

  final MorphAppBar bar;

  @override
  State<_MorphBottomAppBar> createState() => _MorphBottomAppBarState();
}

class _MorphBottomAppBarState extends State<_MorphBottomAppBar> {
  ScrollNotificationObserverState? _observer;
  bool _under = false;
  final _MorphPageScroll _pageScroll = _MorphPageScroll();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollNotificationObserverState? next =
        ScrollNotificationObserver.maybeOf(context);
    if (next == _observer) {
      return;
    }
    _observer?.removeListener(_onNotification);
    _observer = next;
    _observer?.addListener(_onNotification);
  }

  @override
  void dispose() {
    _observer?.removeListener(_onNotification);
    super.dispose();
  }

  void _onNotification(ScrollNotification notification) {
    if (!mounted || !_pageScroll.accepts(notification, context)) {
      return;
    }
    final bool under = notification.metrics.extentBefore > 0;
    if (under != _under && mounted) {
      setState(() => _under = under);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MorphAppBar bar = widget.bar;
    final theme = MorphTheme.of(context);
    final appBarTheme = theme.appBarTheme;
    final scheme = theme.colorScheme;
    final metrics = appBarTheme.metrics(bar.density);
    final contentPadding = appBarTheme.bottomPadding.resolve(
      Directionality.of(context),
    );
    final Widget contentBand = SizedBox(
      height: appBarTheme.bottomHeight,
      child: Padding(
        padding: contentPadding,
        child: Row(
          children: <Widget>[
            IconTheme.merge(
              data: IconThemeData(
                color: scheme.onSurfaceVariant,
                size: appBarTheme.bottomIconSize,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: bar.actions ?? const <Widget>[],
              ),
            ),
            const Spacer(),
            ?bar.floatingActionButton,
          ],
        ),
      ),
    );
    return Material(
      color: appBarTheme.bottomBackgroundColor(scheme),
      elevation: _under ? metrics.scrolledElevation : metrics.elevation,
      shadowColor: scheme.shadow,
      surfaceTintColor: const Color(0x00000000),
      child: Padding(
        padding: bar._edgeSafeAreaInset(context),
        child: contentBand,
      ),
    );
  }
}
