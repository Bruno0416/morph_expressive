import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Column,
        MaterialApp,
        Row,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        Widget,
        EdgeInsets,
        Color,
        Size,
        Padding;
import 'package:morph_expressive/morph_expressive.dart';

/// Diagnostic page (`--dart-define=MORPH_AA_PROBE=true`): the same widgets
/// painted directly (left) and through [MorphSmoothEdges] (right).
class AaProbeApp extends StatefulWidget {
  const AaProbeApp({super.key});
  @override
  State<AaProbeApp> createState() => _AaProbeAppState();
}

class _AaProbeAppState extends State<AaProbeApp> {
  Widget _pair(Widget Function() build) => Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        SizedBox(width: 300, child: build()),
        const SizedBox(width: 40),
        SizedBox(width: 300, child: MorphSmoothEdges(child: build())),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('left: direct · right: MorphSmoothEdges'),
            Row(
              children: [
                for (final r in [
                  0.0,
                  6.283185307179586,
                  6.283185307179586 + 1e-7,
                ])
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: MorphShapeView(
                      shape: MorphShape.ellipse(width: 1, height: .64),
                      size: const Size(120, 120),
                      rotationRadians: r,
                      renderer: MorphShapeRenderer.shader,
                      color: const Color(0xff6750a4),
                    ),
                  ),
              ],
            ),
            _pair(() => const MorphProgressIndicator.circular(value: .62)),
            _pair(() => const MorphProgressIndicator.linear(value: .62)),
            _pair(
              () => const MorphProgressIndicator.circularWavy(
                value: .55,
                size: 45,
              ),
            ),
            _pair(() => const MorphProgressIndicator.linearWavy(value: .55)),
            _pair(() => MorphSlider(value: .4, onChanged: (_) {})),
            _pair(
              () => MorphButton(onPressed: () {}, child: const Text('Button')),
            ),
          ],
        ),
      ),
    ),
  );
}
