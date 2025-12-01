import json
import os
import requests
import asyncio
import aiohttp
from datetime import datetime, timedelta
from collections import defaultdict
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from dotenv import load_dotenv


load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PM_API_KEY = os.getenv('PUBLIC_DATA_API_KEY')
PM_API_KEY_EMC = os.getenv('PUBLIC_DATA_API_KEY_EMC')
WEATHER_API_KEY = os.getenv('WEATHER_API_KEY')
with open(f"{BASE_DIR}/weather/pm_station_xy.json", 'r', encoding='utf-8') as f:
    pm_station_xy = json.load(f)


def get_pm_station_xy():
    stn_xy = defaultdict(dict)
    url = 'http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getMsrstnList'

    params = {
        'serviceKey' : PM_API_KEY,
        'returnType' : 'json', 
        'numOfRows' : '1000', 
        'pageNo' : '1', 
    }
    response = requests.get(url, params=params)
    data = json.loads(response.content.decode('utf-8'))['response']['body']['items']

    for stn in data:
        stn_xy[stn['stationName']] = {'stationX': stn['dmX'], 'stationY': stn['dmY']}

    return stn_xy


def get_pm_data():
    # 데이터 갱신이 느리므로 매시간 15분에 수집할 것
    url = 'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty'
    params ={
        'serviceKey' : PM_API_KEY, 
        'returnType' : 'json', 
        'numOfRows' : '1000', 
        'pageNo' : '1', 
        'sidoName' : '전국', 
        'ver' : '1.0' 
    }
    
    response = requests.get(url, params=params)
    response_data = json.loads(response.content.decode('utf-8'))
    items = response_data['response']['body']['items']
    
    grade_mapping = {"1": "좋음", "2": "보통", "3": "나쁨", "4": "매우나쁨"}
    result = []

    for item in items:
        station_name = item['stationName']
        if station_name not in pm_station_xy:
            print(f"{station_name} not in pm_station_xy. Please update pm_station_xy.json")
            return None
        
        date_time = item.get("dataTime", None)
        pm10_value = item.get("pm10Value") if item.get("pm10Value") != "-" else None
        pm25_value = item.get("pm25Value") if item.get("pm25Value") != "-" else None
        o3_value = item.get("o3Value") if item.get("o3Value") != "-" else None
        khai_value = item.get("khaiValue") if item.get("khaiValue") != "-" else None
        
        try:
            data = {
                "datetime": date_time if date_time else datetime.now().strftime("%Y-%m-%d %H:00"),
                "sido_name": item.get("sidoName"),
                "station_name": station_name,
                "latitude": float(pm_station_xy[station_name].get("stationX")),
                "longitude": float(pm_station_xy[station_name].get("stationY")),
                "pm10_value": int(pm10_value) if pm10_value else None,
                "pm25_value": int(pm25_value) if pm25_value else None,
                "o3_value": float(o3_value) if o3_value else None,
                "khai_value": int(khai_value) if khai_value else None,
                "pm10_grade": grade_mapping.get(item.get("pm10Grade"), None),
                "pm25_grade": grade_mapping.get(item.get("pm25Grade"), None),
                "o3_grade": grade_mapping.get(item.get("o3Grade"), None),
                "khai_grade": grade_mapping.get(item.get("khaiGrade"), None),
            }
            result.append(data)
        except Exception as e:
            print(f"Error processing data for station {station_name}: {e}")
            print(item)
            continue

    return result


async def get_short_forecast_async(date_time, x, y, session=None):
    # 단기 예보
    announce_time = ['2300', '0200', '0500', '0800', '1100', '1400', '1700', '2000']
    index = int(date_time.hour / 3)
    base_date = (date_time - timedelta(days=1)).strftime("%Y%m%d") if index == 0 else date_time.strftime("%Y%m%d")
    base_time = announce_time[index]

    url = 'https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst'
    params = {
        'authKey': WEATHER_API_KEY,
        'pageNo': '1',
        'numOfRows': '1000',
        'dataType': 'JSON',
        'base_date': base_date,
        'base_time': base_time,
        'nx': x,
        'ny': y,
    }
    try:
        async with session.get(url, params=params) as response:
            response.raise_for_status()
            data = await response.json()
            return data['response']['body']['items']['item']
    except Exception as e:
        print(f"[aiohttp error] ({x}, {y}): {e}")
        return None


def get_short_forecast_sync(date_time, x, y, session=None):
    # 단기 예보
    announce_time = ['2300', '0200', '0500', '0800', '1100', '1400', '1700', '2000']
    index = int(date_time.hour / 3)
    base_date = (date_time - timedelta(days=1)).strftime("%Y%m%d") if index == 0 else date_time.strftime("%Y%m%d")
    base_time = announce_time[index]

    url = 'https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst'
    params = {
        'authKey': WEATHER_API_KEY,
        'pageNo': '1',
        'numOfRows': '1000',
        'dataType': 'JSON',
        'base_date': base_date,
        'base_time': base_time,
        'nx': x,
        'ny': y,
    }
    response = session.get(url, params=params)
    data = json.loads(response.content.decode('utf-8'))

    try:
        return data['response']['body']['items']['item']
    except KeyError:
        print(data)
        return []
    

async def get_short_forecast(date_time):
    # 해상 제외한 x, y 좌표 불러오기
    with open(f"{BASE_DIR}/weather/unique_grid_list.json", "r", encoding="utf-8") as f:
        grid_list = json.load(f)

    sync_session = requests.Session()
    retries = Retry(total=5, backoff_factor=1)
    adapter = HTTPAdapter(max_retries=retries)
    sync_session.mount("https://", adapter)

    sem = asyncio.Semaphore(20)
    forecast = []
    count = 0

    # 좌표 별 데이터 수집
    async with aiohttp.ClientSession() as async_session:
        async def handle_point(x, y):
            async with sem:
                data = await get_short_forecast_async(date_time, x, y, async_session)
                if data is None:
                    data = get_short_forecast_sync(date_time, x, y, sync_session)
                if data:
                    forecast.extend(data)

        tasks = [handle_point(x, y) for x, y in grid_list]
        await asyncio.gather(*tasks)

    return forecast


# 단기, 초단기 데이터를 병합 및 가공
def short_forecast_preprocess(date_time, data):
    category_mapping = {
        "TMP": "temp_celsius",
        "T1H": "temp_celsius",
        "TMX": "temp_max_celsius",
        "TMN": "temp_min_celsius",
        "SKY": "weather_condition_code",
        "PTY": "precipitation_type_code",
        "POP": "precipitation_chance",
        "PCP": "precipitation_rain_mm",
        "RN1": "precipitation_rain_mm",
        "SNO": "precipitation_snow_cm",
        "REH": "humidity_percent",
        "WSD": "wind_speed_kph",
        "VEC": "wind_direction",
    }
    processed = defaultdict(dict)

    for item in data:
        category = category_mapping.get(item["category"])
        if category is None:
            continue

        key = (item['fcstDate'], item['fcstTime'], item['nx'], item['ny'])
        processed[key]['base_datetime'] = (date_time - timedelta(minutes=date_time.minute % 10)).strftime("%Y-%m-%d %H:00:00")
        processed[key]['forecast_datetime'] = datetime.strptime(item['fcstDate'] + item['fcstTime'], "%Y%m%d%H%M").strftime("%Y-%m-%d %H:%M:%S")
        processed[key]['x'] = item['nx']
        processed[key]['y'] = item['ny']
        processed[key][category] = item['fcstValue']
    
    return list(processed.values())


if __name__ == "__main__":
    station_xy = get_pm_station_xy()

    with open(f"{BASE_DIR}/weather/pm_station_xy.json", "w", encoding="utf-8") as f:
        json.dump(station_xy, f, ensure_ascii=False, indent=2) 
