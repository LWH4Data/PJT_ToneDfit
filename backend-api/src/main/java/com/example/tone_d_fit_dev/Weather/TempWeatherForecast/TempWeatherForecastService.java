package com.example.tone_d_fit_dev.Weather.TempWeatherForecast;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class TempWeatherForecastService {

    // Repository를 주입받아 데이터 접근을 처리
    private final TempWeatherForecastRepository repository;

    /**
     * 데이터베이스에서 임의의 날씨 예보 레코드 하나를 조회하여 DTO로 변환합니다.
     * @return TempWeatherForecastResponseDto
     * @throws NoSuchElementException 랜덤 레코드가 존재하지 않을 경우
     */
    public TempWeatherForecastResponseDto getRandomForecast() {

        // 1. Repository에서 랜덤 레코드(Entity)를 조회 (Native Query 사용)
        TempWeatherForecastEntity entity = repository.findRandomRecord()
                .orElseThrow(() -> new NoSuchElementException("조회할 날씨 더미 데이터가 없습니다."));

        // 2. Entity를 Response DTO로 변환(매핑)
        return mapToDto(entity);
    }

    /**
     * Entity 객체를 약어 DTO로 변환하는 매핑 로직입니다.
     * @param entity 원본 Entity 객체
     * @return 변환된 DTO 객체
     */
    private TempWeatherForecastResponseDto mapToDto(TempWeatherForecastEntity entity) {

        // DTO record의 정규 생성자를 사용하여 데이터를 매핑하고 객체로 포장합니다.
        return new TempWeatherForecastResponseDto(

                // Temperature (TMP)
                entity.getTemperatureCurrent(),
                entity.getTemperatureMax(),
                entity.getTemperatureMin(),
                entity.getTemperatureFeelsLike(),

                // Weather & Precipitation (WTH, PRC)
                entity.getWeatherCondition(),
                entity.getPrecipitationType(),
                entity.getPrecipitationChance(),
                entity.getPrecipitationAmount(),

                // Wind & Humidity (WND, HUM)
                entity.getHumidityCurrent(),
                entity.getWindSpeed(),

                // Index (IDX)
                entity.getDustIndex(),
                entity.getDustCondition(),
                entity.getUvIndex(),
                entity.getUvCondition()
        );
    }
}