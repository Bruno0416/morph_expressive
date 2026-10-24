import 'package:flutter/widgets.dart';

/// Reduces decorative motion for an application or a component subtree.
///
/// The system and ancestor preferences always take precedence: false means
/// follow them, not force animation. Essential input, scrolling and progress
/// semantics remain available.
class MorphMotionScope extends StatefulWidget {
  const MorphMotionScope({
    required this.child,
    this.reduceMotion = false,
    super.key,
  });

  final bool reduceMotion;
  final Widget child;

  /// Resolves MediaQuery, the platform and the nearest local preference.
  static bool reducedOf(BuildContext context, {bool listen = true}) {
    final inherited = listen
        ? context.dependOnInheritedWidgetOfExactType<MorphMotionPolicy>()
        : context.getInheritedWidgetOfExactType<MorphMotionPolicy>();
    final query = listen
        ? MediaQuery.maybeOf(context)
        : context.getInheritedWidgetOfExactType<MediaQuery>()?.data;
    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    return (inherited?.notifier.value ?? false) ||
        (query?.disableAnimations ?? false) ||
        features.disableAnimations ||
        features.reduceMotion;
  }

  @override
  State<MorphMotionScope> createState() => _MorphMotionScopeState();
}

class _MorphMotionScopeState extends State<MorphMotionScope>
    with WidgetsBindingObserver {
  final _policy = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAccessibilityFeatures() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final reduced = widget.reduceMotion || MorphMotionScope.reducedOf(context);
    _policy.value = reduced;
    final query = MediaQuery.maybeOf(context);
    Widget child = MorphMotionPolicy(
      notifier: _policy,
      value: reduced,
      child: widget.child,
    );
    if (query != null) {
      child = MediaQuery(
        data: query.copyWith(disableAnimations: reduced),
        child: child,
      );
    }
    return child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _policy.dispose();
    super.dispose();
  }
}

/// Internal notification bridge for controllers that cannot depend on an
/// inherited widget during initState or pointer callbacks.
class MorphMotionPolicy extends InheritedTheme {
  const MorphMotionPolicy({
    required this.notifier,
    required this.value,
    required super.child,
    super.key,
  });

  final ValueNotifier<bool> notifier;
  final bool value;

  @override
  bool updateShouldNotify(MorphMotionPolicy oldWidget) =>
      value != oldWidget.value;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      MorphMotionScope(reduceMotion: value, child: child);
}
