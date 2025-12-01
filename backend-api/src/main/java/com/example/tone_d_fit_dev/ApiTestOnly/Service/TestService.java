package com.example.tone_d_fit_dev.ApiTestOnly.Service;

import com.example.tone_d_fit_dev.ApiTestOnly.Domain.TestEntity;
import com.example.tone_d_fit_dev.ApiTestOnly.Repository.TestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service // 1. Spring에게 이 클래스가 비즈니스 로직을 담당하는 Service임을 알려줍니다.
@Transactional(readOnly = true) // 2. 트랜잭션 관리 설정 (조회 전용)
public class TestService {

    private final TestRepository repository;

    // 3. 생성자 주입 (권장 방식): Repository 객체를 주입받습니다.
    @Autowired
    public TestService(TestRepository repository) {
        this.repository = repository;
    }

    /**
     * ID를 사용하여 TestEntity를 조회합니다.
     * @param id 조회할 데이터의 ID
     * @return 조회된 TestEntity를 담은 Optional 객체
     */
    public TestEntity getContent(Long id) {

        // 4. Repository의 findById 메서드를 호출하여 DB에 접근합니다.
        return repository.findById(id).orElse(null);
    }
}