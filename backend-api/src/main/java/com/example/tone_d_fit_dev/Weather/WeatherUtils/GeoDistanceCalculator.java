package com.example.tone_d_fit_dev.Weather.WeatherUtils;

import org.springframework.stereotype.Component; // Spring Bean으로 등록하여 재활용 가능하게 함

/**
 * 지리적 거리 계산 유틸리티 클래스입니다.
 * 하버사인 공식(Haversine Formula)을 사용하여 두 지점 간의 거리를 계산합니다.
 */
@Component
public class GeoDistanceCalculator {

    private static final double EARTH_RADIUS_KM = 6371; // 지구의 평균 반경 (킬로미터)

    /**
     * 두 위도/경도 지점 사이의 거리를 하버사인 공식을 사용하여 계산합니다.
     *
     * @param lat1 첫 번째 지점의 위도 (double)
     * @param lon1 첫 번째 지점의 경도 (double)
     * @param lat2 두 번째 지점의 위도 (double)
     * @param lon2 두 번째 지점의 경도 (double)
     * @return 두 지점 간의 거리 (킬로미터, double)
     */
    public double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        // Haversine 공식의 핵심 연산
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }
}