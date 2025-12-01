import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../data/remote/character_outfit_api_service.dart';
import '../../../image_search/presentation/providers/image_picker_service.dart';

/// 캐릭터 옷 입히기 완전한 위젯 (API 연동 포함)
/// 
/// 이미지 선택부터 API 호출, 결과 표시까지 모든 기능을 포함한 완전한 위젯입니다.
class CharacterOutfitFullWidget extends StatefulWidget {
  /// 생성 완료 콜백 (선택적)
  final void Function(Uint8List generatedImage)? onGenerationComplete;

  const CharacterOutfitFullWidget({
    super.key,
    this.onGenerationComplete,
  });

  @override
  State<CharacterOutfitFullWidget> createState() => _CharacterOutfitFullWidgetState();
}

class _CharacterOutfitFullWidgetState extends State<CharacterOutfitFullWidget> {
  final CharacterOutfitApiService _apiService = CharacterOutfitApiService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  bool _isLoading = false;
  Uint8List? _selectedGarmentImage;
  Uint8List? _generatedImage;
  String? _errorMessage;

  /// 의상 이미지 선택 (갤러리)
  Future<void> _selectGarmentFromGallery() async {
    try {
      final imageFile = await _imagePickerService.pickFromGallery();
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        setState(() {
          _selectedGarmentImage = imageBytes;
          _generatedImage = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('이미지 선택 실패: $e');
    }
  }

  /// 의상 이미지 선택 (카메라)
  Future<void> _selectGarmentFromCamera() async {
    try {
      final imageFile = await _imagePickerService.pickFromCamera();
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        setState(() {
          _selectedGarmentImage = imageBytes;
          _generatedImage = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('이미지 촬영 실패: $e');
    }
  }

  /// 캐릭터 옷 입히기 실행
  Future<void> _generateOutfit() async {
    if (_selectedGarmentImage == null) {
      _showError('의상 이미지를 먼저 선택해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _generatedImage = null;
    });

    try {
      final result = await _apiService.generateCharacterOutfit(_selectedGarmentImage!);
      
      setState(() {
        _generatedImage = result;
        _isLoading = false;
      });

      if (widget.onGenerationComplete != null) {
        widget.onGenerationComplete!(result);
      }

      _showSuccess('이미지 생성 완료!');

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showError('이미지 생성 실패: $e');
    }
  }

  /// 에러 메시지 표시
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 성공 메시지 표시
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 이미지 선택 모달 표시
  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '의상 이미지 선택',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 32),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _selectGarmentFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 32),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _selectGarmentFromCamera();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목
          const Text(
            '🎨 캐릭터 옷 입히기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '캐릭터에 입힐 의상 이미지를 선택하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 의상 이미지 선택 영역
          GestureDetector(
            onTap: _isLoading ? null : _showImagePickerModal,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _selectedGarmentImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _selectedGarmentImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '의상 이미지 선택',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // 생성 버튼
          ElevatedButton(
            onPressed: (_isLoading || _selectedGarmentImage == null)
                ? null
                : _generateOutfit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '옷 입히기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          
          // 로딩 메시지
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    '🎨 이미지 생성 중...\n약 30초 정도 소요됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 에러 메시지
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
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
          if (_generatedImage != null) ...[
            const SizedBox(height: 24),
            const Text(
              '✨ 생성된 이미지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
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
        ],
      ),
    );
  }
}
