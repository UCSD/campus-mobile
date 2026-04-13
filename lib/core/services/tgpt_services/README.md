# TGPT Services

These services back the current mobile AI Assistant flow. The orchestration entry point is `ChatProvider`; these files are the lower-level session, streaming, and persistence pieces it calls.

## Files

| File | Purpose |
|------|---------|
| `chat_session_creation.dart` | Creates a TGPT chat session through `/chat/create-chat-session` |
| `chat_stream.dart` | Streams `/chat/send-message` responses, including token deltas and citations |
| `chat_send_message.dart` | Shared request-body builder for `/chat/send-message` payloads |
| `chat_persistence.dart` | Persists signed-in chat sessions and messages with Hive |

## Actual App Flow

1. `AIAssistantView` wires `ChatComposer.onSubmitted` to `ChatProvider.sendMessage(...)`.
2. `ChatProvider` creates a session if needed, appends the user message plus a streaming placeholder, and starts `ChatMessageStreamService`.
3. `ChatMessageStreamService` sends the request, handles 401 retry via `NetworkHelper.getNewToken(...)`, and yields `StreamingChatChunk` values as the SSE/NDJSON response arrives.
4. `ChatProvider` merges streamed text and citations into the active `AssistantChatMessage`, updates sidebar session metadata, and persists the session when the user is signed in.
5. `ChatMessageBubble` parses assistant text to separate the main markdown answer from `[rq]`-prefixed related questions.

## Auth And Persistence Rules

- Signed-in users send TGPT requests with their bearer token and get persisted chat history.
- Guests send TGPT requests with `MOBILE_APP_PUBLIC_DATA_KEY` and keep chat history in memory only for the current app run.
- Only the signed-in experience uses saved session IDs and time-bucketed sidebar history.

## Configuration

Environment variables used by this flow:

- `CHAT_CREATE_SESSION_ENDPOINT`
- `CHAT_SEND_MESSAGE_ENDPOINT`
- `MOBILE_APP_PUBLIC_DATA_KEY` for guest chat/session requests
- `TGPT_PERSONA_ID` (optional; defaults inside the session service when omitted)

## Notes

- Streaming is the supported message path for the mobile app.
- If request payload fields change, update `BasicCreateChatMessageRequest` in `lib/core/models/tgpt_models/chat_response.dart` and keep `ChatMessageService.buildRequestBody(...)` aligned with it.
