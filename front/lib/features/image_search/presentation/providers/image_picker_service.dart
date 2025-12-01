import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// 이미지 선택 서비스
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// 갤러리에서 이미지 선택
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('갤러리 이미지 선택 에러: $e');
      return null;
    }
  }

  /// 카메라로 사진 촬영
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('카메라 촬영 에러: $e');
      return null;
    }
  }
}

