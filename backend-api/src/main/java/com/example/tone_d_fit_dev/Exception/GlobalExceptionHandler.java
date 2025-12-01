package com.example.tone_d_fit_dev.Exception;

import com.example.tone_d_fit_dev.Exception.ExceptionDto.GlobalErrorResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.List;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * @Valid 또는 @Validated 유효성 검사 실패 시 발생하는 예외 처리 (400 Bad Request)
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<GlobalErrorResponseDto> handleValidationException(MethodArgumentNotValidException e) {
        HttpStatus status = HttpStatus.BAD_REQUEST;

        // 모든 필드의 오류 메시지를 취합하여 사용자에게 보여줍니다.
        List<String> errorMessages = e.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.toList());

        String message = "유효성 검사 실패: " + String.join(", ", errorMessages);

        return ResponseEntity
                .status(status)
                .body(GlobalErrorResponseDto.of(status, message));
    }

    /**
     * 서비스 레이어 등에서 발생하는 잘못된 인자 관련 예외 처리 (400 Bad Request)
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<GlobalErrorResponseDto> handleIllegalArgumentException(IllegalArgumentException e) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        return ResponseEntity
                .status(status)
                .body(GlobalErrorResponseDto.of(status, e.getMessage()));
    }

    // --- 추가적으로 CustomException이 있다면 여기에 핸들러를 추가합니다 ---
    // 예: @ExceptionHandler(ResourceNotFoundException.class)
    // public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException e) { ... }

    /**
     * 정의되지 않은 모든 예외 처리 (500 Internal Server Error)
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<GlobalErrorResponseDto> handleAllUncaughtException(Exception e) {
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        // 실제 운영 환경에서는 상세한 에러 메시지(e.getMessage())를 클라이언트에게 직접 노출하지 않는 것이 보안상 좋습니다.
        return ResponseEntity
                .status(status)
                .body(GlobalErrorResponseDto.of(status, "서버에서 예상치 못한 오류가 발생했습니다."));
    }
}