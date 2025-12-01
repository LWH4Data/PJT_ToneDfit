package com.example.tone_d_fit_dev.User.UserDto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import jakarta.validation.constraints.Size;

@Getter
@Setter
@NoArgsConstructor
public class UserCreateRequestDto {

    // 닉네임은 선택적으로 입력받습니다. 입력하지 않으면 DB의 DEFAULT 값이 사용됩니다.
    // 입력할 경우 DB의 VARCHAR(15) 제약 조건을 따라 길이를 제한합니다.
    @Size(max = 15, message = "Nickname cannot exceed 15 characters")
    private String nickname;

    // 역할(role)을 명시적으로 설정하고 싶다면 이 필드를 추가합니다.
    // private String role;
}