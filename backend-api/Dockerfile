# --- 1단계: 빌드(Build) 환경 ---
# Spring Boot 3+에 맞춰 Java 17 JDK가 포함된 이미지를 사용합니다.
FROM eclipse-temurin:17-jdk-focal AS builder

# 작업 디렉토리 설정
WORKDIR /app

# 1. Gradle 래퍼 및 빌드 설정 파일 복사
#    (이 파일들이 변경되지 않으면 다음 빌드 시 캐시를 사용합니다)
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle .
COPY settings.gradle .

# 2. 의존성만 먼저 다운로드
#    소스 코드가 변경되어도 의존성이 동일하면 이 레이어는 캐시되어 빌드 속도가 향상됩니다.
#    실행 권한 부여
RUN chmod +x ./gradlew
RUN ./gradlew dependencies --info

# 3. 소스 코드 복사
#    (소스 코드만 변경된 경우, 위 단계들은 캐시로 처리됩니다)
COPY src ./src

# 4. 애플리케이션 빌드 (테스트는 스킵)
RUN ./gradlew build -x test

# --- 2단계: 실행(Runtime) 환경 ---
# JRE(Java Runtime Environment)만 포함된 경량 이미지를 사용하여 최종 이미지 크기를 최소화합니다.
FROM eclipse-temurin:17-jre-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 단계에서 생성된 실행 가능한 JAR 파일만 복사
# 'build/libs/' 디렉토리의 모든 .jar 파일을 대상으로 하므로 파일 이름이 변경되어도 유연하게 대처합니다.
COPY --from=builder /app/build/libs/*.jar app.jar

# 애플리케이션이 수신 대기할 포트 (기본 8080)
EXPOSE 8080

# 컨테이너 시작 시 애플리케이션 실행
# 'java -jar app.jar'와 동일
ENTRYPOINT ["java", "-jar", "app.jar"]