from confluent_kafka.admin import AdminClient, NewTopic
from confluent_kafka import Producer, Consumer
import socket
from datetime import datetime
from collections import defaultdict

servers = "kafka-1:19092,kafka-2:19092,kafka-3:19092"
conf = {"bootstrap.servers": servers}
admin = AdminClient(conf)


class KafkaProducer:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        if hasattr(self, "_initialized") and self._initialized:
            return
        
        conf = {
            "bootstrap.servers": servers,
            "client.id": socket.gethostname(),
        }
        self.producer = Producer(conf)
        self._initialized = True

    def produce(self, topic: str, data: str, key: str = None):
        self.producer.produce(topic, value=data, key=key)
        self.producer.poll(0)

    def flush(self, timeout: int = 10):
        self.producer.flush(timeout)


class KafkaConsumer:
    def __init__(self, group_id: str):
        conf = {
            "bootstrap.servers": servers,
            "group.id": group_id,
            "auto.offset.reset": "earliest",
        }
        self.consumer = Consumer(conf)

    def subscribe(self, topic_names: str | list[str]):
        if isinstance(topic_names, str):
            self.consumer.subscribe([topic_names])
        elif isinstance(topic_names, list):
            self.consumer.subscribe(topic_names)

    def poll(self, all: bool = True, timeout: int = 5):
        # 1건 처리
        if not all:
            msg = self.consumer.poll(timeout=timeout)
            if msg is None:
                print(f"[{msg.topic()}] None of Message")
                return None
            if msg.error():
                print(f"Error: {msg.error()}")
                return None
            else:
                return {"topic": msg.topic(), "data": msg.value().decode("utf-8")}

        # 전부 처리
        data = defaultdict(list)

        while True:
            msg = self.consumer.poll(timeout=timeout)
            if msg is None:
                break
            if msg.error():
                print(f"Error: {msg.error()}")
                continue
            else:
                data[msg.topic()].append(msg.value().decode("utf-8"))
        
        return data
    
    def close(self):
        self.consumer.close()
        print("Consumer Closed.")


def create_topic(topic_name, num_partitions=1, replication_factor=1):
    new_topic = NewTopic(
        topic=topic_name,
        num_partitions=num_partitions,
        replication_factor=replication_factor,
    )

    fs = admin.create_topics([new_topic])

    for topic, f in fs.items():
        try:
            f.result()  # 완료 대기
            print(f"Topic '{topic}' created.")
        except Exception as e:
            print(f"Failed to create topic '{topic}': {e}")


def delete_topic(topic_name):
    fs = admin.delete_topics([topic_name], operation_timeout=10)

    for topic, f in fs.items():
        try:
            f.result()  # 삭제 완료 대기
            print(f"Topic '{topic}' deleted.")
        except Exception as e:
            print(f"Failed to delete topic '{topic}': {e}")

            
if __name__=="__main__":
    topics = [
        "crawl.product.raw.v1",
        "weather.pm.raw.v1",
    ]

    for topic in topics:
        create_topic(topic)
