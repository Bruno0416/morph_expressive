part of 'morph_theme_data.dart';

MorphThemeData _morphDeriveDarkTemplate(MorphThemeData source) {
  return MorphThemeData.dark(seedColor: source.colorScheme.primary).copyWith(
    typography: source.typography,
    iconTheme: source.iconTheme,
    spacing: source.spacing,
    visualDensity: source.visualDensity,
    platform: source.platform,
    useMaterial3: source.useMaterial3,
    splashColor: source.splashColor,
    highlightColor: source.highlightColor,
    keyboardFocusIndicators: source.keyboardFocusIndicators,
    hapticsEnabled: source.hapticsEnabled,
    reduceMotion: source.reduceMotion,
    hapticFeedback: source.hapticFeedback,
    focusRingTheme: source.focusRingTheme,
    appBarTheme: source.appBarTheme,
    badgeTheme: source.badgeTheme,
    bottomSheetTheme: source.bottomSheetTheme,
    buttonTheme: source.buttonTheme,
    cardTheme: source.cardTheme,
    carouselTheme: source.carouselTheme,
    checkboxTheme: source.checkboxTheme,
    chipTheme: source.chipTheme,
    datePickerTheme: source.datePickerTheme,
    dialogTheme: source.dialogTheme,
    dividerTheme: source.dividerTheme,
    dropdownMenuTheme: source.dropdownMenuTheme,
    fabTheme: source.fabTheme,
    fabMenuTheme: source.fabMenuTheme,
    iconButtonTheme: source.iconButtonTheme,
    listTheme: source.listTheme,
    loadingIndicatorTheme: source.loadingIndicatorTheme,
    menuTheme: source.menuTheme,
    navigationBarTheme: source.navigationBarTheme,
    navigationDrawerTheme: source.navigationDrawerTheme,
    navigationRailTheme: source.navigationRailTheme,
    progressIndicatorTheme: source.progressIndicatorTheme,
    radioTheme: source.radioTheme,
    refreshIndicatorTheme: source.refreshIndicatorTheme,
    searchBarTheme: source.searchBarTheme,
    searchViewTheme: source.searchViewTheme,
    segmentedButtonTheme: source.segmentedButtonTheme,
    selectionTheme: source.selectionTheme,
    sideSheetTheme: source.sideSheetTheme,
    sliderTheme: source.sliderTheme,
    snackBarTheme: source.snackBarTheme,
    splitButtonTheme: source.splitButtonTheme,
    switchTheme: source.switchTheme,
    tabTheme: source.tabTheme,
    textFieldTheme: source.textFieldTheme,
    timePickerTheme: source.timePickerTheme,
    buttonGroupTheme: source.buttonGroupTheme,
    toolbarTheme: source.toolbarTheme,
    tooltipTheme: source.tooltipTheme,
  );
}

MorphThemeData _morphCopyThemeData(
  MorphThemeData source, {
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
  bool? reduceMotion,
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
}) {
  final MorphTypography nextTypography = _resolveCopyWithTypography(
    source,
    typography: typography,
    typeScale: typeScale,
    typeface: typeface,
    variableFont: variableFont,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package,
    fontVariations: fontVariations,
  );

  return MorphThemeData(
    colorScheme: colorScheme ?? source.colorScheme,
    typography: nextTypography,
    iconTheme: iconTheme ?? source.iconTheme,
    spacing: spacing ?? source.spacing,
    visualDensity: visualDensity ?? source.visualDensity,
    platform: platform ?? source.platform,
    useMaterial3: useMaterial3 ?? source.useMaterial3,
    splashColor: splashColor ?? source.splashColor,
    highlightColor: highlightColor ?? source.highlightColor,
    keyboardFocusIndicators:
        keyboardFocusIndicators ?? source.keyboardFocusIndicators,
    hapticsEnabled: hapticsEnabled ?? source.hapticsEnabled,
    reduceMotion: reduceMotion ?? source.reduceMotion,
    hapticFeedback: hapticFeedback ?? source.hapticFeedback,
    focusRingTheme: focusRingTheme ?? source.focusRingTheme,
    appBarTheme: appBarTheme ?? source.appBarTheme,
    badgeTheme: badgeTheme ?? source.badgeTheme,
    bottomSheetTheme: bottomSheetTheme ?? source.bottomSheetTheme,
    buttonTheme: buttonTheme ?? source.buttonTheme,
    cardTheme: cardTheme ?? source.cardTheme,
    carouselTheme: carouselTheme ?? source.carouselTheme,
    checkboxTheme: checkboxTheme ?? source.checkboxTheme,
    chipTheme: chipTheme ?? source.chipTheme,
    datePickerTheme: datePickerTheme ?? source.datePickerTheme,
    dialogTheme: dialogTheme ?? source.dialogTheme,
    dividerTheme: dividerTheme ?? source.dividerTheme,
    dropdownMenuTheme: dropdownMenuTheme ?? source.dropdownMenuTheme,
    fabTheme: fabTheme ?? source.fabTheme,
    fabMenuTheme: fabMenuTheme ?? source.fabMenuTheme,
    iconButtonTheme: iconButtonTheme ?? source.iconButtonTheme,
    listTheme: listTheme ?? source.listTheme,
    loadingIndicatorTheme:
        loadingIndicatorTheme ?? source.loadingIndicatorTheme,
    menuTheme: menuTheme ?? source.menuTheme,
    navigationBarTheme: navigationBarTheme ?? source.navigationBarTheme,
    navigationDrawerTheme:
        navigationDrawerTheme ?? source.navigationDrawerTheme,
    navigationRailTheme: navigationRailTheme ?? source.navigationRailTheme,
    progressIndicatorTheme:
        progressIndicatorTheme ?? source.progressIndicatorTheme,
    radioTheme: radioTheme ?? source.radioTheme,
    refreshIndicatorTheme:
        refreshIndicatorTheme ?? source.refreshIndicatorTheme,
    searchBarTheme: searchBarTheme ?? source.searchBarTheme,
    searchViewTheme: searchViewTheme ?? source.searchViewTheme,
    segmentedButtonTheme: segmentedButtonTheme ?? source.segmentedButtonTheme,
    selectionTheme: selectionTheme ?? source.selectionTheme,
    sideSheetTheme: sideSheetTheme ?? source.sideSheetTheme,
    sliderTheme: sliderTheme ?? source.sliderTheme,
    snackBarTheme: snackBarTheme ?? source.snackBarTheme,
    splitButtonTheme: splitButtonTheme ?? source.splitButtonTheme,
    switchTheme: switchTheme ?? source.switchTheme,
    tabTheme: tabTheme ?? source.tabTheme,
    textFieldTheme: textFieldTheme ?? source.textFieldTheme,
    timePickerTheme: timePickerTheme ?? source.timePickerTheme,
    buttonGroupTheme: buttonGroupTheme ?? source.buttonGroupTheme,
    toolbarTheme: toolbarTheme ?? source.toolbarTheme,
    tooltipTheme: tooltipTheme ?? source.tooltipTheme,
  );
}

MorphTypography _resolveCopyWithTypography(
  MorphThemeData source, {
  MorphTypography? typography,
  MorphTypeScale? typeScale,
  MorphTypefaceConfig? typeface,
  MorphVariableFontConfig? variableFont,
  String? fontFamily,
  List<String>? fontFamilyFallback,
  String? package,
  List<FontVariation>? fontVariations,
}) {
  MorphTypography nextTypography = typography ?? source.typography;
  if (typeScale != null && typography == null) {
    nextTypography = MorphTypography(
      baseline: typeScale,
      emphasized: nextTypography.emphasized,
    );
  }

  if (variableFont != null) {
    final MorphVariableFontConfig config = fontVariations == null
        ? variableFont
        : variableFont.copyWith(
            extraVariations: <FontVariation>[
              ...variableFont.extraVariations,
              ...fontVariations,
            ],
          );
    return nextTypography
        .apply(
          fontFamily: fontFamily,
          typeface: typeface,
          fontFamilyFallback: fontFamilyFallback,
          package: package,
        )
        .applyVariableFont(config);
  }

  if (fontFamily != null ||
      typeface != null ||
      fontFamilyFallback != null ||
      package != null ||
      fontVariations != null) {
    return nextTypography.apply(
      fontFamily: fontFamily,
      typeface: typeface,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      fontVariations: fontVariations,
    );
  }

  return nextTypography;
}
