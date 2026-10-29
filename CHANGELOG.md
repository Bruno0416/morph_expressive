# Changelog

## 0.6.0 - 2026-10-28

### Breaking changes

- `MorphNavigationBarDestination.icon` and `selectedIcon` now accept `IconData`
  rather than `Widget`. Replace `icon: Icon(MyIcons.home)` with
  `icon: MyIcons.home`; use `iconWidget` / `selectedIconWidget` for custom
  widgets. This requires migration when upgrading from 0.5.0.
- Named bottom navigation variants now match their designs:
  `MorphNavigationBar.expressive()` renders the animated Material 3 icon pill;
  `MorphNavigationBar.morph()` renders the sliding upper dash with the active
  destination label. Swap constructor names in older usages to retain the
  same appearance. The unnamed `MorphNavigationBar()` remains available.

### Added

- `MorphAppBar.frosted()` with `MorphAppBarGlass`: a surface-color tint rising
  from zero at the bottom to 90% at the top (linear in the lower half,
  exponential above the midpoint) and clipped progressive blur bands. Its
  clear lower blur edge and configurable falloff keep scrolling text legible.
- `MorphNavigationBarHost` supports any bottom bar variant, with optional
  floating glass, hide/reveal on scroll, back-to-top and pull-to-refresh. With
  `onRefresh: null` no refresh indicator is built; when content extends under
  a frosted AppBar the refresh indicator's offset is computed automatically.
  `refreshIndicatorEdgeOffset` allows an explicit override.
- `distributeWideDestinations: true` spaces wide-layout destinations evenly;
  the default `false` keeps grouped placement and `alignment`.
- Configurable `iconSize` and `unselectedIconScale` on all bottom navigation
  bar variants. A scale of `0.9` renders inactive glyphs at 90% of the base
  size while the active glyph stays at full size; selection uses the existing
  spring and respects reduced motion.
- Navigation and AppBar integration examples in the native preview, including
  a combined frosted AppBar + floating bar + optional pull-to-refresh scene.

### Changed and fixed

- Compact `.expressive()` uses a 64dp band; `.morph()` uses a 76dp band with
  clearance for its sliding dash. Unselected Morph icons stay vertically
  centered and the selected icon's offset animates with selection. Docked bars
  continue to respect the system safe area; the standard bar retains its
  original 80dp baseline.
- `MorphPageIndicator.spacing` now represents the real visual gap between
  interactive dots, without reducing accessibility targets.
- The navigation and onboarding capture scene follows the corrected variant
  names and icon-data API. `navigation.gif` remains the original standard
  Material showcase.
- Remove costly live glass examples from the continuously scrolling Web
  gallery while keeping the native preview and isolated tests. The actual
  library glass variants remain available on all declared platforms.
- Add regressions for geometry, variant mapping, wide distribution, icon
  scaling, refresh positioning, and native glass composition.

## 0.5.0 - 2026-10-23

### Added

- Two reproducible navigation GIF capture scenes for Morph bar/page indicators
  and rail/drawer; retain the original MD3E navigation showcase.

### Keep nested frosted blur during external scrolling

- Do not disable a floating navigation bar's backdrop filter when an enclosing
  gallery or page scrolls; only the host's own scroll and visibility control it.
- Preserve the fast native `blurRevealProgress` restoration and internal scroll
  performance guard; add an external-scroll regression test.

### Faster native frosted-bar reveal

- Resume backdrop blur when an upward-revealing floating bar reaches 35% of its
  visibility transition on native, rather than waiting for scroll and spring
  completion. Web keeps its existing performance safeguard.
- Allow per-glass customization via `blurRevealProgress` (0–1).

### Real frosted blur with isolated background composition

- Restore actual backdrop blur in the Flutter Web floating navigation sample
  at a reduced 5px sigma (10px on native) while preserving the styling.
- Move backdrop sampling into a clipped background layer separate from
  animated icons/labels and their Material surface; use a RepaintBoundary.
- Keep the BackdropFilter mounted and toggle its `enabled` flag while scrolling
  or moving the bar, avoiding compositor layer churn; omit the default Material
  shadow on glass (explicit elevation still works).

### Frosted navigation rendering performance

- Pause frosted backdrop sampling while the host's own content scrolls or
  its floating bar animates in/out, without rebuilding the body on every
  scroll update or spring frame.
- Add `MorphNavigationGlass.webBackdropBlur` (true by default) for an explicit
  opt-out of the expensive backdrop filter on Flutter Web only; native glass
  and existing applications retain their previous behavior.
- Permit tint/border-only rendering for users who explicitly disable web
  backdrop blur; the preview now uses a lighter real blur instead.

### Web preview performance

- Give each gallery family its own state and repaint boundary so interactions
  do not rebuild neighboring samples in the continuous gallery.
- Isolate selection for each navigation bar demonstration; changing one bar
  no longer animates all five in lockstep.
- Use the library's lighter sigma-8 frosted blur in the embedded scroll demo,
  preserving the full glass behavior and refresh functionality.

### Refinement: selection, frosted navigation and refresh

- Add `selectionDelay` per Morph bar, rail, drawer and page indicator;
  reduce default trailing-edge timing to 60ms horizontally / 20ms vertically.
- Lower the frosted bar default blur from sigma 20 to 8, and omit the
  `BackdropFilter` layer entirely during scroll (unless explicitly enabled)
  or when both blur sigmas are zero.
- Restore the filled expressive pull-to-refresh spinner with a circular
  determinate/indeterminate progress ring and default elevation 0; Material
  and adaptive refresh variants retain elevation 2.

### Navigation refinement

- Delay the trailing selection edge by 90ms for bar, rail, drawer and page
  indicators; cancel stale targets on reversal, disposal and reduced motion.
- Center the return-to-top button on the floating bar's horizontal axis.
- Suspend host backdrop blur while scrolling by default, with an opt-in
  `MorphNavigationGlass.blurDuringScroll` override for continuous glass.
- Isolate content paints and stop painting/ticking a hidden floating bar;
  avoid an opacity layer over the glass surface.
- Give the floating gallery sample local refresh state, explicit mouse drag
  support, clamping physics and a visible asynchronous refresh lifecycle.
- Add pointer, nesting, glass policy and edge timing regression tests.

### Navigation and onboarding

- Add opt-in `.morph` navigation bar, rail and drawer variants with a shared
  elastic selection pill and system-aware reduced motion.
- Add `.expressive` navigation bars with a sliding top dash, floating/docked
  surfaces and configurable frosted glass.
- Add a native navigation host with Motor scroll visibility, return-to-start,
  safe clearance, keyboard handling and existing Morph pull-to-refresh.
- Make rail destinations shorter with configurable spacing and 48px targets.
- Add optional interactive MorphPageIndicator with equal, wide and expanding
  dot geometry, RTL and selected semantics.
- Keep mouse state layers separate from the shared pill and capture local
  theme/motion preferences in navigation overlays.
- Add gallery examples and regression coverage for geometry and accessibility.

### Fixed

- Apply system and application reduced-motion preferences consistently to Morph
  springs, selection choreography, textfield labels, implicit effects, progress,
  loading and slider waves. Complete interrupted spring callbacks and preserve
  normal-motion configuration.
- Keep immediate overlay removal idempotent and bypass animated-size layout
  controllers under reduced motion; flush pointer focus updates without relying
  on a running animation.
- Update carousel geometry atomically when accessibility changes switch between
  weighted and fixed layouts.

### Added

- `MorphThemeData.reduceMotion` and inherited `MorphMotionScope` overrides that
  respect platform/ancestor requests and survive captured overlay themes.
- Reproducible full/reduced/reduce-only animation regression tests.

## 0.4.1 - 2026-10-21

### Fixed

- Resolve geometry namespace collisions after Material UI 1.8.0 introduced
  its own `RoundedPolygon` and `CornerRounding`. Use explicit dependency
  imports across the library, tests, example and preview, including the
  loading/refresh indicators and slider custom-painter regression.
- Preserve `material_new_shapes` type identity, the public shape catalog,
  polygon parameters and existing rendering behavior.
- Explicitly declare the six intended Flutter host platforms in the package
  manifest. Platform compatibility must still be verified with native and Web
  consumer builds; see `doc/PUB_DEV_COMPATIBILITY.md`.

### Added

- An import-policy guard and 11 regression cases to reject unrestricted
  Material UI/geometry imports and accidental dependency-private paths.
- Public geometry compatibility tests covering entrypoint type identity,
  all 35 catalog shapes, loading/refresh indicators and slider coexistence.
- Disposable latest/lowest dependency checks and GitHub Actions lanes covering
  root/preview analysis, tests, formatting and the gallery's Web release build.

### Validation

- Clean root/preview analysis, 759 library tests, 31 preview tests and successful
  Web release builds in each dependency lane (`material_ui` 1.6.0 and 1.8.0).
- Existing branding, Fluent icons, motion, attribution and 39-family preview
  coverage checks pass. See `doc/PUB_DEV_COMPATIBILITY.md` for evidence and
  remaining platform/font verification limits.

## 0.4.0 - 2026-10-18

### Added

- `MorphTextField.onUnfocus` callback receives the current text exactly once
  per loss of focus, supporting custom validation on blur without changing
  existing expression-based `errorText` handling. Works with owned or external
  focus nodes, tap outside, keyboard traversal and programmatic unfocus.
- Expressive refresh feedback with a circular reveal-progress ring, an
  indeterminate refreshing ring, a completion spin, and a distinct completion
  impact. Added `armThreshold` and `pullSensitivity` for tuning the pull
  distance and responsiveness; corrected the contained indicator background.
- Optional horizontal swipe dismissal for `MorphSnackbar.show` through
  `swipeDismissible: true`, with spring-back motion, haptic confirmation,
  and a square close icon button.
- Dedicated native touch lab in the preview to test theme strength, haptic
  overrides, swipe actions, refresh, circular indicator sizes, and continuous
  versus divided sliders. Standard and wavy circular variants are previewed
  at 16, 24, 48 and 64 dp.
- Theme-aware haptics for automatic AppBar back navigation, refresh activation
  and completion, bottom sheet opening, and side sheet interactions.
- Automatic three-dot reveal affordance for swipe-enabled list rows where the
  host opts into it.

### Changed

- Slider and RangeSlider only emit step ticks when `divisions` is set;
  continuous sliders no longer emit repetitive selection clicks as they move.
- Selection feedback now reflects Light / Medium / Heavy theme intensity;
  `none` and `hapticsEnabled: false` suppress Morph-managed feedback.
  Components default to theme inheritance, with explicit local overrides.
- Swipe list rows animate the previous row closed while the next row opens;
  the default gesture does not emit repeated detent ticks. The optional
  `dismissHapticStream` property retains deliberate discrete feedback.
- Circular and circular-wavy progress indicator stroke geometry adapts to
  smaller `size` values, including compact button use.
- NavigationDrawer destinations have an 8 dp vertical gap.

### Fixed

- AppBar title centering uses the full bar geometry even when the leading and
  trailing actions have asymmetric widths.
- Button radius and padding animate smoothly in both directions, including
  interrupted transitions and release after press.
- ButtonGroup haptic overrides and globally disabled selection haptics.
- List-action and reorder haptic calls that previously forced a fixed medium
  strength now inherit the selected theme intensity.
- Touch lab material surfaces render ListTile feedback without covering ink.

### Dependencies

- Morph-managed haptics use Flutter `HapticFeedback` only. No Core Haptics
  FFI dependency or manual Xcode/Swift Package Manager configuration is
  required for package consumers.

## 0.3.1

### Fixed

- Date-range picker filled input fields keep a shared floating-label space,
  so Start/End surfaces remain aligned when either field is focused, empty,
  populated or invalid. The input form stays top-anchored when validation
  text appears, with scrolling retained for small viewports.
- Wavy sliders, range sliders, and linear/circular determinate progress
  indicators smoothly fade their wave amplitude out between 90% and 98%,
  rather than snapping to a flat track at 95%. The entrance now fades in
  smoothly between 10% and 15%. Explicit amplitude overrides are unchanged.
- Single-date and date-range picker input dialogs reserve adequate room for
  filled text-field floating labels and validation messages. Input content
  scrolls when text scaling, compact viewports, or the keyboard reduce
  available space, keeping Cancel/OK and validation reachable. Calendar mode
  layout is unchanged.

### Preview

- Refreshed `sliders` and `loading` GIF capture timelines to demonstrate
  the 90–98% wave-to-flat transition at an observable pace. Wavy range
  sliders and both determinate wavy progress indicators are included.

## 0.3.0

### Added

- Swipe action controls for `MorphListItem` with configurable leading and
  trailing `MorphListSwipeAction` pills, optional tooltips, semantic labels,
  disabled actions, and automatic preview closure. Uses Morph's own spring
  animations rather than an additional slidable dependency.
- Optional `MorphTextField.errorIcon` in filled and outlined variants, with
  `MorphTextFieldErrorIconPosition.prefix` and `.suffix` to place the icon.
- Carousel interaction regression coverage, safe asynchronous swipe-dismissal
  tests, and text-field error icon position/semantics coverage.
- Animated list-items and floating-dialog GIF captures, along with a more
  complete interactive Flutter example of commonly used components.

### Changed

- `MorphTextField` now omits the error glyph by default while retaining error
  colors, helper text and accessibility information. Set `errorIcon` or
  `showErrorIcon: true` to opt in to a glyph.
- Swipe action pills use consistent 4dp spacing between adjacent actions and
  between the card and its nearest revealed action; swipeable rows no longer
  insert a trailing overflow icon automatically.

### Fixed

- Carousel `WidgetStatesController` notifications no longer trigger
  `setState()` during Flutter's build phase. Unsafe notifications are
  coalesced into a post-frame rebuild with mounted checks.
- List dismissal awaits `onDismiss` before collapsing a row or executing its
  primary action. Cancelled and pending confirmations do not dismiss rows;
  disabled rows reject swipe gestures and programmatic commands.

## 0.2.0

### Added

- `MorphChipToggle<T>` multiple selection with `multiSelection`,
  `selectedValues` and `onSelectionChanged`, retaining the existing
  single-selection API by default.
- Theme-level haptic configuration: `hapticsEnabled` (enabled by default) and
  `hapticFeedback` (light by default). Local feedback supports inheritance and
  explicit suppression; Morph's theme-aware dispatch respects the global opt-out.
- Optional `floatingLabelTextStyle` on `MorphTextField` and its field theme.
- Reusable `MorphMotion.spatialTween`, `effectsTween` and `staggeredTween`
  helpers for composing spatial travel, bounded effects and delayed edges.
- Tests covering multi-selection boundary animation, connected transfers,
  motion presets, haptics, text-field label layout and tabs behavior.
- Expanded Web GIF scenes that preserve existing chip/filter and
  search/outlined demos while adding multi-selection chips and filled fields.

### Changed

- The filled `MorphTextField` label moves diagonally above the painted
  surface when focused or populated, revealing the placeholder and retaining
  the outside label on blur when the field has content. It uses `onSurface`
  while focused and slightly larger floating typography. Outlined remains
  unchanged.
- Multi-selection chip pills use a small circular bloom only for transitions
  from zero to one and from one to zero selections; intermediate adds and
  removals use connected duplicate/merge morphs with a trailing-edge delay.
- Default chip motion is 289 ms (15% shorter than 340 ms) with a 77 ms
  trailing-edge delay; explicit component overrides are respected.
- Shared motion curves and expressive spatial springs have more pronounced
  character, while color and opacity curves stay bounded.
- `MorphTabs` and `MorphTabs.sliver` default to
  `autoScrollToFocusedTab: false` for primary and secondary tabs.
- GIFs for chips and text fields now display three distinct variants each
  at 640 x 480; other capture scenes remain unchanged.

### Fixed

- A spurious navigation rail background change in the preview when scrolling
  or switching adjacent tabs.
- Landscape date picker input height with an exterior filled label.
- Duplicate `enableFeedback` arguments in split-button/carousel paths and an
  invalid `const` icon in the preview.

## 0.1.0

Initial public release of Morph Expressive, a Flutter design system inspired by
Material 3 Expressive.

### Added

- Direct `Morph*` component APIs covering 39 families across actions,
  selection, inputs, containment, navigation, and feedback.
- Seed-based light and dark themes, optional dynamic colors, typography,
  shared shape tokens, and component-level customization.
- Fluent Icons Kit defaults and cohesive interaction and focus states.
- Shared spring-based motion tokens, animated selection, morphing shapes,
  and expressive progress and loading indicators.
- An interactive Flutter Web component gallery with theme controls and
  examples for all 39 component families.
- Eight reproducible GIF previews, public documentation, and regression tests.

### Credits

Based on the MIT-licensed Material 3 Expressive implementation by Paa
Developments. See `NOTICE` and `LICENSE` for third-party attribution and
applicable licenses.
