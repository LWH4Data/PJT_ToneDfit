import psycopg2


class PostgreSQL:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self, host: str, port: int, dbname: str, user: str, password: str):
        if hasattr(self, "_initialized") and self._initialized:
            return
        
        self.connection = psycopg2.connect(
            host=host,
            port=port,
            dbname=dbname,
            user=user,
            password=password
        )
        self._initialized = True

    def get_connection(self):
        return self.connection
    
    def close_connection(self):
        if self.connection:
            self.connection.close()
            self._instance = None

    def insert_data(self, table: str, data: dict):
        columns = ', '.join(data.keys())
        placeholders = ', '.join(['%s'] * len(data))
        values = list(data.values())

        query = f"INSERT INTO {table} ({columns}) VALUES ({placeholders})"
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, values)
                self.connection.commit()
        except Exception as e:
            self.connection.rollback()
            print(f"Error inserting data into {table}: {e}")

    def upsert_data(self, table: str, data: dict):
        columns = ', '.join(data.keys())
        placeholders = ', '.join(['%s'] * len(data))
        values = list(data.values())

        # 1️⃣ UNIQUE / PRIMARY KEY 자동 감지
        with self.connection.cursor() as cursor:
            cursor.execute("""
                SELECT a.attname
                FROM pg_index i
                JOIN pg_attribute a ON a.attrelid = i.indrelid
                                AND a.attnum = ANY(i.indkey)
                WHERE i.indrelid = %s::regclass
                AND i.indisunique
                ORDER BY a.attnum;
            """, (table,))
            conflict_columns = [row[0] for row in cursor.fetchall()]

        # 2️⃣ fallback: unique key 없으면 일반 INSERT
        if not conflict_columns:
            query = f"INSERT INTO {table} ({columns}) VALUES ({placeholders});"
        else:
            conflict_target = ', '.join(conflict_columns)
            # 모든 컬럼을 새 값으로 갱신 (PK는 제외)
            update_clause = ', '.join([
                f"{col} = EXCLUDED.{col}"
                for col in data.keys()
                if col not in conflict_columns
            ])

            query = f"""
                INSERT INTO {table} ({columns})
                VALUES ({placeholders})
                ON CONFLICT ({conflict_target}) DO UPDATE
                SET {update_clause};
            """

        # 3️⃣ 실행
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, values)
                self.connection.commit()
        except Exception as e:
            self.connection.rollback()
            print(f"[ERROR] Upsert failed for table '{table}': {e}")


    def truncate_table(self, table: str):
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE;")
                self.connection.commit()
        except Exception as e:
            self.connection.rollback()
            print(f"Error Truncate {table}: {e}")