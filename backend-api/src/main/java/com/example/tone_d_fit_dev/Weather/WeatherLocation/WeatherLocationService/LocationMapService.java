package com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationService;

import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDomain.LocationMapEntity;
import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationRepository.LocationMapRepository;
import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDto.LocationNameResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.Optional;
import com.example.tone_d_fit_dev.Weather.WeatherUtils.GeoConverter;
import com.example.tone_d_fit_dev.Weather.WeatherUtils.GeoConverter.Grid;

@Service
@RequiredArgsConstructor
public class LocationMapService {

    private final GeoConverter geoConverter;
    private final LocationMapRepository locationMapRepository;

    public Optional<LocationNameResponseDto> doFindLocationName(double lat, double lon) {
        Grid locationGrid = getGrid(lat, lon);

        Short x = (short) locationGrid.x;
        Short y = (short) locationGrid.y;

        return findLocationNameByXandY(x, y);
    }

    /**
     * 격자 좌표 (x, y)를 사용하여 지역 엔티티를 조회하고, DTO로 변환하여 반환합니다.
     * * @param x 기상청 격자 x 좌표
     * @param y 기상청 격자 y 좌표
     * @return province와 district가 조합된 locationName을 포함하는 DTO (Optional로 래핑됨)
     */
    public Optional<LocationNameResponseDto> findLocationNameByXandY(Short x, Short y) {

        // 1. Repository를 호출하여 Entity 조회 (Optional<LocationMapEntity> 반환)
        Optional<LocationMapEntity> entityOptional = locationMapRepository.findFirstByXAndY(x, y);

        // 2. Optional에 값이 존재하면 DTO로 변환하고, 그렇지 않으면 Optional.empty() 반환
        return entityOptional.map(LocationNameResponseDto::new);

        /* * [Optional.map() 설명]
         * - entityOptional 내부에 LocationMapEntity 객체가 있다면 (조회 성공했다면),
         * 해당 객체를 LocationNameResponseDto::new (생성자 참조)를 통해
         * LocationNameResponseDto 객체로 변환합니다.
         * - 객체가 없다면(조회 실패했다면), Optional<LocationNameResponseDto>의
         * 빈(empty) Optional 객체를 반환합니다.
         */
    }

    // 좌표 변환 클래스인 GeoConverter를 이용해 위도와 경도를, x와 y좌표를 가지고 있는 Grid 객체로 변환합니다.
    public Grid getGrid(double lat, double lon) {
        return geoConverter.convertToGrid(lat, lon);
    }
}