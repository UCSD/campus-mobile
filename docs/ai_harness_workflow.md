# AI Harness Workflow For API Key Rotation

This document records how the AI harness was used for the API-key rotation work, which systems it touched, and how the same workflow can be moved from a single developer laptop into shared team infrastructure.

## Scope And Safety Boundaries

The harness operated inside the Campus Mobile repository workspace. It did not directly access Google Cloud, Firebase, backend systems, 1Password, or production credentials.

- Secret values were not printed into documentation or commits.
- Cloud-side keys, restrictions, Secret Manager entries, and backend deployments still require authorized human action.
- Production changes require explicit manager approval.
- The branch and pull request are the reviewable record of repository changes.

Related documents:

- `docs/api_key_inventory.md`
- `docs/api_key_rotation_playbook.md`

## Work Completed With The Harness

| Step | Harness-assisted activity | Human oversight |
|---|---|---|
| Repository review | Inspected Git history, working tree, environment-variable names, Android/iOS configuration, and network-service code without exposing key values | Reviewed findings before implementation |
| Research | Reviewed Google Cloud and Firebase guidance on API-key restrictions, rotation, Remote Config, and App Check | Reviewed the resulting options and selected the server-side proxy direction |
| Documentation | Created a non-secret key inventory and phased rotation playbook | Reviewed wording, scope, QA/PROD sequencing, and approval requirements |
| Android configuration | Replaced the literal Maps key in `AndroidManifest.xml` with a Gradle manifest placeholder | Verified the generated Android manifest resolves the key |
| iOS configuration | Replaced the literal Maps key in `AppDelegate.swift` with an Info.plist value supplied by an ignored Xcode configuration file | Reviewed the Swift and configuration changes |
| Validation | Ran repository style checks, an Android debug build, manifest verification, and tracked-source secret scans | Reviewed results and confirmed the next manual tests |
| Git and GitHub | Created a dedicated branch, committed the changes, pushed the branch, and opened PR #2384 using the repository PR template | Approved the branch and pull request creation |

## Repository And Build Integrations Touched

### Git And GitHub

- Dedicated branch: `api-keys-rotation-CoGibby`
- Pull request: [#2384](https://github.com/UCSD/campus-mobile/pull/2384)
- Existing repository PR template used
- Existing GitHub Actions pre-commit workflow observed; not modified

### Android

Files touched:

- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/secrets.properties.example`

Behavior:

- `GOOGLE_MAPS_API_KEY` is read from the ignored `android/secrets.properties` file or the `GOOGLE_MAPS_API_KEY` environment variable.
- The Gradle build injects the value into the existing `com.google.android.geo.API_KEY` manifest metadata.
- `android/secrets.properties` remains ignored by Git.

### iOS

Files touched:

- `ios/Runner/AppDelegate.swift`
- `ios/Runner/Info.plist`
- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Release.xcconfig`
- `ios/Flutter/Secrets.xcconfig.example`

Behavior:

- `GOOGLE_MAPS_API_KEY` is read from the ignored `ios/Flutter/Secrets.xcconfig` file.
- The value is expanded into `GoogleMapsAPIKey` in `Info.plist`.
- `AppDelegate.swift` provides the value to the Google Maps SDK at launch.
- `ios/Flutter/Secrets.xcconfig` remains ignored by Git.

### Repository Documentation

Files added:

- `docs/api_key_inventory.md`
- `docs/api_key_rotation_playbook.md`
- `docs/ai_harness_workflow.md`

## Validation Performed

The following repository-level checks were run:

```bash
./scripts/auto_check_all.sh
flutter build apk --debug
git diff --check
```

Additional checks were performed:

- The generated Android manifest contained a non-empty Maps metadata value.
- No literal Maps key remained in tracked Android or iOS files.
- The local Android and iOS secrets files were ignored by Git.

Remaining manual validation should prioritize login and Maps:

- Fresh-install login.
- Silent login after restart.
- Token refresh.
- Logout and repeat login.
- Android and iOS cold start.
- Map tiles and search results.
- Map deep links and directions.

## Moving The Process Outside A Laptop

The same workflow can be moved into shared infrastructure in phases.

### Phase A: Shared PR Validation

Use GitHub Actions as the first externalization point.

Recommended PR workflow:

1. Checkout the pull request.
2. Install Flutter and Android SDK dependencies.
3. Run repository style checks.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Build an Android debug artifact.
7. Verify that no literal Maps key exists in tracked source.
8. Attach build logs or artifacts for reviewer inspection.

Build secrets can be injected from GitHub Environment secrets. Development and QA environments should be separated, and production secrets should be protected with environment approvals.

### Phase B: Shared Secret Management

Move key values out of local files into controlled secret stores.

Recommended flow:

1. Store Android and iOS Maps keys in the approved secret manager.
2. Inject keys into CI builds through environment variables.
3. Restrict each key by platform, app identifier, API, and environment.
4. Record only non-secret identifiers in documentation and pull requests.
5. Use immutable audit logs for creation, restriction, rotation, and deletion.

For Phase 2, downstream API keys should live in Google Secret Manager or an equivalent approved store and be consumed only by the UCSD-controlled backend gateway.

### Phase C: Infrastructure-As-Code

Use infrastructure-as-code to make key creation and restriction repeatable.

Recommended implementation:

1. Define each key in Terraform with a non-secret name and metadata.
2. Apply API restrictions and application restrictions in code.
3. Store actual key values in Secret Manager.
4. Use GitHub Actions to create a proposed key change through Terraform plan.
5. Require human approval before Terraform apply.
6. Rotate by creating a new key, updating consumers, monitoring traffic, and deleting the old key after the migration window.

This makes rotation repeatable while preserving human approval before destructive changes.

### Phase D: Backend-Mediated Rotation

For APIs that can be proxied, move the key entirely behind UCSD infrastructure:

1. Deploy the mobile gateway to development, QA, and production environments.
2. Store downstream keys in Secret Manager.
3. Validate requests with Firebase App Check or another approved mechanism.
4. Add rate limits, logging, monitoring, alerting, and rollback controls.
5. Migrate read-only APIs first.
6. Migrate authenticated and write-capable APIs only after the gateway is hardened.
7. Retire old client-held keys only after all supported app versions have migrated.

## Required Team Inputs

To complete the shared implementation, the team needs to provide:

- Confirmation of key owners and environments.
- Android debug and release SHA-1 fingerprints.
- iOS bundle identifier and App Store identifier.
- Google Cloud permissions for development/QA key management.
- Backend/infrastructure owner for the gateway and Secret Manager.
- CI/CD permissions for shared build and deployment automation.
- Confirmation of which APIs are eligible for the first proxy migration.

## Recommended Next Automation Step

The next highest-value step is a shared GitHub Actions workflow that performs the same validation used locally:

1. Repository style checks.
2. Flutter analysis and tests.
3. Android debug build.
4. Secret scan for literal Maps keys.

This gives every future pull request the same validation path without relying on an individual developer's machine.
