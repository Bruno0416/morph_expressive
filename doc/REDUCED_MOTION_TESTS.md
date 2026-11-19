# Reduced motion: tests and audit

This battery examines the component families of Morph Expressive. It adds
optional instrumentation and tests; it does not change the animations in `lib/`,
the dependencies or the package version. The preview receives an optional family
filter to isolate the tests; its default keeps the complete gallery. The
carousel runs in a separate test isolate so that an assertion in its render tree
does not contaminate the other families.

## Run

From the repository root (the audit was written against Flutter 3.47.7; CI pins
the SDK in `.github/actions/setup-flutter`):

```bash
flutter pub get
(cd preview && flutter pub get)
python3 tool/audit_reduced_motion.py
```

The report is written to `.dart_tool/motion_audit/REPORT.md`; `summary.json`
keeps the per-family results and the `*.jsonl` files the original output. The
command exits with code **1** if tests fail or families are not mounted. It does
not turn known defects into passing tests or skip them.

To run part of it:

```bash
python3 tool/audit_reduced_motion.py --scope contracts --profiles full reduced
python3 tool/audit_reduced_motion.py --scope catalog --profiles reduced
python3 tool/audit_reduced_motion.py --profiles reduce-only
```

`--scope` accepts `library`, `contracts`, `preview`, `catalog` or `all`.
`--flutter /absolute/path/flutter` uses an SDK that is not on `PATH`;
`--output /path/report` changes the results directory.

## Independent preferences

| Profile | `disableAnimations` | Platform `reduceMotion` |
|---|---|---|
| `full` | false | false |
| `reduced` | true | true |
| `reduce-only` (optional) | false | true |

The platform is simulated through `FakeAccessibilityFeatures`, so the value
reaches the framework and its `AnimationController`s as well as `MediaQuery`.
Overriding only a local `MediaQuery` does not reproduce that whole path. The
environment test verifies the propagation before results are interpreted.

In Flutter 3.47.7, `reduceMotion` is observed in the platform features; that SDK
does not yet expose a `MediaQueryData.reduceMotion` getter. The two preferences
are not assumed to be interchangeable. `accessibleNavigation` is left false:
accessible navigation is a different preference, not a synonym for reduced
motion.

## What is checked

1. **The complete functional suite** of the library and preview under each
   profile. It keeps the existing widget interactions and checks.
2. **Motion contracts**: initial, intermediate and final states of selectable
   controls; visible geometry and paint; the text-field label entering and
   leaving focus. Snapshots compare the same process and renderer; they do not
   depend on golden images from another machine.
3. **Complete catalog**: mounts every family, changes the preferences while they
   are mounted, checks the propagation and unmounts them verifying that no
   ticker callbacks remain. It uses bounded pumps so loaders cannot hang it.
4. **Passive sampling** of observable animations in the frames those tests
   request. It records component, family, effective preference, value changes and
   active time. It does not create frames or disable `TickerMode`.

## How to read a failure

The contracts propose that finite decorative transitions reach their final state
within **112 ms** with reduced motion. That margin allows brief feedback; it is
not meant to define a universal accessibility rule. Text fields verify their
existing behavior of jumping immediately.

An older functional test can fail because it expected a normal animation, for
example a circular bloom halfway through its travel. That requires adapting the
test's expectation to the profile and **does not by itself prove a defect** in
the widget. Read the dedicated contracts and the traces separately.

The report flags animations observed for more than 80 ms for review. That signal
is **not an automatic failure**: a user-controlled scroll or an indeterminate
activity indicator may need continuity. Ornamental waves and spatial movements
are reviewed individually.

## Explicit limits

- Mounting a family is not the same as verifying every parameter combination.
- The functional suite provides the interactions; the catalog test does not
  invent one representative interaction for every widget.
- The absence of observed motion is **not compliance**. Some private
  controllers, `Listenable.merge`, timers and transitions that start and end
  between two pumps can escape the sampling.
- Components without their own animation are also mounted and unmounted; they
  can contain children that do animate.
- These are widget tests on the VM. Visual validation in Firefox/Chrome,
  CanvasKit/Skwasm, GPU and native devices remains a different check.

The files `test/audits/*.dart` and `preview/test/audits/*.dart` are invoked
explicitly by the runner. That way the audit can show current defects without
introducing false expectations or silently breaking the ordinary `flutter test`
command. The instrumentation stays off unless `MORPH_MOTION_AUDIT_PROFILE` is
provided.
