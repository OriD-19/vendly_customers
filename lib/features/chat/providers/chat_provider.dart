import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

/// Chat state model
class ChatState {
  final List<ChatMessage> messages;
  final bool isConnected;
  final bool isTyping;
  final String? error;
  final bool isLoading;

  const ChatState({
    this.messages = const [],
    this.isConnected = false,
    this.isTyping = false,
    this.error,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isConnected,
    bool? isTyping,
    String? error,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Clear error
  ChatState clearError() {
    return copyWith(error: '');
  }
}

/// Chat state notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final int storeId;
  Timer? _typingTimer;
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<TypingIndicator>? _typingSubscription;

  ChatNotifier({
    required this.storeId,
    ChatService? chatService,
  })  : _chatService = chatService ?? ChatService(),
        super(const ChatState(isLoading: true)) {
    _initialize();
  }

  /// Initialize chat connection and listeners
  Future<void> _initialize() async {
    try {
      // 1. Load historical messages
      final historicalMessages = await _chatService.loadMessages(storeId);
      
      if (historicalMessages.isNotEmpty) {
        state = state.copyWith(
          messages: historicalMessages,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      // 2. Listen to connection status
      _connectionSubscription = _chatService.connectionStatus.listen((isConnected) {
        state = state.copyWith(isConnected: isConnected);
      });

      // 3. Listen to incoming messages
      _messageSubscription = _chatService.messages.listen((message) {
        _handleIncomingMessage(message);
      });

      // 4. Listen to typing indicators
      _typingSubscription = _chatService.typingIndicators.listen((indicator) {
        if (!indicator.isTyping) {
          state = state.copyWith(isTyping: indicator.isTyping);
        }
      });

      // 5. Connect to WebSocket
      await _chatService.connect(storeId);

      // 6. Update connection status
      if (_chatService.isConnected) {
        state = state.copyWith(isConnected: true);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  /// Handle incoming message (deduplication logic)
  void _handleIncomingMessage(ChatMessage message) {
    final messages = List<ChatMessage>.from(state.messages);
    
    // Check if message already exists
    final existingIndex = messages.indexWhere((m) {
      // If both have IDs and they match, it's a duplicate
      if (m.id != null && message.id != null && m.id == message.id) {
        return true;
      }
      
      // If we have an optimistic message (no ID) and a confirmed message arrives
      if (m.id == null && message.id != null) {
        final isSameContent = m.content == message.content;
        final timeDiff = message.createdAt.difference(m.createdAt).abs();
        final isRecentlySent = timeDiff.inSeconds < 5;
        
        return isSameContent && isRecentlySent && m.isFromCustomer == message.isFromCustomer;
      }
      
      return false;
    });

    if (existingIndex != -1) {
      // Replace optimistic message with confirmed one
      messages[existingIndex] = message;
    } else {
      // Add new message
      messages.add(message);
    }

    state = state.copyWith(messages: messages);

    // Mark message as read if it's from the store
    if (!message.isFromCustomer && message.id != null) {
      _chatService.markMessagesAsRead([message.id!]);
    }
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(content: content);
      
      // Stop typing indicator
      await _chatService.sendTypingIndicator(false);
      _typingTimer?.cancel();
      
    } catch (e) {
      state = state.copyWith(
        error: 'Error al enviar mensaje: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Handle typing indicator
  void handleTyping(String text) {
    if (text.isNotEmpty) {
      _chatService.sendTypingIndicator(true);
      
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _chatService.sendTypingIndicator(false);
      });
    } else {
      _chatService.sendTypingIndicator(false);
      _typingTimer?.cancel();
    }
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Retry connection
  Future<void> retry() async {
    state = state.copyWith(error: '', isLoading: true);
    await _initialize();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _typingSubscription?.cancel();
    _chatService.dispose();
    super.dispose();
  }
}

/// Provider family for chat state (one provider per store)
final chatProvider = StateNotifierProvider.autoDispose.family<ChatNotifier, ChatState, int>(
  (ref, storeId) {
    return ChatNotifier(storeId: storeId);
  },
);
