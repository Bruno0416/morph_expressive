# Morph Expressive — native haptics lab

The existing `preview/lib/main.dart` remains the browser component gallery.
`preview/lib/main_mobile.dart` launches a focused native test screen with a
live global haptics switch and intensity selector.

## Set up on the development machine

From the Morph repository root:

```bash
bash tool/setup_mobile_preview.sh
cd preview
```

The script generates the missing `preview/android` and `preview/ios` projects
using your **installed Flutter SDK**, without changing the existing Dart
sources. It runs `flutter pub get` and lists connected devices.

### Android (physical device)

```bash
flutter devices
flutter run -t lib/main_mobile.dart -d YOUR_ANDROID_DEVICE_ID
```

### iPhone with xcross on Linux

```bash
xcross flutter run -t lib/main_mobile.dart
```

Run from the `preview/` directory with your iPhone connected and the device
trust/signing requirements already satisfied. You can also use regular
`flutter run -t lib/main_mobile.dart` on a Mac with a configured iPhone.

## Manual validation

1. Enable haptics, choose Light / Medium / Heavy, then disable haptics and
   verify Morph no longer generates feedback.
2. Press and hold each button, release, and repeat with fast taps. Radius
   should animate **both directions** and finish smoothly.
3. Select a ButtonGroup option and open/close the modal drawer.
4. Swipe the list rows and use the `⋮` action; check their rhythmic feedback.
5. Show a snackbar and swipe it away; open the bottom/side sheets and dismiss.
6. Open the automatic-back page and use the leading back action.
7. Pull the refresh list until armed and release. It should vibrate once at the
   trigger threshold, not constantly throughout the drag.

Physical device testing is necessary: web/simulators cannot prove how the
haptic motor feels. Record iOS/Android device and whether feedback felt weak,
strong, or duplicated before declaring this patch visually tested.

Do not run `dart format` during patch iteration; format once at release
validation before publishing.
