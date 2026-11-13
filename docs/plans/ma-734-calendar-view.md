# MA-734: Classes calendar view and .ics export

Status: functional implementation committed and automated verification passed on 2026-11-13 at GREEN commit `f905e6b63a9cd753d523f1ae0bcaec58043b3781` on `add-calendar-view-jod034`, following RED test commits `e8ed91e1e` and `0cc8ffe81`. Design and device acceptance remain open: course colors must still be verified from the linked Figma frame, and anonymous Inspect access remains blocked.

- Ticket: [MA-734](https://its-pro.ucsd.edu/browse/MA-734), "Classes Card - Add Calendar View".
- Branch: `add-calendar-view-jod034`.
- Base: latest remote `dev`, fetched and verified at `0d0515bd0211d534a33f1b96ea21c17c92b1df1e` on 2026-11-13. The new branch already matched it.
- Ticket requirements: a Calendar toggle inside Classes "View All", and a downloadable `.ics` file students can import into a calendar.
- The issue description supplies no layout, export scope, or detailed acceptance criteria; the comments list is empty.

## Confirmed decisions

- Month grid with a selected-day agenda; all seven days, Sunday first, course-colored meeting dots.
- Select today within the loaded quarter. Neighboring-month dates are dimmed and cannot be selected.
- Use only the quarter already loaded by Classes; no quarter picker.
- Reuse full informational class cards with no tap action. Default to List on each visit.
- Display San Diego time with a timezone label.
- Exclude every exam from Calendar and export, including midterms and finals; preserve the existing List's exam presentation.
- Show meetings without usable times in a separate all-day/TBA area. Reliably dated TBA meetings export as all-day events; undated meetings appear once in a separate group and have no invented export date.
- Export the entire loaded quarter as one `.ics` snapshot, with both Share and Save, on iOS and Android. Brief instructions including desktop/web import satisfy the integration requirement; no direct calendar writes or subscription.
- Omit holiday/cancellation exceptions when authoritative data is available. Use Blink's published academic-calendar dates short term; a possible academic-calendar API is a later integration, with existence/access unverified.
- Design reference: [UC San Diego mobile app, Figma node 4188-13427](https://www.figma.com/design/GyPwWvEvtKG6pcCb1crFzH/UC-San-Diego-mobile-app?node-id=4188-13427).
- Launch date coverage: standard Fall/Winter/Spring quarters in academic year 2026-27; no summer sessions.
- Fixed six-row month grid; show a few course dots plus a `+N` count when they overflow.
- Match the Figma palette exactly; the linked frame is the sole approved source for course colors.
- When today is outside the loaded quarter, initially select its first eligible meeting date.
- Export valid meetings with a clear omission notice when some records lack reliable dates/times; export reliably dated TBA records as all-day events.

## MVP scope

Add List / Calendar to the existing Classes page, with the confirmed month grid and day agenda. Generate one eligible-meeting occurrence set for the UI and full-quarter export. Reuse current styling and fetch/cache behavior, plus native Share and Save capabilities.

Snapshot updates require re-export/import. Defer automatic synchronization, editing, reminders, conflict rules, API integration, and new navigation screens.

Confirmed decisions above are reflected in the committed implementation; open questions below remain.

## Implementation sequence

1. Verify Blink's instructional dates/holidays and the loaded schedule's term-code mapping. Agree remaining visual choices and acceptance examples; use one sanitized representative class payload.
2. Add a small local date table for verified supported terms and one shared occurrence helper. Reuse canonical course/section records; do not add a scraper, API abstraction, or speculative metadata fields. Verify recurrence bounds, exam exclusion, reliably dated all-day TBA events, locations, and San Diego timezone handling.
3. Add the view toggle and month grid to Classes "View All". Preserve the existing list and show the loaded quarter label. Verify month navigation, date selection, agenda ordering, overlapping schedules, TBA meetings, empty/loading/error states, and accessibility.
4. Generate an RFC 5545 `.ics` file and implement the agreed save/share path. Verify the actual file contents, export boundaries, daylight-saving behavior, escaped text, and errors/cancellation.
5. Run focused tests and iOS/Android import checks, review the diff for unnecessary code and dependencies, then prepare the PR. Verify current project checks and that existing Classes behavior remains intact.

## Questions for review

Please answer the remaining questions by number; a brief answer is enough. Questions 1-6 are resolved and retained as a decision record.

### Scope and core design

1. Resolved: month grid with selected-day agenda.
2. Resolved: export all scheduled meetings in the selected quarter.
3. Resolved: download/share `.ics` file only.
4. Resolved: both iOS and Android. Specific acceptance devices/OS versions remain to be agreed.
5. Resolved: Figma reference above. Exact frame styles and interactions still need inspection or confirmation.
6. Resolved: latest remote `dev`, fetched and verified.

### Calendar behavior

7. Resolved: all seven days, Sunday start, course-colored dots, and a few dots plus `+N` for overflow. Verify exact colors from the linked Figma frame.
8. Resolved: reuse full informational class cards with no tap action.
9. Resolved by the latest answer: exclude all exams from Calendar and export; preserve existing List behavior.
10. Resolved: omit exceptions when authoritative data is available. Which feed defines them, and what wording should appear when exceptions are unavailable?
11. Resolved: San Diego time with a timezone label.
12. Resolved: a separate all-day/TBA area, an undated group shown once, and all-day `.ics` events only when dates are reliable. Do not invent dates for asynchronous meetings.
13. Resolved: default to List on each visit.
14. Resolved: reuse current full-card information. Are any existing labels inconsistent with the Figma frame?
15. Resolved: use the exact palette from the linked Figma frame. Labels must carry meaning without relying on color.
16. Is displaying every overlapping meeting as a separate agenda card sufficient, or must we add conflict warnings? Recommendation: render all cards without new conflict rules.
17. Resolved: select today within the quarter, otherwise the first eligible meeting date. Instruction start is used only when today is outside the quarter and there are no eligible meetings; within the quarter, today is selected even when the day is empty. Proposed: Previous/Next + Today and preserve/clamp the selected day number on month changes; show the empty state on the fallback day.
18. Resolved: neighboring-month dates are dimmed and disabled, with six fixed grid rows. Are 12-hour agenda time labels required?
19. Resolved: only the loaded quarter, with standard Fall/Winter/Spring dates in 2026-27. Proposed unsupported-term message: "Academic dates unavailable for this term."
20. Are orientation, large text, screen readers, dark mode, and narrow-screen behaviors specified beyond the app's existing support?

### Export and data correctness

21. Resolved: both Share and Save. Should Save always open a system file-location picker? What filename and confirmation wording should be used?
22. Resolved: the file covers the entire quarter and excludes all exams. Which sanitized holiday/cancellation examples should be demonstrated in acceptance?
23. Export titles and details: desired event title, description, location, file name, and calendar name? Recommendation: course/meeting type plus existing location; no student identifiers.
24. Resolved: brief instructions plus file export are acceptable, including desktop/web import. Which destination apps must pass acceptance: Apple Calendar, Google Calendar, Outlook, or others?
25. Are reminders expected? Recommendation: leave reminder settings to the calendar app.
26. Resolved: snapshot export, with manual re-export/import after schedule changes. Should the UI warn that re-import may create duplicates? Stable UIDs alone do not guarantee every importer updates existing events.
27. Resolved: export valid meetings with a clear omission notice. Proposed: if none are eligible, show a notice and do not emit an empty file.
28. Resolved source: Blink's approved academic calendars for short-term dates. Who verifies the term-code/year mapping and the date table? Can we use a sanitized sample covering a lab/discussion, an excluded exam, TBA, and a daylight-saving transition? A future API needs a separately verified contract and access.
29. Should export work from an already cached schedule while offline? How should students see stale data or a save/share failure?
30. What is the release deadline, who approves the design, and which examples must be demonstrated before the PR is accepted?

## Repository findings

- Entry point: `classes_card.dart` -> `CLASS_SCHEDULE_VIEW_ALL` -> `ClassList` in `lib/ui/classes/classes_list.dart`. Keep that entry point and screen.
- Data: `ClassScheduleDataProvider` fetches GR/UN schedules for the current term through `ClassScheduleService`; canonical course/section records live in `lib/core/models/classes.dart`.
- Each section has nullable `days`, `time`, `date`, building/room, meeting type, and section identifiers. Weekday codes are `MO TU WE TH FR SA SU`; regular time strings contain both endpoints. Special meeting codes `MI`/`FI` identify midterms/finals.
- `lib/core/models/term.dart` retains only term name/code; schedule `Metadata.fromJson` discards incoming metadata. Instructional start/end dates, summer-session bounds, timezone, and exceptions are not available through the current models. Supply them through the approved short-term Blink date table and verify its mapping to the displayed term. Quarter end and the last day of regular instruction are different boundaries.
- The current List includes midterms and keeps finals separately. It mutates the provider's weekday buckets during build; those buckets also repeat multi-day sections. Calendar and export should iterate canonical course/section records, applying the same enrollment/meeting rules, and should not flatten these buckets.
- There is no existing quarter picker, class-detail route, calendar widget, or export helper. Reuse `ContainerView`, existing full class cards, `TimeRangeWidget`, `AppSnackBar`, and `app_styles.dart`.
- The app uses Material 2, supports light/dark styles, and has only iOS/Android platform directories. iOS targets 16.0; Android uses SDK 36 and Java 17.
- `timezone` 0.10.1 and `crypto` 3.0.6 are now direct dependencies used by the calendar helper; `share_plus` 11.1.0 and `flutter_file_dialog` 3.3.6 are resolved direct dependencies whose Android plugin Kotlin compilation is verified, while the full Android app build, iOS builds, and device behavior remain unverified.
- Cache can survive failed refreshes without a stored fetch timestamp. Match dates to the cached schedule's actual term code; do not use current-term dates for an older cached schedule. Avoid inventing a last-updated value.

## Month grid and agenda proposal

- Use standard Flutter `ToggleButtons`, a seven-column month grid, `intl` labels, and the existing full class cards. A small `GridView` implementation is sufficient for this bounded month-selector requirement; reconsider `table_calendar` only if approved interactions justify it.
- Proposed controls: month/year, Previous/Next, and Today when applicable. Navigate only months intersecting the verified quarter range; disable dates outside it. Select today within the quarter, otherwise its first eligible meeting date. Use instruction start only when today is outside the quarter and there are no eligible meetings; within the quarter, select today even when the day is empty, and show the empty-state message there.
- Sunday-first, fixed six-row grid with dimmed, disabled neighboring-month dates. Show one colored dot per course with meetings on a date, limited to available space plus `+N` for hidden course dots. Use the supplied Figma palette and distinguish selection and today. Announce full dates, states, and course/meeting counts; do not encode course identity solely through color.
- List is the initial view on every visit. Keep the selected month/date while toggling during the same visit; no stored preference.
- Selecting a date shows a dated heading and chronological agenda cards; overlapping meetings remain separate cards. No card tap action, conflict engine, or new details screen.
- Use a separate all-day/TBA area for meetings without usable times. Put dated TBA meetings on their known day and export them as all-day events as agreed; undated meetings appear in one labeled group and have no export date. Validate ranges before reusing the card's time renderer: the current `TimeRangeWidget` assumes a usable range, so TBA/malformed values need a text fallback.
- Reuse existing tokens and themed components. Verify large text, narrow screens, screen readers, accessible target sizes, and contrast. Avoid hiding weekend meetings or relying on color alone.
- Distinguish a day with no meetings, an empty quarter, unavailable dates, and a data-fetch failure. Keep List available when dates are unavailable. Do not present an incomplete dated schedule as a complete quarter export.

## Short-term academic dates

Use one small versioned table from [Blink's 2026–2027 calendar](https://blink.ucsd.edu/instructors/resources/academic/calendars/2026.html), verified 2026-11-13; the page's last update is October 7, 2026. Dates below are inclusive.

| Term | Quarter range | Regular instruction | Holidays within quarter |
| --- | --- | --- | --- |
| Fall 2026 | 2026-09-21 through 2026-12-12 | 2026-09-24 through 2026-12-04 | 2026-11-11, 2026-11-26, 2026-11-27 |
| Winter 2027 | 2027-01-04 through 2027-03-20 | 2027-01-04 through 2027-03-12 | 2027-01-18, 2027-02-15 |
| Spring 2027 | 2027-03-24 through 2027-06-11 | 2027-03-29 through 2027-06-04 | 2027-03-26, 2027-05-31 |

Use quarter bounds for navigation and instruction bounds for ordinary weekly occurrences. Remove the published holidays and any reliable course-specific cancellations; published academic holidays do not establish individual class changes. Exclude exam meeting records (`MI`/`FI` and any other verified exam identifiers), rather than blindly removing every date in an exam period.

Store only verified term keys, date bounds, exceptions, source URL, and verification date. Term-key mapping for the supported terms is recorded in `lib/core/services/classes_calendar.dart`: `FA26` and `WI27` were verified directly against the official Class Planner term dropdown; `SP27` follows the documented season-plus-year convention and has no directly verified live payload yet. Do not add runtime HTML scraping, API access requests, or an interchangeable calendar-source layer.

Summer is outside the agreed launch scope. Research of the [Summer Session calendar](https://summersession.ucsd.edu/calendar/index.html) confirms that special-session dates vary by course; do not use a generic summer range if summer support is added later.

For an unsupported or mismatched term, retain List and explain that academic dates are unavailable. Do not silently date weekly classes using another term. For a supported term, export eligible meetings with an omission notice for undated/invalid records. Proposed: block a full-quarter export without supported bounds rather than presenting a few independently dated records as the full schedule.

## Minimal file scope

| File | Intended change |
| --- | --- |
| `lib/ui/classes/classes_list.dart` | List/Calendar toggle (default List per visit) and export actions; merged section copies instead of mutating provider buckets. |
| `lib/ui/classes/classes_calendar.dart` (new) | Sunday-first six-row month grid, dimmed/disabled out-of-quarter days, and selected-day agenda. |
| `lib/app_styles.dart` (only as needed for the supplied palette) | Add named course-color tokens matching Figma; reuse those tokens in the grid. |
| `lib/core/services/classes_calendar.dart` (new) | Blink-verified FA26/WI27/SP27 date bounds (FA26/WI27 term keys verified directly; SP27 mapping convention-derived), one shared occurrence set (exam exclusion, holiday removal, TBA/undated handling), and `.ics` serialization. |
| `lib/ui/classes/class_schedule_card.dart` (new) | Full informational class card extracted for reuse by List and Calendar. |
| `lib/core/providers/classes.dart` (only if needed) | Expose the loaded term/canonical records needed by the calendar; preserve existing fetch and cache behavior. |
| `pubspec.yaml`, `pubspec.lock` | Only the sharing/saving capability and direct declarations needed by actual imports. |
| Focused Classes/calendar/export tests | `test/core/services/classes_calendar_test.dart`, `test/ui/classes/classes_calendar_test.dart`, `test/ui/classes/classes_calendar_export_test.dart`, `test/ui/classes/classes_list_test.dart`. |

Do not change home-card navigation, add a backend calendar service, migrate the design system, or upgrade build tooling merely to take the newest package version.

## Verification planned for implementation

- Correct 28/29/30/31-day months, every first weekday, leap years, December/January navigation, and partial-quarter bounds.
- Dots, agenda counts, and exported events agree; multi-day/multi-section meetings appear once per actual occurrence; all exam meeting records are excluded from Calendar/export while List behavior stays intact.
- Correct instructional dates, confirmed exceptions, TBA omissions/all-day behavior, and invalid/zero/reversed/overnight time policy; no fabricated duration.
- San Diego daylight-saving transitions keep campus meeting times stable; travel/device timezone changes do not redefine campus schedule dates.
- RFC text escaping, UTF-8 line folding, CRLFs, required fields, stable unique IDs, and deterministic occurrence identities.
- Share and Save on real iOS/Android targets, iPad share anchoring if supported, cancellation versus errors, partial/no-valid-meeting export behavior, and import results.
- Default List, repeated toggles, empty/loading/error states, narrow screens, large text, light/dark, VoiceOver/TalkBack, and unchanged existing Classes/Finals behavior.
- Use the project's existing provider-test and widget-test conventions, run relevant `flutter test` and `flutter analyze` checks, and perform the Ponytail diff review before preparing a PR.

## External research

### .ics generation

Use [RFC 5545](https://www.rfc-editor.org/info/rfc5545/), particularly sections 3.1 (content lines), 3.3.5 (date/time), 3.3.11 (text), 3.6.1 (events), and 3.8.4.7 (UID).

- Create one `VCALENDAR`, `VERSION:2.0`, an app `PRODID`, and one `VEVENT` per actual occurrence. Each event has a unique stable `UID`, UTC `DTSTAMP`, `DTSTART`, `DTEND`, and a course/meeting-type `SUMMARY`; include existing description/location where useful. Omit `METHOD` for the snapshot export.
- Generate occurrences from Blink's verified instructional/session dates and each section's weekday/time fields. Apply supplied exceptions; add reliable non-exam dated meetings once. Exclude all exams as agreed. The month indicators and agenda use this same occurrence logic.
- Prefer explicit occurrences for the finite quarter: construct each occurrence in `America/Los_Angeles`, then serialize UTC values ending in `Z`. Do not convert using the device timezone or use a fixed Pacific offset. This avoids needing an `RRULE` and `VTIMEZONE` generator while handling daylight-saving transitions correctly.
- A recurring alternative needs local `TZID` dates, a matching `VTIMEZONE`, bounded recurrence, and exceptions. A fixed UTC weekly recurrence can change the local class hour across DST. This additional complexity is unnecessary for the selected snapshot MVP.
- Serialize as UTF-8 with CRLF line endings. Fold content lines at 75 octets without splitting Unicode characters. Escape backslash, comma, semicolon, and intentional newlines in text properties; prevent untrusted text from creating extra properties.
- Use MIME type `text/calendar` and a `.ics` filename. Stable IDs need a confirmed section/meeting discriminator plus occurrence date; do not include student identifiers. Treat duplicate/update behavior as importer-specific and test re-import rather than promising automatic deduplication.
- Do not fabricate dates or durations. Export reliably dated TBA meetings as all-day events using `DTSTART;VALUE=DATE:YYYYMMDD` and an exclusive next-day `DTEND;VALUE=DATE`. Export eligible meetings with a clear notice listing omissions. For multi-day/all-day records, only use a duration supported by the source. Do not emit a malformed file; with zero eligible events, propose a notice instead of an empty export.

### File delivery and import

- `url_launcher` can open URLs, but it does not create/save/share a local `.ics` file or guarantee calendar import. There is no existing hosted schedule-export endpoint to reuse in the inspected client.
- Share should hand the generated file to the OS share sheet. Save should deliver the same bytes to a native user-selected destination. Do not upload a private schedule to obtain a download URL or add direct-calendar permissions for file export.
- A dedicated sharing package is justified by native file delivery. [share_plus 11.1.0 documentation](https://pub.dev/packages/share_plus/versions/11.1.0) lists Flutter >=3.22, Dart >=3.4, iOS >=12, Java 17, AGP >=8.3, and Gradle >=8.4. It supports file sharing on iOS/Android through `SharePlus.instance.share(ShareParams(files: ...))`. Version 11.1.0 is now a resolved direct dependency; its Android plugin Kotlin compilation is verified, while the full Android app build, iOS builds, and device share behavior remain unverified. iPad requires `sharePositionOrigin`; share results may be unavailable and do not verify import.
- For Save, [flutter_file_dialog 3.3.6](https://pub.dev/packages/flutter_file_dialog) documents saving to a selected location on Android API 24+ and iOS 13+. 3.3.6 is now a resolved direct dependency; its Android plugin Kotlin compilation is verified on the host toolchain (Gradle 8.14 / AGP 8.11.1 / Java 17), while the full Android app build and iOS build/device behavior remain unverified. [Version 3.0.3's API](https://pub.dev/documentation/flutter_file_dialog/3.0.3/flutter_file_dialog/SaveFileDialogParams/SaveFileDialogParams.html) accepts `sourceFilePath` or `data` plus `fileName`; `saveFile` returns nullable success/cancellation information. Its declared build versions fit the app, but it has provider/result-handling defects fixed later. Do not pin an older release solely for compatible version numbers; validate the corrected release with the current toolchain and local/cloud save destinations before selection.
- [file_selector 1.1.0](https://pub.dev/packages/file_selector) supports picking files on mobile, but its platform table explicitly marks "Choose a save location" unsupported on Android and iOS. It does not satisfy the requested mobile Save action.
- Prefer two small native-capability packages and generate `.ics` bytes once: Share via `XFile.fromData` with `fileNameOverrides`, and Save via a supported `SaveFileDialogParams(data: ..., fileName: ...)` API. Declare `timezone` directly when imported; use `path_provider` only if actual file handling needs it. Avoid custom platform channels, a storage abstraction, or a backend download endpoint. Both plugins may stage temporary files internally; do not claim a returned Android document identifier is a reusable filesystem path or remove files before handoff readers finish.
- [Google Calendar import instructions](https://support.google.com/calendar/answer/37118?hl=en) explicitly document ICS import on a computer through Settings -> Import & export. Provide accurate guidance; availability of a share target is not proof of phone import support.
- [Apple Calendar on Mac](https://support.apple.com/guide/calendar/import-or-export-calendars-icl1023/mac) supports dragging an `.ics` file into Calendar or using File -> Import, then choosing a calendar. This verifies a Mac import path, not automatic iPhone import from our share sheet.
- [Outlook.com/Outlook on the web](https://support.microsoft.com/en-us/outlook/import-or-subscribe-to-a-calendar-in-outlook-com-or-outlook-on-the-web) supports Add calendar -> Upload from file and distinguishes a snapshot import from a subscription that receives updates. Use the file path for this MVP.
- Verify Apple Calendar and Outlook destination behavior plus Save/Share on actual supported devices. Wording should say the file was saved or handed off, not that calendar import succeeded.

### Design-reference status and review limits

The linked Figma file opens in the viewer as "UC San Diego mobile app". Automated snapshots timed out and the accessible DOM did not expose the referenced frame's components; the viewer offers sign-up for inspection. Exact frame styling and interactions are therefore not verified. The plan follows your explicit month-grid decision and current Flutter styles until those frame details can be inspected or confirmed.

The exact course-color palette is likewise still blocked: the implementation currently uses an empty approved-color list and falls back to a plain meeting count per day. That fallback is an incomplete-design placeholder, not an accepted ship state.

Astryx's CLI was unavailable and its skill describes web/npm components; no Flutter-compatible library was established. Preserve the existing Flutter design system for this change.

## Implementation status (2026-11-13)

- Implemented: List/Calendar toggle in `classes_list.dart` (List default per visit, view state kept while toggling); month grid in `classes_calendar.dart` (Sunday-first fixed six rows, dimmed/disabled out-of-quarter days, today-then-first-meeting selection, instruction start only when today is outside the quarter and no eligible meetings exist); occurrence/export helper `lib/core/services/classes_calendar.dart` (FA26/WI27/SP27 only, all exams excluded, published holidays removed, reliably dated TBA meetings exported all-day, undated meetings shown once and omitted from export); Share/Save actions in `classes_calendar_export.dart` with omission notice, no-empty-file behavior, and import instructions; `calendarSchedule` accessor on the provider.
- Dependencies resolved as direct: `share_plus` 11.1.0, `flutter_file_dialog` 3.3.6, `crypto` 3.0.6, `timezone` 0.10.1; both plugins' Android Kotlin compilation succeeds.
- Checks recorded: RED test commits `e8ed91e1e` and `0cc8ffe81`; helper suite 27/27 and export suite 9/9 pass with analyzer-clean files; first full suite 151 pass with 2 UI failures, fixed before the final run. Final integrated checks pass at GREEN commit `f905e6b63a9cd753d523f1ae0bcaec58043b3781` with pre-final/post-final hashes stable: `flutter test --no-pub --coverage --reporter expanded` exits 0 with 153/153 passing and no failures or skips; CI `flutter analyze --no-pub --no-fatal-warnings --no-fatal-infos` exits 0 at exactly the 140 baseline findings (0 errors, 8 warnings, 132 infos) with no feature findings; format dry-run exits 0 (208 files, 0 changed). Evidence logs: `.dart_tool/ma734-verification/logs/03-auto-fix-dry-run-final.log`, `04-analyze-final.log`, and `05-flutter-test-final.log`. Feature coverage at that commit is 98.3% (624/635 lines) across helper/card/calendar/export/list (247/250, 85/86, 179/181, 59/64, 54/54); the initial 98.1% figure (570/581 lines) excluded `classes_list.dart`. Python gates pass using the isolated `.dart_tool/ma734-verification/python313/python.exe` (3.13.17): pre-commit 4.4.0 `validate-config` exits 0 and all 6 script tests exit 0; Android plugin Kotlin compile BUILD SUCCESSFUL (Gradle 8.14 / AGP 8.11.1 / Java 17, no tooling upgrade); independent FA26 fixture at `.dart_tool/ma734/classes-fa26.ics` contains 29 events, parser-verified with Python 3.13.17 plus `icalendar` 7.3.0 (29 MWF events September 25 through December 4, unique UIDs, required properties, 50-minute durations, exact holiday exclusion, campus starts 10:00, October 30 17:00Z and November 2 18:00Z); the ASCII fixture has no folding/escaping, so those round trips are covered by helper unit tests only.
- Follow-up recorded (later focused run, distinct from the 153/153 full-suite and 98.3% coverage evidence at `f905e6b63a9cd753d523f1ae0bcaec58043b3781`; no subsequent full-suite or coverage rerun was performed): the tiny UI accessibility cleanup completed in `classes_calendar.dart`, removing the literal `Selected` from the date label while retaining the selected flag, with its test using Flutter 3.44.6 replacement flags (`flagsCollection.isSelected == Tristate.isTrue`), semantics anchored to the exact `_cellSemantics` widget, a single date label retained, and tap activation retained. `dart format --line-length 120` completed on `lib/ui/classes/classes_calendar.dart` and `test/ui/classes/classes_calendar_test.dart`; `flutter analyze --no-pub` on those same two files exits 0 with no issues; `flutter test --no-pub test/ui/classes/classes_calendar_test.dart test/ui/classes/classes_list_test.dart` exits 0 with 29/29 passing. Main reviewed the initial docs diff, and Ponytail r3 found no issues in the cleanup.
- Pending, not claimed done: full Android app build (plugin compile verified only); iOS builds (unavailable on Windows, Firebase configs missing); real-device Share/Save/import verification. Figma palette verification additionally needs Inspect access; the latest recheck still shows anonymous Sign up to inspect with the tab visible. SP27 still needs a directly verified live term payload.
