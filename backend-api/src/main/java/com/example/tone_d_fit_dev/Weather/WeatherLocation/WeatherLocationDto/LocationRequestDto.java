package com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class LocationRequestDto {

    @NotNull(message = "위도(latitude)는 필수 값입니다.")
    @DecimalMin(value = "-90.0", inclusive = true, message = "위도는 -90.0보다 작을 수 없습니다.")
    @DecimalMax(value = "90.0", inclusive = true, message = "위도는 90.0보다 클 수 없습니다.")
    private BigDecimal latitude;

    @NotNull(message = "경도(longitude)는 필수 값입니다.")
    @DecimalMin(value = "-180.0", inclusive = true, message = "경도는 -180.0보다 작을 수 없습니다.")
    @DecimalMax(value = "180.0", inclusive = true, message = "경도는 180.0보다 클 수 없습니다.")
    private BigDecimal longitude;

    // ===============================================
    //           [추가된 double 반환 메서드]
    // ===============================================

    /**
     * BigDecimal 위도 값을 double 타입으로 변환하여 반환합니다.
     * 주의: 이 과정에서 정밀도 손실(Precision Loss)이 발생할 수 있습니다.
     */
    public double getLatitudeAsDouble() {
        if (this.latitude == null) {
            // null 체크: null일 경우 0.0을 반환하도록 처리하거나,
            // NullPointerException을 발생시키지 않도록 API 명세에 맞춰 처리해야 합니다.
            // 여기서는 임시로 0.0을 반환합니다.
            return 0.0;
        }
        return this.latitude.doubleValue();
    }

    /**
     * BigDecimal 경도 값을 double 타입으로 변환하여 반환합니다.
     * 주의: 이 과정에서 정밀도 손실(Precision Loss)이 발생할 수 있습니다.
     */
    public double getLongitudeAsDouble() {
        if (this.longitude == null) {
            // null 체크: 마찬가지로 임시 0.0을 반환합니다.
            return 0.0;
        }
        return this.longitude.doubleValue();
    }
}