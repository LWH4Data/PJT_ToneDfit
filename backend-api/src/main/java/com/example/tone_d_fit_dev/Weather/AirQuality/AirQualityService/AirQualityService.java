package com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityService;

import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDto.AirQualityResponseDto;
import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityRepository.AirQualityRepository;
import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDto.LocationRequestDto;
import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDomain.AirQualityEntity;
import com.example.tone_d_fit_dev.Weather.WeatherUtils.GeoDistanceCalculator; // 분리된 모듈
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AirQualityService {

    private final AirQualityRepository airQualityRepository;
    private final GeoDistanceCalculator geoDistanceCalculator;

    // Bounding Box 필터링을 위한 델타 값 (약 55km 반경의 근사치)
    private static final double DELTA_DEGREE = 0.5;

    /**
     * 위도/경도를 받아 가장 가까운 측정소의 최신 공기질 데이터를 조회합니다.
     * 1차: Bounding Box 필터링 (공간) -> 2차: 최신 데이터 추출 (시간) -> 3차: 하버사인 거리 계산 (정확도)
     * * @param request 위도와 경도를 담은 DTO
     * @return 가장 가까운 측정소의 최신 데이터 DTO (Optional 보장)
     */
    public Optional<AirQualityResponseDto> getAirQuality(LocationRequestDto request) {

        // 1. 사용자 위치 및 Bounding Box 경계 계산
        double userLat = request.getLatitudeAsDouble();
        double userLon = request.getLongitudeAsDouble();

        // DB 정합성을 위해 BigDecimal로 경계 값 변환
        BigDecimal minLat = BigDecimal.valueOf(userLat - DELTA_DEGREE);
        BigDecimal maxLat = BigDecimal.valueOf(userLat + DELTA_DEGREE);
        BigDecimal minLon = BigDecimal.valueOf(userLon - DELTA_DEGREE);
        BigDecimal maxLon = BigDecimal.valueOf(userLon + DELTA_DEGREE);

        // 2. [1차 필터링] DB에서 Bounding Box 내의 모든 측정소 데이터를 가져옴 (시간 무시)
        List<AirQualityEntity> nearbyRecords = airQualityRepository.findStationsInBoundingBox(
                minLat, maxLat, minLon, maxLon
        );

        if (nearbyRecords.isEmpty()) {
            return Optional.empty(); // 근처에 데이터가 없으면 종료
        }

        // 3. [2차 필터링] 측정소별로 가장 최신(Datetime이 가장 큰) 데이터만 추출
        List<AirQualityEntity> latestRecords = nearbyRecords.stream()
                .collect(
                        // stationName으로 그룹화하고, 각 그룹에서 가장 최신 레코드를 선택
                        Collectors.groupingBy(AirQualityEntity::getStationName,
                                Collectors.maxBy(Comparator.comparing(AirQualityEntity::getDatetime))
                        )
                )
                .values().stream()
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toList());


        // 4. [3차 필터링] 남은 최신 데이터 중 하버사인 거리가 가장 짧은 측정소 선택
        return latestRecords.stream()
                .min(Comparator.comparingDouble(station -> {
                    // 성능을 위해 BigDecimal을 double로 변환하여 거리 계산 모듈에 전달
                    double stationLat = station.getLatitude().doubleValue();
                    double stationLon = station.getLongitude().doubleValue();

                    return geoDistanceCalculator.calculateHaversineDistance(userLat, userLon, stationLat, stationLon);
                }))
                // 5. 가장 가까운 엔티티를 DTO로 변환하여 Optional로 반환
                .map(AirQualityResponseDto::fromEntity);
    }
}