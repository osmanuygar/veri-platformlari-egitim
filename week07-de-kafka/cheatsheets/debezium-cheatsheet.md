# 📋 Debezium & Kafka Connect Cheatsheet

Connect REST API: **http://localhost:8096**
PostgreSQL (CDC kaynağı): **localhost:5437** · `kafka_user` / `kafka_pass` / `shopdb`

```bash
alias connect='curl -sS http://localhost:8096'
```

---

## 🔌 Connector Yönetimi

```bash
# Kurulu eklentiler
connect/connector-plugins | python3 -m json.tool

# Connector'ları listele
connect/connectors

# Kaydet / güncelle (varsa üzerine yazar — idempotent)
curl -sS -X PUT -H "Content-Type: application/json" \
  --data @connectors/postgres-source.json \
  http://localhost:8096/connectors/shop-cdc-connector/config | python3 -m json.tool

# Durum  ← sorun çıkınca İLK bakılacak yer
connect/connectors/shop-cdc-connector/status | python3 -m json.tool

# Aktif yapılandırma
connect/connectors/shop-cdc-connector/config | python3 -m json.tool

# Duraklat / devam ettir
curl -X PUT http://localhost:8096/connectors/shop-cdc-connector/pause
curl -X PUT http://localhost:8096/connectors/shop-cdc-connector/resume

# Yeniden başlat (task'lar dahil)
curl -X POST "http://localhost:8096/connectors/shop-cdc-connector/restart?includeTasks=true"

# Tek bir task'ı yeniden başlat
curl -X POST http://localhost:8096/connectors/shop-cdc-connector/tasks/0/restart

# Sil
curl -X DELETE http://localhost:8096/connectors/shop-cdc-connector
```

Yardımcı script (aynı işleri yapar):

```bash
./scripts/register_connector.sh register|status|list|restart|delete
```

---

## 🧭 Debezium Olay Yapısı

SMT (`ExtractNewRecordState`) **kapalıyken** ham zarf:

```json
{
  "before": { "id": 1, "price": "32999.00" },
  "after":  { "id": 1, "price": "35999.00" },
  "source": {
    "db": "shopdb", "schema": "shop", "table": "products",
    "lsn": 24857392, "ts_ms": 1758531600000, "snapshot": "false"
  },
  "op": "u",
  "ts_ms": 1758531600123
}
```

SMT **açıkken** (bu haftanın varsayılanı) sadece `after` + `__` önekli metadata gelir:

```json
{ "id": 1, "price": "35999.00", "__op": "u", "__source_ts_ms": 1758531600000 }
```

### `op` kodları

| Kod | Anlamı | Ne zaman |
|---|---|---|
| `r` | **read** | İlk snapshot sırasında mevcut satırlar |
| `c` | **create** | INSERT |
| `u` | **update** | UPDATE |
| `d` | **delete** | DELETE |
| *(null değer)* | **tombstone** | DELETE'ten hemen sonra; log compaction için |

---

## 🏷 Topic Adlandırma

```
<topic.prefix>.<şema>.<tablo>
```

Bu haftanın ayarıyla (`topic.prefix=shop`, şema `shop`):

| Tablo | Topic |
|---|---|
| `shop.customers` | `shop.shop.customers` |
| `shop.products` | `shop.shop.products` |
| `shop.orders` | `shop.shop.orders` |
| `shop.order_items` | `shop.shop.order_items` |

```bash
# CDC topic'lerini listele
docker exec week07_kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:19092 --list | grep '^shop\.'

# Bir tabloyu canlı izle
docker exec -it week07_kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:19092 --topic shop.shop.products --from-beginning
```

---

## ⚙️ Önemli Debezium Ayarları

| Ayar | Seçenekler | Not |
|---|---|---|
| `snapshot.mode` | `initial` / `never` / `always` / `initial_only` | `initial`: önce mevcut veri, sonra canlı akış |
| `plugin.name` | `pgoutput` / `decoderbufs` | PostgreSQL 10+ için `pgoutput` (ek kurulum yok) |
| `slot.name` | replication slot adı | Her connector için **benzersiz** olmalı |
| `publication.name` | PostgreSQL publication | Önceden yaratın ya da `publication.autocreate.mode` |
| `table.include.list` | `şema.tablo,…` | İzlenen tabloları sınırlayın; WAL yükünü düşürür |
| `decimal.handling.mode` | `precise` / `double` / `string` | `precise` base64 döner — okunmaz. `string` tercih edin |
| `tombstones.on.delete` | `true` / `false` | Compacted topic kullanıyorsanız `true` |
| `heartbeat.interval.ms` | ms | Sessiz tablolarda slot'un şişmesini önler |

---

## 🗄 PostgreSQL Tarafı

```bash
# psql'e gir
docker exec -it week07_postgres psql -U kafka_user -d shopdb

# Tek satırlık sorgu
docker exec week07_postgres psql -U kafka_user -d shopdb -c "SELECT * FROM shop.v_order_summary;"
```

```sql
-- wal_level logical mi? (Debezium için ŞART)
SHOW wal_level;

-- Replication slot'ları
SELECT slot_name, plugin, active,
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS geride_kalan_wal
FROM pg_replication_slots;

-- Publication'lar ve kapsadıkları tablolar
SELECT * FROM pg_publication;
SELECT * FROM pg_publication_tables;

-- Tablonun REPLICA IDENTITY ayarı
-- d = default (sadece PK), f = full (tüm satır), n = nothing, i = index
SELECT relname, relreplident FROM pg_class
WHERE relname IN ('customers','products','orders','order_items');

-- CDC olayı üretmek için birkaç işlem
UPDATE shop.products SET price = price * 1.10 WHERE sku = 'LPT-001';
INSERT INTO shop.customers (full_name, email, city)
     VALUES ('Yeni Müşteri', 'yeni@example.com', 'İstanbul');
DELETE FROM shop.customers WHERE email = 'yeni@example.com';
```

> ⚠️ **Terk edilmiş slot = dolan disk.** Connector silindiğinde slot PostgreSQL'de kalır
> ve WAL'ın temizlenmesini engeller. Temizlik:
> ```sql
> SELECT pg_drop_replication_slot('week07_slot');
> ```

---

## 🧯 Sorun Giderme

| Belirti | Olası sebep | Kontrol |
|---|---|---|
| Connector `FAILED` | Bağlantı/yetki/slot hatası | `connect/connectors/<ad>/status` içindeki `trace` |
| Topic'e hiç olay düşmüyor | Tablo `table.include.list` dışında | Ayarı kontrol edin |
| `logical decoding requires wal_level >= logical` | Postgres ayarı | `SHOW wal_level;` → compose'daki `-c wal_level=logical` |
| `replication slot is active` | Aynı slot iki connector'da | `slot.name`'i benzersiz yapın |
| UPDATE'te `before` boş | `REPLICA IDENTITY DEFAULT` | `ALTER TABLE … REPLICA IDENTITY FULL` |
| Sayılar base64 geliyor | `decimal.handling.mode=precise` | `string` yapın |
| Disk doluyor | Terk edilmiş slot WAL tutuyor | `pg_replication_slots` → `pg_drop_replication_slot` |
| Snapshot bitmiyor | Tablo çok büyük | `snapshot.fetch.size`, ya da `snapshot.mode=never` |

```bash
# Connect logları — hata metni burada
docker compose logs -f connect

# Sadece hatalar
docker compose logs connect | grep -iE "error|exception|failed"
```

---

**[← Kafka Cheatsheet](./kafka-cheatsheet.md)** · **[Hafta 7 README →](../README.md)**
