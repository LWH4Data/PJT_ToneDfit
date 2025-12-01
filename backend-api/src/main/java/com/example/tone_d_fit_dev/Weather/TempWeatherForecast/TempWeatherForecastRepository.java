package com.example.tone_d_fit_dev.Weather.TempWeatherForecast;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface TempWeatherForecastRepository extends JpaRepository<TempWeatherForecastEntity, Integer> {

    // PostgreSQL의 ORDER BY RANDOM()을 사용하여 랜덤 레코드 1개를 조회하는 쿼리
    @Query(value = "SELECT * FROM weather_forecast_temp ORDER BY RANDOM() LIMIT 1", nativeQuery = true)
    Optional<TempWeatherForecastEntity> findRandomRecord();
}