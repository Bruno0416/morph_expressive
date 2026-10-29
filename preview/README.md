# Morph Expressive Component Studio

Run from the root:

```bash
bash tool/setup_preview.sh
cd preview
flutter run -d web-server --web-port 8080
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
