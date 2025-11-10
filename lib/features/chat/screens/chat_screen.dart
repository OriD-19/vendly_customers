import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

/// Chat screen for real-time messaging with a store
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  final String storeId;
  final String storeName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  bool _isConnected = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final storeId = int.tryParse(widget.storeId);
      if (storeId == null) {
        setState(() {
          _error = 'ID de tienda inválido';
        });
        return;
      }

      // 1. Load historical messages from database
      print('📖 Cargando mensajes históricos...');
      final historicalMessages = await _chatService.loadMessages(storeId);
      if (mounted && historicalMessages.isNotEmpty) {
        setState(() {
          _messages.addAll(historicalMessages);
        });
        _scrollToBottom();
        print('✅ ${historicalMessages.length} mensajes históricos cargados');
      }

      // 2. Listen to connection status BEFORE connecting
      _chatService.connectionStatus.listen((isConnected) {
        if (mounted) {
          print('🔄 Estado de conexión actualizado en UI: $isConnected');
          setState(() {
            _isConnected = isConnected;
          });
          
          // Show notification when connection changes
          if (!isConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conexión perdida. Intentando reconectar...'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          } 
        }
      });

      // 3. Listen to incoming messages (new real-time messages)
      _chatService.messages.listen((message) {
        if (mounted) {
          // Check if message already exists (avoid duplicates)
          // For messages with IDs, check by ID
          // For optimistic messages (no ID), check by content + timestamp (within 5 seconds)
          final exists = _messages.any((m) {
            // If both have IDs and they match, it's a duplicate
            if (m.id != null && message.id != null && m.id == message.id) {
              return true;
            }
            
            // If we have an optimistic message (no ID) and a confirmed message arrives
            // with the same content around the same time, replace the optimistic one
            if (m.id == null && message.id != null) {
              final isSameContent = m.content == message.content;
              final timeDiff = message.createdAt.difference(m.createdAt).abs();
              final isRecentlySent = timeDiff.inSeconds < 5;
              
              if (isSameContent && isRecentlySent && m.isFromCustomer == message.isFromCustomer) {
                // Replace optimistic message with confirmed one
                final index = _messages.indexOf(m);
                setState(() {
                  _messages[index] = message;
                });
                return true;
              }
            }
            
            return false;
          });
          
          if (!exists) {
            setState(() {
              _messages.add(message);
            });
            _scrollToBottom();
          }
          
          // Mark message as read if it's from the store
          if (!message.isFromCustomer && message.id != null) {
            _chatService.markMessagesAsRead([message.id!]);
          }
        }
      });

      // 4. Listen to typing indicators
      _chatService.typingIndicators.listen((indicator) {
        if (mounted && !indicator.isTyping) {
          // Store stopped typing
          setState(() {
            _isTyping = indicator.isTyping;
          });
        }
      });

      // 5. Connect to WebSocket AFTER setting up listeners
      await _chatService.connect(storeId);
      
      // 6. Manually check connection status after connecting
      if (mounted && _chatService.isConnected) {
        print('✅ Actualizando UI con estado conectado');
        setState(() {
          _isConnected = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
        
        // Show error in snackbar too
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      // Clear input immediately for better UX
      _messageController.clear();

      // Send to server (both WebSocket and HTTP)
      await _chatService.sendMessage(content: text);

      // Stop typing indicator
      await _chatService.sendTypingIndicator(false);
      _typingTimer?.cancel();
      
      // The message will appear via WebSocket stream or can be added optimistically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onMessageChanged(String text) {
    // Send typing indicator
    if (text.isNotEmpty) {
      _chatService.sendTypingIndicator(true);
      
      // Reset typing timer
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _chatService.sendTypingIndicator(false);
      });
    } else {
      _chatService.sendTypingIndicator(false);
      _typingTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                    _initializeChat();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.persianIndigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.storeName,
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _isConnected ? 'En línea' : 'Desconectado',
              style: AppTypography.labelSmall.copyWith(
                color: _isConnected 
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show store info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: AppColors.warning.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reconectando...',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay mensajes',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inicia la conversación con ${widget.storeName}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      
                      final message = _messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),

          // Message input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderColor, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // TODO: Handle attachments
                    },
                    color: AppColors.persianIndigo,
                  ),

                  // Message input field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onMessageChanged,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.persianIndigo,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.persianIndigo,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isConnected ? _sendMessage : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final adjustedValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (adjustedValue * 2).clamp(0.3, 1.0);

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _chatService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromCustomer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.persianIndigo.withOpacity(0.1),
              child: Icon(
                Icons.store,
                size: 18,
                color: AppColors.persianIndigo,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.persianIndigo
                    : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: AppTypography.caption.copyWith(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textTertiary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all
                              : message.isSent
                                  ? Icons.done
                                  : Icons.access_time,
                          size: 14,
                          color: message.isRead
                              ? Colors.blue.shade200
                              : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.mauve.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.persianIndigo,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
