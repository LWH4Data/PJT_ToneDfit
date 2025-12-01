package com.example.tone_d_fit_dev.Auth.AuthService;

import com.example.tone_d_fit_dev.Auth.AuthDomain.RefreshTokenEntity;
import com.example.tone_d_fit_dev.Auth.AuthDto.TokenIssueResponseDto; // 수정된 DTO
import com.example.tone_d_fit_dev.Auth.AuthRepository.RefreshTokenRepository; // 가정한 Repository
import com.example.tone_d_fit_dev.User.UserRepository.UserRepository; // 가정한 Repository
import com.example.tone_d_fit_dev.Security.Jwt.JwtTokenProvider; // 구현된 Provider

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.Collection;
import java.util.UUID;

@Service
public class AuthService {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository; // UUID 존재 여부 및 역할 확인용
    private final RefreshTokenRepository refreshTokenRepository;
    private final long refreshTokenExpirationSeconds;
    private static final String ROLE_PREFIX = "ROLE_"; // security 에서 사용자의 역할을 판단하도록 하기 위한 필수 접두사

    public AuthService(
            JwtTokenProvider jwtTokenProvider,
            UserRepository userRepository,
            RefreshTokenRepository refreshTokenRepository,

            @Value("${time.hour}") long timeHour,
            @Value("${time.day}") long timeDay,
            @Value("${time.multiplier}") long timeMultiplier
    ) {
        // DI 필드 주입
        this.jwtTokenProvider = jwtTokenProvider;
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;

        // @Value 필드 주입
        this.refreshTokenExpirationSeconds = timeDay * timeMultiplier;
    }

    /**
     * 1. 🥇 생성된 UUID를 받아 토큰 쌍 발급 (메서드명 변경 권장: register -> issue)
     * * @param userUuid 이미 UserService에서 생성 및 DB에 저장된 사용자의 UUID
     */
    public TokenIssueResponseDto issueInitialTokens(UUID userId) {

        String userRole = userRepository.findRoleByUserId(userId)
                .orElseThrow(() -> new RuntimeException("DB에 사용자 정보가 없습니다."));

        // 1. 권한 부여 (이전 로직 동일)
        Collection<GrantedAuthority> authorities =
                Arrays.asList(new SimpleGrantedAuthority(ROLE_PREFIX + userRole));

        Authentication authentication = new UsernamePasswordAuthenticationToken(
                userId,
                "",
                authorities
        );

        // 2. 토큰 쌍 생성 (이전 로직 동일)
        String accessToken = jwtTokenProvider.createAccessToken(authentication);
        String refreshToken = jwtTokenProvider.createRefreshToken(authentication);

        // -------------------------------------------------------------------------
        // 3. 💾 Refresh Token DB 저장을 위한 Entity 생성 (수정된 부분)

        // Refresh Token의 만료 시점 계산
        Instant expiration = Instant.now().plus(refreshTokenExpirationSeconds, ChronoUnit.SECONDS);

        // RefreshTokenEntity 객체 생성 (@Builder 사용 가정)
        RefreshTokenEntity refreshTokenEntity = RefreshTokenEntity.builder()
                .userId(userId)
                .tokenValue(refreshToken)
                .expiration(expiration)
                .build();

        // 4. 🚀 JpaRepository.save(Entity) 호출
        // RefreshTokenEntity 객체 하나만 인수로 전달하여 저장
        refreshTokenRepository.save(refreshTokenEntity);

//        String userIdString = userId.toString();

        // 5. 클라이언트에 전달할 DTO 반환 (이전 로직 동일)
        return new TokenIssueResponseDto(accessToken, refreshToken);
    }

    //---------------------------------------------------------------------

    /**
     * 2. 🔄 유효한 Refresh Token을 사용하여 Access Token을 재발급 (POST /refresh)
     * -> Refresh Token Rotation (RTR) 적용
     */
    public TokenIssueResponseDto reissueAccessToken(String clientRefreshToken) {

        // 1. 🛑 1차 검증 및 Authentication 객체 추출 (이전 로직 동일)
        if (!jwtTokenProvider.validateToken(clientRefreshToken)) {
            throw new RuntimeException("Refresh Token이 유효하지 않거나 만료되었습니다.");
        }
        Authentication authentication = jwtTokenProvider.getAuthentication(clientRefreshToken);
//        String userIdString = authentication.getName();
        UUID userId = UUID.fromString(authentication.getName());

        // 2. 💾 DB에서 RefreshTokenEntity 조회 (이전 로직 동일)
        RefreshTokenEntity storedEntity = refreshTokenRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("DB에 토큰 정보가 없습니다. 재로그인 필요."));

        // 3. ⏰ 만료 시점 검증 및 🚨 토큰 값 일치 여부 검증 (탈취 방지 로직)
        if (storedEntity.getExpiration().isBefore(Instant.now())) {
            refreshTokenRepository.deleteById(userId);
            throw new RuntimeException("Refresh Token이 DB에 저장된 만료 시점을 지났습니다. 재로그인 필요.");
        }

        // 💡 [RTR 핵심] 제출된 토큰이 DB의 토큰과 일치하는지 확인 (탈취 여부 확인)
        if (!clientRefreshToken.equals(storedEntity.getTokenValue())) {
            // 탈취 의심 시, 기존 토큰과 관련된 모든 세션 무효화
            refreshTokenRepository.deleteById(userId);
            throw new RuntimeException("Refresh Token이 일치하지 않습니다. 보안 위험!");
        }

        // -------------------------------------------------------------------------
        // 4. 🔄 새 토큰 쌍 생성 및 DB 갱신 (RTR 구현)
        // -------------------------------------------------------------------------

        // 4-1. 새 Access Token 생성
        String newAccessToken = jwtTokenProvider.createAccessToken(authentication);

        // 4-2. 새 Refresh Token 생성
        String newRefreshToken = jwtTokenProvider.createRefreshToken(authentication);

        // 4-3. 새 Refresh Token 만료 시점 계산
        Instant newExpiration = Instant.now().plus(refreshTokenExpirationSeconds, ChronoUnit.SECONDS);

        // 4-4. 💾 DB 업데이트: 기존 엔티티의 토큰 값과 만료 시점 갱신
        storedEntity.updateToken(newRefreshToken, newExpiration);
        refreshTokenRepository.save(storedEntity); // dirty checking 또는 명시적 save

        // 5. 응답: 새 Access Token과 새 Refresh Token을 반환
        return new TokenIssueResponseDto(newAccessToken, newRefreshToken);
    }
}