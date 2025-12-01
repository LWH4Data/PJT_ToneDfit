package com.example.tone_d_fit_dev.User.UserDto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.example.tone_d_fit_dev.User.UserDomain.UserEntity;
import lombok.Getter;
import lombok.Setter;
import lombok.AllArgsConstructor;

@Getter
@Setter
@AllArgsConstructor // 엔티티에서 변환 시 생성자를 쉽게 사용하기 위해 추가
public class UserInfoResponseDto {

    private UUID userId;
    private String nickname;
    private String role;
    private OffsetDateTime createdAt;
    private OffsetDateTime lastLoginAt;

    // 이메일이나 비밀번호 같은 민감한 정보는 여기에 포함하지 않습니다.

    // 엔티티를 Response DTO로 변환하는 정적 팩토리 메서드 (선택 사항)
    public static UserInfoResponseDto fromEntity(UserEntity user) {
        return new UserInfoResponseDto(
                user.getUserId(),
                user.getNickname(),
                user.getRole(),
                user.getCreatedAt(),
                user.getLastLoginAt()
        );
    }
}