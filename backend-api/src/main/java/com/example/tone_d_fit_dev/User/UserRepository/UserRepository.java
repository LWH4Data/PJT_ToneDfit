package com.example.tone_d_fit_dev.User.UserRepository;

import com.example.tone_d_fit_dev.User.UserDomain.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * UserRepository:
 * User 엔티티에 대한 데이터베이스 접근(CRUD)을 담당하는 저장소 인터페이스입니다.
 * JpaRepository를 상속받아 기본 CRUD 메서드(save, findById, findAll 등)를 자동으로 제공받습니다.
 * * JpaRepository<엔티티 타입, 기본 키(PK) 타입>
 */
@Repository
public interface UserRepository extends JpaRepository<UserEntity, UUID> {

    // 추가적인 사용자 정의 쿼리 메서드가 필요하면 여기에 선언할 수 있습니다.

    // 💡 UUID를 기반으로 role 필드의 값(String)만 조회
    Optional<String> findRoleByUserId(UUID userId);
}