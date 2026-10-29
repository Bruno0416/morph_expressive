# Morph Expressive documentation

This directory contains **maintained reference documentation**, not compiled
Flutter Web output or historical patch reports.

| Guide | Contents |
| --- | --- |
| [Getting started](GETTING_STARTED.md) | Installation and minimal integration |
| [Interactive example](../example/README.md) | A runnable tour of common component APIs |
| [Theming](THEMING.md) | Light/dark seeds, typography, and component overrides |
| [Components](COMPONENTS.md) | Public component families and composition |
| [Motion](MOTION.md) | Expressive curves, tweens, choreography, and customization |
| [Preview](PREVIEW.md) | Browser gallery (40 families), GIF capture scenes, and native testing |
| [Release](RELEASE.md) | 0.6.1 release gates, CI review, pub.dev publication and tagging |
| [Navigation and frosted surfaces](NAVIGATION_MORPH.md) | 0.6.1 nested scrolling, navigation API and migration from 0.5.0 |
| [pub.dev compatibility](PUB_DEV_COMPATIBILITY.md) | Historical 0.4.1 namespace fixes and regression checks |

Morph Expressive is an independent fork of Material 3 Expressive by Paa Developments.
See the root [NOTICE](../NOTICE) and [LICENSE](../LICENSE) for attribution.

The showcase is developed in `preview/`. Do not check generated `flutter build web` files into this documentation directory. If GitHub Pages previously used
`docs/` as a publishing source, update its deployment before removing the old
build output; see [Release](RELEASE.md).
