import requests
from datetime import datetime, timedelta

WEATHER_API_KEY = "vO2m1zkqTpitptc5Kg6YEw"

def test_weather_api():
    date_time = datetime.now()
    announce_time = ['2300', '0200', '0500', '0800', '1100', '1400', '1700', '2000']
    index = int(date_time.hour / 3)
    base_date = (date_time - timedelta(days=1)).strftime("%Y%m%d") if index == 0 else date_time.strftime("%Y%m%d")
    base_time = announce_time[index]

    url = "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst"
    params = {
        "authKey": WEATHER_API_KEY,
        "dataType": "JSON",
        "base_date": base_date,
        "base_time": base_time,
        "nx": 60,
        "ny": 127,
        "numOfRows": "10",
        "pageNo": "1",
    }

    try:
        print("➡️ 요청 시도:", url)
        resp = requests.get(url, params=params, timeout=10, verify=True)
        print("✅ 상태 코드:", resp.status_code)
        print("✅ 응답 길이:", len(resp.text))
        print("✅ 내용 일부:", resp.text[:300])
    except requests.exceptions.RequestException as e:
        print("❌ 요청 실패:", e)


if __name__ == "__main__":
    test_weather_api()
