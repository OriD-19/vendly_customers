/// Example usage of the WebSocket Chat functionality
/// 
/// This example demonstrates how to integrate the chat feature into the Vendly app.
/// 
/// ## WebSocket Integration
/// 
/// The chat functionality uses WebSocket for real-time communication between
/// customers and stores.
/// 
/// ### Connection URL
/// ```
/// ws://localhost:8000/chat/ws/{store_id}?token=<jwt_token>
/// ```
/// 
/// ### Features Implemented
/// 
/// 1. **Real-time Messaging**
///    - Send and receive messages instantly
///    - Message status tracking (sending, sent, delivered, read)
///    - Automatic message ordering and display
/// 
/// 2. **Typing Indicators**
///    - Shows when the store is typing
///    - Automatically sent when customer types
///    - Cleared after 2 seconds of inactivity
/// 
/// 3. **Read Receipts**
///    - Automatically marks incoming messages as read
///    - Displays double-check marks for read messages
///    - Single check for sent/delivered messages
/// 
/// 4. **Connection Management**
///    - Automatic connection on screen load
///    - Connection status display
///    - Reconnection banner when disconnected
///    - Graceful error handling
/// 
/// ### Usage
/// 
/// #### 1. Navigate to Chat from Store Detail
/// ```dart
/// // From StoreDetailScreen, tap the floating chat button
/// FloatingActionButton.extended(
///   onPressed: () {
///     context.push('/store/$storeId/chat?storeName=${store.name}');
///   },
///   icon: Icon(Icons.chat_bubble_outline),
///   label: Text('Chat'),
/// )
/// ```
/// 
/// #### 2. Chat Service automatically handles:
/// - WebSocket connection with JWT authentication
/// - Message serialization/deserialization
/// - Stream management for messages, typing, and status
/// - Automatic disconnection on screen close
/// 
/// #### 3. UI Features:
/// - Modern bubble-style messages
/// - Differentiated customer/store messages
/// - Time stamps with smart formatting
/// - Typing indicator animation
/// - Empty state for new conversations
/// - Connection status banner
/// 
/// ### Message Types
/// 
/// **Client → Server:**
/// - `send_message`: Send a text message
/// - `typing`: Typing indicator
/// - `mark_read`: Mark messages as read
/// 
/// **Server → Client:**
/// - `new_message`: New message received
/// - `typing`: Store typing status
/// - `user_status`: User online/offline status
/// - `read_receipt`: Messages read confirmation
/// 
/// ### Architecture
/// 
/// ```
/// ChatScreen (UI)
///     ↓
/// ChatService (WebSocket Manager)
///     ↓
/// WebSocket Channel
///     ↓
/// API Server (ws://localhost:8000)
/// ```
/// 
/// ### Error Handling
/// 
/// - Connection errors show retry UI
/// - Send failures show snackbar notification
/// - WebSocket close codes handled:
///   - 1008: Authentication failed
///   - 1011: Server error
/// 
/// ### Testing
/// 
/// 1. **Prerequisites:**
///    - User must be logged in (JWT token required)
///    - WebSocket server running on localhost:8000
///    - Store must exist in database
/// 
/// 2. **Test Flow:**
///    - Login to app
///    - Browse to a store
///    - Tap "Chat" button
///    - Send test messages
///    - Verify real-time delivery
///    - Check typing indicators
///    - Verify read receipts
/// 
/// ### Files Created
/// 
/// - `lib/features/chat/models/chat_message.dart` - Message models
/// - `lib/features/chat/services/chat_service.dart` - WebSocket service
/// - `lib/features/chat/screens/chat_screen.dart` - Chat UI
/// - `lib/core/router/app_router.dart` - Updated with chat route
/// - `lib/features/stores/screens/store_detail_screen.dart` - Added chat button
/// 
/// ### Next Steps
/// 
/// - Add image/attachment support
/// - Implement message persistence (local storage)
/// - Add push notifications for new messages
/// - Create conversation list screen
/// - Add message search functionality
/// - Implement message deletion
/// - Add emoji picker

void main() {
  print('Chat integration complete!');
  print('Navigate to any store and tap the "Chat" button to start messaging.');
}
