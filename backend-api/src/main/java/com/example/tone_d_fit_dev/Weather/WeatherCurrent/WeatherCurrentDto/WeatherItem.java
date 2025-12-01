package com.example.tone_d_fit_dev.Weather.WeatherCurrent.WeatherCurrentDto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class WeatherItem {
    @JsonProperty("baseDate")
    private String baseDate;
    @JsonProperty("baseTime")
    private String baseTime;
    @JsonProperty("category")
    private String category;
    @JsonProperty("nx")
    private int nx;
    @JsonProperty("ny")
    private int ny;
    @JsonProperty("obsrValue")
    private String obsrValue;
}