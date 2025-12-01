package com.example.tone_d_fit_dev.User.UserDto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull; // 필수가 아니지만, ID가 필수임을 명시
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Lombok 애너테이션을 사용하여 Getter, Setter, 기본 생성자를 자동 생성합니다.
@Getter // 모든 필드의 Getter 메소드를 생성
@Setter // 모든 필드의 Setter 메소드를 생성
@NoArgsConstructor // 인자 없는 기본 생성자를 생성
public class UserFindRequestDto {

    // @NotNull: 요청 본문에 'id' 필드가 반드시 포함되어야 함을 명시
    // 'id'는 UUID 타입이므로, @Size는 보통 문자열(String)에 사용되기에 제외합니다.
    @NotNull(message = "User ID는 필수입니다.")
    private UUID userId;
}