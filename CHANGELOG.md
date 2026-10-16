# Changelog

## 0.2.0 (pending publication)

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

### Release status

Version and documentation are prepared for 0.2.0. Publication requires the
full library + preview checks, reviewed regenerated GIFs, `dart pub publish
--dry-run`, and an explicit publish step. This entry is not a publication
confirmation.

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
