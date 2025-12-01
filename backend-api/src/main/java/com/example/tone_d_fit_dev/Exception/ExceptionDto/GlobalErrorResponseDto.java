package com.example.tone_d_fit_dev.Exception.ExceptionDto;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@Builder
// 💡 컴파일 오류 해결 핵심: 빌더가 사용하는 전체 필드 생성자의 접근 제어자를 private으로 지정
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class GlobalErrorResponseDto {
    private final int status;       // HTTP 상태 코드
    private final String error;     // HTTP 상태 코드 이름
    private final String message;   // 사용자에게 보여줄 상세 메시지
    private final String code;      // (선택 사항) 내부 오류 코드

    public static GlobalErrorResponseDto of(HttpStatus status, String message) {
        return GlobalErrorResponseDto.builder()
                .status(status.value())
                .error(status.getReasonPhrase())
                .message(message)
                .build();
    }
}