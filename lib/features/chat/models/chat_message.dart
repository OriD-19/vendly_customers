/// Chat message model
class ChatMessage {
  final int? id;
  final String content;
  final int? senderId; // Nullable for optimistic messages
  final int storeId;
  final DateTime createdAt;
  final String messageType;
  final bool isFromCustomer;
  final String status;
  final DateTime? readAt;
  final String? attachmentUrl;

  ChatMessage({
    this.id,
    required this.content,
    this.senderId, // Now nullable
    required this.storeId,
    required this.createdAt,
    this.messageType = 'text',
    required this.isFromCustomer,
    this.status = 'sending',
    this.readAt,
    this.attachmentUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      content: json['content'] as String,
      senderId: json['sender_id'] as int?,
      storeId: json['store_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      messageType: json['message_type'] as String? ?? 'text',
      isFromCustomer: json['is_from_customer'] as bool,
      status: json['status'] as String? ?? 'sent',
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String)
          : null,
      attachmentUrl: json['attachment_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'content': content,
      if (senderId != null) 'sender_id': senderId,
      'store_id': storeId,
      'created_at': createdAt.toIso8601String(),
      'message_type': messageType,
      'is_from_customer': isFromCustomer,
      'status': status,
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    };
  }

  ChatMessage copyWith({
    int? id,
    String? content,
    int? senderId,
    int? storeId,
    DateTime? createdAt,
    String? messageType,
    bool? isFromCustomer,
    String? status,
    DateTime? readAt,
    String? attachmentUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      messageType: messageType ?? this.messageType,
      isFromCustomer: isFromCustomer ?? this.isFromCustomer,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  bool get isRead => readAt != null;
  bool get isSent => status == 'sent' || status == 'delivered' || status == 'read';
  bool get isFailed => status == 'failed';
}

/// WebSocket message wrapper
class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  WebSocketMessage({
    required this.type,
    required this.data,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
}

/// Typing indicator model
class TypingIndicator {
  final int userId;
  final int storeId;
  final bool isTyping;

  TypingIndicator({
    required this.userId,
    required this.storeId,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['user_id'] as int,
      storeId: json['store_id'] as int,
      isTyping: json['is_typing'] as bool,
    );
  }
}

/// User status model
class UserStatus {
  final int userId;
  final bool isOnline;

  UserStatus({
    required this.userId,
    required this.isOnline,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      userId: json['user_id'] as int,
      isOnline: json['is_online'] as bool,
    );
  }
}
