package com.example.tone_d_fit_dev.Auth.AuthDto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter // Getter 제공
@NoArgsConstructor // 기본 생성자 (JSON 역직렬화 등에 필요)
@AllArgsConstructor // 모든 필드를 인자로 받는 생성자
public class TokenIssueResponseDto {

    //    기본적인 토큰 응답에 대해서는 id 가 노출될 필요가 없음.
    //    private String userId;
    private String accessToken;
    private String refreshToken;

    // 필드를 final로 선언하여 생성 시점 이후의 값 변경을 방지합니다.
}