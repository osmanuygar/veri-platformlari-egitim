# 📋 Kafka Cheatsheet

> Bu haftanın broker'ı container içinde `localhost:19092`, host'tan `localhost:9092`.
> `docker exec` ile çalıştırırken **19092**, kendi makinenizden bağlanırken **9092** kullanın.

Kısaltma için önce şunu tanımlayın:

```bash
alias kt='docker exec -it week07_kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:19092'
alias kc='docker exec -it week07_kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:19092'
alias kp='docker exec -it week07_kafka /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:19092'
alias kg='docker exec -it week07_kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:19092'
```

---

## 🗂 Topic İşlemleri

```bash
# Listele
kt --list

# Oluştur
kt --create --topic orders --partitions 3 --replication-factor 1

# Detay: partition, lider, ISR
kt --describe --topic orders

# Partition SAYISINI ARTIR (azaltmak mümkün değil!)
kt --alter --topic orders --partitions 6

# Sil
kt --delete --topic orders

# Yapılandırmayı gör
kt --describe --topic orders --all
```

> ⚠️ **Partition sayısı azaltılamaz.** Artırmak da key→partition eşlemesini bozar:
> aynı key artık farklı partition'a düşebilir, sıra garantisi kırılır.
> Kapasiteyi baştan biraz cömert planlayın.

---

## 📤 Mesaj Üretme

```bash
# Basit
echo '{"sku":"LPT-001","qty":1}' | kp --topic orders

# Key ile (key:value formatı)
kp --topic orders --property "parse.key=true" --property "key.separator=:"
# > 42:{"sku":"LPT-001","qty":1}

# Dosyadan toplu
docker exec -i week07_kafka /opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server localhost:19092 --topic orders < events.jsonl
```

---

## 📥 Mesaj Tüketme

```bash
# Şu andan itibaren
kc --topic orders

# En baştan
kc --topic orders --from-beginning

# Key, partition, offset, zaman damgasıyla
kc --topic orders --from-beginning \
   --property print.key=true \
   --property print.partition=true \
   --property print.offset=true \
   --property print.timestamp=true

# Sadece belirli partition
kc --topic orders --partition 0 --from-beginning

# Belirli offset'ten
kc --topic orders --partition 0 --offset 100

# Grup olarak tüket (offset commit eder)
kc --topic orders --group analytics

# İlk N mesaj
kc --topic orders --from-beginning --max-messages 10
```

---

## 👥 Consumer Group ve Lag

```bash
# Grupları listele
kg --list

# Lag dahil detay  ← en çok kullanılan komut
kg --describe --group analytics

# Çıktı sütunları:
#   TOPIC PARTITION CURRENT-OFFSET LOG-END-OFFSET LAG CONSUMER-ID HOST CLIENT-ID
#   LAG = LOG-END-OFFSET − CURRENT-OFFSET

# Tüm gruplar
kg --describe --all-groups

# Offset'i başa al (grup DURMUŞ olmalı)
kg --group analytics --topic orders --reset-offsets --to-earliest --execute

# Sona al (birikmiş mesajları atla)
kg --group analytics --topic orders --reset-offsets --to-latest --execute

# Belirli zamana
kg --group analytics --topic orders \
   --reset-offsets --to-datetime 2026-09-22T10:00:00.000 --execute

# N mesaj geri sar
kg --group analytics --topic orders --reset-offsets --shift-by -100 --execute

# Önce prova et (--execute yerine)
kg --group analytics --topic orders --reset-offsets --to-earliest --dry-run

# Grubu sil
kg --delete --group analytics
```

> 💡 `--reset-offsets` grup **aktifken çalışmaz**. Önce tüm tüketicileri kapatın.

---

## 🔍 Teşhis

```bash
# Broker sürümü / canlı mı
docker exec week07_kafka /opt/kafka/bin/kafka-broker-api-versions.sh \
  --bootstrap-server localhost:19092

# Partition'daki ilk ve son offset
docker exec week07_kafka /opt/kafka/bin/kafka-get-offsets.sh \
  --bootstrap-server localhost:19092 --topic orders

# Topic'teki toplam mesaj sayısı (son − ilk)
docker exec week07_kafka /opt/kafka/bin/kafka-get-offsets.sh \
  --bootstrap-server localhost:19092 --topic orders --time -1

# Log segment dosyalarını çöz
docker exec week07_kafka /opt/kafka/bin/kafka-dump-log.sh \
  --files /tmp/kraft-combined-logs/orders-0/00000000000000000000.log --print-data-log

# Performans testi — üretim
docker exec week07_kafka /opt/kafka/bin/kafka-producer-perf-test.sh \
  --topic perf-test --num-records 100000 --record-size 200 --throughput -1 \
  --producer-props bootstrap.servers=localhost:19092

# Performans testi — tüketim
docker exec week07_kafka /opt/kafka/bin/kafka-consumer-perf-test.sh \
  --bootstrap-server localhost:19092 --topic perf-test --messages 100000
```

---

## ⚙️ Önemli Producer Ayarları

| Ayar | Anlamı | Ne zaman değiştirilir |
|---|---|---|
| `acks=0` | Onay bekleme | Metrik/log gibi kaybı tolere edilebilen veri |
| `acks=1` | Lider yazdı | Varsayılan denge; lider çökerse kayıp olabilir |
| `acks=all` | Tüm ISR yazdı | Finansal/kritik veri. `min.insync.replicas` ile birlikte anlamlı |
| `enable.idempotence=true` | Yeniden denemede tekrar yazma | Neredeyse her zaman açık olmalı (acks=all gerektirir) |
| `linger.ms` | Batch için bekleme | Artırmak verimi yükseltir, gecikmeyi artırır |
| `batch.size` | Batch üst sınırı (bayt) | Yüksek hacimde artırın |
| `compression.type` | `none/gzip/snappy/lz4/zstd` | `zstd` en iyi oran, `lz4` en hızlı |
| `max.in.flight.requests.per.connection` | Onaysız paralel istek | Idempotence yoksa sıralama için 1 yapın |

---

## ⚙️ Önemli Consumer Ayarları

| Ayar | Anlamı | Not |
|---|---|---|
| `group.id` | Grup kimliği | Aynı grup → partition paylaşımı |
| `auto.offset.reset` | `earliest` / `latest` | **Sadece commit edilmiş offset yokken** geçerli |
| `enable.auto.commit` | Periyodik otomatik commit | `false` + elle commit = at-least-once |
| `max.poll.records` | poll başına mesaj | İşlem yavaşsa düşürün |
| `max.poll.interval.ms` | İki poll arası üst sınır | Aşılırsa "öldü" sayılır, rebalance olur |
| `session.timeout.ms` | Heartbeat zaman aşımı | Kısa = hızlı tespit, gereksiz rebalance riski |
| `partition.assignment.strategy` | `range` / `roundrobin` / `sticky` / `cooperative-sticky` | `cooperative-sticky` duraklamayı azaltır |

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `UNKNOWN_TOPIC_OR_PART` | Topic yok / henüz yayılmadı | `kt --create` ya da birkaç saniye bekleyin |
| Tüketici hiç mesaj almıyor | `auto.offset.reset=latest` ve grup yeni | `--from-beginning` veya offset reset |
| `CommitFailedException` | İşlem `max.poll.interval.ms`'i aştı | `max.poll.records` düşürün ya da süreyi artırın |
| Sürekli rebalance | `session.timeout.ms` kısa / tüketici yavaş | Süreyi artırın, işlemi hızlandırın |
| Producer'da mesaj kayboluyor | `flush()` çağrılmamış | Çıkmadan önce `producer.flush()` |
| Tüm mesajlar tek partition'da | Key sabit ya da null değil | Key dağılımını kontrol edin |
| Lag sürekli büyüyor | Tüketici üretime yetişemiyor | Partition + tüketici sayısını artırın |

---

## 🖥 Kafka UI (http://localhost:8092)

| Yapmak istediğiniz | Nerede |
|---|---|
| Topic'leri ve partition'ları görmek | **Topics** |
| Mesajları okumak, filtrelemek | **Topics → \<topic\> → Messages** |
| Lag'i görmek | **Consumers → \<group\>** |
| Şema sürümlerini görmek | **Schema Registry** |
| Connector durumu / restart | **Kafka Connect → debezium** |
| Topic oluşturmak / partition artırmak | **Topics → Add a Topic** |

---

**[← Hafta 7 README](../README.md)** · **[Debezium Cheatsheet →](./debezium-cheatsheet.md)**
