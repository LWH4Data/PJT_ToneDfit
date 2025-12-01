package com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDomain;

import java.io.Serializable;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Objects;

// @EqualsAndHashCode 롬복 어노테이션을 쓰면 되지만, 개념 학습을 위해 직접 코드를 추가했습니다.
// Serializable 구현 필수
public class AirQualityId implements Serializable {

    // 복합 키 필드 (AirQuality 엔티티의 @Id 필드와 이름이 일치해야 함)
    private LocalDateTime datetime;
    private String stationName;

    // 1. JPA 사용을 위한 기본 생성자 필수
    public AirQualityId() {
    }

    // 2. Getter (선택적이지만 좋은 관례)
    public LocalDateTime getDatetime() {
        return datetime;
    }

    public String getStationName() {
        return stationName;
    }

    // Setter는 조회 전용이므로 생략

    // 3. equals()와 hashCode() 구현 필수
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        AirQualityId that = (AirQualityId) o;
        return Objects.equals(datetime, that.datetime) &&
                Objects.equals(stationName, that.stationName);
    }

    @Override
    public int hashCode() {
        return Objects.hash(datetime, stationName);
    }
}