# Reliable PR Test Plans

## Scope and guarantees

Replace build-specific spreadsheets with **one workbook per PR, platform, and environment**. Repeated successful builds update that workbook's metadata, not its identity. A PR can therefore have multiple workbooks, but not a new workbook for every push.

Keep test cases and tester input. Publish a durable GitHub copy and a Codemagic artifact; SharePoint becomes optional. This protects against SharePoint failure, not simultaneous failure of all services.

This document is an implementation plan. Branch/release regression plans and bidirectional SharePoint editing are outside scope.

## Current issues

`scripts/codemagic-ci/post-publish.sh` invokes `build-notifier.js`, which generates a workbook after a successful build and uploads through `upload-build.py`.

- Build/version-specific filenames create duplicate plans.
- Mandatory `SP_CONFIG` can block startup before generation.
- Failed uploads still return an expected SharePoint URL.
- Existing template substitution does not implement updates to completed workbooks.

Use the tracked templates in `scripts/codemagic-ci/testing/`; no SharePoint template download is needed.

## Storage and ownership

| Location | Role | Rule |
| --- | --- | --- |
| Protected GitHub branch `test-plan-artifacts` | Authoritative workbook and manifest | Only the publisher writes; retain revision history. |
| Codemagic build artifacts | Immutable recovery snapshots | Label with build/revision; disclose configured expiry. |
| SharePoint | Optional read-only mirror | Upload verified canonical revisions, never use as authoritative input. |

An administrator creates the storage branch and grants the publisher access. GitHub file-page links use repository permissions; they are not public attachment links. Binary history increases repository size: measure usage during the pilot and approve retention before rollout. No sensitive test data belongs in a public repository.

Stable paths:

```text
test-plans/pr-123/ios/qa/Test-Plan.xlsx
test-plans/pr-123/ios/qa/manifest.json
test-plans/pr-123/android/qa/Test-Plan.xlsx
test-plans/pr-123/android/qa/manifest.json
```

The latest canonical revision is authoritative. Old artifacts remain snapshots, not competing live plans.

### Tester editing

Before rollout, provide an authenticated import command/tool:

1. Download a workbook together with its canonical revision.
2. Edit test cases/results locally.
3. Submit the workbook and base revision to the publisher.
4. Reject a stale submission and ask the tester to reconcile; never silently merge binary files.

Import existing manually maintained plans before enabling CI for their variants. SharePoint must be read-only or excluded from automated mirroring until this editing process is accepted. Otherwise mirroring could overwrite tester edits.

## Build processing

1. **Validate:** identify repository, PR, platform, environment, commit SHA, provider build ID, start time, version, and build URL. Accept successful builds from an authorized workflow only.
2. **Read:** retrieve the authoritative workbook and manifest. Initialize from a tracked template only when the branch exists, access is verified, and the variant is confirmed absent. An ambiguous `404`, timeout, or permission failure is not proof of absence.
3. **Edit:** change only named metadata fields: version, displayed/raw build number, branch, successful SHA, build URL, and update time. Validate platform/environment against the path. Preserve other content and workbook features.
4. **Preserve:** write the candidate workbook and manifest into a configured Codemagic artifact directory before artifact collection.
5. **Commit:** publish workbook and manifest together through a new Git commit. Push without force; a concurrent branch advance requires rereading canonical state and reapplying metadata-only changes. Stop after three conflicts and report a retryable failure.
6. **Mirror/report:** publish the committed revision to SharePoint and update GitHub/Teams independently. Never label an uncommitted candidate as canonical.

Keep the existing displayed number rule, `PROJECT_BUILD_NUMBER + 1000`. The manifest also records schema version, variant, provider build ID/start time, and tested-build references. Its revision is the containing Git commit, not a self-referential commit ID stored inside itself.

Use named ranges for mutable cells. Select an editing library only after round-trip checks preserve template formulas, styles, validation, merged cells, and tester-entered content. `xlsx-template` may remain for initialization; do not assume replaced placeholders can be reused for updates.

### Results and changed builds

Recorded results must retain their tested build/SHA. On a different successful build ID, display **retest required** without erasing prior results. Only an explicit tester submission can mark the new build tested. Repeated processing of the same build is idempotent.

New pushes do not reset cases automatically. Developers/testers must revise cases for changed scope through the editing process. Failed builds leave successful-build metadata unchanged.

## Ordering and concurrency

Git's non-force push protects canonical state, but does not order external uploads or notifications.

- Before each commit attempt, confirm the build SHA matches the current PR head.
- For the same SHA/variant, compare provider start time, with a deterministic build-ID tie-breaker. Reject older candidates even if they finish later.
- After a push conflict, reload and repeat both checks; do not reuse a stale workbook.
- Manual imports require the submitted base revision to remain current.
- Route SharePoint writes and GitHub status updates through one serialized publisher for the repository. It rereads canonical state before each operation and retries failed work. Queue/lock configuration is a rollout prerequisite; workflow concurrency settings alone are not evidence of durable FIFO delivery.

PR head changes cannot be atomic with storage commits. Always show the tested SHA and reconcile status after pushes. A build may become outdated immediately after publication; never claim it verifies a different head.

## PR Test Plan section

GitHub's API cannot attach an Excel file directly to a PR description. Put stable workbook links there instead.

Use a **static bot-owned link block** in the description and a bot-owned comment for changing build/status information. This avoids rewriting developer text on every build:

```markdown
## Test Plan
Developer-authored scenarios and checkboxes remain here.

<!-- campus-mobile:test-plan:start -->
- [iOS / QA workbook](...)
- [Android / QA workbook](...)
- [Current CI testing status](...)
<!-- campus-mobile:test-plan:end -->
```

Create/update the block only when links change. Preserve text outside it; add the section if missing. Stop on duplicate/malformed markers. Because body updates cannot atomically merge concurrent human edits, prefer developer insertion of the initial block when a race is detected.

The status comment lists tested SHA/build, retest state, canonical revision, and publication outcomes. Link SharePoint only after upload succeeds; identify a stale mirror as stale. Add verified artifact links with expiry information. Reconcile a failed comment update from canonical state on retry.

## Failure policy

| Failure | Required action |
| --- | --- |
| SharePoint missing/unavailable | Continue canonical/artifact publication; report mirror unavailable. |
| Canonical read fails | Do not manufacture a blank replacement; retain diagnostics and retry. No new updated workbook is guaranteed in this case. |
| Canonical push fails | Keep candidate artifact and previous canonical link; report pending/stale state. Retry from current canonical content. |
| Artifact collection fails | Retain canonical copy if published; report reduced redundancy. |
| PR/Teams update fails | Keep stored copies; retry reporting independently. |
| Schema invalid or import conflicts | Reject update; preserve previous canonical state and report remediation. |

Separate app-build result from test-plan workflow health. Return explicit stage outcomes; never infer publication success from an intended URL.

## Implementation checklist

1. Verify Codemagic artifact timing; move generation before collection and reporting afterward.
2. Validate the editor and metadata schema; migrate existing workbooks without losing tester content.
3. Extract generation/update and make SharePoint optional throughout startup.
4. Configure protected storage, publisher identity, serialization/retries, and authenticated import.
5. Add conditional Git publication, stale-build checks, optional mirroring, and PR reporting.
6. Pilot one PR across both platforms; approve tester workflow, storage retention, and recovery before rollout.

Use a narrowly scoped GitHub App/service identity. Codemagic does not automatically receive GitHub Actions' `GITHUB_TOKEN`. Isolate publisher credentials from untrusted PR/fork code, validate artifact provenance, and never log credentials or secret-bearing URLs.

## Acceptance tests

- Repeated builds keep stable paths and preserve workbook features/tester content.
- New builds require retesting; repeated delivery of one build is idempotent.
- SharePoint outage or missing credentials still leaves a canonical workbook and downloadable artifact when those services succeed.
- Read failures never initialize blank state; write conflicts never overwrite newer work.
- Out-of-order builds cannot roll canonical metadata backward; serialized mirroring publishes current revisions.
- Stale tester imports are rejected; manually created plans survive migration.
- Reporting preserves developer text and truthfully labels stale/failed publication.
- Artifact expiry, retry exhaustion, closed-PR archival, and recovery are documented. Do not automatically delete plans until retention is approved.
