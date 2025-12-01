package com.example.tone_d_fit_dev.Security.Jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.stream.Collectors;

@Component
public class JwtTokenProvider {

    private final Key secretKey;
    private final String authoritiesKey;
    private final long accessTokenExpirationInMilliseconds;
    private final long refreshTokenExpirationInMilliseconds;


    // 1. 설정 값을 주입받아 Key 객체와 밀리초 단위 유효 시간을 초기화합니다.
    public JwtTokenProvider(
            // 1. JWT 기본 설정 주입
            @Value("${jwt.secret-key}") String secretKey,
            @Value("${jwt.authorities-key}") String authoritiesKey,

            // 2. 💡 시간 단위 상수 주입
            @Value("${time.hour}") long timeHour,
            @Value("${time.day}") long timeDay,
            @Value("${time.multiplier}") long timeMultiplier
            //  @Value("${jwt.access-token-expiration-seconds}") long accessTokenExpirationInSeconds,
            //  @Value("${jwt.refresh-token-expiration-seconds}") long refreshTokenExpirationInSeconds
    ) {
        // Secret Key를 Base64 Decode 후 Key 객체로 변환
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
        this.authoritiesKey = authoritiesKey;

        // 초 단위를 밀리초로 변환하여 저장
        this.accessTokenExpirationInMilliseconds = timeHour * timeMultiplier * 1000;
        this.refreshTokenExpirationInMilliseconds = timeDay * timeMultiplier * 1000;
    }

    // --- Access Token 생성 ---
    public String createAccessToken(Authentication authentication) {
        return createToken(authentication, this.accessTokenExpirationInMilliseconds);
    }

    // --- Refresh Token 생성 ---
    // Refresh Token은 주로 권한 정보 대신 사용자 식별자만 포함할 수 있습니다.
    public String createRefreshToken(Authentication authentication) {
        // 리프레시 토큰은 만료 시간만 다르고, 생성 로직은 동일하게 가져가도 무방합니다.
        return createToken(authentication, this.refreshTokenExpirationInMilliseconds);
    }

    // --- 실제 토큰 생성 로직 ---
    private String createToken(Authentication authentication, long tokenExpiration) {
        String authorities = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining(","));

        long now = (new Date()).getTime();
        Date expiration = new Date(now + tokenExpiration); // 밀리초 단위 유효 시간 적용

        return Jwts.builder()
                .setSubject(authentication.getName())
                .claim(authoritiesKey, authorities)
                .signWith(secretKey, SignatureAlgorithm.HS512) // HS512가 구체적으로 무엇인지?
                .setExpiration(expiration)
                .compact();
    }

    // --- 토큰에서 인증 정보(Authentication) 획득 ---
    public Authentication getAuthentication(String token) {
        // 1. 토큰에서 Claim 정보 파싱 (서명 검증 포함)
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

        // 2. Claim에서 권한 정보 추출
        Collection<? extends GrantedAuthority> authorities =
                Arrays.stream(claims.get(authoritiesKey).toString().split(","))
                        .map(SimpleGrantedAuthority::new)
                        .collect(Collectors.toList());

        // 3. UserDetails 객체 생성 (사용자 ID와 권한 정보를 담음)
        // Spring Security에서 사용할 principal 객체
        User principal = new User(claims.getSubject(), "", authorities);

        // 4. Authentication 객체 리턴
        return new UsernamePasswordAuthenticationToken(principal, token, authorities);
    }

    // --- 토큰 유효성 검사 ---
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(secretKey).build().parseClaimsJws(token);
            return true;
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            // 잘못된 JWT 서명
        } catch (ExpiredJwtException e) {
            // 만료된 JWT 토큰
        } catch (UnsupportedJwtException e) {
            // 지원되지 않는 JWT 토큰
        } catch (IllegalArgumentException e) {
            // JWT 토큰이 잘못됨
        }
        return false;
    }
}