import 'package:material_ui/material_ui.dart' show runApp;

import 'main.dart';

/// Native Android/iOS preview for testing Morph on a physical device.
void main() => runApp(const MorphPreviewApp(mobileLab: true));
