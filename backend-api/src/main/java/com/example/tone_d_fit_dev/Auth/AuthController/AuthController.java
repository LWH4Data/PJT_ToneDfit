package com.example.tone_d_fit_dev.Auth.AuthController;

import com.example.tone_d_fit_dev.Auth.AuthDto.TokenIssueRequestDto;
import com.example.tone_d_fit_dev.Auth.AuthDto.TokenIssueResponseDto;
import com.example.tone_d_fit_dev.Auth.AuthService.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    // 💡 UserRepository는 UserService에서 사용되므로 여기서는 주입하지 않습니다.

    /**
     * 1. 🥇 최초 신원 등록 후 토큰 발급 API (POST /api/auth/issue/initial)
     * * 클라이언트가 UserService에서 발급받은 UUID를 제출하면,
     * 이 UUID를 기반으로 Access/Refresh Token 쌍을 발급합니다.
     * * @param userId UUID (클라이언트나 UserService에서 생성된)
     * @return TokenResponseDto (액세스 토큰, 리프레시 토큰)
     */
    @PostMapping("/issue/initial")
    public ResponseEntity<TokenIssueResponseDto> issueInitialTokens(@RequestBody TokenIssueRequestDto request) {

        UUID userId = request.getUserId(); // Record의 접근자(Getter) 사용

        TokenIssueResponseDto response = authService.issueInitialTokens(userId);

        return ResponseEntity.ok(response);
    }

    //---------------------------------------------------------------------

    /**
     * 2. 🔄 Refresh Token을 사용하여 Access Token을 재발급하는 API (POST /api/auth/refresh)
     * * 클라이언트가 만료된 Access Token 대신 Refresh Token을 제출합니다.
     * * @param refreshToken DTO 없이 요청 본문에 직접 문자열로 Refresh Token을 받습니다.
     * @return TokenResponseDto (새 Access Token, 새 Refresh Token)
     */
    @PostMapping("/refresh")
    public ResponseEntity<TokenIssueResponseDto> reissueTokens(@RequestBody String refreshToken) {

        // AuthService를 호출하여 RTR(Refresh Token Rotation) 로직 실행
        TokenIssueResponseDto response = authService.reissueAccessToken(refreshToken);

        return ResponseEntity.ok(response);
    }

    //---------------------------------------------------------------------

    // 💡 로그아웃/세션 폐기 API (선택 사항)
    /*
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestHeader("Authorization") String accessToken) {
        // ... 토큰을 파싱하여 UUID를 얻고, AuthService를 통해 DB에서 Refresh Token을 삭제하는 로직 구현 ...
        return ResponseEntity.ok().build();
    }
    */
}