# Morph Expressive Widgetbook

Widgetbook catalog of every exported Morph Expressive widget. From the repository root:

```bash
bash tool/run_preview.sh
```

Choose `1` to run on your desktop (Linux, macOS, or Windows via Git Bash),
or `2` to open Firefox automatically at <http://127.0.0.1:8080/>.
The desktop option requires Flutter's native build tools for your OS; the
Firefox option requires `curl` and Firefox.

To run the web preview manually:

```bash
flutter pub get
cd preview
flutter pub get
dart run build_runner build
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

All documentation is in [`../doc/PREVIEW.md`](../doc/PREVIEW.md).

## Native mobile haptics preview

To test buttons, list swipes, sheets and haptics on a physical Android/iOS
phone, generate the missing native project scaffolding and run the dedicated
mobile entrypoint:

```bash
bash tool/setup_mobile_preview.sh
cd preview
flutter run -t lib/main_mobile.dart
```

See [`doc/MOBILE_HAPTICS.md`](doc/MOBILE_HAPTICS.md) for the device checklist.
