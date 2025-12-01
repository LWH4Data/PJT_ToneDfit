import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image/image.dart' as img;

/// 이미지 크롭 및 편집 페이지
class ImageCropPage extends StatefulWidget {
  final File imageFile;

  const ImageCropPage({
    super.key,
    required this.imageFile,
  });

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  final _cropController = CropController();
  Uint8List? _imageData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// 이미지 로드
  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      setState(() {
        _imageData = bytes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 로드 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, null);
      }
    }
  }

  /// 크롭 완료
  void _onCropped(Uint8List croppedData) async {
    try {
      // 크롭된 이미지를 임시 파일로 저장
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(croppedData);
      
      if (mounted) {
        // 크롭된 이미지와 바이트 데이터를 함께 반환
        Navigator.pop(context, {'file': tempFile, 'bytes': croppedData});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: const Text(
          '이미지 영역 조정',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              _cropController.crop();
            },
          ),
        ],
      ),
      body: _isLoading || _imageData == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFB4A6E),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '이미지 로드 중...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Crop(
                    image: _imageData!,
                    controller: _cropController,
                    onCropped: _onCropped,
                    aspectRatio: null, // 자유 비율
                    initialSize: 0.8,
                    baseColor: Colors.black,
                    maskColor: Colors.black.withOpacity(0.5),
                    radius: 0,
                    cornerDotBuilder: (size, edgeAlignment) => const DotControl(
                      color: Color(0xFFFB4A6E),
                    ),
                  ),
                ),
                // 하단 툴바
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _cropController.aspectRatio = 1.0; // 1:1 정사각형
                        },
                        icon: const Icon(Icons.crop_square, color: Colors.black),
                        label: const Text('1:1', style: TextStyle(color: Colors.black)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _cropController.aspectRatio = 3 / 2; // 3:2
                        },
                        icon: const Icon(Icons.crop_3_2, color: Colors.black),
                        label: const Text('3:2', style: TextStyle(color: Colors.black)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _cropController.aspectRatio = 4 / 3; // 4:3
                        },
                        icon: const Icon(Icons.crop_5_4, color: Colors.black),
                        label: const Text('4:3', style: TextStyle(color: Colors.black)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _cropController.aspectRatio = null; // 자유
                        },
                        icon: const Icon(Icons.crop_free, color: Colors.black),
                        label: const Text('자유', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

