package com.example.tone_d_fit_dev.User.UserDto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.UUID;

/**
 * 닉네임 수정 요청 (PATCH) 시 클라이언트로부터 받을 데이터를 정의합니다.
 */
@Getter
@Setter
@NoArgsConstructor
public class UserUpdateNicknameRequestDto {

    @NotNull(message = "User ID is required for update") // ID 필드 추가 및 NotNull 검사
    private UUID userId;

    // 닉네임은 수정 시 필수값이므로 @NotBlank를 사용하고 길이 제한을 둡니다.
    @NotBlank(message = "Nickname is required")
    @Size(max = 15, message = "Nickname cannot exceed 15 characters")
    private String nickname;
}
