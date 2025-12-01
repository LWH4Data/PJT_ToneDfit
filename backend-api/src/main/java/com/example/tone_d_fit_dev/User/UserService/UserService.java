package com.example.tone_d_fit_dev.User.UserService;

import com.example.tone_d_fit_dev.User.UserDomain.UserEntity;
import com.example.tone_d_fit_dev.User.UserDto.UserCreateRequestDto;
import com.example.tone_d_fit_dev.User.UserDto.UserInfoResponseDto;
import com.example.tone_d_fit_dev.User.UserDto.UserUpdateNicknameRequestDto;
import com.example.tone_d_fit_dev.User.UserDto.UserUpdateNicknameResponseDto;
import com.example.tone_d_fit_dev.User.UserRepository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * UserService:
 * 닉네임 초기화 로직을 서비스 계층에서 담당하여 엔티티와 DB의 충돌을 해결합니다.
 */
@Service
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    // 익명 닉네임 리스트 정의 (DB의 DEFAULT 대신 Service가 관리)
    private static final List<String> ANONYMOUS_NAMES =
            Arrays.asList("익명의 톤톤", "익명의 디디", "익명의 피트");

    private final Random random = new Random();

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // ----------------------------------------------------
    // 1. 사용자 생성 (POST "/create" 요청 대응)
    // ----------------------------------------------------

    /**
     * DTO를 받아 새로운 사용자를 생성하고 저장합니다.
     * 닉네임이 null인 경우, Service에서 익명 닉네임을 생성하여 주입합니다.
     * @param request 사용자 생성 요청 DTO.
     * @return 생성된 User 엔티티의 Response DTO.
     */
    @Transactional
    public UserInfoResponseDto createUser(UserCreateRequestDto request) {

        String nickname = request.getNickname();

        // 1. 닉네임 검사 및 익명 닉네임 주입 (비즈니스 로직)
        if (nickname == null || nickname.isBlank()) {
            // 닉네임이 없으면, 3가지 익명 닉네임 중 하나를 무작위로 선택하여 할당합니다.
            int randomIndex = random.nextInt(ANONYMOUS_NAMES.size());
            nickname = ANONYMOUS_NAMES.get(randomIndex);
        }

        // 2. 널이 아닌 유효한 닉네임을 사용하여 User 엔티티를 생성합니다. (새로운 생성자 호출)
        UserEntity user = new UserEntity(nickname);

        // 3. DB 저장
        UserEntity createdUser = userRepository.save(user);

        // 4. Entity -> Response DTO 변환 및 반환
        return UserInfoResponseDto.fromEntity(createdUser);
    }

    // ----------------------------------------------------
    // 2. 개별 사용자 조회 (POST "/find" 요청 대응)
    // ----------------------------------------------------

    /**
     * ID로 사용자 한 명을 조회하고 Response DTO로 반환합니다.
     * @param userId 사용자 ID (UUID).
     * @return UserResponse DTO를 포함하는 Optional.
     */
    public Optional<UserInfoResponseDto> findUserById(UUID userId) {
        return userRepository.findById(userId)
                // Optional<User>를 Optional<UserResponse>로 변환
                .map(user -> UserInfoResponseDto.fromEntity(user));
    }

    // ----------------------------------------------------
    // 3. 닉네임 수정 (PUT/PATCH 요청 대응)
    // ----------------------------------------------------

    /**
     * ID를 기준으로 사용자를 찾아 닉네임을 수정합니다.
     * @param id 수정할 사용자의 ID (UUID).
     * @param newNickname 새로 설정할 닉네임.
     * @return 수정된 User 엔티티.
     * @throws NoSuchElementException 해당 ID의 사용자를 찾지 못한 경우 발생.
     */
    // ----------------------------------------------------
    // 3. 닉네임 수정 (PATCH 요청 대응)
    // ----------------------------------------------------

    /**
     * ID를 DTO에서 받아 사용자를 찾아 닉네임을 수정합니다.
     * @param request ID와 새로운 닉네임을 담은 DTO.
     * @return 수정된 User 엔티티의 Response DTO.
     * @throws NoSuchElementException 해당 ID의 사용자를 찾지 못한 경우 발생.
     */
    @Transactional
    public UserUpdateNicknameResponseDto updateNickname(UserUpdateNicknameRequestDto request) {

        // 1. DTO에서 ID 추출 및 사용자 조회
        UserEntity user = userRepository.findById(request.getUserId()) // DTO에서 ID 사용
                .orElseThrow(() -> new NoSuchElementException("User not found with ID: " + request.getUserId()));

        // 2. 엔티티의 비즈니스 메서드를 호출하여 상태를 변경합니다.
        user.updateNickname(request.getNickname());

        // 3. Entity -> Response DTO 변환 및 반환
        return UserUpdateNicknameResponseDto.fromEntity(user);
    }
}