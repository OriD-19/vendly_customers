import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      print('📖 Cargando mensajes históricos de la tienda $storeId...');
      final result = await ChatRepository.getMessages(storeId: storeId);

      if (result.success) {
        print('✅ ${result.messages.length} mensajes cargados de la base de datos');
        return result.messages;
      } else {
        print('⚠️ Error al cargar mensajes: ${result.error}');
        return [];
      }
    } catch (e) {
      print('❌ Error al cargar mensajes históricos: $e');
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
      
      print('🔌 Intentando conectar a WebSocket: $wsUrl');
      print('📝 Token (primeros 20 caracteres): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('🌐 Plataforma: ${kIsWeb ? "Web" : "Mobile/Desktop"}');

      // Create WebSocket connection (platform-agnostic)
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);
      _currentStoreId = storeId;

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          print('📨 Mensaje recibido: $data');
          _handleIncomingMessage(data);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          print('   Error type: ${error.runtimeType}');
          _handleDisconnection();
        },
        onDone: () {
          print('🔌 WebSocket connection closed by server');
          _handleDisconnection();
        },
        cancelOnError: false,
      );

      // Wait a bit to ensure connection is established and first messages are received
      await Future.delayed(const Duration(milliseconds: 500));

      // Set connected status AFTER stream is set up
      _isConnected = true;
      _connectionController!.add(true);
      print('✅ WebSocket conectado a la tienda $storeId - Estado: $_isConnected');
    } catch (e, stackTrace) {
      print('❌ Error al conectar WebSocket: $e');
      print('Stack trace: $stackTrace');
      _handleDisconnection();
      rethrow;
    }
  }

  /// Handle incoming WebSocket messages
  void _handleIncomingMessage(dynamic data) {
    try {
      final jsonData = json.decode(data as String) as Map<String, dynamic>;
      final message = WebSocketMessage.fromJson(jsonData);
      
      print('📥 Procesando mensaje tipo: ${message.type}');

      switch (message.type) {
        case 'new_message':
          print('   Datos del mensaje: ${message.data}');
          try {
            final chatMessage = ChatMessage.fromJson(message.data);
            print('   ✅ Mensaje parseado correctamente');
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
          print('Read receipt: ${message.data}');
          break;

        default:
          print('⚠️ Unknown message type: ${message.type}');
      }
    } catch (e, stackTrace) {
      print('❌ Error handling incoming message: $e');
      print('Stack trace: $stackTrace');
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
      // 1. Create optimistic message (show immediately in UI)
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

      print('📤 Agregando mensaje optimista a la UI');
      _messageController!.add(optimisticMessage);

      // 2. Send via WebSocket for real-time delivery
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
      print('📤 Enviando mensaje via WebSocket: $jsonMessage');
      _channel!.sink.add(jsonMessage);
      print('✅ Mensaje enviado via WebSocket');

      // 3. Persist to database via HTTP
      print('💾 Guardando mensaje en la base de datos...');
      final result = await ChatRepository.sendMessage(
        content: content,
        storeId: _currentStoreId!,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        isFromCustomer: true,
      );

      if (result.success && result.message != null) {
        print('✅ Mensaje persistido en la base de datos con ID: ${result.message!.id}');
        // The server might echo this back via WebSocket, or we rely on the optimistic update
      } else {
        print('⚠️ Error al persistir mensaje: ${result.error}');
        // Don't throw - the message was already sent via WebSocket and shown optimistically
      }
    } catch (e) {
      print('❌ Error al enviar mensaje: $e');
      rethrow;
    }
  }

  /// Send typing indicator
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

  /// Mark messages as read
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

  /// Handle disconnection
  void _handleDisconnection() {
    print('⚠️ _handleDisconnection llamado - Estado anterior: $_isConnected');
    _isConnected = false;
    _currentStoreId = null;
    _connectionController!.add(false);
    print('   Estado actual: $_isConnected');
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    _handleDisconnection();
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController?.close();
    _typingController?.close();
    _statusController?.close();
    _connectionController?.close();
  }
}
