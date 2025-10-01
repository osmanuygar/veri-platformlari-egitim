# Redis Hızlı Referans

## Bağlantı
```bash
redis-cli                   # Bağlan
redis-cli -h host -p 6379  # Remote bağlantı
PING                        # Test
INFO                        # Sunucu bilgisi
```

## String
```redis
SET key value              # Ayarla
GET key                    # Getir
MSET k1 v1 k2 v2          # Çoklu set
MGET k1 k2                 # Çoklu get
INCR counter               # Artır
DECR counter               # Azalt
APPEND key value           # Ekle
```

## Hash
```redis
HSET user:1000 name "John"
HGET user:1000 name
HMSET user:1000 name "John" age 30
HGETALL user:1000
HDEL user:1000 age
HEXISTS user:1000 name
```

## List
```redis
LPUSH mylist "first"       # Başa ekle
RPUSH mylist "last"        # Sona ekle
LRANGE mylist 0 -1         # Tümünü getir
LPOP mylist                # Baştan al
RPOP mylist                # Sondan al
LLEN mylist                # Uzunluk
```

## Set
```redis
SADD myset "a" "b" "c"
SMEMBERS myset
SISMEMBER myset "a"
SCARD myset                # Eleman sayısı
SREM myset "b"
```

## Sorted Set
```redis
ZADD leaderboard 100 "player1"
ZRANGE leaderboard 0 -1 WITHSCORES
ZRANK leaderboard "player1"
ZINCRBY leaderboard 10 "player1"
```

## Keys & TTL
```redis
KEYS *                     # Tüm key'ler (DİKKAT: Production'da kullanma!)
EXISTS key
DEL key
EXPIRE key 3600            # 1 saat
TTL key                    # Kalan süre
PERSIST key                # TTL kaldır
```

## Transactions
```redis
MULTI                      # Transaction başlat
SET key1 value1
SET key2 value2
EXEC                       # Çalıştır
```