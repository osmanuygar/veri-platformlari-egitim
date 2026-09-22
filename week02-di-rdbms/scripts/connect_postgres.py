import psycopg2
from psycopg2.extras import RealDictCursor

def connect_postgres():
    """PostgreSQL'e bağlan"""
    try:
        conn = psycopg2.connect(
            host="192.168.107.0",
            port=5432,
            database="veri_db",
            user="veri_user",
            password="veri_pass"
        )
        print("✅ PostgreSQL bağlantısı başarılı!")
        return conn
    except Exception as e:
        print(f"❌ Bağlantı hatası: {e}")
        return None

if __name__ == "__main__":
    conn = connect_postgres()
    if conn:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        print(f"PostgreSQL Version: {version['version']}")
        cursor.execute("SELECT *  FROM  veri_db.ecommerce.adresler LIMIT 10;")
        adresler = cursor.fetchall()
        print(adresler)
        cursor.close()
        conn.close()