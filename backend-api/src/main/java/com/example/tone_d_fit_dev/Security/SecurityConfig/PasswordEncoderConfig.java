package com.example.tone_d_fit_dev.Security.SecurityConfig;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration // 이 클래스를 설정 파일로 등록
public class PasswordEncoderConfig {

    /**
     * BCryptPasswordEncoder 객체를 생성하고 Bean으로 등록합니다.
     * Spring Security가 인증 과정에서 이 Bean을 자동으로 찾아 사용합니다.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        // BCryptPasswordEncoder는 강력한 단방향 해시 함수로,
        // 비밀번호 보안을 위해 가장 널리 권장됩니다.
        return new BCryptPasswordEncoder();
    }
}