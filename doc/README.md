# Morph Expressive documentation

This directory contains **maintained reference documentation** and versioned
implementation/release records, rather than compiled Flutter Web output.

| Guide | Contents |
| --- | --- |
| [Getting started](GETTING_STARTED.md) | Installation and minimal integration |
| [Upgrading from 0.7.x](UPGRADE_0_8_0.md) | 0.8.0 contract and default changes, new APIs, renderers and compatibility |
| [0.8.0 final report](RELEASE_0_8_0.md) | Implementation scope, validation status, GIF assets and publication checklist |
| [Interactive example](../example/README.md) | A runnable tour of common component APIs |
| [Theming](THEMING.md) | Light/dark seeds, typography, and component overrides |
| [Tabs](TABS.md) | Continuous selection indicator, page-linked progress, configuration and limits |
| [Operations and skeleton](OPERATION_LOADING.md) | `MorphAsyncButton`, `MorphSkeleton`, shimmer angle and the reactive button group |
| [Shapes and renderers](SHAPE_ENGINE.md) | Geometry engine, catalog, Canvas / Shader contracts and limits |
| [Visual and interaction fixes](R3_VISUAL_FIXES.md) | Connected groups, FAB menu, submenus, antialiasing, 360° rotation and menu semantics |
| [Frosted surfaces](FROSTED_SURFACES.md) | Shared glass configuration, opt-in cards, floating menus, and performance |
| [MorphScrollBehavior](MORPH_SCROLL.md) | Flutter-like geometric overscroll compatible with frosted blur |
| [Components](COMPONENTS.md) | Public component families and composition |
| [Motion](MOTION.md) | Expressive curves, tweens, choreography, and customization |
| [Preview](PREVIEW.md) | Browser gallery (40 families), labs (`operations`, `shapes`, `tabs`), the 14 GIF capture scenes and native testing |
| [0.7.0 release checklist (archived)](RELEASE_0_7_0.md) | Historical validation gates, dependency matrix and publication checklist |
| [Release](RELEASE.md) | Historical 0.6.1 release gates, CI review, pub.dev publication and tagging |
| [Navigation and frosted surfaces](NAVIGATION_MORPH.md) | 0.6.1 nested scrolling, navigation API and migration from 0.5.0 |
| [pub.dev compatibility](PUB_DEV_COMPATIBILITY.md) | Historical 0.4.1 namespace fixes and regression checks |

Morph Expressive is an independent fork of Material 3 Expressive by Paa Developments.
See the root [NOTICE](../NOTICE) and [LICENSE](../LICENSE) for attribution.

The showcase is developed in `preview/`. Do not check generated `flutter build web` files into this documentation directory. If GitHub Pages previously used
`docs/` as a publishing source, update its deployment before removing the old
build output; see [Release](RELEASE.md).
