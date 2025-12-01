package com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentClient;

import com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentDto.WeatherResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

@Component
public class WeatherCurrentClient {
    private final RestClient restClient;
    private final String apiKey;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final String API_PATH = "/VilageFcstInfoService_2.0/getUltraSrtNcst";

    public WeatherCurrentClient(
            // RestClient.Builder를 주입받습니다. Spring Boot가 자동으로 구성해줍니다.
            RestClient.Builder restClientBuilder,
            @Value("${weather.api.key}") String apiKey,
            @Value("${weather.api.url}") String baseUrl
    ) {
        // RestClient.Builder를 사용하여 기본 URL을 설정한 RestClient 인스턴스를 생성합니다.
        this.restClient = restClientBuilder
                .baseUrl(baseUrl)
                .build();
        this.apiKey = apiKey;
        // baseUrl 필드는 RestClient가 내부적으로 관리하므로 더 이상 필요하지 않습니다.
    }

    // --- getFormattedTime, getFormattedDate 메서드는 로직이 동일하므로 변경 없음 ---

    private String getFormattedTime(LocalDateTime now) {
        // 1. 외부에서 받은 KST LocalDateTime을 ZonedDateTime으로 올바르게 변환
        ZonedDateTime kstDateTime = now.atZone(ZoneId.of("Asia/Seoul"));

        // 2. 변환된 한국 시간에서 10분 빼기 (기존 로직 동일)
        ZonedDateTime baseDateTime = kstDateTime.minusMinutes(10);

        // 3. 계산된 시각을 "HH00" 형식으로 변환하여 반환 (기존 로직 동일)
        return baseDateTime.format(DateTimeFormatter.ofPattern("HH00"));
    }

    private String getFormattedDate(LocalDateTime now, String baseTime) {
        // base_time이 "2300"이고, 현재 시간이 00시 10분 이전인 경우에만 날짜를 하루 뺍니다.
        int nowHour = now.getHour();
        int nowMinute = now.getMinute();
        int currentTime = nowHour * 100 + nowMinute;

        if ("2300".equals(baseTime) && currentTime < 10) {
            return now.minusDays(1).format(DATE_FORMATTER);
        }
        return now.format(DATE_FORMATTER);
    }

    /**
     * 동기식(RestClient)으로 현재 날씨를 가져옵니다.
     * @param nx X 좌표
     * @param ny Y 좌표
     * @return WeatherResponse DTO, 실패 시 null
     */
    public WeatherResponse getCurrentWeather(String nx, String ny) {
        LocalDateTime now = LocalDateTime.now();
        String baseTime = getFormattedTime(now);
        String baseDate = getFormattedDate(now, baseTime);

        // RestClient는 URI 템플릿과 queryParam을 사용하여 자동으로 인코딩을 처리합니다.
        // 수동 URL 인코딩(URLEncoder.encode)이 더 이상 필요하지 않습니다.

        try {
            // RestClient를 사용하여 API 호출
            WeatherResponse response = restClient.get()
                    // .uri() 메서드를 사용하여 경로와 쿼리 파라미터를 설정합니다.
                    .uri(uriBuilder -> uriBuilder
                            .path(API_PATH)
                            .queryParam("pageNo", "1")
                            .queryParam("numOfRows", "1000")
                            .queryParam("dataType", "JSON")
                            .queryParam("base_date", baseDate)
                            .queryParam("base_time", baseTime)
                            .queryParam("nx", nx)
                            .queryParam("ny", ny)
                            .queryParam("authKey", apiKey) // 인코딩되지 않은 원본 키를 전달
                            .build())
                    .retrieve() // 응답을 가져옵니다.
                    .body(WeatherResponse.class); // 응답 본문을 WeatherResponse.class로 변환

            return response;

        } catch (HttpClientErrorException | HttpServerErrorException e) {
            // 4xx (Client) 또는 5xx (Server) 에러 처리
            // 예외 처리 로직은 RestTemplate과 동일하게 작동합니다.
            System.err.println("API 호출 실패. 상태 코드: " + e.getStatusCode());
            System.err.println("응답 본문: " + e.getResponseBodyAsString());
            return null; // 원본의 Mono.empty()와 동일하게 null 반환
        } catch (RestClientException e) {
            // 그 외 RestClient 관련 예외 (e.g., 연결 실패, 타임아웃 등)
            System.err.println("API 호출 중 기타 오류 발생: " + e.getMessage());
            return null;
        }
    }
}