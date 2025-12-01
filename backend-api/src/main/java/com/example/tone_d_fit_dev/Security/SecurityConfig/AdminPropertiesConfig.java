package com.example.tone_d_fit_dev.Security.SecurityConfig;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * application.yml (security.admin.*)에서 관리자 Basic Auth 계정 정보를 주입받는 클래스입니다.
 * 이 정보를 UserDetailsService 빈을 생성할 때 사용합니다.
 * Lombok의 @Getter/@Setter를 사용하여 코드를 간결하게 유지합니다.
 */
@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "security.admin")
public class AdminPropertiesConfig {

    // YML의 security.admin.username 값이 주입됩니다.
    private String username;

    // YML의 security.admin.password 값이 주입됩니다.
    private String password;
}