# TGPT Services

These services back the current mobile AI Assistant flow. The orchestration entry point is `ChatProvider`; these files are the lower-level session, streaming, and persistence pieces it calls.

## Files

| File | Purpose |
|------|---------|
| `chat_session_creation.dart` | Creates a TGPT chat session through `/chat/create-chat-session` |
| `chat_stream.dart` | Streams WSO2 `/chat/send-chat-message` responses, including token deltas and citations |
| `chat_send_message.dart` | Shared request-body builder for message payloads |
| `chat_persistence.dart` | Persists signed-in chat sessions and messages with Hive |
| `chat_feedback.dart` | Creates and removes assistant message feedback |
| `tgpt_request.dart` | Selects WSO2 Basic application auth or non-proxy bearer auth |
| `tgpt_debug_log.dart` | Emits debug-only route, auth-mode, status, and masked session logs |

## Actual App Flow

1. `AIAssistantView` wires `ChatComposer.onSubmitted` to `ChatProvider.sendMessage(...)`.
2. `ChatProvider` creates a session if needed, appends the user message plus a streaming placeholder, and starts `ChatMessageStreamService`.
3. `ChatMessageStreamService` sends the request and yields `StreamingChatChunk` values as the SSE/NDJSON response arrives.
4. `ChatProvider` merges streamed text and citations into the active `AssistantChatMessage`, updates sidebar session metadata, and persists the session when the user is signed in.
5. `ChatMessageBubble` parses assistant text to separate the main markdown answer from `[rq]`-prefixed related questions.
6. Completed assistant messages show feedback controls. `ChatProvider` sends create or remove feedback requests and rolls back local state when a request fails.

## Auth And Persistence Rules

- WSO2 `tgpt-mobileproxy` requests use `MOBILE_APP_PUBLIC_DATA_KEY` for signed-in and guest users
- Campus Mobile sign-in controls local persistence, not TGPT proxy authentication
- Non-proxy signed-in endpoints retain user bearer support
- Guests keep chat history in memory only for the current app run
- Only the signed-in experience uses saved session IDs and time-bucketed sidebar history.

## Configuration

Environment variables used by this flow:

- `CHAT_CREATE_SESSION_ENDPOINT`
- `CHAT_SEND_MESSAGE_ENDPOINT`
- `CHAT_CREATE_FEEDBACK_ENDPOINT`
- `CHAT_REMOVE_FEEDBACK_ENDPOINT`
- `TGPT_CHAT_SEND_CONTEXT_URL` (optional; sent as `url` on each message, defaults to `https://mobile.ucsd.edu/`)
- `MOBILE_APP_PUBLIC_DATA_KEY` for guest chat/session requests
- `TGPT_PERSONA_ID` (optional; defaults inside the session service when omitted)

## Notes

- Streaming is the supported message path for the mobile app.
- If request payload fields change, update `BasicCreateChatMessageRequest` in `lib/core/models/tgpt_models/chat_response.dart` and keep `ChatMessageService.buildRequestBody(...)` aligned with it.
