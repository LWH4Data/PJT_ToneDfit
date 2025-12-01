package com.example.tone_d_fit_dev.ApiTestOnly.Domain;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor; // 기본 생성자
import lombok.AllArgsConstructor; // 전체 필드 생성자

@Entity // 1. JPA 엔티티임을 선언 (Hibernate 관리 대상)
@Table(name = "test_table") // 2. 실제 DB 테이블 이름 명시
@Getter // Lombok: 모든 필드의 Getter 자동 생성
@Setter // Lombok: 모든 필드의 Setter 자동 생성
@NoArgsConstructor // Lombok: 기본 생성자 (JPA 필수)
@AllArgsConstructor // Lombok: 모든 필드를 인자로 받는 생성자
public class TestEntity {

    @Id // 3. 이 필드가 테이블의 기본 키(Primary Key)임을 선언
    @GeneratedValue(strategy = GenerationType.IDENTITY) // 4. ID 자동 증가 전략 (SERIAL에 대응)
    private Long id; // DB의 SERIAL은 자바의 Long 타입으로 매핑하는 것이 일반적입니다.

    // 5. 테이블의 content 컬럼에 매핑됩니다. (컬럼 이름 생략 시 필드명과 동일)
    private String content;
}