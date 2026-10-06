# Reliable PR Test Plan Workflow

## Objective

Keep one logical testing plan per PR. Later successful CI builds update build metadata rather than create new plans. Preserve tester input and keep spreadsheets accessible when SharePoint fails. This is a design proposal, not an implemented workflow.

## Current problems

`scripts/codemagic-ci/post-publish.sh` runs `build-notifier.js`, generating spreadsheets after successful builds and uploading through `upload-build.py`. Filenames contain version/environment/build numbers, creating new files per build. Startup requires SharePoint configuration, and upload failures still return an expected SharePoint URL.

Templates already exist in `scripts/codemagic-ci/testing/`. Use tracked templates directly instead of external template locations.

## Architecture

Separate generation/update, independent preservation, optional SharePoint mirroring, and PR/Teams reporting. SharePoint must not be required for generation or startup.

Proposed canonical store: an administrator-created, protected GitHub branch, `test-plan-artifacts`, separate from developer branches. Publish workbook and JSON manifest atomically using Git commits with conditional branch advancement. Reject conflicts rather than overwrite tester input. Stable GitHub file pages provide authenticated access and version history. Private raw URLs should not be assumed to work anonymously. Binary history grows repository storage; review retention and consider object storage if volume grows. Never store secrets or personal information in a public repository.

Always retain another copy as a Codemagic artifact. Artifacts expire and are not canonical storage. Verify artifact paths and collection timing: the current post-publish hook may be too late. Generate before collection; report artifact URLs afterward.

## Identity and updates

Key plans by repository and PR number, never build/version/commit. Preserve platform/environment variants because templates differ:

```text
test-plans/pr-123/ios/qa/Test-Plan.xlsx
test-plans/pr-123/android/qa/Test-Plan.xlsx
```

Later builds update the same variant path. Another platform/environment initializes a variant within the same PR plan, not a workbook per push. Combining platforms is outside initial scope. Keep branch/release regression plans separate initially.

First successful build: read canonical state; only confirmed not-found allows initialization. Copy the tracked template, populate metadata, preserve artifacts, and publish. Authentication/timeouts never trigger blank replacement.

Later builds: fetch the existing workbook and update only version, environment, build number, branch, successful commit SHA, build URL, and timestamp. Preserve cases, worksheets, assignments, notes, results, and formatting. Save artifact snapshots before conditional canonical publication.

Use named ranges or an explicit metadata schema. Current `xlsx-template` initialization cannot be assumed to edit replaced placeholders later. Validate an editor against actual formulas, styles, validation, and merged cells. Retain `PROJECT_BUILD_NUMBER + 1000` unless deliberately changed. The manifest records PR/variant, schema version, raw/displayed numbers, commit, URL, provider timestamp, and revision.

Results belong to their tested build. Preserve that reference and mark a changed build **retest required**; changing metadata does not validate new code.

## Manual edits and concurrency

GitHub is canonical; SharePoint is initially a mirror. Provide authenticated download/edit/import with revision checks before migrating testers. Import existing manual plans once rather than replacing them with blank templates. SharePoint-only edits are not automatically preserved: if SharePoint remains the editing interface, implement revision-aware reconciliation before automatic mirroring.

Serialize publication and manual imports per PR variant, preferably using a protected GitHub Actions publisher accepting verified Codemagic metadata/artifact references. Validate provenance and isolate secrets from untrusted PR scripts. Check current PR head SHA: older commits retain artifacts but cannot replace current-head metadata. For repeated builds of one commit, reject stale candidates using trusted timestamps/identifiers, not build numbers alone. On conflicts, reload and reapply metadata-only changes with bounded retries. Serialize mirrors too so delayed uploads cannot replace newer files. Report tested SHA explicitly; PR head and storage changes are not atomic, so recheck near publication and reconcile on pushes.

## PR Test Plan section

GitHub's API cannot directly upload Excel attachments into a PR description. Link stored files in a bot-owned block:

```markdown
## Test Plan
Developer-authored scenarios and checkboxes remain here.

<!-- campus-mobile:test-plan:start -->
- iOS / QA: build 1042, commit abc1234
- Workbook: [View/download](...)
- SharePoint: unavailable; use GitHub
- Status: retest required
<!-- campus-mobile:test-plan:end -->
```

Include all variants. Replace only the marked block; add the section if absent. Malformed/duplicate markers produce a warning instead of destructive edits. Read the latest body and verify updates. The body API cannot atomically merge human edits; strict preservation requires a bot-owned comment and stable description pointer. Show only verified SharePoint/artifact links and label artifact retention limits.

## Failures and security

- SharePoint absent/failing: generation, artifacts, canonical storage, and PR access continue.
- Canonical read failing: retry/report; never initialize blank state.
- Canonical publish failing: retain artifact/prior link and report stale metadata.
- PR/Teams failing: stored files remain; retry reporting independently.
- App build failing: keep last successful workbook metadata; report separately.
- Invalid schema/conflicts: report explicitly; never erase tester input or advertise failed uploads as successful.

Return structured outcomes and separate app-build status from test-plan health. Use a narrowly scoped GitHub App/service identity; Codemagic cannot assume GitHub Actions' `GITHUB_TOKEN`. Configure storage, templates, artifacts, and optional mirrors. Never log secrets.

## Implementation and acceptance

1. Inspect schemas/artifact timing; verify editor round trips.
2. Extract generation/update and make SharePoint optional throughout startup.
3. Add stable identities, metadata schema, manifests, and artifact collection.
4. Implement canonical storage, serialized imports/publication, stale-build checks, and conflicts.
5. Add PR updates and independent SharePoint/Teams reporting.
6. Import an active plan and pilot both platforms before rollout.

Tests cover stable paths across pushes, preserved tester content/features, retest status, SharePoint outages/missing credentials, independent failures, stale builds/uploads, conflicts, manual imports, read errors, and safe PR updates. Document setup, tester import, recovery, retention, and archival. Do not delete plans on PR closure until retention is approved.
