# Morph Expressive documentation

Reference guides for the current API (1.0.0 is implemented and validated
locally; publication is pending, and 0.8.0 is the latest published version),
followed by historical records of earlier releases. Dart snippets in the current
guides are compiled by `test/doc_examples_test.dart`.

## Start here

| Guide | Contents |
| --- | --- |
| [Getting started](GETTING_STARTED.md) | Install, `MorphMaterialApp` or your own `MaterialApp`, first widgets |
| [Theming](THEMING.md) | Seed colors, the real color algorithm, light/dark, dynamic color, nested themes, component overrides, typography, haptics |
| [Component API](API_V1.md) | Visual types via named constructors, `MorphVariant` roles, `MorphSurface` finishes, precedence and family support |
| [Components](COMPONENTS.md) | Catalog of every exported family with constructors and representative examples |
| [Frosted surfaces](FROSTED_SURFACES.md) | Solid versus frosted, `surface:` and `glass:`, legibility, high contrast, web and performance |
| [Density and context menus](DENSITY_AND_CONTEXT_MENUS.md) | Global `MorphDensity`, coverage, badges; desktop context menu geometry and keyboard/pointer behavior |
| [Accessibility](ACCESSIBILITY.md) | Semantics, keyboard and focus ring, hit targets, text scale, contrast, reduced motion, haptics |
| [Motion](MOTION.md) | Expressive curves, tweens, choreography and customization |
| [Widgetbook preview](PREVIEW.md) | Run and extend the catalog of every exported widget, labs, GIF capture scenes |
| [Upgrading to 1.0.0](UPGRADE_1_0_0.md) | Breaking and additive changes from 0.8.x, intentional visual changes |
| [Release process](RELEASE.md) | Validation stages, gated publication from `main`, recovery |
| [Runnable examples](../example/README.md) | Apps under `example/` |

## Feature guides (current)

| Guide | Contents |
| --- | --- |
| [Tabs](TABS.md) | Continuous selection indicator, page-linked progress, configuration and limits |
| [Operations and skeleton](OPERATION_LOADING.md) | `MorphAsyncButton`, `MorphSkeleton`, shimmer angle and the reactive button group |
| [Shapes and renderers](SHAPE_ENGINE.md) | Geometry engine, catalog, Canvas / Shader contracts and limits |
| [MorphScrollBehavior](MORPH_SCROLL.md) | Flutter-like geometric overscroll compatible with frosted blur |
| [Navigation](NAVIGATION_MORPH.md) | Navigation bar API, nested scrolling host and frosted bars (written for 0.6.1; the API still applies) |
| [Reduced motion](REDUCED_MOTION_ACCESSIBILITY.md) and [its tests](REDUCED_MOTION_TESTS.md) | Per-family reduced-motion behavior and reproducible checks |
| [Frosted blur benchmark](FROSTED_BLUR_BENCHMARK.md) | Native lab for blur strategies (experiment, not production) |

## Historical records

These documents describe earlier versions as they were when written. They are
kept for context and are not instructions for the current version.

| Document | Describes |
| --- | --- |
| [Upgrading from 0.7.x](UPGRADE_0_8_0.md) | 0.8.0 contract and default changes (read it when coming from 0.7.x) |
| [0.8.0 final report](RELEASE_0_8_0.md) | Implementation scope, validation status and publication checklist of 0.8.0 |
| [0.7.0 release checklist](RELEASE_0_7_0.md) | Validation gates and publication checklist of 0.7.0 |
| [R3 implementation](R3_IMPLEMENTATION.md) | Implementation notes of the R3 interaction work |
| [Visual and interaction fixes](R3_VISUAL_FIXES.md) | Record of the R3 fixes: connected groups, FAB menu, submenus, antialiasing, rotation and menu semantics (written in Spanish) |
| [pub.dev compatibility](PUB_DEV_COMPATIBILITY.md) | 0.4.1 namespace fixes and regression checks |
| [Chip organic experiment](CHIP_ORGANIC_EXPERIMENT.md), [dropdown motion](DROPDOWN_CENTERED_MOTION.md), [dropdown unfold](DROPDOWN_LIQUID_UNFOLD.md), [shape dependency audit](SHAPE_DEPENDENCY_AUDIT.md), [operation loading plan](OPERATION_LOADING_PLAN.md) | Design experiments and audits |

Morph Expressive is an independent fork of Material 3 Expressive by Paa
Developments. See the root [NOTICE](../NOTICE) and [LICENSE](../LICENSE) for
attribution.

The Widgetbook catalog is developed in `preview/`. Do not check generated
`flutter build web` output into this directory.
