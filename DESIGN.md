# Student ID: Graceful Degradation

Status: proposed design; implementation is pending.

## Objective

Preserve every usable Student ID component when another component fails. Replace the card body with the generic error only when no usable content remains and no load is pending.

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

Start all three API requests in parallel after authentication: none depends on another response. Render each result immediately. Start the image download when its URL arrives; do not make other components wait for it.

If request concurrency must be limited, prioritize:

1. **Profile:** restores scanning and supplies academic details.
2. **Name:** identifies the student by name.
3. **Photo:** supports visual identification.

This ranking assumes scanning is the primary task. It does not change normal parallel loading or make any one endpoint mandatory for displaying partial content.

## Card state and fallbacks

**Usable content** means at least one validated, nonempty displayed text field (name, classification, major, or college), a valid barcode, or a successfully loaded student photo. A URL alone, placeholder, static label, or HTTP `200` does not qualify. Under this design, any one usable component is enough to retain the card.

Evaluate the card state in this order:

1. **Usable content exists:** render it. Show loading indicators for pending components and the fallbacks below for unavailable components.
2. **No usable content, but a load is pending:** show a loading state.
3. **No usable content and no load is pending:** replace the card body with exactly:

   > An error occurred, please try again.

Pending work includes the image download and decoding. Give each load attempt a finite deadline so it cannot prevent the final error indefinitely. A future manual retry does not count as pending work.

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

Reuse the existing Reload menu action. During partial failure, retry failed or unusable sections, including the image, while preserving successful content. Otherwise, refresh all three APIs. Missing optional academic fields alone do not count as a failure. Add no new retry controls.

## Essential change 1: Independent section state

Replace the service's shared `_error` and `_isLoading` with request-specific results. Parallelizing the existing methods alone allows requests to overwrite one another's state.

- Track data, loading, and errors independently for name, profile, photo metadata, and the image load. Derive component availability from validated data.
- Set pending flags before notifying the UI at the start of a load to avoid briefly showing the final error.
- Start image loading even while the card body shows a loading indicator, so a photo-only response can become visible.
- Update the provider and UI after each result; one failure must not stop another request.
- Supply the aggregate flags above from `StudentIdCard`; keep `CardContainer` unchanged.
- Preserve successful content during retries. Retained content must belong to the current authenticated user.

## Essential change 2: Field-level parsing and validation

Parse fields independently so one missing or malformed value cannot discard valid sibling fields. Invalid JSON or an unexpected response structure fails that endpoint; a valid JSON object can still supply partial content.

- Accept valid string values, trim display text, and treat `null`, empty strings, or wrong-type values as unavailable. Unused metadata must not invalidate displayed fields.
- Build the name from available `firstName` and `lastName` values.
- Use a valid, nonempty graduate major; otherwise try the undergraduate major.
- Validate `Barcode` against the Codabar renderer. Keep other profile fields if it is invalid; never generate a replacement value.
- Validate the photo URL, then handle download, timeout, and decoding failures with the placeholder. Mark the photo usable only after it loads successfully.

## Acceptance checks

- Vary response order and delay each API/image in turn: ready components appear without waiting.
- Fail each API and every combination of APIs: preserve all remaining usable components.
- Fail or stall the image after `/photo` succeeds: use the placeholder when other content exists; show the generic error once all work ends without usable content.
- Return empty `200` responses or malformed fields: apply the same availability rules as other failures.
- Return a valid barcode with malformed unrelated fields: keep scanning available. Return an invalid barcode with valid text: keep the text and disable scanning.
- Leave only one usable component, including an academic field: retain it. Leave none after all loads end: show the exact generic error.
- Use Reload during partial failure: retry affected sections and preserve successful content. With no failures, refresh all three APIs.
- Check narrow screens and portrait/landscape layouts: image-state changes must not shift the details column or cause overflow; omitted fields must not leave orphaned spacing or dividers.
- Check the barcode popup uses the same value as the card, and partial Student ID failures do not change other cards' loading/error behavior.

## Implementation references

- Data flow: [service](lib/core/services/student_id.dart), [provider](lib/core/providers/student_id.dart), [provider registration](lib/app_provider.dart).
- Parsing: [name](lib/core/models/student_id_name.dart), [photo](lib/core/models/student_id_photo.dart), [profile](lib/core/models/student_id_profile.dart).
- Rendering: [Student ID card](lib/ui/student_id/student_id_card.dart), [card container](lib/ui/common/card_container.dart).
- Infrastructure: [network helper](lib/app_networking.dart), [global error reporting](lib/main.dart).
