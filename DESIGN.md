# Student ID: Data Sources and Graceful Degradation

This document records the current Student ID data flow and the proposed design for preserving useful card content when individual requests or fields fail. The proposed behavior still needs to be implemented.

## Design objective

The Student ID card should degrade one component at a time. A missing photo, name, academic detail, or barcode must not discard other usable information.

Replace the entire card body with the following message only when no section has usable content and all outstanding requests and relevant image loads have finished or failed:

> An error occurred, please try again.

A placeholder, static title, loading indicator, or error label does not count as usable student information. An HTTP `200` response alone does not establish that a section has usable content.

## Data sources and component ownership

The card reads models from `StudentIdDataProvider`, which calls `StudentIdService`. The service makes authenticated GET requests through `NetworkHelper.authorizedFetch`, using the logged-in user's bearer access token.

The local `.env` configuration reviewed for this design points to the QA API host, `https://api-qa.ucsd.edu:8243`:

| Environment variable | Configured base URL |
| --- | --- |
| `MY_STUDENT_CONTACT_API_ENDPOINT` | `https://api-qa.ucsd.edu:8243/student/my/student_contact_info/v1` |
| `MY_STUDENT_PROFILE_API_ENDPOINT` | `https://api-qa.ucsd.edu:8243/student/my/v1` |

These are the reviewed local settings, not a statement about the production build. The app code does not identify the databases behind these APIs.

| Visible component | API endpoint | Response field and behavior |
| --- | --- | --- |
| Student photo | Contact API: `/photo` | `photoUrl`; the image is downloaded separately from that URL. |
| Displayed name | Contact API: `/display_name` | `firstName` + `lastName`. The returned middle name is not currently displayed. |
| Classification beneath the name | Profile API: `/profile` | `Classification_Type`. |
| Major | Profile API: `/profile` | `Graduate_Primary_Major_Current` when nonempty; otherwise `UG_Primary_Major_Current`. |
| College | Profile API: `/profile` | `College_Current`. |
| Barcode graphic | Profile API: `/profile` | `Barcode`, rendered locally using Codabar. |
| Number beneath the barcode | Profile API: `/profile` | Also `Barcode`. |

The enlarged scanning view belongs to the same barcode component and should use the same validated `Barcode` value. The card title and "tap for easier scanning" instruction are local UI text.

`Student_PID` and `Card_Number` are returned by the profile API but are not currently displayed as separate fields. They must not be substituted for `Barcode` without an explicit change to the API contract and product behavior.

## Current error handling

Requests currently run sequentially: name, then photo, then profile. Each service method catches both request failures and JSON/model parsing failures, stores `e.toString()` in a shared error field, returns `false`, and clears its loading flag.

| Failed request | Current result |
| --- | --- |
| `/display_name` | Stops loading immediately; photo and profile are never requested. |
| `/photo` | Stops loading immediately; profile is never requested. |
| `/profile` | Stops after name and photo succeeded; their content is still hidden by the card error. |

The provider copies the first error, stops loading, and notifies the UI. `CardContainer` prints the technical error to the console and replaces the card body with the generic message. The menu's Reload action restarts the full sequence.

The network helper accepts HTTP `200` as success. Dio throws for HTTP failures such as `401`, `403`, `404`, and `500`, as well as connection failures and timeouts. The reviewed configuration sets connection and receive timeouts to 60 seconds each. This GET request path has no automatic retry or token refresh.

There are two additional error paths:

- The photo API returns a URL, not the image itself. The current `Image.network` has no image fallback. Asynchronous image download or decoding errors are outside the API service's catch block and the surrounding widget-construction catch.
- The widget-construction catch reports to Crashlytics and displays a separate message containing the support email. Global Flutter error reporting is also configured. Caught API errors are converted to strings and are not explicitly reported to Crashlytics by this service.

## Fetch strategy and priority

Fetch all three APIs in parallel after authentication. They share an access token, but no request requires another request's response.

Publish each result as soon as it is available. Start the image download as soon as `/photo` supplies a usable URL. Do not wait for all requests to finish before displaying successful sections, and do not let a slow image delay a ready barcode.

Assuming scanning is the primary task, use this order when prioritizing recovery or when concurrency must be limited:

1. **Profile (`/profile`):** Provides the barcode and most of the card's information. The barcode is its highest-priority field; academic details are supplementary.
2. **Name (`/display_name`):** Identifies the student by name and complements both scanning and visual identification.
3. **Photo (`/photo` plus image download):** Supports visual identification, but its absence should not block the barcode or text.

This is a usefulness and recovery ranking. Normal loading should start all three requests together.

## Degradation and recovery behavior

| Failure or missing content | Proposed behavior |
| --- | --- |
| Photo API fails, URL is absent/invalid, or image download/decoding fails | Display `assets/images/staff_id_placeholder.png`; preserve available text and barcode. |
| Name is unavailable | Display "Name unavailable"; preserve other sections. |
| Profile is unavailable | Preserve name/photo, display "Barcode unavailable", and omit unavailable academic details. |
| College, major, or classification is missing | Omit the affected field and its unnecessary spacing; preserve other profile fields. |
| Barcode is missing or invalid | Display "Barcode unavailable" and disable the scan interaction, popup, and scan instruction; preserve usable identity details. |
| Multiple sections fail | Combine the relevant fallbacks and preserve every remaining useful section. |
| No section has usable content, but work is still pending | Keep an appropriate loading state; do not declare complete failure yet. |
| No section has usable content and all work has settled | Replace the card body with "An error occurred, please try again." |

The placeholder asset exists and `pubspec.yaml` already includes the `assets/images/` directory. It is also used by the Employee ID card.

Successful sections should remain visible during recovery. Support retrying failed sections without forcing successful sections to disappear or reload. A failed image download should be recoverable independently of the name and profile APIs.

The last-resort decision must include actual image availability: a successful `/photo` response does not rescue the card if its image cannot load and no other useful content exists. Conversely, a name-only or photo-only result should remain visible under this design.

## Essential implementation change 1: Independent section state

Replace the shared error/loading state with independent results for name, photo metadata/image, and profile. Each section needs its own loading status, usable data, and failure information.

The service currently shares `_error` and `_isLoading` across all three methods. Simply placing the existing calls in a parallel wait is insufficient: one request can clear or overwrite another request's state. Prefer returning request-specific results or otherwise isolating their state.

The provider must update the UI when each section completes, without short-circuiting the remaining requests. A failed section must not become the card-level error while another section has usable content or is still loading.

The Student ID integration with `CardContainer` must allow partial rendering. Its current card-wide error and loading flags suppress the entire child. Derive the whole-card failure only after all relevant work settles and no usable section remains. Track image success/failure explicitly and render the placeholder when needed.

## Essential implementation change 2: Field-level parsing and validation

Preserve valid fields even when another field in the same response is missing or malformed. The current models can reject a whole response because a directly assigned field has an unexpected type or is null, including fields the card does not display.

- Treat optional fields independently. Missing college, major, classification, middle name, or unused metadata must not invalidate otherwise usable content.
- Build the displayed name from available, valid name parts; trim whitespace and treat an empty result as unavailable.
- Validate the barcode for the existing Codabar renderer. Missing or invalid barcode data should disable only the barcode component; do not invent a fallback barcode.
- Validate the photo URL and handle subsequent image download/decoding failures with the provided placeholder.
- Distinguish an unreadable response from a readable response containing partially usable data. Determine availability from validated fields, not just request success or an allocated model with empty defaults.

## Verification scenarios for implementation

- All APIs succeed: the complete card renders, with each section appearing when ready.
- Each API fails independently: other requests still complete and their content remains visible.
- A slow API or image load does not delay already available sections.
- The photo API succeeds but the image fails: the placeholder appears without hiding other content.
- One or two APIs fail: the remaining usable sections are retained, including name-only and photo-only results.
- A valid barcode survives missing or malformed unrelated profile fields.
- A missing or invalid barcode disables scanning without hiding usable name, photo, or academic details.
- All requests settle without usable content, including empty successful responses: the exact generic card error appears.
- Retrying failed sections preserves successful sections and restores recovered content.

## Relevant code

- [Student ID service](lib/core/services/student_id.dart)
- [Student ID provider](lib/core/providers/student_id.dart)
- [Student ID card](lib/ui/student_id/student_id_card.dart)
- [Name model](lib/core/models/student_id_name.dart)
- [Photo model](lib/core/models/student_id_photo.dart)
- [Profile model](lib/core/models/student_id_profile.dart)
- [Network helper](lib/app_networking.dart)
- [Shared card container](lib/ui/common/card_container.dart)
- [Provider registration](lib/app_provider.dart)
- [Global error reporting](lib/main.dart)
- [Photo placeholder](assets/images/staff_id_placeholder.png)
