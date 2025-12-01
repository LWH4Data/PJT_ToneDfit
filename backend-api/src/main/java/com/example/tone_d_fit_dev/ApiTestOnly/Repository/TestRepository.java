package com.example.tone_d_fit_dev.ApiTestOnly.Repository;

import com.example.tone_d_fit_dev.ApiTestOnly.Domain.TestEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository // Spring에게 이 인터페이스가 데이터 접근 계층(Repository)임을 알려줍니다.
public interface TestRepository extends JpaRepository<TestEntity, Long> {
    // JpaRepository를 상속받는 것으로 끝납니다.
    // Spring Data JPA가 자동으로 다음 메서드의 구현체를 제공합니다:
    // - save(entity): 데이터 저장 및 업데이트
    // - findById(id): ID로 단일 데이터 조회
    // - findAll(): 모든 데이터 조회
    // - delete(entity): 데이터 삭제

    // 만약 content를 찾는 메서드가 필요하다면, 여기에 선언만 하면 됩니다.
    // List<TestEntity> findByContent(String content);
}