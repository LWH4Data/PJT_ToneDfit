import 'package:flutter/material.dart';

/// 이미지 검색 모달
class ImageSearchModal extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onCancel;

  const ImageSearchModal({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 350,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: ShapeDecoration(
            color: const Color(0xFFF3F5F8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (취소 + 제목)
              SizedBox(
                width: double.infinity,
                height: 72,
                child: Stack(
                  children: [
                    // 취소 버튼
                    Positioned(
                      left: 0,
                      top: 5,
                      child: GestureDetector(
                        onTap: onCancel,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 1.20,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 제목
                    const Positioned(
                      left: 92,
                      top: 0,
                      child: Text(
                        '이미지 검색',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 0.96,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 옵션들
              SizedBox(
                width: double.infinity,
                height: 342,
                child: Column(
                  children: [
                     // 앨범에서 선택
                     GestureDetector(
                       onTap: onGalleryTap,
                       child: Container(
                         width: 306,
                         height: 165,
                         decoration: ShapeDecoration(
                           color: Colors.white,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10),
                           ),
                         ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 갤러리 아이콘
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFB4A6E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 36,
                                  color: Color(0xFFFB4A6E),
                                ),
                              ),
                              const SizedBox(width: 24),
                              const Text(
                                '앨범에서 사진 선택',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                     // 카메라로 촬영
                     GestureDetector(
                       onTap: onCameraTap,
                       child: Container(
                         width: 306,
                         height: 165,
                         decoration: ShapeDecoration(
                           color: Colors.white,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10),
                           ),
                         ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 카메라 아이콘
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFB4A6E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 36,
                                  color: Color(0xFFFB4A6E),
                                ),
                              ),
                              const SizedBox(width: 24),
                              const Text(
                                '카메라로 사진 촬영',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

