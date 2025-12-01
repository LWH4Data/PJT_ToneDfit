package com.example.tone_d_fit_dev.Auth.AuthDto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;
import jakarta.validation.constraints.NotNull; // Jakarta EE/Spring Boot 3.x 환경 기준

/**
 * 최초 토큰 발급 시 클라이언트로부터 UUID를 전달받기 위한 Request DTO.
 * 요청 예시: {"userId": "a1b2c3d4-e5f6-7890-a1b2-c3d4e5f67890"}
 */
@Getter // 필드 값 조회를 위한 Getter 제공
@NoArgsConstructor // JSON 역직렬화(Deserialization)를 위한 기본 생성자
@AllArgsConstructor // 모든 필드를 인자로 받는 생성자
public class TokenIssueRequestDto {

    @NotNull(message = "사용자 ID(UUID)는 필수입니다.")
    private UUID userId;

    // Lombok이 @Getter와 모든 생성자를 자동으로 생성하며,
    // 불필요한 Setter는 포함하지 않아 불변성을 지향합니다.
}