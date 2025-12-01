package com.example.tone_d_fit_dev.Weather.TempWeatherForecast;

public record TempWeatherForecastResponseDto(

        // Temperature (TMP)
        Double TMP_CUR, // temperature_current
        Double TMP_MAX, // temperature_max
        Double TMP_MIN, // temperature_min
        Double TMP_FEEL, // temperature_feels_like

        // Weather & Precipitation (WTH, PRC)
        String WTH_COND, // weather_condition
        String PRC_TYP, // precipitation_type_code
        Short PRC_CHNC, // precipitation_chance
        Double PRC_AMT, // precipitation_amount

        // Wind & Humidity (WND, HUM)
        Short HUM_CUR, // humidity_current
        Double WND_SPD, // wind_speed

        // Index (IDX)
        Short DUST_IDX, // dust_index
        String DUST_COND,
        Short UV_IDX, // uv_index
        String UV_COND
) {}