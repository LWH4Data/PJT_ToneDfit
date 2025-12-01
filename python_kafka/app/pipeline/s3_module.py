import os
import boto3
import json
import gzip
from dotenv import load_dotenv
from io import BytesIO


load_dotenv()

s3 = boto3.client("s3")
bucket_name = "tonedfit-data"
region = "ap-northeast-2"


def put_object(data, key):
    buffer = BytesIO()
    json_bytes = json.dumps(data, ensure_ascii=False).encode("utf-8")

    with gzip.GzipFile(fileobj=buffer, mode="wb") as gz:
        gz.write(json_bytes)

    # S3 업로드
    buffer.seek(0)
    s3.put_object(
        Bucket=bucket_name,
        Key=key,
        Body=buffer.getvalue(),
        ContentType="application/json",
        ContentEncoding="gzip",
    )

    print("Uploaded:", key)