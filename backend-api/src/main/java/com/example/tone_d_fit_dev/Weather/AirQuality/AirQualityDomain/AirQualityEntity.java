package com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDomain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable; // 불변성 명시를 위해 추가 (Hibernate 사용 시)

import java.sql.Timestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "air_quality")
@IdClass(AirQualityId.class)
@Immutable // 이 엔티티는 변경되지 않음을 명시
@Getter // Getter만 유지
@NoArgsConstructor // 기본 생성자 (JPA 필수)
// @Setter, @ToString 등 제거
public class AirQualityEntity {

    // Primary Key (복합 키)
    @Id
    @Column(name = "datetime", nullable = false)
    private LocalDateTime datetime;

    @Id
    @Column(name = "station_name", length = 50, nullable = false)
    private String stationName;

    // 나머지 컬럼
    @Column(name = "sido_name", length = 30)
    private String sidoName;

    @Column(name = "latitude", precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 10, scale = 7)
    private BigDecimal longitude;

    @Column(name = "pm10_value")
    private Short pm10Value;

    @Column(name = "pm25_value")
    private Short pm25Value;

    @Column(name = "o3_value", precision = 4, scale = 3)
    private BigDecimal o3Value;

    @Column(name = "khai_value")
    private Short khaiValue;

    @Column(name = "pm10_grade", length = 10)
    private String pm10Grade;

    @Column(name = "pm25_grade", length = 10)
    private String pm25Grade;

    @Column(name = "o3_grade", length = 10)
    private String o3Grade;

    @Column(name = "khai_grade", length = 10)
    private String khaiGrade;
}