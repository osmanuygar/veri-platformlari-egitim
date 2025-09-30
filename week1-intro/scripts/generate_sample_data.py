import pandas as pd
import numpy as np
from faker import Faker
import json
import random
from datetime import datetime, timedelta

fake = Faker('tr_TR')  # Türkçe fake data
Faker.seed(42)
np.random.seed(42)


def generate_customers_csv(n=1000):
    """Müşteri verisi oluştur (CSV)"""
    print(f"Generating {n} customers...")

    data = {
        'customer_id': range(1, n + 1),
        'first_name': [fake.first_name() for _ in range(n)],
        'last_name': [fake.last_name() for _ in range(n)],
        'email': [fake.email() for _ in range(n)],
        'phone': [fake.phone_number() for _ in range(n)],
        'birth_date': [fake.date_of_birth(minimum_age=18, maximum_age=80) for _ in range(n)],
        'city': [fake.city() for _ in range(n)],
        'registration_date': [fake.date_between(start_date='-2y', end_date='today') for _ in range(n)],
        'is_active': [random.choice([True, False]) for _ in range(n)],
        'total_purchases': np.random.randint(0, 50, n),
        'total_spent': np.round(np.random.uniform(0, 10000, n), 2)
    }

    df = pd.DataFrame(data)

    # Bazı eksik değerler ekle (gerçekçilik için)
    df.loc[random.sample(range(n), 50), 'phone'] = None
    df.loc[random.sample(range(n), 30), 'birth_date'] = None

    output_path = '/app/data-samples/structured/customers.csv'
    df.to_csv(output_path, index=False)
    print(f"✅ Customers saved to {output_path}")

    return df


def generate_sales_csv(n=5000):
    """Satış verisi oluştur (CSV)"""
    print(f"Generating {n} sales records...")

    start_date = datetime.now() - timedelta(days=365)

    data = {
        'sale_id': range(1, n + 1),
        'customer_id': np.random.randint(1, 1001, n),
        'product_id': np.random.randint(1, 201, n),
        'sale_date': [fake.date_time_between(start_date=start_date, end_date='now') for _ in range(n)],
        'quantity': np.random.randint(1, 10, n),
        'unit_price': np.round(np.random.uniform(10, 1000, n), 2),
        'discount': np.round(np.random.uniform(0, 0.3, n), 2),
        'payment_method': [random.choice(['Credit Card', 'Debit Card', 'Cash', 'Bank Transfer']) for _ in range(n)]
    }

    df = pd.DataFrame(data)
    df['total_amount'] = np.round(df['quantity'] * df['unit_price'] * (1 - df['discount']), 2)

    output_path = '/app/data-samples/structured/sales.csv'
    df.to_csv(output_path, index=False)
    print(f"✅ Sales saved to {output_path}")

    return df


def generate_products_csv(n=200):
    """Ürün verisi oluştur (CSV)"""
    print(f"Generating {n} products...")

    categories = ['Electronics', 'Clothing', 'Books', 'Home & Garden', 'Sports', 'Toys']

    data = {
        'product_id': range(1, n + 1),
        'product_name': [fake.catch_phrase() for _ in range(n)],
        'category': [random.choice(categories) for _ in range(n)],
        'price': np.round(np.random.uniform(10, 2000, n), 2),
        'cost': np.round(np.random.uniform(5, 1500, n), 2),
        'stock_quantity': np.random.randint(0, 500, n),
        'supplier': [fake.company() for _ in range(n)],
        'is_available': [random.choice([True, False]) for _ in range(n)]
    }

    df = pd.DataFrame(data)
    df['profit_margin'] = np.round(((df['price'] - df['cost']) / df['price']) * 100, 2)

    output_path = '/app/data-samples/structured/products.csv'
    df.to_csv(output_path, index=False)
    print(f"✅ Products saved to {output_path}")

    return df


def generate_api_response_json():
    """API yanıtı formatında JSON oluştur"""
    print("Generating API response JSON...")

    data = {
        "status": "success",
        "timestamp": datetime.now().isoformat(),
        "data": {
            "users": [
                {
                    "id": i,
                    "username": fake.user_name(),
                    "email": fake.email(),
                    "profile": {
                        "full_name": fake.name(),
                        "bio": fake.text(max_nb_chars=100),
                        "location": {
                            "city": fake.city(),
                            "country": "Turkey"
                        }
                    },
                    "posts": [
                        {
                            "post_id": j,
                            "title": fake.sentence(),
                            "content": fake.paragraph(),
                            "likes": random.randint(0, 1000),
                            "comments": random.randint(0, 100)
                        }
                        for j in range(random.randint(1, 5))
                    ]
                }
                for i in range(1, 11)
            ]
        },
        "meta": {
            "total_users": 10,
            "api_version": "1.0",
            "rate_limit": {
                "remaining": 998,
                "limit": 1000
            }
        }
    }

    output_path = '/app/data-samples/semi-structured/api-response.json'
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ API response saved to {output_path}")


def generate_config_xml():
    """XML config dosyası oluştur"""
    print("Generating XML config...")

    xml_content = """
<database>
  <host>localhost</host>
  <port>5432</port>
  <username>admin</username>
  <password>secret</password>
</database>
"""

    output_path = '/app/data-samples/semi-structured/config.xml'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(xml_content)

    print(f"✅ XML config saved to {output_path}")


def generate_text_file():
    """Yapısal olmayan metin dosyası oluştur"""
    print("Generating text file...")

    content = f"""
ÜRÜN AÇIKLAMASI

{fake.company()} tarafından üretilen bu ürün, en yüksek kalite standartlarında hazırlanmıştır.

ÖZELLİKLER:
{fake.text(max_nb_chars=500)}

KULLANIM ALANLARI:
{fake.text(max_nb_chars=300)}

TEKNİK ÖZELLİKLER:
- Boyut: {random.randint(10, 100)} cm
- Ağırlık: {random.randint(1, 50)} kg
- Renk: {random.choice(['Siyah', 'Beyaz', 'Gri', 'Mavi'])}
- Garanti: {random.randint(1, 5)} yıl

MÜŞTERİ YORUMLARI:
"{fake.text(max_nb_chars=150)}" - {fake.name()}
"{fake.text(max_nb_chars=150)}" - {fake.name()}

İletişim: {fake.email()}
Telefon: {fake.phone_number()}
"""

    output_path = '/app/data-samples/unstructured/sample.txt'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"✅ Text file saved to {output_path}")


def main():
    """Tüm örnek verileri oluştur"""
    print("=" * 50)
    print("ÖRNEK VERİ OLUŞTURMA")
    print("=" * 50)

    # Yapısal veri
    generate_customers_csv(1000)
    generate_sales_csv(5000)
    generate_products_csv(200)

    # Yarı-yapısal veri
    generate_api_response_json()
    generate_config_xml()

    # Yapısal olmayan veri
    generate_text_file()

    print("\n" + "=" * 50)
    print("✅ TÜM ÖRNEK VERİLER OLUŞTURULDU!")
    print("=" * 50)
    print("\nVeri dosyaları:")
    print("  - /app/data-samples/structured/")
    print("  - /app/data-samples/semi-structured/")
    print("  - /app/data-samples/unstructured/")


if __name__ == "__main__":
    main()
