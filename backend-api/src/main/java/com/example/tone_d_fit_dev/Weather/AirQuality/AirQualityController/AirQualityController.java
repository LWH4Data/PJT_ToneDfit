package com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityController;

import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityDto.AirQualityResponseDto;
import com.example.tone_d_fit_dev.Weather.WeatherLocation.WeatherLocationDto.LocationRequestDto;
import com.example.tone_d_fit_dev.Weather.AirQuality.AirQualityService.AirQualityService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/weather")
// @RequiredArgsConstructor // Service 주입을 위해 Lombok을 사용하는 경우 추가
public class AirQualityController {

    private final AirQualityService airQualityService;

    // Service를 생성자 주입
    public AirQualityController(AirQualityService airQualityService) {
        this.airQualityService = airQualityService;
    }

    /**
     * [GET] 쿼리 파라미터로 위도(latitude)와 경도(longitude)를 받아 가장 가까운 공기질 데이터를 조회합니다.
     * * 요청 예시: GET /api/air-quality/search?latitude=37.5665&longitude=126.9780
     *
     * @param request 위도와 경도 데이터 (Request Params에서 자동 매핑 및 @Valid 검증)
     * @return AirQualityResponseDto와 HTTP 상태 코드 (200 OK 또는 204 No Content)
     */
    @GetMapping("/air-quality")
    public ResponseEntity<AirQualityResponseDto> getAirQualityResponse(
            @Valid LocationRequestDto request) {

        // 1. Service 호출 및 Optional<DTO> 반환 받음
        return airQualityService.getAirQuality(request)
                // 2. Optional 처리: 값이 있을 경우 (성공)
                .map(response -> ResponseEntity.ok(response)) // 200 OK와 함께 DTO 반환

                // 3. Optional 처리: 값이 없을 경우 (데이터 없음)
                // 204 No Content (요청은 성공, 반환할 내용만 없음) 응답 반환
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NO_CONTENT).build());
    }
}