package com.example.tone_d_fit_dev.Config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
public class CorsConfig {

    /**
     * 모든 요청에 대해 모든 출처, 모든 메서드를 허용하는 CORS 설정 소스 Bean 정의
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // **모든 출처(*), 모든 메서드(*), 모든 헤더(*) 허용** (테스트 목적)
        // 출처, 도메인, origin
        configuration.setAllowedOrigins(Arrays.asList("*"));
        // 메소드, method
        configuration.setAllowedMethods(Arrays.asList("*"));
        // 헤더, header
        configuration.setAllowedHeaders(Arrays.asList("*"));

        // AllowedOrigins가 '*'이므로 false로 설정
        configuration.setAllowCredentials(false);
        configuration.setMaxAge(3600L); // Pre-flight 요청 캐시 시간

        // 모든 경로(/**)에 대해 CORS 설정 적용
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }
}