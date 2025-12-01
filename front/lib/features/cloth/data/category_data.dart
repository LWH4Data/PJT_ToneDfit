import '../../category/domain/entities/gender.dart';
import '../../category/domain/entities/category_large.dart';
import '../../category/domain/entities/category_small.dart';

class CategoryData {
  /// 성별 카테고리 목록 가져오기
  static List<Gender> getGenders() {
    return [
      // 남성
      Gender(
        id: '1',
        name: '남성',        larges: _getMaleCategories(),
      ),
      
      // 여성
      Gender(
        id: '2',
        name: '여성',
        larges: _getFemaleCategories(),
      ),
    ];
  }

  /// 남성 카테고리
  static List<CategoryLarge> _getMaleCategories() {
    return [
      // 1. 상의
      CategoryLarge(
        id: '1',
        name: '상의',
        smalls: [
          CategorySmall(id: '1', name: '맨투맨/스웨트'),
          CategorySmall(id: '2', name: '후드 티셔츠'),
          CategorySmall(id: '3', name: '셔츠/블라우스'),
          CategorySmall(id: '4', name: '긴소매 티셔츠'),
          CategorySmall(id: '5', name: '반소매 티셔츠'),
          CategorySmall(id: '6', name: '피케/카라 티셔츠'),
          CategorySmall(id: '7', name: '니트/스웨터'),
          CategorySmall(id: '8', name: '민소매 티셔츠'),
        ],
      ),
      
      // 2. 아우터
      CategoryLarge(
        id: '2',
        name: '아우터',
        smalls: [
          CategorySmall(id: '9', name: '패딩'),
          CategorySmall(id: '10', name: '코트'),
          CategorySmall(id: '11', name: '무스탕/퍼'),
          CategorySmall(id: '12', name: '플리스/카디건'),
          CategorySmall(id: '13', name: '레더/라이더스'),
          CategorySmall(id: '14', name: '블루종/MA-1/야상'),
          CategorySmall(id: '15', name: '재킷/블레이저'),
          CategorySmall(id: '16', name: '후드 집업'),
          CategorySmall(id: '17', name: '베스트'),
        ],
      ),
      
      // 3. 하의
      CategoryLarge(
        id: '3',
        name: '하의',
        smalls: [
          CategorySmall(id: '18', name: '데님 팬츠'),
          CategorySmall(id: '19', name: '트레이닝/조거 팬츠'),
          CategorySmall(id: '20', name: '코튼 팬츠'),
          CategorySmall(id: '21', name: '슈트 팬츠/슬렉스'),
          CategorySmall(id: '22', name: '숏 팬츠'),
          CategorySmall(id: '23', name: '레깅스'),
          CategorySmall(id: '24', name: '점프 슈트/오버올'),
        ],
      ),
    ];
  }

  /// 여성 카테고리
  static List<CategoryLarge> _getFemaleCategories() {
    return [
      // 1. 상의
      CategoryLarge(
        id: '1',
        name: '상의',
        smalls: [
          CategorySmall(id: '1', name: '맨투맨/스웨트'),
          CategorySmall(id: '2', name: '후드 티셔츠'),
          CategorySmall(id: '3', name: '셔츠/블라우스'),
          CategorySmall(id: '4', name: '긴소매 티셔츠'),
          CategorySmall(id: '5', name: '반소매 티셔츠'),
          CategorySmall(id: '6', name: '피케/카라 티셔츠'),
          CategorySmall(id: '7', name: '니트/스웨터'),
          CategorySmall(id: '8', name: '민소매 티셔츠'),
        ],
      ),
      
      // 2. 아우터
      CategoryLarge(
        id: '2',
        name: '아우터',
        smalls: [
          CategorySmall(id: '9', name: '패딩'),
          CategorySmall(id: '10', name: '코트'),
          CategorySmall(id: '11', name: '무스탕/퍼'),
          CategorySmall(id: '12', name: '플리스/카디건'),
          CategorySmall(id: '13', name: '레더/라이더스'),
          CategorySmall(id: '14', name: '블루종/MA-1/야상'),
          CategorySmall(id: '15', name: '재킷/블레이저'),
          CategorySmall(id: '16', name: '후드 집업'),
          CategorySmall(id: '17', name: '베스트'),
        ],
      ),
      
      // 3. 하의
      CategoryLarge(
        id: '3',
        name: '하의',
        smalls: [
          CategorySmall(id: '18', name: '데님 팬츠'),
          CategorySmall(id: '19', name: '트레이닝/조거 팬츠'),
          CategorySmall(id: '20', name: '코튼 팬츠'),
          CategorySmall(id: '21', name: '슈트 팬츠/슬렉스'),
          CategorySmall(id: '22', name: '숏 팬츠'),
          CategorySmall(id: '23', name: '레깅스'),
          CategorySmall(id: '24', name: '점프 슈트/오버올'),
        ],
      ),
      
      // 4. 원피스/스커트 (여성 전용)
      CategoryLarge(
        id: '4',
        name: '원피스/스커트',
        smalls: [
          CategorySmall(id: '25', name: '미니원피스'),
          CategorySmall(id: '26', name: '미디원피스'),
          CategorySmall(id: '27', name: '롱원피스'),
          CategorySmall(id: '28', name: '미니스커트'),
          CategorySmall(id: '29', name: '미디스커트'),
          CategorySmall(id: '30', name: '롱스커트'),
        ],
      ),
    ];
  }

  /// 특정 성별의 대분류 목록 가져오기
  static List<CategoryLarge> getLargeCategories(String genderId) {
    final gender = getGenders().firstWhere(
      (g) => g.id == genderId,
      orElse: () => throw Exception('Gender not found: $genderId'),
    );
    return gender.larges;
  }

  /// 특정 대분류의 소분류 목록 가져오기
  static List<CategorySmall> getSmallCategories(String largeId) {
    final genders = getGenders();
    for (final gender in genders) {
      for (final large in gender.larges) {
        if (large.id == largeId) {
          return large.smalls;
        }
      }
    }
    throw Exception('Large category not found: $largeId');
  }

  /// 대분류 찾기
  static CategoryLarge? findLargeCategory(String id) {
    final genders = getGenders();
    for (final gender in genders) {
      try {
        return gender.larges.firstWhere((large) => large.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  static CategorySmall? findSmallCategory(String id) {
    final genders = getGenders();
    for (final gender in genders) {
      for (final large in gender.larges) {
        try {
          return large.smalls.firstWhere((small) => small.id == id);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  /// 소분류 이름으로 ID 찾기
  static String? findSmallCategoryIdByName(String smallCategoryName) {
    final genders = getGenders();
    for (final gender in genders) {
      for (final large in gender.larges) {
        try {
          final small = large.smalls.firstWhere((small) => small.name == smallCategoryName);
          return small.id;
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  /// 하위 호환성을 위한 메서드
  @Deprecated('Use getGenders instead')
  static List<Gender> getCategories() => getGenders();
}