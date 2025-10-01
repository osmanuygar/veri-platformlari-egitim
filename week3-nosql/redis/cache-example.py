"""
Redis Cache Örneği
"""
import redis
import time
import json

# Redis bağlantısı
r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)


def get_user_from_db(user_id):
    """Veritabanından kullanıcı getir (simülasyon)"""
    print(f"⏳ DB'den kullanıcı {user_id} getiriliyor...")
    time.sleep(2)  # DB gecikme simülasyonu
    return {
        "id": user_id,
        "name": f"User {user_id}",
        "email": f"user{user_id}@email.com"
    }


def get_user(user_id):
    """Cache-first stratejisi"""
    cache_key = f"user:{user_id}"

    # Önce cache'de ara
    cached = r.get(cache_key)
    if cached:
        print("✅ Cache'den geldi!")
        return json.loads(cached)

    # Cache'de yoksa DB'den getir
    user = get_user_from_db(user_id)

    # Cache'e kaydet (5 dakika)
    r.setex(cache_key, 300, json.dumps(user))

    return user


# Test
if __name__ == "__main__":
    print("İlk istek:")
    user = get_user(1000)
    print(user)

    print("\nİkinci istek:")
    user = get_user(1000)  # Cache'den gelecek
    print(user)