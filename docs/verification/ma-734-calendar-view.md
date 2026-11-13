# MA-734 calendar view verification record

Updated: 2026-11-13. Implementation is in progress; nothing below claims pending work is done.

## Recorded

- RED test commits: `e8ed91e1e` (calendar view behavior tests) and `0cc8ffe81` (meeting dates and export tests).
- Focused gates: helper suite 27/27 passes with analyzer no issues; export suite 9/9 passes with analyzer no issues.
- First full suite: 151 pass, 2 UI failures; fixes are assigned and in-flight with the UI agent.
- Analyzer: CI analyzer exits 0 at exactly 140 baseline findings; this run predates the final ExcludeSemantics UI change, so a final rerun remains pending.
- Format dry-run: exit 0 (208 files, 0 changes), also predating the final ExcludeSemantics UI change.
- Python gates with the isolated interpreter `.dart_tool/ma734-verification/python313/python.exe` (3.13.17): pre-commit 4.4.0 `validate-config` exits 0; all 6 script tests exit 0.
- Dependency resolution: `share_plus` 11.1.0, `flutter_file_dialog` 3.3.6, `crypto` 3.0.6, and `timezone` 0.10.1 resolve as direct dependencies.
- Android plugin Kotlin compile: `:flutter_file_dialog:compileDebugKotlin` and `:share_plus:compileDebugKotlin` BUILD SUCCESSFUL (8m53s) on host Gradle 8.14 / AGP 8.11.1 / Java 17; no build tooling upgrade required.
- Independent ICS fixture: 29 events at `.dart_tool/ma734/classes-fa26.ics`.
- Independent parser verification (Python 3.13.17 with `icalendar` 7.3.0 on the fixture): exactly 29 MWF events in September 25 through December 4, unique UIDs, all required properties present, 50-minute durations, precise holiday date-set exclusion, every campus start at 10:00, October 30 serializing as 17:00Z and November 2 as 18:00Z (DST transitions).
- Fixture round-trip limits: the fixture is ASCII with no line folding or text escaping, so those paths are covered by helper unit tests only.
- Initial feature coverage: 98.1% (570/581 lines; excludes `classes_list.dart` in that calculation). The initial whole suite still failed (2 UI failures, fixes in-flight).

## Pending

- Full-suite rerun once the 2 UI failures are fixed (the verifier has paused the full suite until UI GREEN), plus the final analyzer rerun.
- Final integrated formatter/analyzer/full-suite run has been delegated and is in flight; results are not yet recorded here.
- Full Android app build; plugin Kotlin compilation is verified but the whole-app build is not.
- iOS builds are unavailable on this Windows host, and Firebase configuration files are missing.
- Real-device Share/Save/import verification for the generated `.ics` snapshot, including cancellation and failure paths.
- Design access: exact Figma course-color palette still needs Inspect access; the current empty palette with a plain count fallback is an incomplete-design placeholder.
- Data access: SP27 term mapping is convention-derived and still needs a directly verified live payload.
