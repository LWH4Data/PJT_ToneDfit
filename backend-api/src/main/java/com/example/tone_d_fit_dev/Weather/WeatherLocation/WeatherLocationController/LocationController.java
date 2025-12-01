package com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationController;

import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationService.LocationMapService;
import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDto.LocationNameResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/weather")
@RequiredArgsConstructor
public class LocationController {

    private final LocationMapService locationMapService;

    /**
     * 위도(lat)와 경도(lon)를 받아 해당 위치의 지역 이름을 조회합니다.
     * GET /weather/location?lat={위도}&lon={경도}
     *
     * @param lat 위도
     * @param lon 경도
     * @return 지역 이름 DTO를 포함하는 ResponseEntity (성공 시 200 OK, 실패 시 404 NOT FOUND)
     */
    @GetMapping("/location")
    public ResponseEntity<LocationNameResponseDto> getLocationName(
            @RequestParam("lat") double lat,
            @RequestParam("lon") double lon) {

        // 1. Service 계층 호출 (Optional<LocationNameResponseDto> 반환)
        return locationMapService.doFindLocationName(lat, lon)
                .map(ResponseEntity::ok) // 값이 존재하면 200 OK와 함께 DTO 반환
                .orElseGet(() -> ResponseEntity.notFound().build()); // 값이 없으면 404 Not Found 반환
    }
}