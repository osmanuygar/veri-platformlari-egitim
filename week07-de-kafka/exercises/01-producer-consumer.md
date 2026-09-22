# Alıştırma 1: Producer & Consumer

**Süre:** ~25 dakika · **Dosyalar:** `scripts/producer.py`, `scripts/consumer.py`

---

## 1.1 İlk akış

İki terminal açın.

```bash
# Terminal 1 — dinle
python scripts/consumer.py --group ex1

# Terminal 2 — üret
python scripts/producer.py --count 20
```

**Soru:** Consumer'ı producer'dan **sonra** başlatsaydınız mesajları görür müydünüz?
Neden? (İpucu: `auto.offset.reset`)

---

## 1.2 Key ve partition dağılımı

```bash
# Key = customer_id
python scripts/producer.py --count 60 --key-by customer

# Key = rastgele UUID
python scripts/producer.py --count 60 --key-by random

# Key yok
python scripts/producer.py --count 60 --key-by none
```

Her çalıştırmadan sonra Kafka UI → **Topics → orders → Messages**'ta partition
dağılımına bakın (ya da `--from-beginning` ile `print.partition=true` kullanın).

**Görev:** Tabloyu doldurun.

| Key stratejisi | p0 | p1 | p2 | Aynı müşteri hep aynı partition'da mı? |
|---|---|---|---|---|
| `customer` | | | | |
| `random` | | | | |
| `none` | | | | |

**Soru:** Bir müşterinin sipariş olaylarının **sırasının korunması** gerekiyorsa
hangi stratejiyi seçmelisiniz? Neden diğerleri olmaz?

---

## 1.3 `acks` ödünleşmesi

```bash
python scripts/producer.py --count 2000 --rate 0 --acks 0   --quiet
python scripts/producer.py --count 2000 --rate 0 --acks 1   --quiet
python scripts/producer.py --count 2000 --rate 0 --acks all --quiet
```

`--rate 0` gecikmesiz üretir; çıktıdaki `msg/sn` değerini karşılaştırın.

| acks | msg/sn | Broker çökerse veri kaybı? |
|---|---|---|
| 0 | | |
| 1 | | |
| all | | |

**Soru:** Bu haftanın kümesi **tek broker**. `acks=all` ile `acks=1` arasındaki
dayanıklılık farkı burada neden gözlemlenemez?

---

## 1.4 `flush()` neden şart?

`scripts/producer.py` içindeki `producer.flush(timeout=10)` satırını yorum satırına alın,
sonra çalıştırın:

```bash
python scripts/producer.py --count 500 --rate 0 --quiet
```

Tüketilen mesaj sayısını sayın:

```bash
python scripts/consumer.py --group ex1-flush --from-beginning
```

**Soru:** Kaç mesaj eksik? Neden?

> Bitince değişikliği geri alın (`git checkout scripts/producer.py`).

---

## ✅ Ne öğrendik

- `produce()` **asenkrondur**; mesaj çağrı döndüğünde henüz gönderilmemiş olabilir.
- **Key, partition'ı belirler** — sıra garantisi partition içinde geçerlidir, topic genelinde değil.
- `acks` bir dayanıklılık/gecikme ödünleşmesidir ve replikasyon olmadan anlamı sınırlıdır.
- Çıkmadan önce `flush()` çağırmamak, veri kaybının en sık sebebidir.

📎 [Çözüm](./solutions/01-producer-consumer.md)
