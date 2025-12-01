import json
import os
from datetime import date, datetime
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from kafka_module import KafkaProducer, KafkaConsumer
import crawling as crawl
import s3_module as s3


service = Service()
options = webdriver.ChromeOptions()
options.add_argument("--headless") # 브라우저 UI 없이 백그라운드에서 동작하게 함
options.add_argument("--window-size=1920,1080")  # 브라우저 창 크기 설정
options.add_argument("--no-sandbox")  # 보안 기능을 비활성화하여 브라우저가 더 많은 권한을 가지게 함
options.add_argument("--disable-dev-shm-usage")  # 메모리 공유를 비활성화하여 메모리 부족 문제를 방지함
options.add_argument("--ignore-certificate-errors")  # SSL 인증서 오류를 무시
# options.add_argument("--disable-gpu") # GPU 하드웨어 가속을 비활성화
options.add_argument("--incognito") # 시크릿 모드로 브라우저 실행
driver = webdriver.Chrome(service=service, options=options)
driver.set_page_load_timeout(10)
driver.set_script_timeout(10)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TODAY = date.today()


if __name__ == "__main__":
    topic = "test" # "crawl.product.raw.v1"

    # PID 크롤링
    pids = crawl.get_new_pid_category(driver)

    # 임시 (test)
    file_name = f"{BASE_DIR}/twentyninecm/data/test_product_list_{TODAY}.json"
    with open(file_name, "w", encoding="utf-8") as f:
        json.dump(pids, f, ensure_ascii=False, indent=2)

    print(f" → PID 총 {len(pids)}개 추출, {file_name} 저장 완료")

    # # 데이터 추출 및 생산
    # data = crawl.extract_data_from_pid(driver, kafka_produce=True)
    # print(f" → 데이터 {len(data)}개 추출 완료")

    # 크롬 드라이버 종료
    driver.quit()

    # file_name = f"{BASE_DIR}/twentyninecm/data/2025-10-29/raw_data/29cm_data_01.json"
    # with open(file_name, "r", encoding="utf-8") as f:
    #     products = json.load(f)

    # producer = KafkaProducer()
    # for divide in products:
    #     producer.produce(topic, json.dumps(divide, ensure_ascii=False).encode("utf-8"))
    # producer.flush()

    # print(f"[{datetime.now()}] Complete!", flush=True)
    
    # # 데이터 소모
    # print(f"[{datetime.now()}] Data Consuming...", flush=True)
    # consumer = KafkaConsumer(topic)
    # consumer.subscribe(topic)

    # data = consumer.poll(all=True)
    # print(f"[{datetime.now()}] Complete!", flush=True)
    # consumer.close()

    # # 테스트
    # with open(f"{BASE_DIR}/raw_data.json", "w", encoding="utf-8") as f:
    #     json.dump(data, f, ensure_ascii=False, indent=2)
    
    # # 데이터 S3 업로드
    # print(f"[{datetime.now()}] Data Uploading...", flush=True)
    # key = f"raw/product/data-{TODAY}.json.gz"
    # s3.put_object(data, key)
    # print(f"[{datetime.now()}] Complete!", flush=True)
