import '../domain/entities/color_entity.dart';

/// 색상 데이터
class ColorData {
  /// 모든 색상 목록
  static List<ColorEntity> getColors() {
    return const [
      ColorEntity(id: '1', name: '블랙', hexCode: '#000000'),
      ColorEntity(id: '2', name: '화이트', hexCode: '#FFFFFF'),
      ColorEntity(id: '3', name: '그레이', hexCode: '#808080'),
      ColorEntity(id: '4', name: '네이비', hexCode: '#000080'),
      ColorEntity(id: '5', name: '블루', hexCode: '#0000FF'),
      ColorEntity(id: '6', name: '스카이블루', hexCode: '#87CEEB'),
      ColorEntity(id: '7', name: '레드', hexCode: '#FF0000'),
      ColorEntity(id: '8', name: '핑크', hexCode: '#FFC0CB'),
      ColorEntity(id: '9', name: '옐로우', hexCode: '#FFFF00'),
      ColorEntity(id: '10', name: '그린', hexCode: '#008000'),
      ColorEntity(id: '11', name: '베이지', hexCode: '#F5F5DC'),
      ColorEntity(id: '12', name: '브라운', hexCode: '#A52A2A'),
      ColorEntity(id: '13', name: '퍼플', hexCode: '#800080'),
      ColorEntity(id: '14', name: '오렌지', hexCode: '#FFA500'),
      ColorEntity(id: '15', name: '카키', hexCode: '#F0E68C'),
      ColorEntity(id: '16', name: '버건디', hexCode: '#800020'),
      ColorEntity(id: '17', name: '민트', hexCode: '#98FF98'),
      ColorEntity(id: '18', name: '라벤더', hexCode: '#E6E6FA'),
      ColorEntity(id: '19', name: '기타', hexCode: null),
    ];
  }

  /// 이름으로 색상 찾기
  static ColorEntity? findColorByName(String name) {
    try {
      return getColors().firstWhere((color) => color.name == name);
    } catch (e) {
      return null;
    }
  }

  /// ID로 색상 찾기
  static ColorEntity? findColorById(String id) {
    try {
      return getColors().firstWhere((color) => color.id == id);
    } catch (e) {
      return null;
    }
  }
}
