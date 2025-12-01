package com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationRepository;

import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDomain.LocationMapEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LocationMapRepository extends JpaRepository<LocationMapEntity, Integer> {

    /**
     * 주어진 격자 좌표 (x, y)를 사용하여 LocationMapEntity를 조회합니다.
     * x, y 쌍은 unique 하지 않아 여러 결과가 나올 수 있지만,
     * 'findFirstBy' 키워드를 사용하여 데이터베이스에서 조회된 결과 중
     * 가장 최상단(first)의 단일 행만 Optional로 반환합니다.
     * * @param x 기상청 격자 x 좌표
     * @param y 기상청 격자 y 좌표
     * @return 해당 좌표를 가진 가장 먼저 조회된 단일 Entity 객체 (Optional<LocationMapEntity>)
     */
    Optional<LocationMapEntity> findFirstByXAndY(Short x, Short y);
}