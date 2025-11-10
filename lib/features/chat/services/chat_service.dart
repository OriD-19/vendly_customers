import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import 'chat_repository.dart';

/// WebSocket chat service for real-time messaging
class ChatService {
  WebSocketChannel? _channel;
  StreamController<ChatMessage>? _messageController;
  StreamController<TypingIndicator>? _typingController;
  StreamController<UserStatus>? _statusController;
  StreamController<bool>? _connectionController;
  
  int? _currentStoreId;
  bool _isConnected = false;

  // Streams
  Stream<ChatMessage> get messages => _messageController!.stream;
  Stream<TypingIndicator> get typingIndicators => _typingController!.stream;
  Stream<UserStatus> get userStatus => _statusController!.stream;
  Stream<bool> get connectionStatus => _connectionController!.stream;

  bool get isConnected => _isConnected;
  int? get currentStoreId => _currentStoreId;

  ChatService() {
    _messageController = StreamController<ChatMessage>.broadcast();
    _typingController = StreamController<TypingIndicator>.broadcast();
    _statusController = StreamController<UserStatus>.broadcast();
    _connectionController = StreamController<bool>.broadcast();
  }

  /// Load historical messages from database
  Future<List<ChatMessage>> loadMessages(int storeId) async {
    try {
      final result = await ChatRepository.getMessages(storeId: storeId);

      if (result.success) {
        return result.messages;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Connect to WebSocket for a specific store
  Future<void> connect(int storeId) async {
    try {
      // Disconnect if already connected
      if (_isConnected) {
        await disconnect();
      }

      // Get JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('No se encontró el token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      // Build WebSocket URL
      final wsUrl = 'ws://localhost:8000/chat/ws/$storeId?token=$token';
      
      // Create WebSocket connection (platform-agnostic)
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);
      _currentStoreId = storeId;

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          _handleIncomingMessage(data);
        },
        onError: (error) {
          _handleDisconnection();
        },
        onDone: () {
          _handleDisconnection();
        },
        cancelOnError: false,
      );

      // Wait a bit to ensure connection is established and first messages are received
      await Future.delayed(const Duration(milliseconds: 500));

      // Set connected status AFTER stream is set up
      _isConnected = true;
      _connectionController!.add(true);
    } catch (e) {
      _handleDisconnection();
      rethrow;
    }
  }

  /// Handle incoming WebSocket messages
  void _handleIncomingMessage(dynamic data) {
    try {
      final jsonData = json.decode(data as String) as Map<String, dynamic>;
      final message = WebSocketMessage.fromJson(jsonData);
      
      switch (message.type) {
        case 'new_message':
          try {
            final chatMessage = ChatMessage.fromJson(message.data);
            _messageController!.add(chatMessage);
          } catch (e) {
            print('   ❌ Error al parsear mensaje: $e');
            print('   Datos recibidos: ${message.data}');
          }
          break;

        case 'typing':
          final typingIndicator = TypingIndicator.fromJson(message.data);
          _typingController!.add(typingIndicator);
          break;

        case 'user_status':
          final userStatus = UserStatus.fromJson(message.data);
          _statusController!.add(userStatus);
          break;

        case 'read_receipt':
          // Handle read receipts if needed
          break;

        default:
      }
    } catch (e) {
      print('   ❌ Error al manejar mensaje entrante: $e');
    }
  }

  /// Send a text message (via WebSocket and HTTP persistence)
  Future<void> sendMessage({
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    if (!_isConnected || _channel == null || _currentStoreId == null) {
      throw Exception('Not connected to chat');
    }

    try {
      final optimisticMessage = ChatMessage(
        id: null, // Will be set by server
        content: content,
        senderId: null, // Will be set by server
        storeId: _currentStoreId!,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        isFromCustomer: true,
        createdAt: DateTime.now(),
        status: 'sending',
      );

      _messageController!.add(optimisticMessage);

      final messageData = WebSocketMessage(
        type: 'send_message',
        data: {
          'content': content,
          'message_type': messageType,
          'is_from_customer': true,
          'attachment_url': attachmentUrl,
        },
      );

      final jsonMessage = json.encode(messageData.toJson());
      _channel!.sink.add(jsonMessage);

      final _ = await ChatRepository.sendMessage(
        content: content,
        storeId: _currentStoreId!,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        isFromCustomer: true,
      );

    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendTypingIndicator(bool isTyping) async {
    if (!_isConnected || _channel == null) {
      return;
    }

    try {
      final typingData = WebSocketMessage(
        type: 'typing',
        data: {
          'is_typing': isTyping,
        },
      );

      _channel!.sink.add(json.encode(typingData.toJson()));
    } catch (e) {
      print('Failed to send typing indicator: $e');
    }
  }

  Future<void> markMessagesAsRead(List<int> messageIds) async {
    if (!_isConnected || _channel == null || messageIds.isEmpty) {
      return;
    }

    try {
      final readData = WebSocketMessage(
        type: 'mark_read',
        data: {
          'message_ids': messageIds,
        },
      );

      _channel!.sink.add(json.encode(readData.toJson()));
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _currentStoreId = null;
    _connectionController!.add(false);
  }

  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    _handleDisconnection();
  }

  void dispose() {
    disconnect();
    _messageController?.close();
    _typingController?.close();
    _statusController?.close();
    _connectionController?.close();
  }
}
