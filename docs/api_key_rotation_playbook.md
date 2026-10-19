# API Key Rotation Playbook

This playbook documents the phased approach for rotating and securing Campus Mobile API keys.

## Guiding Principles

- Rotate keys during a controlled migration, not by deleting the old key first.
- Use separate keys per platform and purpose.
- Apply API restrictions and application restrictions before releasing a key.
- Monitor traffic before retiring the previous key.
- Keep key values in secret storage; documentation and commits may reference key IDs and names only.
- Treat credentials used for login, token exchange, or guest chat as higher-risk, not read-only.

## Phase 1: Security Hardening

1. Complete `docs/api_key_inventory.md`.
2. Confirm key ownership and environment for each key.
3. Create separate Android, iOS, and service-specific keys where appropriate.
4. Apply API restrictions and application restrictions.
5. Move build-specific client keys out of source and into local/CI configuration.
6. Enable billing, quota, and abuse monitoring.
7. Document rollback and emergency revocation steps.

## Phase 2: Backend-Mediated Keys

1. Introduce a UCSD-controlled mobile gateway.
2. Validate requests with Firebase App Check or an equivalent approved mechanism.
3. Store downstream credentials in Secret Manager.
4. Migrate lower-risk, read-only content APIs first.
5. Add rate limits, logging, monitoring, alerting, and rollback behavior.
6. Migrate authenticated or write-capable APIs only after the gateway is hardened.
7. Retire old client-held keys only after all supported app versions have migrated.

Native Google Maps rendering may continue to require a tightly restricted client-side key because a server-side proxy cannot protect native SDK rendering.

## Client Key Rotation

For keys that must remain client-side:

1. Create a new restricted key in Google Cloud.
2. Store the key in the approved secret store.
3. Add the key to local or CI build configuration.
4. Build and test the app before release.
5. Release the app with the new key.
6. Monitor old-key and new-key traffic.
7. Disable the old key when traffic is no longer observed.
8. Delete the old key after the retirement window.

### Local Build Configuration

For Android:

1. Copy `android/secrets.properties.example` to `android/secrets.properties`.
2. Set `GOOGLE_MAPS_API_KEY` in the ignored secrets file or the CI environment.
3. Verify the Gradle build resolves the manifest placeholder.
4. Confirm the key is not present in tracked files.

For iOS:

1. Copy `ios/Flutter/Secrets.xcconfig.example` to `ios/Flutter/Secrets.xcconfig`.
2. Set `GOOGLE_MAPS_API_KEY` in the ignored xcconfig file.
3. Build and confirm `GoogleMapsAPIKey` is populated in the app bundle.
4. Confirm the key is not present in tracked files.

## Backend Key Rotation

For keys held by the backend:

1. Add the new key to Secret Manager with the same or stricter restrictions.
2. Update the gateway to use the new key.
3. Deploy to development, then QA, then production.
4. Confirm downstream traffic succeeds and monitoring is healthy.
5. Move traffic gradually if the gateway supports staged rollout.
6. Disable and later delete the old key after monitoring confirms migration.

## Required Testing

Testing must prioritize login and map functionality.

### Login

- Fresh-install login with valid student credentials.
- Fresh-install login with valid staff credentials, if available.
- Invalid-credential failure.
- Silent login after an app restart.
- Token refresh after an access token expires.
- Logout and repeat login.
- Confirm no credentials or tokens appear in logs.

### Map

- Android and iOS cold start.
- Map tiles render after opening the Map tab.
- Current-location behavior works with permission granted.
- Search results and markers render.
- Map deep links open the correct location.
- Directions buttons open the expected external map flow.
- Test debug and release builds.
- Test both fresh install and app upgrade.

## Rollback

- Keep the previous key enabled until the new key is verified.
- Return build configuration to the previous key if the new key fails before release.
- Return gateway routing to the previous API path if a backend migration fails.
- Disable a compromised key only after confirming an emergency replacement is active.

## Incident Response

1. Identify the affected key from the inventory.
2. Restrict the key immediately if possible.
3. Issue or activate a replacement.
4. Notify the key owner and affected service owners.
5. Monitor abuse and downstream failures.
6. Rotate related credentials if compromise is suspected.
7. Remove the compromised key after replacement traffic is healthy.
8. Record the incident and update this playbook.
