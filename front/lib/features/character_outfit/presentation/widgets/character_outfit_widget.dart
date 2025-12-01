import 'package:flutter/material.dart';
import 'dart:typed_data';

/// 캐릭터 옷 입히기 위젯
/// 
/// 의상 이미지를 선택하여 캐릭터에 옷을 입힌 이미지를 생성하는 위젯입니다.
class CharacterOutfitWidget extends StatefulWidget {
  /// 의상 이미지 선택 콜백
  final Future<Uint8List?> Function() onSelectGarment;
  
  /// 이미지 생성 성공 콜백
  final void Function(Uint8List generatedImage)? onSuccess;
  
  /// 에러 콜백
  final void Function(String error)? onError;

  const CharacterOutfitWidget({
    super.key,
    required this.onSelectGarment,
    this.onSuccess,
    this.onError,
  });

  @override
  State<CharacterOutfitWidget> createState() => _CharacterOutfitWidgetState();
}

class _CharacterOutfitWidgetState extends State<CharacterOutfitWidget> {
  bool _isLoading = false;
  Uint8List? _generatedImage;
  String? _errorMessage;

  /// 캐릭터 옷 입히기 실행
  Future<void> _generateOutfit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _generatedImage = null;
    });

    try {
      // 의상 이미지 선택
      final garmentImage = await widget.onSelectGarment();
      
      if (garmentImage == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // API 서비스 import 필요
      // final apiService = CharacterOutfitApiService();
      // final result = await apiService.generateCharacterOutfit(garmentImage);
      
      // 임시: 실제 API 호출로 대체 필요
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        // _generatedImage = result;
        _isLoading = false;
      });

      // if (_generatedImage != null && widget.onSuccess != null) {
      //   widget.onSuccess!(_generatedImage!);
      // }

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (widget.onError != null) {
        widget.onError!(_errorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 버튼
        ElevatedButton(
          onPressed: _isLoading ? null : _generateOutfit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  '옷 입히기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        
        const SizedBox(height: 16),

        // 로딩 메시지
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  '이미지 생성 중...\n약 30초 정도 소요됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

        // 에러 메시지
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 생성된 이미지
        if (_generatedImage != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _generatedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
