import 'package:flutter/material.dart';
import '../../../../shared/utils/weather_utils.dart';

/// 날씨 정보 카드 (강수, 습도, 풍속 등)
class WeatherInfoCard extends StatelessWidget {
  final String title; // 제목 (강수, 습도 등)
  final IconData icon; // 아이콘
  final Color? iconColor; // 아이콘 색상 (null이면 기본 색상)
  final String mainValue; // 주요 값 (70%, 5mm 등)
  final String? subValue; // 부가 값
  final String? description; // 설명
  final bool centerAlign; // 중앙 정렬 여부 (기본값: false)

  const WeatherInfoCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.mainValue,
    this.subValue,
    this.description,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 110, // 150 → 135로 감소
      padding: const EdgeInsets.all(5),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: OverflowBox(
        maxHeight: double.infinity, // 높이 제약 무시
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
          // 아이콘 + 제목
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: centerAlign ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: iconColor ?? const Color(0xCC292D32),
              ),
              const SizedBox(width: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xCC292D32),
                  fontSize: 10,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w500,
                  height: 1,
                  letterSpacing: 0.38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          // 주요 값
          Text(
            mainValue,
            style: const TextStyle(
              color: Color(0xB2292D32),
              fontSize: 13,
              fontFamily: 'NanumSquare Neo',
              fontWeight: FontWeight.w700,
              height: 1.10,
            ),
          ),
          // 부가 값
          if (subValue != null) ...[
            const SizedBox(height: 11),
            Text(
              subValue!,
              style: const TextStyle(
                color: Color(0xB2292D32),
                fontSize: 13,
                fontFamily: 'NanumSquare Neo',
                fontWeight: FontWeight.w700,
                height: 1.10,
              ),
            ),
          ],
          // 설명
          if (description != null) ...[
            const SizedBox(height: 11),
            SizedBox(
              width: 94,
              child: Text(
                description!,
                textAlign: centerAlign ? TextAlign.center : TextAlign.left,
                style: const TextStyle(
                  color: Color(0x4C292D32),
                  fontSize: 8,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}

/// 강수 정보 카드 (Helper)
class PrecipitationCard extends StatelessWidget {
  final int probability; // 강수확률 (%)
  final double? amount; // 강수량 (mm)
  final String? precipitationType; // 강수 유형

  const PrecipitationCard({
    super.key,
    required this.probability,
    this.amount,
    this.precipitationType,
  });

  @override
  Widget build(BuildContext context) {
    // 강수 유형에 따른 아이콘
    IconData icon = Icons.water_drop;
    if (precipitationType != null && precipitationType != '없음') {
      icon = WeatherUtils.getPrecipitationIconByName(precipitationType!);
    }
    
    // 설명 텍스트
    String? desc;
    if (precipitationType != null && precipitationType != '없음') {
      desc = '현재 ${precipitationType}이/가 내리는 중입니다.';
    }
    
    return WeatherInfoCard(
      title: '강수',
      icon: icon,
      mainValue: '$probability%',
      subValue: amount != null ? '${amount}mm' : null,
      description: desc,
      centerAlign: true, // 중앙 정렬
    );
  }
}

/// 미세먼지 정보 카드 (Helper)
class FineDustCard extends StatelessWidget {
  final int concentration; // 미세먼지 농도

  const FineDustCard({
    super.key,
    required this.concentration,
  });

  String _getDescription(int concentration) {
    if (concentration <= 30) {
      return '야외활동을 즐기기 좋아요.';
    } else if (concentration <= 80) {
      return '보통 수준입니다.';
    } else if (concentration <= 150) {
      return '민감군은 활동을 자제해주세요.';
    } else if (concentration <= 250) {
      return '실내활동을 자제해주세요.';
    } else {
      return '외출을 자제해주세요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WeatherInfoCard(
      title: '미세먼지',
      icon: Icons.masks, // 마스크 아이콘으로 변경
      // iconColor 제거 - 기본 색상 사용 (다른 카드들과 동일)
      mainValue: '$concentration',
      subValue: WeatherUtils.getFineDustLevelText(concentration),
      description: _getDescription(concentration),
      centerAlign: true, // 중앙 정렬
    );
  }
}

/// 자외선 지수 카드 (Helper)
class UvIndexCard extends StatelessWidget {
  final int uvIndex; // 자외선 지수

  const UvIndexCard({
    super.key,
    required this.uvIndex,
  });

  String _getDescription(int uvIndex) {
    if (uvIndex <= 2) {
      return '햇빛 노출에 안전해요.';
    } else if (uvIndex <= 5) {
      return '2시간 이상 햇빛 노출 시 자외선 차단제를 바르세요.';
    } else if (uvIndex <= 7) {
      return '외출 시 자외선 차단제를 바르세요.';
    } else if (uvIndex <= 10) {
      return '오전 10시~오후 3시 외출을 자제하세요.';
    } else {
      return '가급적 실내에 머물러 주세요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WeatherInfoCard(
      title: '자외선',
      icon: Icons.wb_sunny,
      // iconColor 제거 - 기본 색상 사용 (다른 카드들과 동일)
      mainValue: '$uvIndex',
      subValue: WeatherUtils.getUvLevelText(uvIndex),
      description: _getDescription(uvIndex),
      centerAlign: true, // 중앙 정렬
    );
  }
}

/// 체감온도 카드 (Helper)
class ApparentTempCard extends StatelessWidget {
  final int apparentTemp; // 체감온도 (°C)
  final int actualTemp; // 실제온도 (°C)

  const ApparentTempCard({
    super.key,
    required this.apparentTemp,
    required this.actualTemp,
  });

  String _getDescription(int apparentTemp, int actualTemp) {
    final diff = apparentTemp - actualTemp;
    if (diff > 3) {
      return '실제보다 ${diff}도 더 덥게 느껴져요.';
    } else if (diff < -3) {
      return '실제보다 ${-diff}도 더 춥게 느껴져요.';
    } else {
      return '실제 온도와 비슷하게 느껴져요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WeatherInfoCard(
      title: '체감온도',
      icon: Icons.thermostat,
      mainValue: '$apparentTemp°',
      subValue: '실제 $actualTemp°',
      description: _getDescription(apparentTemp, actualTemp),
      centerAlign: true, // 중앙 정렬
    );
  }
}

/// 습도 카드 (Helper)
class HumidityCard extends StatelessWidget {
  final int humidity; // 습도 (%)

  const HumidityCard({
    super.key,
    required this.humidity,
  });

  String _getDescription(int humidity) {
    if (humidity <= 30) {
      return '매우 건조합니다. 수분 섭취에 신경 써주세요.';
    } else if (humidity <= 50) {
      return '쾌적한 습도입니다.';
    } else if (humidity <= 70) {
      return '조금 습한 날씨입니다.';
    } else {
      return '매우 습합니다. 불쾌감을 느낄 수 있어요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WeatherInfoCard(
      title: '습도',
      icon: Icons.water_drop_outlined,
      mainValue: '$humidity%',
      subValue: ' ', // 더미 값으로 설명 위치 맞춤
      description: _getDescription(humidity),
      centerAlign: true, // 중앙 정렬
    );
  }
}

/// 바람(풍속) 카드 (Helper)
class WindCard extends StatelessWidget {
  final double windSpeed; // 풍속 (m/s)

  const WindCard({
    super.key,
    required this.windSpeed,
  });

  String _getDescription(double windSpeed) {
    if (windSpeed < 4.0) {
      return '바람이 약합니다.';
    } else if (windSpeed < 9.0) {
      return '약간 바람이 붑니다.';
    } else if (windSpeed < 14.0) {
      return '바람이 강합니다. 주의하세요.';
    } else {
      return '매우 강한 바람입니다. 외출에 주의하세요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WeatherInfoCard(
      title: '바람',
      icon: Icons.air,
      mainValue: '${windSpeed.toStringAsFixed(1)}m/s',
      subValue: ' ', // 더미 값으로 설명 위치 맞춤
      description: _getDescription(windSpeed),
      centerAlign: true, // 중앙 정렬
    );
  }
}

