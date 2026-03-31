# TGPT Services

Services for interfacing with the TritonGPT chat API.

## Files

| File | Purpose |
|------|---------|
| `chat_session_creation.dart` | Creates new chat sessions via `/chat/create-chat-session` endpoint |
| `chat_send_message.dart` | Builds request payload and sends messages (returns raw response) |
| `chat_stream.dart` | Streams chat responses in real-time for token-by-token display |
| `chat_persistence.dart` | Local storage of chat messages and session history via Hive |

## Dependencies

- **Models**: `lib/core/models/tgpt_models/` - Data classes for API requests/responses
  - `BasicCreateChatMessageRequest` - Request payload (used by both services)
  - `RetrievalOptions` - Search options for request
  - `ChatCitation` - Citation data in streaming responses
- **Auth**: `UserDataProvider` - Provides login state and access tokens
- **Network**: `app_networking.dart` - HTTP helpers with token refresh
- **Config**: `.env` - API endpoints (`CHAT_CREATE_SESSION_ENDPOINT`, `CHAT_SEND_MESSAGE_ENDPOINT`)

## Usage

```dart
// 1. Create a session
final sessionService = ChatSessionService(userDataProvider);
final session = await sessionService.createChatSession();

// 2. Stream messages (recommended for UI)
final streamService = ChatMessageStreamService(userDataProvider);
int? lastMessageId;

await for (final chunk in streamService.streamMessage(
  message: "Hello",
  chatSessionId: session!.chatSessionId,
  parentMessageId: lastMessageId, // null for first message
)) {
  // Capture message ID for threading
  if (chunk.messageId != null) lastMessageId = chunk.messageId;
  
  // Display streaming text
  print(chunk.delta);
  
  if (chunk.done) break;
}

// For follow-up messages, pass the lastMessageId
await for (final chunk in streamService.streamMessage(
  message: "Tell me more",
  chatSessionId: session.chatSessionId,
  parentMessageId: lastMessageId,
)) {
  if (chunk.messageId != null) lastMessageId = chunk.messageId;
  print(chunk.delta);
  if (chunk.done) break;
}

// Persist messages
final persistence = ChatPersistenceService(userDataProvider);
await persistence.saveMessagesForSession(sessionId, messages);
```
