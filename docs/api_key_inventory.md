# API Key Inventory

This inventory tracks credential ownership and handling without storing secret values. Key values must remain in the approved secret store and local build configuration.

## Inventory

| Identifier | Platform | Location | Purpose | Handling | Rotation impact |
|---|---|---|---|---|---|
| Android Google Maps key | Android | `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle` | Native map rendering | Inject at build time through `GOOGLE_MAPS_API_KEY`; apply Android package and SHA-1 restrictions | Requires a new Android build/release unless later moved to a backend-mediated flow |
| iOS Google Maps key | iOS | `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift` | Native map rendering | Inject at build time through `GOOGLE_MAPS_API_KEY` in `ios/Flutter/Secrets.xcconfig`; apply iOS bundle-ID restrictions | Requires a new iOS build/release unless later moved to a backend-mediated flow |
| `AUTH_SERVICE_API_KEY` | Android/iOS | `.env` | Authentication-service requests | High priority for backend proxying; do not treat as read-only | Requires coordinated mobile and backend deployment |
| `MOBILE_APP_PUBLIC_DATA_KEY` | Android/iOS | `.env` | Token exchange and guest TGPT/chat requests | High priority for backend proxying; do not treat as read-only | Requires coordinated mobile and backend deployment |
| `USER_CREDENTIALS_PUBLIC_KEY` | Android/iOS | `.env` | Public key used to encrypt user credentials | Public key; track separately from secret API keys | Change only with a cryptography migration plan |
| `CAMPUS_MAP_SEARCH_KEY` | Android/iOS | `.env` | No current code reference found | Confirm ownership; rotate or retire if unused | Low impact if confirmed unused |
| Firebase Android API key | Android | `android/app/google-services.json` | Firebase project configuration | Apply Firebase restrictions and App Check where supported | Requires coordinated app release and Firebase configuration |
| Firebase iOS API key | iOS | `ios/Runner/GoogleService-Info.plist` | Firebase project configuration | Apply Firebase restrictions and App Check where supported | Requires coordinated app release and Firebase configuration |

## Known Constraints

- Native Google Maps rendering requires a client-side Maps key unless the app changes map providers or uses a custom native integration.
- Firebase configuration keys are intended to be client-visible but must be protected with API restrictions, App Check, and security rules.
- `.env` is bundled as a Flutter asset, so its values should not be treated as secret on a distributed device.

## Local Build Configuration

Do not commit local key values.

For Android, set `GOOGLE_MAPS_API_KEY` in `android/secrets.properties` or as a CI environment variable. Do not use `android/local.properties` because Flutter manages that file.

For iOS:

1. Copy `ios/Flutter/Secrets.xcconfig.example` to `ios/Flutter/Secrets.xcconfig`.
2. Set `GOOGLE_MAPS_API_KEY` to the iOS Maps key.
3. Keep `ios/Flutter/Secrets.xcconfig` ignored by Git.

## Verification Checklist

- [ ] Confirm the owner of every Google Cloud key.
- [ ] Confirm whether each key is development, QA, or production.
- [ ] Confirm Android package name and SHA-1 fingerprints for debug and release signing.
- [ ] Confirm the iOS bundle identifier and App Store identifier.
- [ ] Confirm API restrictions for each key.
- [ ] Confirm billing, quota, and abuse alerts.
- [ ] Confirm no key values are stored in source control.
