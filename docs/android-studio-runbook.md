# Android Studio Stable Runbook

## Daily launch

1. Close unused Chrome tabs, Grammarly, or other heavy apps if free RAM is under 2 GB.
2. Open Android Studio.
3. Start the `Pixel_6a` emulator from **Device Manager**. The AVD is configured to cold boot; do not switch back to quick boot.
4. Wait until the emulator shows the Android launcher.
5. Open `campus-mobile` in Android Studio.
6. Run `flutter pub get` once after switching branches or editing `pubspec.yaml`.
7. Press the normal Android Studio run button. You do not need to run `main.dart` separately.

The debug build is configured as the emulator's HOME activity, so the app will
open automatically on cold boot. To restore the normal Android launcher, open
the emulator's **Settings > Apps > Default apps > Home app** and select the
Android launcher.

## If the emulator will not launch

- Close the emulator from its window or run `adb emu kill`.
- Delete `C:\Users\conno\.android\avd\Pixel_6a.avd\multiinstance.lock` if the emulator is not running.
- In Device Manager, use a cold boot.
- Expected startup time is 30–60 seconds.

## If the emulator freezes or shows ANR

- Keep the emulator at 3 GB RAM (`hw.ramSize=3072`).
- Close unused Chrome tabs, Grammarly, or other heavy apps if host RAM drops below 2 GB.
- Wait 30 seconds after cold boot before using the emulator.

## Hot reload

- In the Android Studio device selector, choose `sdk gphone64 x86 64`; do not leave Chrome selected.
- The `main.dart` run configuration uses a 30-second device timeout and skips dependency resolution after `flutter pub get`.
- If a top-level `const` color does not change after hot reload, use **hot restart** instead.

## Practical task location

- App-wide color constants are in `lib/app_styles.dart`.
- The main primary color is `lightPrimaryColor`.
- The `ColorPrimary` swatch is nearby and may also need matching changes.

## Known non-blocking warnings

- `flutter analyze` currently reports five unused-variable warnings and no errors.
- Firebase and Google Maps certificate messages may appear because the QA debug key is not registered to the current Firebase project.
- Temporary QA API connection errors are external; retry rather than changing app code.
