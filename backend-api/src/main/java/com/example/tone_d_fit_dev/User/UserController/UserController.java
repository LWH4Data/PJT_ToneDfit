package com.example.tone_d_fit_dev.User.UserController;

import com.example.tone_d_fit_dev.User.UserDto.*;
import com.example.tone_d_fit_dev.User.UserService.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.UUID;
import java.util.NoSuchElementException;


/**
 * UserController:
 * 사용자 관련 HTTP 요청을 처리하는 RESTful 컨트롤러입니다.
 */
@RestController
@RequestMapping("/user") // 기본 경로: /api/user
public class UserController {

    private final UserService userService;

    // 의존성 주입 (Constructor Injection)
    public UserController(UserService userService) {
        this.userService = userService;
    }

    // ----------------------------------------------------
    // 1. 사용자 생성 (POST /api/users/create)
    // ----------------------------------------------------
    /**
     * 새로운 사용자 생성 요청을 처리합니다.
     * @param request 요청 본문에서 받은 UserCreateRequest DTO. (@Valid로 유효성 검사)
     * @return 201 Created와 생성된 UserResponse DTO를 반환합니다.
     */
    @PostMapping("/create")
    public ResponseEntity<UserInfoResponseDto> createUser(@RequestBody @Valid UserCreateRequestDto request) {

        // 서비스 호출 및 DTO 반환
        UserInfoResponseDto createdUser = userService.createUser(request);

        // HTTP 201 Created 상태 코드 반환
        return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
    }

    // ----------------------------------------------------
    // 2. 개별 사용자 조회 (POST /api/users/find)
    // ----------------------------------------------------
    /**
     * 특정 ID를 가진 사용자 한 명을 조회합니다.
     * @return 200 OK와 UserResponse DTO 또는 404 Not Found를 반환합니다.
     */
    @PostMapping("/find") // POST 메서드로 변경
    public ResponseEntity<UserInfoResponseDto> getUserById(@RequestBody UserFindRequestDto requestDto) {

        UUID id = requestDto.getUserId(); // 요청 DTO에서 ID 추출

        // findUserById 결과를 Optional에서 추출하고, 없으면 예외 발생
        UserInfoResponseDto user = userService.findUserById(id)
                .orElseThrow(() -> new NoSuchElementException("User not found with ID: " + id));

        return ResponseEntity.ok(user); // HTTP 200 OK 반환
    }

    // ----------------------------------------------------
    // 3. 닉네임 수정 (PATCH /api/users/update-nickname)
    // ----------------------------------------------------
    /**
     * 특정 사용자의 닉네임을 부분 수정(PATCH)합니다.
     * @param request id와 새로운 닉네임을 담은 UserUpdateNicknameRequest DTO. (@Valid로 유효성 검사)
     * @return 200 OK와 수정된 UserResponse DTO를 반환합니다.
     */
    @PatchMapping("/update-nickname")
    public ResponseEntity<UserUpdateNicknameResponseDto> updateNickname(
            @RequestBody @Valid UserUpdateNicknameRequestDto request) {

        // 서비스 계층의 닉네임 수정 로직을 호출합니다.
        UserUpdateNicknameResponseDto updatedUser = userService.updateNickname(request);

        return ResponseEntity.ok(updatedUser); // HTTP 200 OK 반환
    }
}