import 'package:flutter/material.dart';
import '../../../../shared/styles/tokens.dart';

class SearchInput extends StatefulWidget {
  final EdgeInsetsGeometry? margin;
  final void Function(String value)? onSubmitted;
  final String hintText;
  final bool autoFocus;
  final String? initialValue; // 초기 검색어

  const SearchInput({
    super.key,
    this.margin,
    this.onSubmitted,
    this.hintText = '검색어를 입력하세요',
    this.autoFocus = false,
    this.initialValue,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // 초기값 설정
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _controller.text = widget.initialValue!;
    }
    _controller.addListener(() {
      setState(() {});
    });
    // 포커스 상태 감지
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    // 자동 포커스 옵션이 활성화되어 있으면 포커스 요청
    // 애니메이션 완료 후 포커스를 주기 위해 약간의 지연 시간 추가
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 페이지 전환 애니메이션 완료 후 포커스 (약 350ms 지연)
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 스타일
    const borderRadius = 4.0;
    const borderWidth = 1.0;

    final isEmpty = _controller.text.isEmpty;

    return Container(
      margin: widget.margin,
      // 반응형: Expanded로 감싸져 있으므로 width 제거 (부모가 결정)
      height: 40.0,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: borderWidth, color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          // 돋보기 아이콘 (비활성화 시 입력창 안 왼쪽에 표시)
          if (!_isFocused && isEmpty) ...[
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: Colors.black38,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Color(0xFFFB4A6E),
                  selectionColor: Color(0x33FB4A6E),
                  selectionHandleColor: Color(0xFFFB4A6E),
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                cursorColor: const Color(0xFFFB4A6E),
                keyboardType: TextInputType.text, // 텍스트 입력 타입 명시
                enableSuggestions: true, // 자동완성 활성화
                autocorrect: true, // 자동교정 활성화
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => widget.onSubmitted?.call(v),
              ),
            ),
          ),
          // x 버튼 (텍스트 있을 때만)
          if (!isEmpty) ...[
            GestureDetector(
              onTap: () {
                _controller.clear(); // 텍스트만 지우고 포커스 유지
              },
              child: const Icon(
                Icons.close,
                size: 25,
                color: Colors.black45,
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}





