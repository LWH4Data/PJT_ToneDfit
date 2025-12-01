package com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDomain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
// Setter와 Builder는 제거합니다.

@Getter // 데이터를 읽는 용도이므로 Getter는 유지
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA 리플렉션을 위해 필수
@Entity
@Table(name = "location_map")
public class LocationMapEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "province", length = 20, nullable = false)
    private String province;

    @Column(name = "district", length = 20, nullable = false)
    private String district;

    @Column(name = "category", length = 10)
    private String category;

    @Column(name = "latitude", precision = 11, scale = 7, nullable = false)
    private BigDecimal latitude; // Double -> BigDecimal로 변경

    @Column(name = "longitude", precision = 11, scale = 7, nullable = false)
    private BigDecimal longitude; // Double -> BigDecimal로 변경

    @Column(name = "x")
    private Short x;

    @Column(name = "y")
    private Short y;

    // 이 객체는 JPA에 의해 내부적으로 생성되므로, 별도의 public 생성자는 필요하지 않습니다.
    // DTO 변환이나 테스트를 위해 필요하다면, private 생성자를 사용할 수 있습니다.
}