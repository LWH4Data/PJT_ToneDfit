package com.example.tone_d_fit_dev.User.UserDto;

import com.example.tone_d_fit_dev.User.UserDomain.UserEntity;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
public class UserUpdateNicknameResponseDto {

    private UUID userId;
    private String nickname;

    // 엔티티를 DTO로 변환하는 정적 팩토리 메서드 (권장)
    public static UserUpdateNicknameResponseDto fromEntity(UserEntity user) {
        return new UserUpdateNicknameResponseDto(
                user.getUserId(),
                user.getNickname()
        );
    }
}