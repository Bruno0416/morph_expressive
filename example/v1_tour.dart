// A tour of the 1.0.0 component API: visual types (named constructors), color
// roles (`variant`) and surface finishes (`surface`), plus density, brightness
// control, controlled async buttons and desktop context menus.
//
//   flutter run -t example/v1_tour.dart
import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Center,
        Color,
        Column,
        Container,
        CrossAxisAlignment,
        EdgeInsets,
        Icon,
        LinearGradient,
        Padding,
        Radius,
        Scaffold,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextTheme,
        Theme,
        ValueChanged,
        VoidCallback,
        Widget,
        Wrap,
        WrapCrossAlignment,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const V1TourApp());

class V1TourApp extends StatefulWidget {
  const V1TourApp({super.key});

  @override
  State<V1TourApp> createState() => _V1TourAppState();
}

class _V1TourAppState extends State<V1TourApp> {
  static const Color _seed = Color(0xFF6750A4);

  final MorphThemeController _brightness = MorphThemeController();
  MorphDensity _density = MorphDensity.standard;

  @override
  void dispose() {
    _brightness.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorphMaterialApp(
      title: 'Morph Expressive v1 tour',
      // The light template; dark mode is derived from the same seed.
      data: MorphThemeData.light(seedColor: _seed, density: _density),
      controller: _brightness,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _TourPage(
              density: _density,
              onDensityChanged: (value) => setState(() => _density = value),
              onToggleBrightness: _brightness.toggleBrightness,
            ),
          ),
        ),
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage({
    required this.density,
    required this.onDensityChanged,
    required this.onToggleBrightness,
  });

  final MorphDensity density;
  final ValueChanged<MorphDensity> onDensityChanged;
  final VoidCallback onToggleBrightness;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SizedBox(
      width: 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text('Morph Expressive 1.0 tour', style: text.headlineMedium),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MorphSegmentedToggle<MorphDensity>(
                options: [
                  for (final MorphDensity value in MorphDensity.values)
                    MorphSegmentedToggleOption(value: value, label: value.name),
                ],
                selected: density,
                onChanged: onDensityChanged,
              ),
              MorphButton.tonal(
                onPressed: onToggleBrightness,
                icon: Icon(FluentIcons.line.weather_moon),
                label: const Text('Light / dark'),
              ),
            ],
          ),
          Text('Types x roles', style: text.titleLarge),
          const _TypeRoleMatrix(),
          Text('Frosted card over a colorful backdrop', style: text.titleLarge),
          const _FrostedBackdrop(),
          Text('Controlled operation', style: text.titleLarge),
          const _SaveButton(),
          Text('Inputs and chips', style: text.titleLarge),
          const _Inputs(),
          Text('Desktop context menu (right click)', style: text.titleLarge),
          const _ContextMenuTarget(),
        ],
      ),
    );
  }
}

class _TypeRoleMatrix extends StatelessWidget {
  const _TypeRoleMatrix();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Omitting `variant` keeps each type's canonical Material 3 colors.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MorphButton.filled(onPressed: () {}, child: const Text('Filled')),
            MorphButton.tonal(onPressed: () {}, child: const Text('Tonal')),
            MorphButton.elevated(
              onPressed: () {},
              child: const Text('Elevated'),
            ),
            MorphButton.outlined(
              onPressed: () {},
              child: const Text('Outlined'),
            ),
            MorphButton.text(onPressed: () {}, child: const Text('Text')),
          ],
        ),
        for (final MorphVariant variant in MorphVariant.values)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MorphButton.filled(
                variant: variant,
                onPressed: () {},
                child: Text(variant.name),
              ),
              MorphButton.tonal(
                variant: variant,
                onPressed: () {},
                child: Text(variant.name),
              ),
              MorphButton.outlined(
                variant: variant,
                onPressed: () {},
                child: Text(variant.name),
              ),
              MorphIconButton.filled(
                variant: variant,
                onPressed: () {},
                tooltip: 'Add (${variant.name})',
                icon: Icon(FluentIcons.line.add),
              ),
              MorphCard.outlined(
                variant: variant,
                headline: 'Card',
                supportingText: variant.name,
              ),
            ],
          ),
      ],
    );
  }
}

class _FrostedBackdrop extends StatelessWidget {
  const _FrostedBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF4D96FF)],
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(
            width: 260,
            child: MorphCard(
              surface: MorphSurface.frosted,
              headline: 'Frosted card',
              supportingText: 'Content is never blurred, only the backdrop.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton();

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  MorphOperationState _state = MorphOperationState.idle;

  Future<void> _save() async {
    setState(() => _state = MorphOperationState.loading);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }
    setState(() => _state = MorphOperationState.success);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _state = MorphOperationState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MorphAsyncButton(
      label: 'Save changes',
      state: _state,
      labels: const {MorphOperationState.success: 'Saved'},
      onPressed: _save,
    );
  }
}

class _Inputs extends StatefulWidget {
  const _Inputs();

  @override
  State<_Inputs> createState() => _InputsState();
}

class _InputsState extends State<_Inputs> {
  bool _open = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SizedBox(
          width: 360,
          child: MorphTextField.outlined(
            label: 'Email',
            errorText: _error,
            onUnfocus: (value) => setState(
              () => _error = value.contains('@') ? null : 'Enter a valid email',
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            MorphChip.filter(
              label: 'Open now',
              selected: _open,
              onPressed: () => setState(() => _open = !_open),
            ),
            MorphChip.assist(label: 'Directions', onPressed: () {}),
            MorphChip.suggestion(label: 'Nearby', onPressed: () {}),
          ],
        ),
      ],
    );
  }
}

class _ContextMenuTarget extends StatefulWidget {
  const _ContextMenuTarget();

  @override
  State<_ContextMenuTarget> createState() => _ContextMenuTargetState();
}

class _ContextMenuTargetState extends State<_ContextMenuTarget> {
  String _last = 'Nothing chosen yet';

  @override
  Widget build(BuildContext context) {
    return MorphContextMenuRegion<String>(
      onSelected: (value) => setState(() => _last = value),
      children: const <MorphMenuNode>[
        MorphMenuEntry(label: 'Copy', trailingText: 'Ctrl+C', value: 'copy'),
        MorphMenuEntry(label: 'Paste', trailingText: 'Ctrl+V', value: 'paste'),
        MorphMenuDivider(),
        MorphMenuEntry(label: 'Delete', isDestructive: true, value: 'delete'),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: MorphCard.filled(
          headline: 'report.pdf',
          supportingText: 'Right click, long press or press Shift+F10. $_last',
        ),
      ),
    );
  }
}
