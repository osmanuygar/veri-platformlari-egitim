# 📝 Hafta 7 Alıştırmaları

Önce kendiniz deneyin, sonra `solutions/` klasörüne bakın. Her alıştırmanın sonunda
**"Ne öğrendik"** bölümü var — asıl mesele orada.

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Producer & Consumer](./01-producer-consumer.md) | 25 dk | Temel üretim/tüketim, key seçimi, `acks` |
| 2 | [Partition, Consumer Group ve Lag](./02-partitions-and-lag.md) | 35 dk | Paralel tüketim, rebalance, lag ölçümü |
| 3 | [Şema Evrimi](./03-schema-evolution.md) | 30 dk | Avro, Schema Registry, uyumluluk kuralları |
| 4 | [Debezium ile CDC](./04-debezium-cdc.md) | 40 dk | Logical replication, olay zarfı, snapshot |
| 5 | [Dead Letter Topic](./05-dead-letter-queue.md) | 30 dk | Bozuk mesaj yönetimi, teslimat garantileri |

**Ön koşul:** `./setup-week07.sh` çalıştı ve `pip install -r requirements.txt` yapıldı.

```bash
# Ortamın ayakta olduğunu doğrulayın
docker compose ps
curl -s http://localhost:8096/connectors
open http://localhost:8092        # Kafka UI
```

---

**[← Hafta 7 README](../README.md)**
