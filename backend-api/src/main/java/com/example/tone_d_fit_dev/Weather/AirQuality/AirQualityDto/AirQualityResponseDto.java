package com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDto;

import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDomain.AirQualityEntity;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class AirQualityResponseDto {

    // 엔티티 필드 그대로 포함
    private String stationName;
    private LocalDateTime datetime;

    private String sidoName;
    private BigDecimal latitude;
    private BigDecimal longitude;

    private Integer pm10Value;
    private Integer pm25Value;
    private BigDecimal o3Value;
    private Integer khaiValue;

    private String pm10Grade;
    private String pm25Grade;
    private String o3Grade;
    private String khaiGrade;

    /**
     * AirQuality 엔티티 객체를 받아 AirQualityResponseDto 객체로 변환하는 정적 팩토리 메서드입니다.
     */
    public static AirQualityResponseDto fromEntity(AirQualityEntity entity) {
        // 엔티티의 Getter를 사용하여 모든 필드를 AllArgsConstructor를 통해 채웁니다.
        // Short 타입을 Integer로 변환하기 위해 Integer.valueOf()를 사용합니다.

        // 엔티티 필드 중 SmallInt (Short)로 매핑된 값은 DTO에서 Integer로 변환합니다.
        Integer pm10 = entity.getPm10Value() != null ? entity.getPm10Value().intValue() : null;
        Integer pm25 = entity.getPm25Value() != null ? entity.getPm25Value().intValue() : null;
        Integer khai = entity.getKhaiValue() != null ? entity.getKhaiValue().intValue() : null;

        return new AirQualityResponseDto(
                entity.getStationName(),
                entity.getDatetime(),

                entity.getSidoName(),
                entity.getLatitude(),
                entity.getLongitude(),

                // Short -> Integer 변환 적용
                pm10,
                pm25,
                entity.getO3Value(),
                khai,

                entity.getPm10Grade(),
                entity.getPm25Grade(),
                entity.getO3Grade(),
                entity.getKhaiGrade()
        );
    }
}