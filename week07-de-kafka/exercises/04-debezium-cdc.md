# Alıştırma 4: Debezium ile CDC

**Süre:** ~40 dakika · **Dosyalar:** `scripts/cdc_watch.py`, `scripts/db_simulator.py`, `connectors/`

---

## 4.0 Connector ayakta mı?

```bash
./scripts/register_connector.sh status
```

`"state": "RUNNING"` görmelisiniz. Değilse `docker compose logs connect` ve
[Debezium cheatsheet](../cheatsheets/debezium-cheatsheet.md#-sorun-giderme).

---

## 4.1 ✨ Wow anı

```bash
# Terminal 1
python scripts/cdc_watch.py

# Terminal 2
docker exec -it week07_postgres psql -U kafka_user -d shopdb
```

psql'de tek tek çalıştırın ve **her seferinde 1. terminale bakın**:

```sql
UPDATE shop.products SET price = 39999.00 WHERE sku = 'LPT-001';

INSERT INTO shop.customers (full_name, email, city)
     VALUES ('Deneme Kişi', 'deneme@example.com', 'İzmir');

DELETE FROM shop.customers WHERE email = 'deneme@example.com';
```

**Soru:** Uygulama koduna tek satır eklemeden veritabanı değişikliklerini yakaladık.
Bunu **periyodik sorgulama** (`SELECT … WHERE updated_at > ?`) ile yapsaydık hangi
üç problemle karşılaşırdık?

---

## 4.2 Snapshot

```bash
python scripts/cdc_watch.py --from-beginning --table products
```

**Soru:** `op` değeri `r` olan olaylar nedir? Neden `c` değil?

```bash
# Connector'ı silip snapshot.mode=never ile yeniden kurun
./scripts/register_connector.sh delete
docker exec week07_postgres psql -U kafka_user -d shopdb \
  -c "SELECT pg_drop_replication_slot('week07_slot');"
```

`connectors/postgres-source.json` içinde `"snapshot.mode": "never"` yapıp kaydedin.

**Soru:** Mevcut satırlar artık akıyor mu? Bu mod hangi durumda doğru seçimdir?

> Bitince `"initial"`a geri alın ve yeniden kaydedin.

---

## 4.3 Ham zarf: `before` / `after`

Ham (SMT'siz) connector'ı kurun:

```bash
curl -sS -X PUT -H "Content-Type: application/json" \
  --data @connectors/postgres-source-raw.json \
  http://localhost:8096/connectors/shop-cdc-raw/config | python3 -m json.tool

docker exec -it week07_kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:19092 --topic shopraw.shop.products
```

Başka terminalde:

```sql
UPDATE shop.products SET price = 45000.00, stock = 5 WHERE sku = 'LPT-002';
```

**Görev:** Gelen JSON'daki `before`, `after`, `source`, `op` alanlarını inceleyin.

**Soru:** `before` alanı dolu geldi. `01-schema.sql` içindeki hangi satır bunu mümkün kıldı?
O satır olmasaydı ne görürdünüz?

**Soru:** `before` + `after` birlikte olunca hangi iş sorusunu cevaplayabiliriz ki
sadece `after` ile cevaplayamayız?

```bash
# Temizlik
curl -X DELETE http://localhost:8096/connectors/shop-cdc-raw
docker exec week07_postgres psql -U kafka_user -d shopdb \
  -c "SELECT pg_drop_replication_slot('week07_slot_raw');"
```

---

## 4.4 Tombstone

```bash
python scripts/cdc_watch.py --table customers
```

```sql
INSERT INTO shop.customers (full_name, email, city)
     VALUES ('Geçici', 'gecici@example.com', 'Bursa');
DELETE FROM shop.customers WHERE email = 'gecici@example.com';
```

**Soru:** DELETE'ten sonra **iki** olay geldi. İkincisi (`🪦 TOMBSTONE`) neden var?
Log compaction'la ilişkisi nedir?

---

## 4.5 Replication slot bakımı

```sql
SELECT slot_name, active,
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS geride
FROM pg_replication_slots;
```

Connector'ı duraklatın, birkaç UPDATE atın, tekrar sorgulayın:

```bash
curl -X PUT http://localhost:8096/connectors/shop-cdc-connector/pause
```

**Soru:** `geride` değeri büyüyor. Connector haftalarca kapalı kalsa ne olur?
Bu neden production'da **disk dolması** olarak karşımıza çıkar?

```bash
curl -X PUT http://localhost:8096/connectors/shop-cdc-connector/resume
```

---

## 4.6 Yük altında yüksek hacim

```bash
# Terminal 1
python scripts/cdc_watch.py --table orders

# Terminal 2
python scripts/db_simulator.py --op insert --delay 0.05 --count 200
```

**Soru:** Gecikme (veritabanı işlemi → Kafka olayı) gözle görülür mü?
Kafka UI'da `shop.shop.orders` topic'inin mesaj sayısı veritabanındaki satır sayısıyla uyuşuyor mu?

---

## ✅ Ne öğrendik

- CDC, **WAL'ı okur** — uygulamaya dokunmaz, sorgu yükü getirmez, silmeleri de yakalar.
- `snapshot` (`op=r`) mevcut durumu, sonraki olaylar değişimi taşır.
- `REPLICA IDENTITY FULL` olmadan UPDATE'in **eski hali** kaybolur.
- Tombstone, compacted topic'te kaydın gerçekten silinebilmesi için gerekir.
- **Terk edilmiş replication slot, PostgreSQL diskini doldurur.** CDC'nin 1 numaralı operasyon riski budur.

📎 [Çözüm](./solutions/04-debezium-cdc.md)
