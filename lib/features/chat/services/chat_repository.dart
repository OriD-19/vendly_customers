import 'package:dio/dio.dart';
import '../../../core/services/api_config.dart';
import '../models/chat_message.dart';

/// HTTP repository for chat message persistence
class ChatRepository {
  /// Get all messages for a conversation with a store
  static Future<ChatMessagesResult> getMessages({
    required int storeId,
  }) async {
    try {
      final response = await ApiConfig.dio.get(
        '/chat/conversations/$storeId/messages',
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final messages = data
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by creation date (oldest first)
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return ChatMessagesResult(
          success: true,
          messages: messages,
        );
      } else {
        return ChatMessagesResult(
          success: false,
          error: 'Error al cargar mensajes: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ChatMessagesResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return ChatMessagesResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Send a message to the server (HTTP fallback or persistence)
  static Future<ChatMessageResult> sendMessage({
    required String content,
    required int storeId,
    String messageType = 'text',
    String? attachmentUrl,
    bool isFromCustomer = true,
  }) async {
    try {
      final requestData = {
        'content': content,
        'message_type': messageType,
        'attachment_url': attachmentUrl,
        'store_id': storeId,
        'is_from_customer': isFromCustomer,
      };

      final response = await ApiConfig.dio.post(
        '/chat/messages',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final messageData = response.data as Map<String, dynamic>;
        final message = ChatMessage.fromJson(messageData);

        return ChatMessageResult(
          success: true,
          message: message,
        );
      } else {
        return ChatMessageResult(
          success: false,
          error: 'Error al enviar mensaje: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ChatMessageResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return ChatMessageResult(
        success: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Handle Dio errors
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 400) {
          if (data is Map<String, dynamic>) {
            return data['detail'] ?? data['error'] ?? 'Datos inválidos';
          }
          return 'Datos inválidos';
        } else if (statusCode == 401) {
          return 'No autorizado. Por favor, inicia sesión nuevamente.';
        } else if (statusCode == 404) {
          return 'Conversación no encontrada';
        } else if (statusCode == 500) {
          return 'Error del servidor. Intenta más tarde.';
        }
        return 'Error de conexión (${statusCode ?? 'desconocido'})';

      case DioExceptionType.cancel:
        return 'Solicitud cancelada';

      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor. Verifica tu conexión.';

      case DioExceptionType.badCertificate:
        return 'Error de certificado de seguridad';

      case DioExceptionType.unknown:
        return 'Error de conexión. Intenta nuevamente.';
    }
  }
}

/// Result wrapper for message list operations
class ChatMessagesResult {
  final bool success;
  final List<ChatMessage> messages;
  final String? error;

  ChatMessagesResult({
    required this.success,
    this.messages = const [],
    this.error,
  });
}

/// Result wrapper for single message operations
class ChatMessageResult {
  final bool success;
  final ChatMessage? message;
  final String? error;

  ChatMessageResult({
    required this.success,
    this.message,
    this.error,
  });
}
