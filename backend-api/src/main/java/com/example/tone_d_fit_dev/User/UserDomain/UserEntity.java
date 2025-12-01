package com.example.tone_d_fit_dev.User.UserDomain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.GenericGenerator;

import java.time.OffsetDateTime;
import java.util.Objects;
import java.util.UUID;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "users")
@Getter // 모든 필드에 대한 Getter 자동 생성
@NoArgsConstructor // JPA 사용을 위한 기본 생성자 자동 생성
public class UserEntity {

    // 1. 기본 키 (PK)
    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(name = "user_id", columnDefinition = "uuid")
    private UUID userId;

    // 2. 생성 시간 (불변)
    @Column(name = "created_at", nullable = false, updatable = false) // updatable = false: 이 필드는 INSERT 후에 변경되지 않음을 명시
    private OffsetDateTime createdAt;

    // 3. 최근 로그인 시간 (변경 가능)
    @Setter // 이 필드만 Setter를 명시적으로 허용
    @Column(name = "last_login_at", nullable = false)
    private OffsetDateTime lastLoginAt;

    // 4. 닉네임 (비즈니스 메서드를 통해 변경)
    @Column(name = "nickname", length = 15, nullable = false)
    private String nickname;

    // 5. 사용자 역할 (변경 가능)
    @Setter // 이 필드만 Setter를 명시적으로 허용
    @Column(name = "role", length = 20, nullable = false)
    private String role;

    // ------------------------------------------------------------------
    // 핵심 수정: 서비스 계층에서 호출하는 객체 생성 전용 생성자
    // ------------------------------------------------------------------
    /**
     * Service 계층에서 사용할 객체 생성 생성자.
     * Service 계층이 닉네임을 결정(익명 이름 포함)하여 전달하므로,
     * 여기서 null 체크는 하지 않습니다.
     */
    public UserEntity(String nickname) {
        // Service에서 결정된 닉네임을 할당
        this.nickname = nickname;

        // 필수 값 초기화 (DB DEFAULT 대신 Java에서 초기화)
        this.createdAt = OffsetDateTime.now();
        this.lastLoginAt = OffsetDateTime.now();
        this.role = "USER"; // 기본 역할 설정
    }

    // ------------------------------------------------------------------
    // 비즈니스 로직 메서드 (Update 시 사용)
    // ------------------------------------------------------------------
    /**
     * 닉네임을 변경하는 비즈니스 메서드. (Update 시 사용)
     */
    public void updateNickname(String newNickname) {
        // *업데이트 시*: 닉네임은 필수이며, 엄격하게 검사해야 합니다.
        Objects.requireNonNull(newNickname, "Nickname cannot be null");

        if (newNickname.length() > 15) {
            throw new IllegalArgumentException("Nickname is too long.");
        }

        this.nickname = newNickname;
    }
}