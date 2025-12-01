package com.example.tone_d_fit_dev.Weather.TempWeatherForecast;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.NoSuchElementException;

@RestController // 이 클래스를 RESTful 웹 서비스 컨트롤러로 지정
@RequestMapping("/temp/forecast") // 기본 경로 설정
@RequiredArgsConstructor // final 필드(Service)를 주입받기 위한 Lombok 어노테이션
public class TempWeatherForecastController {

    // Service 계층을 주입받음
    private final TempWeatherForecastService weatherForecastService;

    /**
     * GET /temp/forecast 요청을 처리하여 랜덤한 날씨 예보 데이터를 반환합니다.
     * @return ResponseEntity<TempWeatherForecastResponseDto>
     */
    @GetMapping
    public ResponseEntity<TempWeatherForecastResponseDto> getRandomWeatherForecast() {
        try {
            // Service 계층을 호출하여 랜덤 레코드를 조회 및 DTO로 변환
            TempWeatherForecastResponseDto responseDto = weatherForecastService.getRandomForecast();

            // 조회 성공 시 HTTP 200 OK와 함께 DTO 반환
            return ResponseEntity.ok(responseDto);

        } catch (NoSuchElementException e) {
            // 데이터베이스에 레코드가 존재하지 않을 경우 HTTP 404 Not Found 반환
            // 실제 운영 환경에서는 Custom Exception Handler를 사용하는 것이 더 좋습니다.
            return ResponseEntity.notFound().build();

        } catch (Exception e) {
            // 그 외 예외 발생 시 HTTP 500 Internal Server Error 반환
            // 자세한 로깅 처리 필요
            return ResponseEntity.internalServerError().build();
        }
    }
}