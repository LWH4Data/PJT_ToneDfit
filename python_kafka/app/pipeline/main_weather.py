import os
import asyncio
from datetime import datetime
from zoneinfo import ZoneInfo
import weather_api as weather
import postgres_module as postgres
from dotenv import load_dotenv
import time

load_dotenv()


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
NOW = datetime.now(ZoneInfo("Asia/Seoul"))


def short_forecast():
    print(f"[{datetime.now()}] 단기예보 API 호출 진행 중...")
    data = asyncio.run(weather.get_short_forecast(NOW))
    print(f"[{datetime.now()}] 단기예보 API 호출 완료!")

    print(f"[{datetime.now()}] 단기예보 데이터 전처리 진행 중...")
    processed_data = weather.short_forecast_preprocess(NOW, data)
    print(f"[{datetime.now()}] 단기예보 데이터 전처리 완료!")
    
    print(f"[{datetime.now()}] PostgreSQL 작업 진행 중...")
    pg = postgres.PostgreSQL(
        host=os.getenv('POSTGRES_HOST'),
        port=int(os.getenv('POSTGRES_PORT')),
        dbname=os.getenv('POSTGRES_DB'),
        user=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD')
    )
    for item in processed_data:
        pg.upsert_data('weather_forecast', item)
    pg.close_connection()
    print(f"[{datetime.now()}] PostgreSQL 작업 완료!")


def pm_data():
    print(f"[{datetime.now()}] 미세먼지 데이터 수집 진행 중...")
    data = weather.get_pm_data()
    print(f"[{datetime.now()}] 미세먼지 데이터 수집 완료!")
    
    print(f"[{datetime.now()}] PostgreSQL 작업 진행 중...")
    pg = postgres.PostgreSQL(
        host=os.getenv('POSTGRES_HOST'),
        port=int(os.getenv('POSTGRES_PORT')),
        dbname=os.getenv('POSTGRES_DB'),
        user=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD')
    )
    for item in data:
        pg.insert_data('air_quality', item)
    pg.close_connection()
    print(f"[{datetime.now()}] PostgreSQL 작업 완료!")


if __name__ == "__main__":
    short_forecast()