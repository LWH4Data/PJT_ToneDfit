package com.example.tone_d_fit_dev.Auth.AuthRepository;

import com.example.tone_d_fit_dev.Auth.AuthDomain.RefreshTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshTokenEntity, UUID> {

    /**
     * user_id를 기반으로 RefreshTokenEntity를 조회합니다.
     * AuthService에서 토큰 재발급 시 사용자의 토큰 존재 여부 및 값을 확인하는 데 사용됩니다.
     * * @param userId 토큰 소유자의 UUID
     * @return 해당 UUID에 해당하는 RefreshTokenEntity (Optional로 반환)
     */
    Optional<RefreshTokenEntity> findById(UUID userId);


    /**
     * 토큰 값(tokenValue)을 기반으로 엔티티를 조회합니다.
     * (선택 사항: 토큰 값 자체가 고유하므로, 역으로 토큰 소유자를 찾는 데 사용될 수 있음)
     * * @param tokenValue 리프레시 토큰 문자열
     * @return 해당 토큰 문자열에 해당하는 RefreshTokenEntity (Optional로 반환)
     */
    Optional<RefreshTokenEntity> findByTokenValue(String tokenValue);

    /**
     * 사용자 ID를 기반으로 해당 토큰 레코드를 삭제합니다.
     * 이는 로그아웃이나 토큰 재발급 시 기존 토큰을 폐기할 때 사용됩니다.
     * * @param userId 토큰 소유자의 UUID
     */
    void deleteById(UUID userId);
}