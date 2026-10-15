// Button state + icon layout extracted for file_length.
part of '../morph_buttons.dart';

class _MorphButtonIconLayout extends StatelessWidget {
  const _MorphButtonIconLayout({
    required this.icon,
    required this.label,
    required this.size,
    required this.iconAlignment,
  });

  final Widget icon;
  final Widget label;
  final MorphButtonSize size;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final m = MorphTheme.of(context).buttonTheme.measurements(size);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final maxLines = textScale >= 2.0 ? 2 : 1;
    final children = <Widget>[
      RepaintBoundary(
        child: IconTheme.merge(
          data: IconThemeData(size: m.iconSize),
          child: icon,
        ),
      ),
      SizedBox(width: m.iconGap),
      Flexible(
        child: DefaultTextStyle.merge(
          maxLines: maxLines,
          softWrap: maxLines > 1,
          overflow: TextOverflow.ellipsis,
          child: label,
        ),
      ),
    ];

    if (iconAlignment == IconAlignment.end) {
      children.setAll(0, [children[2], children[1], children[0]]);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class _MorphButtonState extends State<MorphButton>
    with MorphBaseButtonState<MorphButton> {
  late MorphButtonMeasurements _measurements;

  /// [MorphButton.decoration] merged over the nearest scope decoration.
  MorphButtonDecoration? _decoration;

  MorphButtonTheme get _buttonTheme => MorphTheme.of(context).buttonTheme;

  MorphColorScheme get _scheme => MorphTheme.of(context).colorScheme;

  @override
  MorphButtonSize get buttonSize => widget.size;

  @override
  WidgetStatesController? get externalStatesController =>
      widget.statesController;

  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  MorphButtonMotion? get effectiveMotion {
    final decorationMotion = _decoration?.motion;
    if (decorationMotion != null) {
      return decorationMotion;
    }
    final spring = _buttonTheme.shapeSpring;
    return MorphButtonMotion(
      stiffness: spring.stiffness,
      damping: spring.damping,
    );
  }

  @override
  void initState() {
    super.initState();
    initBaseButtonState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveDecoration();
    _updateMeasurements();
    updateLabelStyle(context);
    updateSpringMotion();
  }

  /// Own decoration merged over the nearest [MorphButtonDecorationScope].
  void _resolveDecoration() {
    final MorphButtonDecoration? scoped = MorphButtonDecorationScope.maybeOf(
      context,
      widget.style,
    );
    _decoration = scoped == null
        ? widget.decoration
        : scoped.merge(widget.decoration);
  }

  void _updateMeasurements() {
    _measurements = _buttonTheme.measurements(widget.size);
  }

  @override
  void didUpdateWidget(covariant MorphButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleStatesControllerUpdate(
      oldWidget.statesController,
      widget.statesController,
    );
    handleFocusNodeUpdate(oldWidget.focusNode, widget.focusNode);

    if (oldWidget.size != widget.size) {
      _updateMeasurements();
    }

    final MorphButtonDecoration? previous = _decoration;
    _resolveDecoration();
    if (oldWidget.size != widget.size ||
        previous?.foregroundColor != _decoration?.foregroundColor ||
        oldWidget.style != widget.style) {
      updateLabelStyle(context);
    }

    if (_decoration?.motion != previous?.motion) {
      updateSpringMotion();
    }
  }

  @override
  void dispose() {
    disposeBaseButtonState();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<MorphButtonStyle>('style', widget.style))
      ..add(DiagnosticsProperty<MorphButtonSize>('size', widget.size))
      ..add(EnumProperty<MorphButtonShape>('shape', widget.shape))
      ..add(
        FlagProperty('enabled', value: widget.enabled, ifFalse: 'disabled'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildContent);
  }
}
