# Student ID: Graceful Degradation

Status: proposed design; implementation is pending.

## Objective

Preserve every usable Student ID verification component when another component fails, with barcode, name, and photo in that order of importance. Keep available academic details alongside verification content. Replace the card body with the generic error only when no usable verification content remains and no load is pending.

Keep changes limited to Student ID data handling and UI. Reuse `CardContainer` unchanged and preserve the existing visual design.

## Data sources

`StudentIdDataProvider` calls `StudentIdService`, which sends authenticated GET requests through `NetworkHelper.authorizedFetch` using the logged-in user's bearer token.

The reviewed local `.env` uses these QA endpoints:

| API | Environment variable | Base URL |
| --- | --- | --- |
| Contact | `MY_STUDENT_CONTACT_API_ENDPOINT` | `https://api-qa.ucsd.edu:8243/student/my/student_contact_info/v1` |
| Profile | `MY_STUDENT_PROFILE_API_ENDPOINT` | `https://api-qa.ucsd.edu:8243/student/my/v1` |

The app code does not identify the databases behind these APIs.

| Card component | Endpoint | Response fields |
| --- | --- | --- |
| Photo | Contact: `/photo` | `photoUrl`; requires a separate image download. |
| Name | Contact: `/display_name` | `firstName` + `lastName`; middle name is not displayed. |
| Classification | Profile: `/profile` | `Classification_Type`. |
| Major | Profile: `/profile` | `Graduate_Primary_Major_Current`, falling back to `UG_Primary_Major_Current`. |
| College | Profile: `/profile` | `College_Current`. |
| Barcode and printed number | Profile: `/profile` | `Barcode`; rendered locally as Codabar. |

Use the same validated `Barcode` in the card and enlarged scanning view. `Student_PID` and `Card_Number` are fetched but are not separately displayed; do not substitute them for `Barcode`. The card title and scan instruction are local UI text.

## Current behavior

- Requests run in order: name, photo, profile. The first request or parsing failure stops the sequence and hides the entire card body, including previously fetched content.
- Each service method stores `e.toString()` in a shared error field and returns `false`. `CardContainer` prints the error and displays "An error occurred, please try again." Reload restarts the sequence.
- The network helper accepts HTTP `200`. HTTP errors, connection failures, and timeouts reach the same catch block. Connection and receive timeouts are each configured to 60 seconds; this request path has no automatic retry or token refresh.
- `Image.network` has no fallback. Asynchronous image failures bypass the API and widget-construction catches.
- The widget-construction catch reports to Crashlytics and displays a support message. Global Flutter error reporting is configured, but the service does not explicitly report caught API failures to Crashlytics.

## Fetching and recovery priority

Start all three API requests in parallel after authentication: none depends on another response. Render each usable verification result immediately, along with available academic details. Start the image download when its URL arrives; do not make other components wait for it.

If request concurrency must be limited, prioritize:

1. **Barcode, through Profile:** restores scanning and also supplies academic details.
2. **Name:** identifies the student by name.
3. **Photo:** supports visual identification.

This ranking reflects the student's verification priorities: barcode, then name, then photo. It does not change normal parallel loading or make any one endpoint mandatory for displaying partial content.

## Card state and fallbacks

**Usable verification content** means a valid barcode, a validated, nonempty displayed name, or a successfully loaded student photo. Any one of these components is enough to retain the card. Classification, major, and college are supplementary: display them when available alongside verification content, but academic details alone do not qualify. A URL alone, placeholder, static label, or HTTP `200` does not qualify. Throughout this design, "usable content" and `hasUsableContent` refer to usable verification content.

Evaluate the card state in this order:

1. **Usable content exists:** render it and available academic details. Show loading indicators for pending components and the fallbacks below for unavailable components.
2. **No usable content, but a load is pending:** show a loading state.
3. **No usable content and no load is pending:** replace the card body with exactly:

   > An error occurred, please try again.

Pending work includes the image download and decoding. Apply a 60-second overall deadline to each API request and a 30-second overall deadline to each image download plus decoding attempt. These deadlines cover the entire attempt, rather than restarting for each network phase. On timeout, end that component's pending state, record the failure, and apply its fallback or the whole-card error according to the rules above. Ignore any subsequent completion from the expired attempt. A future manual retry does not count as pending work.

Apply these component fallbacks only while retaining the card:

| Unavailable component | Fallback |
| --- | --- |
| Photo API, URL, or image | Show `assets/images/staff_id_placeholder.png`. |
| Name | Show "Name unavailable". |
| Classification, major, or college | Omit the affected field and its spacing. |
| Barcode | Show "Barcode unavailable"; disable scanning and the popup, and hide the scan instruction. |
| Entire profile | Apply the academic-field and barcode fallbacks; preserve name/photo. |

Combine fallbacks when multiple components fail. The whole-card error takes precedence once nothing usable or pending remains.

The [placeholder image](assets/images/staff_id_placeholder.png) exists, is included by `pubspec.yaml`, and is used by Employee ID.

## Minimal UI changes

In `StudentIdCard`, pass aggregate state to the existing `CardContainer` interface:

```dart
isLoading: !hasUsableContent && hasPendingWork,
errorText: !hasUsableContent && !hasPendingWork
    ? 'An error occurred, please try again.'
    : null,
```

Derive these values from validated content and pending API/image work. This reuses the container's loading, content, and error states without changing its implementation or other cards.

| Area | Change within Student ID |
| --- | --- |
| Layout | Keep the photo-left, details-right arrangement, fonts, colors, and styling. |
| Photo | Give the photo, placeholder, and loading indicator identical bounds. Constrain the photo width to leave room for details. |
| Name | Keep its position and styling; use the fallback only after loading finishes without a usable name. |
| Academic details | Include each available field with its spacing. Hide the divider when it no longer separates visible sections. |
| Barcode | Keep the renderer and popup; pass the validated barcode string to both. Replace an unavailable barcode and printed number with the fallback text. |
| Partial loading | Show small indicators in pending sections while keeping successful content visible. |

Reuse the existing Reload menu action. Add no new retry controls.

- During partial failure, retry failed or unavailable verification components through their owning endpoint while preserving successful content. A failed or invalid barcode requires refetching `/profile`; keep successful academic fields visible and merge validated response fields independently so another malformed barcode cannot discard valid text.
- If only the image download or decoding failed, start a fresh image attempt using the existing validated photo URL, even when the URL is unchanged. If that URL no longer works, refetch `/photo` to obtain a fresh URL. Failed photo metadata or an invalid URL also requires refetching `/photo`.
- Missing optional academic fields alone do not count as a failure or trigger a retry. With no failed or unavailable verification components, refresh all three APIs while preserving successful content.
- Skip sections already loading. Repeated Reload taps must not create duplicate API requests or image loads; failed sections can still be retried while other sections are pending.

## Essential change 1: Independent section state

Replace the service's shared `_error` and `_isLoading` with request-specific results. Parallelizing the existing methods alone allows requests to overwrite one another's state.

- Track data, loading, and errors independently for name, profile, photo metadata, and the image load. Derive component availability from validated data.
- Set pending flags before notifying the UI at the start of a load to avoid briefly showing the final error.
- Start image loading even while the card body shows a loading indicator, so a photo-only response can become visible.
- Update the provider and UI after each result; one failure must not stop another request.
- Supply the aggregate flags above from `StudentIdCard`; keep `CardContainer` unchanged.
- Preserve successful content during retries, including successful sibling fields when an endpoint is refetched for one failed component. Merge valid replacement fields independently; a failed request or unavailable replacement field must not discard retained successful content.
- Identify every API and image attempt with a request identifier tied to the authenticated session. Accept a result only if its identifier is still current for that section and session; ignore results from superseded or expired attempts.
- Clear retained content when the authenticated user changes or signs out. Invalidate outstanding attempts from the previous session so late responses cannot populate the new user's card.

## Essential change 2: Field-level parsing and validation

Parse fields independently so one missing or malformed value cannot discard valid sibling fields. Invalid JSON or an unexpected response structure fails that endpoint; a valid JSON object can still supply partial content.

- Accept valid string values, trim display text, and treat `null`, empty strings, or wrong-type values as unavailable. Unused metadata must not invalidate displayed fields.
- Build the name from available `firstName` and `lastName` values.
- Use a valid, nonempty graduate major; otherwise try the undergraduate major.
- Validate `Barcode` against the Codabar renderer. Keep other profile fields if it is invalid; never generate a replacement value.
- Validate the photo URL, then handle download, timeout, and decoding failures with the placeholder. Mark the photo usable only after it loads successfully.

## Acceptance checks

- Vary response order and delay each API/image in turn: ready verification components appear without waiting, along with available academic details.
- Fail each API and every combination of APIs: preserve all remaining usable components.
- Fail or stall the image after `/photo` succeeds: use the placeholder when other usable verification content exists; show the generic error once all work ends without usable content.
- Return empty `200` responses or malformed fields: apply the same availability rules as other failures.
- Return a valid barcode with malformed unrelated fields: keep scanning available. Return an invalid barcode with valid academic fields: preserve those fields and disable scanning while retaining the card if name or photo is usable; otherwise follow the loading and whole-card error rules.
- Leave only a valid barcode, name, or successfully loaded photo: retain the card. Leave only academic details, or no content, after all loads end: show the exact generic error.
- Use Reload during partial failure: retry affected endpoints and preserve successful content, including academic fields during a barcode retry. With no failed or unavailable verification components, refresh all three APIs. Missing optional academic fields alone must not trigger retries.
- Retry an image failure using the existing validated URL; refetch `/photo` if that URL no longer works. Repeated Reload taps while sections are pending must not start duplicate work.
- Stall each API and image attempt: API pending states end within 60 seconds and image download plus decoding ends within 30 seconds. Ignore completions after timeout and apply the appropriate fallback or final error.
- Deliver superseded responses after a new attempt starts: only the current attempt may update its section. Change users or sign out during loading or retries: clear retained content and ignore all previous-session results.
- Check narrow screens and portrait/landscape layouts: image-state changes must not shift the details column or cause overflow; omitted fields must not leave orphaned spacing or dividers.
- Check the barcode popup uses the same value as the card, and partial Student ID failures do not change other cards' loading/error behavior.

## Implementation references

- Data flow: [service](lib/core/services/student_id.dart), [provider](lib/core/providers/student_id.dart), [provider registration](lib/app_provider.dart).
- Parsing: [name](lib/core/models/student_id_name.dart), [photo](lib/core/models/student_id_photo.dart), [profile](lib/core/models/student_id_profile.dart).
- Rendering: [Student ID card](lib/ui/student_id/student_id_card.dart), [card container](lib/ui/common/card_container.dart).
- Infrastructure: [network helper](lib/app_networking.dart), [global error reporting](lib/main.dart).
