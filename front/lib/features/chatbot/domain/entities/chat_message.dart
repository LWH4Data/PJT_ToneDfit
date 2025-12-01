import 'chat_product.dart';
import 'chat_metadata.dart';

/// 채팅 메시지 발신자 타입
enum Sender { user, bot, system }

/// 채팅 메시지 엔티티
class ChatMessage {
  final String id;
  final String text;
  final Sender sender;
  final DateTime? timestamp;
  final bool isLoading;
  final bool isError;
  final List<ChatProduct>? products;
  final ChatMetaData? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    this.timestamp,
    this.isLoading = false,
    this.isError = false,
    this.products,
    this.metadata,
  });

  ChatMessage copyWith({
    String? text,
    bool? isLoading,
    bool? isError,
    List<ChatProduct>? products,
    ChatMetaData? metadata,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      products: products ?? this.products,
      metadata: metadata ?? this.metadata,
    );
  }
}

