# Alıştırma 2: Partition, Consumer Group ve Lag

**Süre:** ~35 dakika · **Dosyalar:** `scripts/consumer.py`, `scripts/lag_monitor.py`

---

## 2.1 Paralel tüketim

`orders` topic'i 3 partition'a sahip. Üç terminal açıp **aynı grupla** tüketici başlatın:

```bash
python scripts/consumer.py --group ex2      # Terminal 1
python scripts/consumer.py --group ex2      # Terminal 2
python scripts/consumer.py --group ex2      # Terminal 3
```

Her terminalde `⇄ ATAMA` satırına bakın.

**Görev:** Hangi tüketiciye hangi partition düştü?

| Tüketici | Atanan partition'lar |
|---|---|
| 1 | |
| 2 | |
| 3 | |

Şimdi **dördüncü** bir tüketici başlatın.

**Soru:** Ne oldu? Neden?

---

## 2.2 Rebalance

3 tüketici çalışırken 2. terminalde `Ctrl+C` yapın.

**Görev:** Diğer terminallerde gördüğünüz `⇄ GERİ ALMA` / `⇄ ATAMA` satırlarını not edin.

**Soru:** Rebalance sırasında mesaj işleme **durur mu**? `cooperative-sticky`
stratejisi bunu nasıl hafifletiyor? (İpucu: `consumer.py` içindeki
`partition.assignment.strategy` satırı)

---

## 2.3 Farklı gruplar birbirini etkilemez

```bash
python scripts/consumer.py --group analytics   # Terminal 1
python scripts/consumer.py --group audit       # Terminal 2
python scripts/producer.py --count 10          # Terminal 3
```

**Soru:** Her iki grup da 10 mesajın tamamını aldı mı? Bu, Kafka'yı klasik bir
mesaj kuyruğundan (RabbitMQ gibi) nasıl ayırıyor?

---

## 2.4 Lag üretin ve ölçün

```bash
# Terminal 1 — hızlı üretim
python scripts/producer.py --rate 200 --quiet

# Terminal 2 — yavaş tüketim (her mesaj 100 ms)
python scripts/consumer.py --group slow --process-ms 100

# Terminal 3 — lag'i izle
python scripts/lag_monitor.py --group slow --watch
```

**Görev:** Lag'i 30 saniye izleyin ve kaydedin.

| Saniye | Toplam lag |
|---|---|
| 0 | |
| 10 | |
| 20 | |
| 30 | |

**Soru:** Producer saniyede 200, consumer saniyede ~10 mesaj işliyor.
Lag saniyede kaç artmalı? Ölçtüğünüzle uyuşuyor mu?

---

## 2.5 Lag'i kapatın

Aynı grupla 2 tüketici daha başlatın (toplam 3).

**Soru:** Lag'in büyüme hızı düştü mü? **4.** tüketiciyi eklerseniz daha da düşer mi?
Bu topic'te paralelliğin üst sınırı nedir?

**Bonus:** Partition sayısını artırın ve tekrar deneyin.

```bash
docker exec week07_kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:19092 --alter --topic orders --partitions 6
```

**Soru:** Bu değişiklik `--key-by customer` ile üretilmiş mesajların
**sıra garantisini** bozar mı? Neden?

---

## ✅ Ne öğrendik

- Bir grup içinde bir partition'ı **tek bir tüketici** okur → paralellik tavanı = partition sayısı.
- Farklı `group.id`'ler aynı veriyi **bağımsız** okur (pub/sub); Kafka bir kuyruk değil, bir logtur.
- **Lag** tüketici sağlığının birinci göstergesidir; sabit büyüyen lag kapasite sorunudur.
- Partition sayısını artırmak key→partition eşlemesini değiştirir ve sıra garantisini kırar.

📎 [Çözüm](./solutions/02-partitions-and-lag.md)
