import 'package:material_ui/material_ui.dart'
    show
        Brightness,
        BuildContext,
        ScrollConfiguration,
        State,
        StatefulWidget,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';

import '../../mobile_frosted_surfaces_lab.dart';
import '../../mobile_haptics_lab.dart';
import '../../mobile_scroll_blur_lab.dart';

/// Hosts the mobile glass/haptics labs, which keep their controls in the
/// parent. The brightness follows the Morph panel; glass and haptics state
/// live here and are applied to a nested [MorphTheme] exactly as the native
/// mobile preview does.
enum MobileLabKind { frostedSurfaces, scrollBlur, haptics }

class MobileLabHost extends StatefulWidget {
  const MobileLabHost({super.key, required this.kind});

  final MobileLabKind kind;

  @override
  State<MobileLabHost> createState() => _MobileLabHostState();
}

class _MobileLabHostState extends State<MobileLabHost> {
  bool _glassEnabled = true;
  double _blur = 12;
  double _tint = 0.65;
  bool _haptics = true;
  MorphHapticFeedback _feedback = MorphHapticFeedback.light;

  @override
  Widget build(BuildContext context) {
    final base = MorphTheme.of(context);
    final dark = base.brightness == Brightness.dark;
    final themed = base.copyWith(
      hapticsEnabled: _haptics,
      hapticFeedback: _feedback,
      floatingSurfaceGlass: MorphSurfaceGlass(
        enabled: _glassEnabled,
        blurX: _blur,
        blurY: _blur,
        tintOpacity: _tint,
      ),
    );
    final lab = switch (widget.kind) {
      MobileLabKind.frostedSurfaces => MorphFrostedSurfacesLab(
        darkMode: dark,
        onToggleTheme: () {},
        glassEnabled: _glassEnabled,
        onGlassEnabledChanged: (v) => setState(() => _glassEnabled = v),
        blur: _blur,
        onBlurChanged: (v) => setState(() => _blur = v),
        tintOpacity: _tint,
        onTintOpacityChanged: (v) => setState(() => _tint = v),
        hapticsEnabled: _haptics,
        hapticFeedback: _feedback,
        onHapticsEnabledChanged: (v) => setState(() => _haptics = v),
        onHapticFeedbackChanged: (v) => setState(() {
          _feedback = v;
          _haptics = true;
        }),
      ),
      MobileLabKind.scrollBlur => MorphScrollBlurLab(
        darkMode: dark,
        onToggleTheme: () {},
        glassEnabled: _glassEnabled,
        onGlassEnabledChanged: (v) => setState(() => _glassEnabled = v),
        blur: _blur,
        onBlurChanged: (v) => setState(() => _blur = v),
        tintOpacity: _tint,
        onTintOpacityChanged: (v) => setState(() => _tint = v),
      ),
      MobileLabKind.haptics => MorphMobileHapticsLab(
        hapticsEnabled: _haptics,
        hapticFeedback: _feedback,
        onHapticsEnabledChanged: (v) => setState(() => _haptics = v),
        onHapticFeedbackChanged: (v) => setState(() {
          _feedback = v;
          _haptics = true;
        }),
        darkMode: dark,
        onToggleTheme: () {},
      ),
    };
    return MorphTheme(
      data: themed,
      child: ScrollConfiguration(
        behavior: const MorphScrollBehavior(),
        child: lab,
      ),
    );
  }
}
