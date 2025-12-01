package com.example.tone_d_fit_dev.Security.Jwt;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    public static final String AUTHORIZATION_HEADER = "Authorization";
    public static final String BEARER_PREFIX = "Bearer ";

    private final JwtTokenProvider jwtTokenProvider; // 토큰 검증 도구 주입

    /**
     * 모든 HTTP 요청이 이 필터를 통과하며, 토큰을 검증하고 사용자 정보를 SecurityContext에 저장합니다.
     */
    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        // 1. Request Header에서 Access Token 문자열 추출
        String jwt = resolveToken(request);

        // 2. TokenProvider로 유효성 검증 (서명, 만료 시간 확인)
        if (StringUtils.hasText(jwt) && jwtTokenProvider.validateToken(jwt)) {

            // 3. 토큰이 유효하면 Authentication 객체 생성
            Authentication authentication = jwtTokenProvider.getAuthentication(jwt);

            // 4. SecurityContext에 Authentication 객체 저장
            // 이로써 현재 요청은 Spring Security에 의해 '인증된 상태'가 됩니다.
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        // 5. 다음 필터로 요청 전달
        filterChain.doFilter(request, response);
    }

    /**
     * Request Header에서 "Bearer 토큰" 형태의 Access Token을 추출하는 헬퍼 메서드
     */
    private String resolveToken(HttpServletRequest request) {
        // "Authorization" 헤더 값을 가져옴 (예: "Bearer eyJhbG...")
        String bearerToken = request.getHeader(AUTHORIZATION_HEADER);

        // 헤더 값이 존재하고 "Bearer "로 시작하는지 확인
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith(BEARER_PREFIX)) {
            // "Bearer " (7글자)를 제외한 순수 토큰 문자열만 반환
            return bearerToken.substring(BEARER_PREFIX.length());
        }
        return null;
    }
}