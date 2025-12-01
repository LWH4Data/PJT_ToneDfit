package com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityRepository;

import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDomain.AirQualityEntity;
import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDomain.AirQualityId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface AirQualityRepository extends JpaRepository<AirQualityEntity, AirQualityId> {

    /**
     * 특정 바운딩 박스(직사각형 영역) 내의 모든 공기질 측정소 데이터를 조회합니다.
     * 이 쿼리는 DB의 인덱스를 활용하여 빠르게 1차 필터링을 수행합니다.
     * * @param minLat 최소 위도 경계
     * @param maxLat 최대 위도 경계
     * @param minLon 최소 경도 경계
     * @param maxLon 최대 경도 경계
     * @return 필터링된 AirQuality 엔티티 목록
     */
    @Query("SELECT a FROM AirQualityEntity a " +
            "WHERE a.latitude BETWEEN :minLat AND :maxLat " +
            "  AND a.longitude BETWEEN :minLon AND :maxLon")
    List<AirQualityEntity> findStationsInBoundingBox(
            @Param("minLat") BigDecimal minLat,
            @Param("maxLat") BigDecimal maxLat,
            @Param("minLon") BigDecimal minLon,
            @Param("maxLon") BigDecimal maxLon
    );
}