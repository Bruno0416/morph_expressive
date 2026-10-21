import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show FocusHighlightStrategy, FocusManager;

void setUpFocusRingTests() {
  MorphFocusInteraction.resetForTest();
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
}

void tearDownFocusRingTests() {
  MorphFocusInteraction.resetForTest();
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
}
