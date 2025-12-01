package com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentDto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class WeatherResponse {
    @JsonProperty("response")
    private Response response;

    @Getter
    @Setter
    public static class Response {
        private Header header;
        private WeatherBody body;
    }

    @Getter
    @Setter
    public static class Header {
        private String resultCode;
        private String resultMsg;
    }

}