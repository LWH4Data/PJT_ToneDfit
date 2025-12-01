package com.example.tone_d_fit_dev.Auth.AuthDomain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Comment;

import java.time.Instant;
import java.util.UUID;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA 사용 시 기본 생성자 필수
@Entity
@Table(name = "refresh_tokens") // DDL에서 정의한 테이블 이름
public class RefreshTokenEntity {

    /**
     * user_id: 토큰 소유자 ID (Primary Key & Foreign Key)
     * UUID 타입으로 선언하여 PostgreSQL의 UUID 컬럼과 매핑
     */
    @Id
    @Column(name = "user_id", nullable = false)
    @Comment("토큰 소유자의 고유 ID (UUID) 및 기본 키")
    private UUID userId;

    /**
     * token_value: 발급된 리프레시 토큰 문자열
     */
    @Column(name = "token_value", length = 512, unique = true, nullable = false)
    @Comment("발급된 리프레시 토큰의 문자열 값")
    private String tokenValue;

    /**
     * expiration: 토큰의 만료 시점 (PostgreSQL의 TIMESTAMP WITHOUT TIME ZONE에 매핑)
     * Java 8+에서 날짜/시간 처리를 위해 Instant를 사용합니다.
     */
    @Column(name = "expiration", nullable = false)
    @Comment("토큰의 만료 시점")
    private Instant expiration;

    /**
     * created_at: 토큰 발급 시각
     */
    @Column(name = "created_at", nullable = false)
    @Comment("토큰이 처음 발급된 시각")
    private Instant createdAt;


    // --- Builder 및 생성자 ---
    @Builder
    public RefreshTokenEntity(UUID userId, String tokenValue, Instant expiration) {
        this.userId = userId;
        this.tokenValue = tokenValue;
        this.expiration = expiration;
        this.createdAt = Instant.now(); // 생성 시점은 엔티티 생성 시 결정
    }

    /**
     * 토큰 값만 갱신하는 메소드 (Refresh Token Rotation 또는 재발급 시 사용)
     */
    public void updateToken(String newTokenValue, Instant newExpiration) {
        this.tokenValue = newTokenValue;
        this.expiration = newExpiration;
    }
}