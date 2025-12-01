package com.example.tone_d_fit_dev.Security.SecurityConfig;

import com.example.tone_d_fit_dev.Security.Jwt.JwtAuthenticationFilter;
import com.example.tone_d_fit_dev.Security.Jwt.JwtTokenProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

/**
 * Spring Security의 메인 설정 클래스입니다.
 * 보안 필터 체인(SecurityFilterChain)을 정의하고, 전역 보안 정책을 설정합니다.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // 1. 주입받을 필드 선언
    private final CorsConfigurationSource corsConfigurationSource;
    private final AdminPropertiesConfig adminProperties;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider; // 앞에서 만든 Provider 객체
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    // 2. 생성자를 통한 의존성 주입
    public SecurityConfig(
            CorsConfigurationSource corsConfigurationSource,
            AdminPropertiesConfig adminProperties,
            PasswordEncoder passwordEncoder,
            JwtTokenProvider jwtTokenProvider,
            JwtAuthenticationFilter jwtAuthenticationFilter
    ) {
        // Spring이 Bean을 자동으로 찾아서 주입합니다.
        this.adminProperties = adminProperties;
        this.passwordEncoder = passwordEncoder;
        this.corsConfigurationSource = corsConfigurationSource;
        this.jwtTokenProvider = jwtTokenProvider;
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    /**
     * 3. UserDetailsService Bean 정의: Properties 객체의 값을 사용
     */
    @Bean
    public UserDetailsService userDetailsService() {

        // 4. 주입받은 adminProperties 객체의 Getter 메서드를 사용하여 값에 접근합니다.
        UserDetails adminUser = User.builder()
                .username(adminProperties.getUsername()) // adminProperties에서 username 가져오기
                .password(passwordEncoder.encode(adminProperties.getPassword())) // adminProperties에서 password 가져오기
                .roles("ADMIN")
                .build();

        // 메모리 사용자 정보 등록
        return new InMemoryUserDetailsManager(adminUser);
    }

    /**
     * 중앙 보안 필터 체인을 정의하는 빈입니다.
     * 모든 HTTP 요청은 이 체인을 통과합니다.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                // 모바일 환경에서 cors 정책을 불필요하나, 테스트 용이성을 위해서 모든 web 접근에 대해서 허용
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
                // REST API 환경 설정 (CSRF 비활성화, Stateless 세션)
                // 모바일 환경 및 JWT 사용 시, CSRF 보호는 불필요하므로 비활성화합니다.
                .csrf(csrf -> csrf.disable())

                // 세션을 사용하지 않고 JWT 기반의 무상태(Stateless) 정책을 설정합니다.
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // HTTP 요청에 대한 인가(Authorization) 규칙 정의
                .authorizeHttpRequests(authorize -> authorize

//                        .requestMatchers(HttpMethod.POST, "/actuator/shutdown").hasRole("ADMIN")
//                        // Actuator 및 공개 API 경로는 인증 없이 모두 허용 (Health Check, 로그인 등)
//                        .requestMatchers("/actuator/**").permitAll()

                        .requestMatchers(
                                "/v3/api-docs/**",     // API 문서 JSON/YAML
                                "/swagger-ui/**",      // Swagger-UI HTML/JS/CSS 파일
                                "/swagger-ui.html",    // Swagger 2의 기본 HTML
                                "/webjars/**"          // 스웨거 리소스를 위한 webjars 경로
                        ).permitAll()

                        // 개발 중 테스트 편의를 위해 일단 모든 요청을 인증 없이 허용합니다.
                        .anyRequest().permitAll()
                        // 💡 JWT 필터 구현 후, .authenticated()로 변경 예정
//                      .anyRequest().authenticated() // ✅ 모든 요청에 대해 인증(Authentication)을 요구합니다.
                );

        // 3. (추후 JWT 필터 등록 위치)
//        .addFilterBefore(
//                // JwtAuthenticationFilter 객체를 주입
//                jwtAuthenticationFilter,
//                // 이 필터보다 먼저 실행되도록 지정
//                UsernamePasswordAuthenticationFilter.class
//        );

        return http.build();
    }
}
