import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show Brightness, Color, TargetPlatform, TextTheme, ThemeData, VisualDensity;

import '../../components/app_bars/styles/morph_app_bar_theme.dart';
import '../../components/badges/styles/morph_badge_theme.dart';
import '../../components/bottom_sheets/styles/morph_bottom_sheet_theme.dart';
import '../../components/button_group/styles/morph_button_group_theme.dart';
import '../../components/buttons/styles/morph_button_theme.dart';
import '../../components/cards/styles/morph_card_theme.dart';
import '../../components/carousel/styles/morph_carousel_theme.dart';
import '../../components/checkbox/styles/morph_checkbox_theme.dart';
import '../../components/chips/styles/morph_chip_theme.dart';
import '../../components/date_pickers/styles/morph_date_picker_theme.dart';
import '../../components/dialogs/styles/morph_dialog_theme.dart';
import '../../components/divider/styles/morph_divider_theme.dart';
import '../../components/dropdown_menus/styles/morph_dropdown_menu_theme.dart';
import '../../components/fab_menu/styles/morph_fab_menu_theme.dart';
import '../../components/floating_action_buttons/styles/morph_fab_theme.dart';
import '../../components/icon_buttons/styles/morph_icon_button_theme.dart';
import '../../components/lists/styles/morph_list_theme.dart';
import '../../components/loading_indicator/styles/morph_loading_indicator_theme.dart';
import '../../components/menus/styles/morph_menu_theme.dart';
import '../../components/navigation_bar/styles/morph_navigation_bar_theme.dart';
import '../../components/navigation_drawer/styles/morph_navigation_drawer_theme.dart';
import '../../components/navigation_rail/styles/morph_navigation_rail_theme.dart';
import '../../components/progress_indicators/styles/morph_progress_indicator_theme.dart';
import '../../components/radio_button/styles/morph_radio_theme.dart';
import '../../components/refresh_indicator/styles/morph_refresh_indicator_theme.dart';
import '../../components/search/styles/morph_search_bar_theme.dart';
import '../../components/search/styles/morph_search_view_theme.dart';
import '../../components/segmented_buttons/styles/morph_segmented_button_theme.dart';
import '../../components/selection/styles/morph_selection_theme.dart';
import '../../components/side_sheets/styles/morph_side_sheet_theme.dart';
import '../../components/sliders/styles/morph_slider_theme.dart';
import '../../components/snackbar/styles/morph_snackbar_theme.dart';
import '../../components/split_buttons/styles/morph_split_button_theme.dart';
import '../../components/switch_control/styles/morph_switch_theme.dart';
import '../../components/tabs/styles/morph_tab_theme.dart';
import '../../components/text_fields/styles/morph_text_field_theme.dart';
import '../../components/time_pickers/styles/morph_time_picker_theme.dart';
import '../../components/toolbars/styles/morph_toolbar_theme.dart';
import '../../components/tooltips/styles/morph_tooltip_theme.dart';
import '../color/morph_color_scheme.dart';
import '../interaction/morph_focus_ring_theme.dart';
import '../interaction/morph_haptics.dart';
import '../tokens/morph_spacing.dart';
import '../type/morph_typography.dart';
import '../type/morph_variable_font_config.dart';

part 'morph_theme_data_copy_with.dart';

/// Immutable bundle of expressive design tokens and per-component themes.
@immutable
class MorphThemeData {
  /// Creates an expressive theme from tokens and component themes.
  MorphThemeData({
    MorphColorScheme? colorScheme,
    MorphTypography? typography,
    MorphTypeScale? typeScale,
    TextTheme? textTheme,
    this.iconTheme = const IconThemeData(size: 24),
    this.spacing = const MorphSpacing.regular(),
    this.visualDensity = 0,
    this.platform,
    this.useMaterial3 = true,
    this.splashColor,
    this.highlightColor,
    this.keyboardFocusIndicators = true,
    this.hapticsEnabled = true,
    this.hapticFeedback = MorphHapticFeedback.light,
    this.focusRingTheme = MorphFocusRingTheme.defaults,
    this.appBarTheme = MorphAppBarTheme.defaults,
    this.badgeTheme = MorphBadgeTheme.defaults,
    this.bottomSheetTheme = MorphBottomSheetTheme.defaults,
    this.buttonTheme = MorphButtonTheme.defaults,
    this.cardTheme = MorphCardTheme.defaults,
    this.carouselTheme = MorphCarouselTheme.defaults,
    this.checkboxTheme = MorphCheckboxTheme.defaults,
    this.chipTheme = MorphChipTheme.defaults,
    this.datePickerTheme = MorphDatePickerTheme.defaults,
    this.dialogTheme = MorphDialogTheme.defaults,
    this.dividerTheme = MorphDividerTheme.defaults,
    this.dropdownMenuTheme = MorphDropdownMenuTheme.defaults,
    this.fabTheme = MorphFabTheme.defaults,
    this.fabMenuTheme = MorphFabMenuTheme.defaults,
    this.iconButtonTheme = MorphIconButtonTheme.defaults,
    this.listTheme = MorphListTheme.defaults,
    this.loadingIndicatorTheme = MorphLoadingIndicatorTheme.defaults,
    this.menuTheme = MorphMenuTheme.defaults,
    this.navigationBarTheme = MorphNavigationBarTheme.defaults,
    this.navigationDrawerTheme = MorphNavigationDrawerTheme.defaults,
    this.navigationRailTheme = MorphNavigationRailTheme.defaults,
    this.progressIndicatorTheme = MorphProgressIndicatorTheme.defaults,
    this.radioTheme = MorphRadioTheme.defaults,
    this.refreshIndicatorTheme = MorphRefreshIndicatorTheme.defaults,
    this.searchBarTheme = MorphSearchBarTheme.defaults,
    this.searchViewTheme = MorphSearchViewTheme.defaults,
    this.segmentedButtonTheme = MorphSegmentedButtonTheme.defaults,
    this.selectionTheme = MorphSelectionTheme.defaults,
    this.sideSheetTheme = MorphSideSheetTheme.defaults,
    this.sliderTheme = MorphSliderTheme.defaults,
    this.snackBarTheme = MorphSnackbarTheme.defaults,
    this.splitButtonTheme = MorphSplitButtonTheme.defaults,
    this.switchTheme = MorphSwitchTheme.defaults,
    this.tabTheme = MorphTabTheme.defaults,
    this.textFieldTheme = MorphTextFieldTheme.defaults,
    this.timePickerTheme = MorphTimePickerTheme.defaults,
    this.buttonGroupTheme = MorphButtonGroupTheme.defaults,
    this.toolbarTheme = MorphToolbarTheme.defaults,
    this.tooltipTheme = MorphTooltipTheme.defaults,
  }) : colorScheme = colorScheme ?? MorphColorScheme.light(),
       typography = _resolveTypography(typography, typeScale, textTheme),
       brightness = (colorScheme ?? MorphColorScheme.light()).brightness;

  static MorphTypography _resolveTypography(
    MorphTypography? typography,
    MorphTypeScale? typeScale,
    TextTheme? textTheme,
  ) {
    if (typography != null) {
      return typography;
    }
    if (textTheme != null) {
      // 1. tomar los estilos proporcionados por la aplicacion (Google Fonts, etc.)
      final baseline = MorphTypeScale.fromTextTheme(textTheme);
      final fontFamily =
          textTheme.bodyMedium?.fontFamily ?? textTheme.bodyLarge?.fontFamily;
      return MorphTypography(
        baseline: baseline,
        emphasized: MorphTypeScale.emphasized().apply(fontFamily: fontFamily),
      );
    }
    if (typeScale != null) {
      return MorphTypography(
        baseline: typeScale,
        emphasized: MorphTypeScale.emphasized(),
      );
    }
    return MorphTypography.material3();
  }

  /// Light theme, optionally seeded from [seedColor].
  factory MorphThemeData.light({Color? seedColor, TextTheme? textTheme}) {
    return MorphThemeData(
      textTheme: textTheme,
      colorScheme: seedColor == null
          ? MorphColorScheme.light()
          : MorphColorScheme.fromSeed(seedColor),
    );
  }

  /// Dark theme, optionally seeded from [seedColor].
  factory MorphThemeData.dark({Color? seedColor, TextTheme? textTheme}) {
    return MorphThemeData(
      textTheme: textTheme,
      colorScheme: seedColor == null
          ? MorphColorScheme.dark()
          : MorphColorScheme.fromSeed(seedColor, brightness: Brightness.dark),
    );
  }

  /// Adapts a Material [ThemeData] into an [MorphThemeData].
  factory MorphThemeData.fromMaterial(ThemeData theme) {
    final MorphThemeData? cached = _materialCache[theme];
    if (cached != null) {
      return cached;
    }
    final data = MorphThemeData(
      colorScheme: MorphColorScheme.fromColorScheme(theme.colorScheme),
      typography: MorphTypography(
        baseline: MorphTypeScale.fromTextTheme(theme.textTheme),
        emphasized: MorphTypeScale.emphasized(),
      ),
      iconTheme: theme.iconTheme,
      visualDensity: theme.visualDensity.vertical,
      platform: theme.platform,
      useMaterial3: theme.useMaterial3,
      splashColor: theme.splashColor,
      highlightColor: theme.highlightColor,
    );
    _materialCache[theme] = data;
    return data;
  }

  /// Color roles for this theme.
  final MorphColorScheme colorScheme;

  /// Baseline and emphasized type scales for this theme.
  final MorphTypography typography;

  /// Baseline type scale for this theme (alias for `typography.baseline`).
  MorphTypeScale get typeScale => typography.baseline;

  /// Default icon size/opacity/etc. When color is null, icons use
  /// [MorphColorScheme.onSurface] (including after dynamic color updates).
  final IconThemeData iconTheme;

  /// Spacing scale for this theme.
  final MorphSpacing spacing;

  /// Visual density offset applied to Material [VisualDensity].
  final double visualDensity;

  /// Target platform overrides, if any.
  final TargetPlatform? platform;

  /// Whether Material 3 behavior is enabled in [toThemeData].
  final bool useMaterial3;

  /// Optional splash color override for ink.
  final Color? splashColor;

  /// Optional highlight color override for ink.
  final Color? highlightColor;

  /// Whether keyboard Tab focus rings and focus-state chrome are shown.
  ///
  /// When false, Tab traversal and activation still work, but no focus ring or
  /// focus state-layer indicators are painted. Defaults to true.
  final bool keyboardFocusIndicators;

  /// Whether Morph interactions emit haptic feedback. Defaults to true.
  /// This setting overrides all component-level feedback preferences.
  final bool hapticsEnabled;

  /// Default impact intensity inherited by Morph components.
  /// A component may explicitly use [MorphHapticFeedback.none] to opt out.
  final MorphHapticFeedback hapticFeedback;

  /// Shared keyboard focus ring tokens for actionable controls.
  final MorphFocusRingTheme focusRingTheme;

  /// Brightness derived from [colorScheme].
  final Brightness brightness;

  /// [typeScale] as a Material [TextTheme], colored with
  /// [MorphColorScheme.onSurface] so it tracks the active scheme.
  TextTheme get textTheme =>
      typeScale.withColor(colorScheme.onSurface).toTextTheme();

  /// [iconTheme] with [MorphColorScheme.onSurface] when no explicit color is set.
  IconThemeData get resolvedIconTheme =>
      iconTheme.copyWith(color: iconTheme.color ?? colorScheme.onSurface);

  /// App bar component theme.
  final MorphAppBarTheme appBarTheme;

  /// Badge component theme.
  final MorphBadgeTheme badgeTheme;

  /// Bottom sheet component theme.
  final MorphBottomSheetTheme bottomSheetTheme;

  /// Button component theme.
  final MorphButtonTheme buttonTheme;

  /// Card component theme.
  final MorphCardTheme cardTheme;

  /// Carousel component theme.
  final MorphCarouselTheme carouselTheme;

  /// Checkbox component theme.
  final MorphCheckboxTheme checkboxTheme;

  /// Chip component theme.
  final MorphChipTheme chipTheme;

  /// Date picker component theme.
  final MorphDatePickerTheme datePickerTheme;

  /// Dialog component theme.
  final MorphDialogTheme dialogTheme;

  /// Divider component theme.
  final MorphDividerTheme dividerTheme;

  /// Dropdown menu component theme.
  final MorphDropdownMenuTheme dropdownMenuTheme;

  /// FAB component theme.
  final MorphFabTheme fabTheme;

  /// FAB menu component theme.
  final MorphFabMenuTheme fabMenuTheme;

  /// Icon button component theme.
  final MorphIconButtonTheme iconButtonTheme;

  /// List component theme.
  final MorphListTheme listTheme;

  /// Loading indicator component theme.
  final MorphLoadingIndicatorTheme loadingIndicatorTheme;

  /// Menu component theme.
  final MorphMenuTheme menuTheme;

  /// Navigation bar component theme.
  final MorphNavigationBarTheme navigationBarTheme;

  /// Navigation drawer component theme.
  final MorphNavigationDrawerTheme navigationDrawerTheme;

  /// Navigation rail component theme.
  final MorphNavigationRailTheme navigationRailTheme;

  /// Progress indicator component theme.
  final MorphProgressIndicatorTheme progressIndicatorTheme;

  /// Radio button component theme.
  final MorphRadioTheme radioTheme;

  /// Refresh indicator component theme.
  final MorphRefreshIndicatorTheme refreshIndicatorTheme;

  /// Search bar component theme.
  final MorphSearchBarTheme searchBarTheme;

  /// Search view component theme.
  final MorphSearchViewTheme searchViewTheme;

  /// Segmented button component theme.
  final MorphSegmentedButtonTheme segmentedButtonTheme;

  /// Selection list / app bar component theme.
  final MorphSelectionTheme selectionTheme;

  /// Side sheet component theme.
  final MorphSideSheetTheme sideSheetTheme;

  /// Slider component theme.
  final MorphSliderTheme sliderTheme;

  /// Snackbar component theme.
  final MorphSnackbarTheme snackBarTheme;

  /// Split button component theme.
  final MorphSplitButtonTheme splitButtonTheme;

  /// Switch component theme.
  final MorphSwitchTheme switchTheme;

  /// Tab component theme.
  final MorphTabTheme tabTheme;

  /// Text field component theme.
  final MorphTextFieldTheme textFieldTheme;

  /// Time picker component theme.
  final MorphTimePickerTheme timePickerTheme;

  /// Button group component theme.
  final MorphButtonGroupTheme buttonGroupTheme;

  /// Toolbar component theme.
  final MorphToolbarTheme toolbarTheme;

  /// Tooltip component theme.
  final MorphTooltipTheme tooltipTheme;

  /// Returns a copy with [colorScheme] swapped and all component themes kept.
  MorphThemeData withColorScheme(MorphColorScheme colorScheme) {
    return copyWith(colorScheme: colorScheme);
  }

  /// Builds a dark template from this light-oriented [MorphThemeData].
  ///
  /// Preserves non-color tokens (type scale, spacing, component themes) while
  /// swapping in a dark `MorphColorScheme` seeded from `colorScheme.primary`.
  MorphThemeData deriveDarkTemplate() => _morphDeriveDarkTemplate(this);

  /// Returns a copy with the given fields replaced.
  MorphThemeData copyWith({
    MorphColorScheme? colorScheme,
    MorphTypography? typography,
    MorphTypeScale? typeScale,
    MorphTypefaceConfig? typeface,
    MorphVariableFontConfig? variableFont,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    List<FontVariation>? fontVariations,
    IconThemeData? iconTheme,
    MorphSpacing? spacing,
    double? visualDensity,
    TargetPlatform? platform,
    bool? useMaterial3,
    Color? splashColor,
    Color? highlightColor,
    bool? keyboardFocusIndicators,
    bool? hapticsEnabled,
    MorphHapticFeedback? hapticFeedback,
    MorphFocusRingTheme? focusRingTheme,
    MorphAppBarTheme? appBarTheme,
    MorphBadgeTheme? badgeTheme,
    MorphBottomSheetTheme? bottomSheetTheme,
    MorphButtonTheme? buttonTheme,
    MorphCardTheme? cardTheme,
    MorphCarouselTheme? carouselTheme,
    MorphCheckboxTheme? checkboxTheme,
    MorphChipTheme? chipTheme,
    MorphDatePickerTheme? datePickerTheme,
    MorphDialogTheme? dialogTheme,
    MorphDividerTheme? dividerTheme,
    MorphDropdownMenuTheme? dropdownMenuTheme,
    MorphFabTheme? fabTheme,
    MorphFabMenuTheme? fabMenuTheme,
    MorphIconButtonTheme? iconButtonTheme,
    MorphListTheme? listTheme,
    MorphLoadingIndicatorTheme? loadingIndicatorTheme,
    MorphMenuTheme? menuTheme,
    MorphNavigationBarTheme? navigationBarTheme,
    MorphNavigationDrawerTheme? navigationDrawerTheme,
    MorphNavigationRailTheme? navigationRailTheme,
    MorphProgressIndicatorTheme? progressIndicatorTheme,
    MorphRadioTheme? radioTheme,
    MorphRefreshIndicatorTheme? refreshIndicatorTheme,
    MorphSearchBarTheme? searchBarTheme,
    MorphSearchViewTheme? searchViewTheme,
    MorphSegmentedButtonTheme? segmentedButtonTheme,
    MorphSelectionTheme? selectionTheme,
    MorphSideSheetTheme? sideSheetTheme,
    MorphSliderTheme? sliderTheme,
    MorphSnackbarTheme? snackBarTheme,
    MorphSplitButtonTheme? splitButtonTheme,
    MorphSwitchTheme? switchTheme,
    MorphTabTheme? tabTheme,
    MorphTextFieldTheme? textFieldTheme,
    MorphTimePickerTheme? timePickerTheme,
    MorphButtonGroupTheme? buttonGroupTheme,
    MorphToolbarTheme? toolbarTheme,
    MorphTooltipTheme? tooltipTheme,
  }) => _morphCopyThemeData(
    this,
    colorScheme: colorScheme,
    typography: typography,
    typeScale: typeScale,
    typeface: typeface,
    variableFont: variableFont,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package,
    fontVariations: fontVariations,
    iconTheme: iconTheme,
    spacing: spacing,
    visualDensity: visualDensity,
    platform: platform,
    useMaterial3: useMaterial3,
    splashColor: splashColor,
    highlightColor: highlightColor,
    keyboardFocusIndicators: keyboardFocusIndicators,
    hapticsEnabled: hapticsEnabled,
    hapticFeedback: hapticFeedback,
    focusRingTheme: focusRingTheme,
    appBarTheme: appBarTheme,
    badgeTheme: badgeTheme,
    bottomSheetTheme: bottomSheetTheme,
    buttonTheme: buttonTheme,
    cardTheme: cardTheme,
    carouselTheme: carouselTheme,
    checkboxTheme: checkboxTheme,
    chipTheme: chipTheme,
    datePickerTheme: datePickerTheme,
    dialogTheme: dialogTheme,
    dividerTheme: dividerTheme,
    dropdownMenuTheme: dropdownMenuTheme,
    fabTheme: fabTheme,
    fabMenuTheme: fabMenuTheme,
    iconButtonTheme: iconButtonTheme,
    listTheme: listTheme,
    loadingIndicatorTheme: loadingIndicatorTheme,
    menuTheme: menuTheme,
    navigationBarTheme: navigationBarTheme,
    navigationDrawerTheme: navigationDrawerTheme,
    navigationRailTheme: navigationRailTheme,
    progressIndicatorTheme: progressIndicatorTheme,
    radioTheme: radioTheme,
    refreshIndicatorTheme: refreshIndicatorTheme,
    searchBarTheme: searchBarTheme,
    searchViewTheme: searchViewTheme,
    segmentedButtonTheme: segmentedButtonTheme,
    selectionTheme: selectionTheme,
    sideSheetTheme: sideSheetTheme,
    sliderTheme: sliderTheme,
    snackBarTheme: snackBarTheme,
    splitButtonTheme: splitButtonTheme,
    switchTheme: switchTheme,
    tabTheme: tabTheme,
    textFieldTheme: textFieldTheme,
    timePickerTheme: timePickerTheme,
    buttonGroupTheme: buttonGroupTheme,
    toolbarTheme: toolbarTheme,
    tooltipTheme: tooltipTheme,
  );

  /// Projects this theme onto a Material [ThemeData].
  ThemeData toThemeData() {
    final IconThemeData icons = resolvedIconTheme;
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: colorScheme.toColorScheme(),
      textTheme: textTheme,
      iconTheme: icons,
      primaryIconTheme: icons.copyWith(color: colorScheme.onPrimary),
      visualDensity: VisualDensity(
        horizontal: visualDensity,
        vertical: visualDensity,
      ),
      platform: platform,
      splashColor: splashColor,
      highlightColor: highlightColor,
    );
  }
}

final Expando<MorphThemeData> _materialCache = Expando<MorphThemeData>();
