package com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentController;

import com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentDto.WeatherCurrentDto;
import com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentService.WeatherCurrentService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


/**
 * 실시간 날씨 정보 API 요청을 처리하는 REST 컨트롤러입니다.
 */
@RestController
@RequestMapping("/weather")
public class WeatherCurrentController {

    private final WeatherCurrentService weatherCurrentService;

    /**
     * WeatherCurrentService를 주입받습니다.
     * @param weatherCurrentService 실시간 날씨 로직을 처리하는 서비스
     */
    @Autowired
    public WeatherCurrentController(WeatherCurrentService weatherCurrentService) {
        this.weatherCurrentService = weatherCurrentService;
    }

    /**
     * 위도(lat)와 경도(lon)를 파라미터로 받아 현재 날씨 정보를 반환합니다.
     * @param lat 위도 (기본값: 36.3504 - 대전)
     * @param lon 경도 (기본값: 127.3849 - 대전)
     * @return 200 OK 상태와 함께 WeatherCurrentDto를 반환합니다.
     */
    @GetMapping("/current")
    public ResponseEntity<WeatherCurrentDto> getCurrentWeather(
            // default 좌표로 대전광역시를 매핑합니다.
            @RequestParam(defaultValue = "36.3504") double lat,
            @RequestParam(defaultValue = "127.3849") double lon) {

        // 동기식으로 서비스 호출
        WeatherCurrentDto currentWeather = weatherCurrentService.getCurrentWeather(lat, lon);

        // ResponseEntity.ok()를 사용하여 HTTP 200 상태와 함께 DTO를 반환
        return ResponseEntity.ok(currentWeather);
    }
}