package com.example.tone_d_fit_dev.ApiTestOnly.Controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/test")
public class LogTestController {

    // Logger 인스턴스 생성
    private static final Logger log = LoggerFactory.getLogger(LogTestController.class);

    @GetMapping("/log-error")
    public String testErrorLogging() {
        // 1. 단순 ERROR 메시지 기록
        log.error(">>> [TEST LOG] 로그백 설정 테스트를 위한 강제 ERROR 메시지입니다.");

        // 2. 스택 트레이스를 포함한 ERROR 메시지 기록 (더 확실한 테스트)
        try {
            int result = 10 / 0; // 고의적인 ArithmeticException 발생
        } catch (Exception e) {
            log.error(">>> [TEST LOG] 고의적인 예외 발생! 상세 스택 트레이스 확인", e);
        }

        return "Error logs have been generated. Check ./logs/error.log file.";
    }
}