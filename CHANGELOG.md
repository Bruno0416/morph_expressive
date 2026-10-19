# Changelog

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
