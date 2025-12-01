package com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentService;

import com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentClient.WeatherCurrentClient;
import com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentDto.WeatherCurrentDto;
import com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentDto.WeatherItem;
import com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentDto.WeatherResponse;
import com.example.tone_d_fit_dev.Weather.WeatherUtils.GeoConverter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class WeatherCurrentService {
    private final WeatherCurrentClient weatherCurrentClient;
    private final GeoConverter geoConverter;

    /**
     * 의존성 주입: WeatherCurrentClient와 Converter 빈을 주입받습니다.
     * @param weatherCurrentClient 날씨 API 호출을 담당하는 클라이언트
     * @param geoConverter 위도/경도 좌표를 격자 좌표로 변환하는 컴포넌트
     */
    @Autowired
    public WeatherCurrentService(WeatherCurrentClient weatherCurrentClient, GeoConverter geoConverter) {
        this.weatherCurrentClient = weatherCurrentClient;
        this.geoConverter = geoConverter;
    }

    /**
     * 위도와 경도를 받아 실시간 날씨 정보를 조회합니다. (동기 방식)
     * @param lat 위도
     * @param lon 경도
     * @return 가공된 실시간 날씨 정보 DTO (실패 시 빈 DTO 또는 null을 반환할 수 있음)
     */
    public WeatherCurrentDto getCurrentWeather(double lat, double lon) {
        GeoConverter.Grid grid = geoConverter.convertToGrid(lat, lon);
        String nx = String.valueOf(grid.x);
        String ny = String.valueOf(grid.y);

        // 1. (동기) Client 호출: 공유해주신 클라이언트는 실패 시 null을 반환합니다.
        WeatherResponse weatherResponse = weatherCurrentClient.getCurrentWeather(nx, ny);

        // 2. (동기) 반환된 응답을 DTO로 가공
        //    (Mono의 .map() 대신, 반환된 객체를 바로 처리합니다.)
        return processWeatherResponse(weatherResponse);
    }


    /**
     * API 응답(WeatherResponse)을 최종 DTO(WeatherCurrentDto)로 변환합니다.
     * @param weatherResponse API로부터 받은 응답 객체 (null일 수 있음)
     * @return 가공된 WeatherCurrentDto
     */
    private WeatherCurrentDto processWeatherResponse(WeatherResponse weatherResponse) {
        WeatherCurrentDto weatherCurrentDto = new WeatherCurrentDto();

        // 3. API 응답이 null이거나, 비정상적인 경우 빈 DTO를 반환
        if (weatherResponse == null ||
                weatherResponse.getResponse() == null ||
                weatherResponse.getResponse().getBody() == null ||
                weatherResponse.getResponse().getBody().getItems() == null ||
                weatherResponse.getResponse().getBody().getItems().getItem() == null) {

            System.err.println("날씨 API 응답이 없거나 비정상입니다.");
            return weatherCurrentDto; // 빈 DTO 반환
        }

        List<WeatherItem> items = weatherResponse.getResponse().getBody().getItems().getItem();

        if (items.isEmpty()) {
            System.err.println("날씨 API 응답 항목(items)이 비어있습니다.");
            return weatherCurrentDto;
        }

        // 4. 날씨 데이터를 key-value 형태로 가공 (원본 로직 동일)
        // (참고: toMap 사용 시 중복 키가 있으면 예외가 발생할 수 있습니다.
        //  (k, v) -> v, 덮어쓰기)
        Map<String, String> weatherDataMap = items.stream()
                .collect(Collectors.toMap(
                        WeatherItem::getCategory,
                        WeatherItem::getObsrValue,
                        (existingValue, newValue) -> newValue // 중복 키 발생 시 새 값으로 덮어쓰기
                ));

        // 5. DTO 필드에 데이터 매핑 (원본 로직 동일)
        weatherCurrentDto.setBaseDate(items.get(0).getBaseDate());
        weatherCurrentDto.setBaseTime(items.get(0).getBaseTime());

        // 관측 데이터를 매핑하고, 필요에 따라 타입 변환
        weatherCurrentDto.setTemperature(Double.parseDouble(weatherDataMap.getOrDefault("T1H", "0.0")));
        weatherCurrentDto.setOneHourPrecipitation(Double.parseDouble(weatherDataMap.getOrDefault("RN1", "0.0")));
        weatherCurrentDto.setHumidity(Double.parseDouble(weatherDataMap.getOrDefault("REH", "0.0")));
        weatherCurrentDto.setWindSpeed(Double.parseDouble(weatherDataMap.getOrDefault("WSD", "0.0")));
        weatherCurrentDto.setWindDirection((int) Double.parseDouble(weatherDataMap.getOrDefault("VEC", "0.0")));        weatherCurrentDto.setEastWestWind(Double.parseDouble(weatherDataMap.getOrDefault("UUU", "0.0")));
        weatherCurrentDto.setSouthNorthWind(Double.parseDouble(weatherDataMap.getOrDefault("VVV", "0.0")));

        // 강수 형태(PTY)는 코드값을 문자열로 변환
        weatherCurrentDto.setPrecipitationType(convertPrecipitationType(weatherDataMap.getOrDefault("PTY", "0")));

        // 디버그 코드 추가
        System.out.println("가공된 최종 데이터: " + weatherCurrentDto.toString());

        return weatherCurrentDto;
    }

    /**
     * 강수형태 코드(PTY)를 문자열로 변환합니다. (원본 로직 동일)
     * @param ptyCode PTY 코드
     * @return 변환된 문자열
     */
    public String convertPrecipitationType(String ptyCode) {
        if (ptyCode == null || ptyCode.equals("-1") || ptyCode.equals("0")) {
            return "없음";
        }

        switch (ptyCode) {
            case "1":
                return "비";
            case "2":
                return "비/눈";
            case "3":
                return "눈";
            case "5":
                return "빗방울";
            case "6":
                return "빗방울/눈날림";
            case "7":
                return "눈날림";
            default:
                return "확인불가";
        }
    }
}