import json
import re
import os
import time
from datetime import date, datetime
from collections import defaultdict
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from kafka_module import KafkaProducer


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SHOP_BASE_URL = "https://shop.29cm.co.kr/category/list?"
PRODUCT_BASE_URL = "https://www.29cm.co.kr/products/"
TODAY = date.today()

with open(f"{BASE_DIR}/twentyninecm/categories_29cm.json", "r", encoding="utf-8") as f:
    CATEGORIES = json.load(f)


def extract_brand(driver):
    try:
        elem = driver.find_element(By.CSS_SELECTOR, "div.flex.max-w-700.flex-1.gap-2 h3 > span")
        return elem.text.strip()

    except Exception as e:
        print(f"[extract_brand] Error: {e}")
        return None
    

def extract_name(driver):
    try:
        elem = driver.find_element(By.ID, "pdp_product_name")
        return elem.text.strip()

    except Exception as e:
        print(f"[extract_name] Error: {e}")
        return None


def extract_price(driver):
    try:
        elem = driver.find_element(By.CSS_SELECTOR, "div.flex.flex-col.gap-4.desktop\\:gap-0")

        original_price_el = elem.find_elements(
            By.CSS_SELECTOR, "original_price_el.block.text-m.text-tertiary.line-through"
        )
        discount_rate_el = elem.find_elements(By.CSS_SELECTOR, "strong")
        final_price_el = elem.find_element(By.ID, "pdp_product_price")

        if original_price_el:
            original_price = int(re.sub(r"[^\d]", "", original_price_el[0].text))
            discount_rate = int(re.sub(r"[^\d]", "", discount_rate_el[0].text))
            discounted_price = int(re.sub(r"[^\d]", "", final_price_el.text))
        else:
            original_price = int(re.sub(r"[^\d]", "", final_price_el.text))
            discounted_price = None
            discount_rate = 0

        return original_price, discounted_price, discount_rate

    except Exception as e:
        print(f"[extract_price] Error: {e}")
        return None, None, None


def extract_fabric_color_size(driver):
    info = {}
    try:
        elem = driver.find_element(By.CSS_SELECTOR, "div.mt-40")
        info_table = elem.find_element(By.CSS_SELECTOR, "div.mt-3 table")

        for tr in info_table.find_elements(By.CSS_SELECTOR, "tbody tr"):
            key = tr.find_element(By.CSS_SELECTOR, "th").text.strip()
            val = tr.find_element(By.CSS_SELECTOR, "td").text.strip()
            if key in {"제품 소재", "색상", "치수"}:
                info[key] = val
    
    except Exception as e:
        print(f"[extract_fabric_color_size] Info Table Error: {e}")
        return info

    # 치수 정보에 상세수치 포함된 경우 추가 파싱
    try:
        elem = driver.find_element(By.CSS_SELECTOR, "div.desktop\\:pt-40")
        table = elem.find_element(By.CSS_SELECTOR, "div.mt-3 table")
        headers = [
            th.text.strip() for th in table.find_elements(By.CSS_SELECTOR, "thead th")
        ]

        sizes = []
        size_name_map = {
            "어깨 너비": "shoulder",
            "소매 길이": "sleeve",
            "가슴 너비": "chest",
            "총길이": "length",
            "허리 너비": "waist",
            "골반 너비": "hip",
            "허벅지 너비": "thigh",
            "밑단 너비": "hem",
            "밑위 너비": "frise"
        }
        for tr in table.find_elements(By.CSS_SELECTOR, "tbody tr"):
            tds = [td.text.strip() for td in tr.find_elements(By.CSS_SELECTOR, "td")]
            if not tds:
                continue
            size_name = tds[0]
            measurements = {}
            for i, h in enumerate(headers[1:], 1):
                val = tds[i] if i < len(tds) else None
                measurements[size_name_map.get(h, h)] = val
            sizes.append({"size": size_name, "measurements": measurements})

        info["치수"] = sizes

    except Exception:
        pass

    return info


def extract_image_urls(driver):
    try:
        elem = driver.find_element(By.CSS_SELECTOR, "div.desktop\\:my-0")
        images = elem.find_elements(By.TAG_NAME, "img")
        image_urls = [img.get_attribute("src") for img in images if img.get_attribute("src")]

        return image_urls
    
    except Exception as e:
        print(f"[extract_image_urls] Error: {e}")
        return []


def extract_reviews(driver):
    # 리뷰 일단 최대 20개까지만 추출
    try:
        elem = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "product-review-section"))
        )
        review_items = elem.find_elements(By.CSS_SELECTOR, "div.p-12.px-20")

        reviews = []
        for item in review_items:
            try:
                info_div = item.find_element(By.CSS_SELECTOR, "div.mb-16")

                try:
                    option_el = info_div.find_element(By.XPATH, ".//*[contains(text(), '옵션 : ')]")
                    option = (option_el.text.replace("옵션 : ", "").strip() if option_el else None)
                except Exception:
                    option = None

                try:
                    body_el = info_div.find_element(By.XPATH, ".//*[contains(text(), '체형 : ')]")
                    body_shape = (body_el.text.replace("체형 : ", "").strip() if body_el else None)
                except Exception:
                    body_shape = None

                try:
                    size_el = info_div.find_element(By.XPATH, ".//*[contains(text(), '사이즈 : ')]")
                    size_fit = (size_el.text.replace("사이즈 : ", "").strip() if size_el else None)
                except Exception:
                    size_fit = None

            except Exception:
                option = None
                body_shape = None
                size_fit = None

            try:
                date = item.find_element(By.CSS_SELECTOR, "span.text-tertiary").text.strip()
                rating = len(item.find_elements(By.CSS_SELECTOR, "svg.text-primary"))
                content = item.find_element(By.CSS_SELECTOR, "p.text-primary").text.strip()
            except Exception as e:
                print(f"[extract_reviews] Review Basic Info Error: {e}")
                continue

            try:
                image_urls = []
                for img in item.find_elements(By.CSS_SELECTOR, "img[alt='review photo']"):
                    src = img.get_attribute("src")
                    if src:
                        clean_src = src.split("?")[0]
                        image_urls.append(clean_src)
            except Exception:
                image_urls = []

            reviews.append({
                "date": date,
                "rating": rating,
                "option": option,
                "body_shape": body_shape,
                "size_fit": size_fit,
                "content": content,
                "image_urls": image_urls,
            })
        return reviews 

    except Exception as e:
        print(f"[extract_reviews] 리뷰 엘리멘트를 찾지 못했습니다.")
        return []


def extract_representative_image_url(driver):
    try:
        img = driver.find_element(By.CSS_SELECTOR, "img.h-full.w-full.object-cover")
        src = img.get_attribute("src") or ""
        clean_src = src.split("?", 1)[0]
    except Exception as e:
        print(f"[extract_representative_image_url] 대표이미지 추출 실패")
        clean_src = None
    
    return clean_src


def get_new_pid_category(driver):
    with open(f"{BASE_DIR}/twentyninecm/processed_pids_29cm.txt", "r", encoding="utf-8") as f:
        processed_pids = set(line.strip() for line in f if line.strip())
    
    data = defaultdict(list)

    for large in CATEGORIES["large"]:
        large_name = CATEGORIES["large"][large]["name"]
        print(f"[대분류] {large_name} ({large})")

        for medium in CATEGORIES["large"][large]["medium"]:
            medium_name = CATEGORIES["large"][large]["medium"][medium]["name"]
            print(f" └ [중분류] {medium_name} ({medium})")

            for small in CATEGORIES["large"][large]["medium"][medium]["small"]:
                small_name = CATEGORIES["large"][large]["medium"][medium]["small"][small]["name"]
                print(f"    └ [소분류] {small_name} ({small})", end="", flush=True)
                
                category = {
                    "large": large_name,
                    "medium": medium_name,
                    "small": small_name
                }
                seen = set()

                url = f"{SHOP_BASE_URL}categoryLargeCode={large}&categoryMediumCode={medium}&categorySmallCode={small}&sort=NEWEST"
                driver.get(url)

                while True:
                    try:
                        elements = WebDriverWait(driver, 5).until(
                            EC.presence_of_all_elements_located((By.CSS_SELECTOR, ".mb-40"))
                        )

                        for el in elements:
                            try:
                                a_tag = el.find_element(By.TAG_NAME, "a")
                                href = a_tag.get_attribute("href")
                                match = re.search(r"catalog/(\d+)", href)

                                # 임시
                                # --------------------------
                                img = a_tag.find_element(By.TAG_NAME, "img")
                                raw_src = img.get_attribute("src") or ""
                                clean_src = raw_src.split("?", 1)[0]
                                # --------------------------

                                if match:
                                    pid = match.group(1)
                                    # if pid in processed_pids:
                                    #     break
                                    if pid not in seen:
                                        seen.add(pid)
                                        # 임시(category -> clean_src)
                                        data[pid].append(clean_src)
                            except Exception as e:
                                print(f"[extract_product_id] Error extracting product ID")
                                continue

                        # if pid in processed_pids:
                        #     break

                        buttons = driver.find_elements(By.CSS_SELECTOR, "button.e12g5a9y0")
                        next_button = buttons[1]

                        if next_button.get_attribute("disabled"):
                            break  # disabled이면 마지막 페이지

                        next_button.click()
                        time.sleep(1)

                    except TimeoutException:
                        print(f"[extract_pid] mb-40 클래스 요소를 찾지 못함: {url}")
                        break
                print(f" → {len(seen)}개 찾음")
            
    return data


def extract_data_from_pid(driver, kafka_produce: bool = False, start: int = None, end: int = None):
    with open(f"{BASE_DIR}/twentyninecm/data/product_list_{TODAY}.json", "r", encoding="utf-8") as f:
        product_ids = json.load(f)
    with open(f"{BASE_DIR}/twentyninecm/processed_pids_29cm.txt", "r", encoding="utf-8") as f:
        processed_pids = set(line.strip() for line in f if line.strip())

    if kafka_produce:
        producer = KafkaProducer()
        f = open(f"{BASE_DIR}/twentyninecm/processed_pids_29cm.txt", "a", encoding="utf-8")

    products = []

    for i, (pid, data) in enumerate(product_ids.items()):
        if pid in processed_pids:
            continue
        if start:
            if i < start:
                continue
        if end:
            if i > end:
                break
        

        try:
            url = f"{PRODUCT_BASE_URL}/{pid}"
            driver.get(url)
        except Exception as e:
            print(f"[{i}][{datetime.now()}] 웹페이지 접속 실패: {url}")
            continue

        try:
            WebDriverWait(driver, 5).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "div.desktop\\:my-0"))
            )
        except Exception as e:
            print(f"[{i}][{datetime.now()}] 판매 종료된 상품: {url}")
            continue

        prices = extract_price(driver)
        product_info = extract_fabric_color_size(driver)

        product = {
            "product_url": url,
            "product_id": pid,
            "brand": extract_brand(driver),
            "categories": product_ids[pid],
            "name": extract_name(driver),
            "original_price": prices[0],
            "discounted_price": prices[1],
            "discount_rate": prices[2],
            "fabrics": product_info.get("제품 소재"),
            "colors": product_info.get("색상"),
            "sizes": product_info.get("치수"),
            "texture": None,
            "sheerness": None,
            "thickness": None,
            "fit": None,
            "stretch": None,
            "weather": [],
            "representative_image_url": extract_representative_image_url(driver),
            "image_urls": extract_image_urls(driver),
            "reviews": extract_reviews(driver),
        }
        products.append(product)

        if kafka_produce:
            producer.produce("test", json.dumps(product, ensure_ascii=False).encode("utf-8"))
            f.write(product["product_id"] + "\n")
        
        print(f"[{i}][{datetime.now()}] 처리 완료")

    if kafka_produce:
        f.close()
        producer.flush()

    return products
