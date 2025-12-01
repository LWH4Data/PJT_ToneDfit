import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_product.dart';
import '../../domain/entities/chat_metadata.dart';
import '../../data/remote/chatbot_api_service.dart';
import '../widgets/message_tile.dart';
import '../widgets/loading_bubble.dart';
import '../widgets/error_banner.dart';

/// 챗봇 페이지
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ChatbotApiService _apiService = ChatbotApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _msgCtrl = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _seedWelcome();
  }

  void _seedWelcome() {
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '''
안녕하세요! 저는 패션 전문 AI 어시스턴트입니다.
다음과 같은 도움을 드릴 수 있습니다.

• 의류 검색 및 추천
• 날씨에 맞는 코디 제안
• 상품 정보 문의
• 트렌드 정보 제공

무엇을 도와드릴까요?
        ''',
        sender: Sender.bot,
      ),
    );
  }

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 160,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _addError(String text) {
    _messages.add(ChatMessage(
      id: _genId(),
      text: text, // _escapeHtml 제거 - 원본 그대로 표시
      sender: Sender.system,
      isError: true,
    ));
    setState(() {});
    _scrollToBottom();
  }

  String _addLoading() {
    final id = _genId();
    _messages.add(ChatMessage(
      id: id,
      text: '',
      sender: Sender.bot,
      isLoading: true,
    ));
    setState(() {});
    _scrollToBottom();
    return id;
  }

  void _removeLoading(String id) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _messages.removeAt(idx);
      setState(() {});
      _scrollToBottom();
    }
  }

  Future<void> _submit() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    // user message
    final userMessage = ChatMessage(
      id: _genId(),
      text: text, // _escapeHtml 제거 - 그대로 전달
      sender: Sender.user,
      timestamp: DateTime.now(),
    );
    
    print('💬 [Chatbot] 사용자 메시지 추가: ${userMessage.text}');
    _messages.add(userMessage);
    print('📊 [Chatbot] 전체 메시지 수: ${_messages.length}');
    _msgCtrl.clear();
    setState(() {});
    _scrollToBottom();

    final loadingId = _addLoading();

    try {
      // TODO: 체감온도는 weather provider에서 가져오기
      final response = await _apiService.sendMessage(
        message: text,
        apparentTemp: null, // 체감온도는 선택사항
      );

      _removeLoading(loadingId);

      final botText = response['message']?.toString() ?? response.toString();
      final ts = response['timestamp'] != null
          ? DateTime.tryParse(response['timestamp'].toString())?.toLocal() // 로컬 시간으로 변환
          : DateTime.now();

      final List<ChatProduct> products = (response['products'] is List)
          ? (response['products'] as List)
              .whereType<Map>()
              .map((e) => ChatProduct.fromJson(e as Map<String, dynamic>))
              .toList()
          : [];

      final ChatMetaData? meta = (response['metadata'] is Map)
          ? ChatMetaData.fromJson(response['metadata'] as Map<String, dynamic>)
          : null;

      _messages.add(ChatMessage(
        id: _genId(),
        text: botText, // _escapeHtml 제거 - 원본 그대로 표시
        sender: Sender.bot,
        timestamp: ts,
        products: products.isEmpty ? null : products,
        metadata: meta,
      ));

      setState(() {});
      _scrollToBottom();
    } catch (e) {
      _removeLoading(loadingId);
      _addError('요청 중 오류가 발생했습니다: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF303E51), // 헤더 배경색
        centerTitle: true, // 타이틀 가운데 정렬
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '톤디 챗봇',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '톤디핏 서비스 AI 어시스턴트',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 채팅 영역
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, idx) {
                final m = _messages[idx];
                if (m.isError) return ErrorBanner(text: m.text);
                if (m.isLoading) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: LoadingBubble(),
                  );
                }
                return MessageTile(message: m);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemCount: _messages.length,
            ),
          ),
          // 입력 영역
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE9ECEF)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Color(0xFFE9ECEF),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Color(0xFF303E51), // 입력창 활성화 색
                          width: 2,
                        ),
                      ),
                    ),
                    cursorColor: const Color(0xFFFB4A6E), // 커서 색상
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: const StadiumBorder(),
                    backgroundColor: const Color(0xFF303E51), // 전송 버튼 배경색
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('전송'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

