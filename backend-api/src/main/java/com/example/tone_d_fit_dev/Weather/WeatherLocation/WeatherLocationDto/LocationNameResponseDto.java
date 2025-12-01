package com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDto;

import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDomain.LocationMapEntity;
import lombok.Getter;

@Getter
public class LocationNameResponseDto {

    private final String locationName; // 최종적으로 조합된 지역 이름 (예: 서울특별시 강남구)
//    private final Short x;             // 격자 x 좌표 (필요에 따라 포함)
//    private final Short y;             // 격자 y 좌표 (필요에 따라 포함)

    /**
     * Entity 객체를 받아 DTO를 생성하는 생성자 (Converter 역할).
     * @param entity LocationMapEntity 객체
     */
    public LocationNameResponseDto(LocationMapEntity entity) {
        String province = entity.getProvince();
        String district = entity.getDistrict();

        // province와 district가 동일한지 확인합니다.
        if (province.equals(district)) {
            // 동일하다면 province만 할당합니다. (예: 세종특별자치시)
            this.locationName = province;
        } else {
            // 다르다면 province와 district를 조합하여 할당합니다. (예: 서울특별시 강남구)
            this.locationName = province + " " + district;
        }

        // 매핑에 사용된 격자 좌표도 함께 포함합니다.
//        this.x = entity.getX();
//        this.y = entity.getY();
    }
}