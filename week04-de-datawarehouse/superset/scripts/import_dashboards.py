#!/usr/bin/env python3
"""
Superset Dashboard Import Script
Programmatically create database connections and datasets
"""

import requests
import json

# Superset Configuration
SUPERSET_URL = "http://localhost:8088"
USERNAME = "admin"
PASSWORD = "admin123"


class SupersetClient:
    """Superset API Client"""

    def __init__(self, base_url, username, password):
        self.base_url = base_url
        self.session = requests.Session()
        self.csrf_token = None
        self.access_token = None

        # Login
        self.login(username, password)

    def login(self, username, password):
        """Login to Superset and get access token"""

        print(f"[LOGIN] Superset'e bağlanılıyor: {self.base_url}")

        # Get CSRF token
        response = self.session.get(f"{self.base_url}/login/")

        # Login
        login_data = {
            "username": username,
            "password": password,
            "provider": "db"
        }

        response = self.session.post(
            f"{self.base_url}/api/v1/security/login",
            json=login_data
        )

        if response.status_code == 200:
            data = response.json()
            self.access_token = data.get("access_token")
            self.session.headers.update({
                "Authorization": f"Bearer {self.access_token}"
            })
            print("  ✓ Login başarılı")
        else:
            print(f"  ✗ Login hatası: {response.text}")
            raise Exception("Login failed")

    def create_database(self, database_name, sqlalchemy_uri):
        """Create database connection"""

        print(f"\n[DATABASE] '{database_name}' oluşturuluyor...")

        # CSRF token al
        csrf_response = self.session.get(f"{self.base_url}/api/v1/security/csrf_token/")
        self.csrf_token = csrf_response.json().get("result")

        self.session.headers.update({
            "X-CSRFToken": self.csrf_token,
            "Referer": self.base_url
        })

        database_data = {
            "database_name": database_name,
            "sqlalchemy_uri": sqlalchemy_uri,
            "expose_in_sqllab": True,
            "allow_run_async": True,
            "allow_ctas": False,
            "allow_cvas": False,
            "allow_dml": False,
        }

        response = self.session.post(
            f"{self.base_url}/api/v1/database/",
            json=database_data
        )

        if response.status_code in [200, 201]:
            print(f"  ✓ Database oluşturuldu: {database_name}")
            return response.json()
        else:
            print(f"  ⚠ Database zaten var veya hata: {response.text}")
            return None

    def list_databases(self):
        """List all databases"""

        print("\n[LIST] Mevcut database'ler:")

        response = self.session.get(f"{self.base_url}/api/v1/database/")

        if response.status_code == 200:
            databases = response.json().get("result", [])
            for db in databases:
                print(f"  - {db['database_name']} (ID: {db['id']})")
            return databases
        else:
            print(f"  ✗ Liste alınamadı: {response.text}")
            return []


def main():
    """Ana fonksiyon"""

    print("=" * 60)
    print("Superset Database Import")
    print("=" * 60)

    try:
        # Superset client oluştur
        client = SupersetClient(SUPERSET_URL, USERNAME, PASSWORD)

        # OLAP Database ekle
        print("\n[OLAP] Data Warehouse database'i ekleniyor...")
        client.create_database(
            database_name="OLAP Data Warehouse",
            sqlalchemy_uri="postgresql://olap_user:olap_pass123@postgres-olap:5432/ecommerce_dw"
        )

        # OLTP Database ekle (Read-only)
        print("\n[OLTP] Source database'i ekleniyor...")
        client.create_database(
            database_name="OLTP Source",
            sqlalchemy_uri="postgresql://oltp_user:oltp_pass123@postgres-oltp:5432/ecommerce_oltp"
        )

        # Mevcut database'leri listele
        databases = client.list_databases()

        print("\n" + "=" * 60)
        print("✓ Database'ler başarıyla eklendi!")
        print("=" * 60)

        print("\nSonraki adımlar:")
        print("1. Web UI'da Settings > Database Connections'da bağlantıları kontrol et")
        print("2. Data > Datasets'den tablolarını ekle")
        print("3. Charts oluşturmaya başla!")

    except Exception as e:
        print(f"\n✗ Hata: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()