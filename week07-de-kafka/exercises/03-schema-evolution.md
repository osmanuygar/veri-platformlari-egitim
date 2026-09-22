# Alıştırma 3: Şema Evrimi

**Süre:** ~30 dakika · **Dosyalar:** `scripts/avro_producer.py`, `scripts/avro_consumer.py`

---

## 3.1 v1 şemasıyla üretin

```bash
python scripts/avro_producer.py --schema v1 --count 10
```

Kaydı görün:

```bash
curl -s http://localhost:8095/subjects | python3 -m json.tool
curl -s http://localhost:8095/subjects/orders-avro-value/versions | python3 -m json.tool
curl -s http://localhost:8095/subjects/orders-avro-value/versions/1 | python3 -m json.tool
```

**Soru:** Mesajın kendisinde şema **taşınmıyor**. Tüketici şemayı nereden biliyor?
(İpucu: Avro mesajının ilk 5 baytı)

---

## 3.2 v2 — geriye uyumlu ekleme

```bash
python scripts/avro_producer.py --schema v2 --count 10
curl -s http://localhost:8095/subjects/orders-avro-value/versions | python3 -m json.tool
```

**Görev:** `v1` tüketicisiyle `v2` mesajlarını okuyun:

```bash
python scripts/avro_consumer.py --from-beginning
```

**Soru:** v1 mesajlarında `channel` alanı nasıl göründü? Kod neden çökmedi?

---

## 3.3 Uyumsuz değişiklik

```bash
python scripts/avro_producer.py --schema bad --count 1
```

**Görev:** Hata mesajını okuyun ve neden reddedildiğini yazın.

Aktif uyumluluk modunu görün:

```bash
curl -s http://localhost:8095/config | python3 -m json.tool
```

---

## 3.4 Uyumluluk modlarını deneyin

```bash
# Bu konu (subject) için uyumluluğu kapat
curl -X PUT -H "Content-Type: application/json" \
  --data '{"compatibility":"NONE"}' \
  http://localhost:8095/config/orders-avro-value

python scripts/avro_producer.py --schema bad --count 1
```

**Soru:** Şimdi kabul edildi mi? Bunu production'da yapmanın bedeli nedir?

```bash
# Geri al!
curl -X PUT -H "Content-Type: application/json" \
  --data '{"compatibility":"BACKWARD"}' \
  http://localhost:8095/config/orders-avro-value
```

---

## 3.5 Uyumluluk tablosunu tamamlayın

| Mod | Yeni şemayı kim okuyabilmeli | Alan **eklemek** | Alan **silmek** |
|---|---|---|---|
| `BACKWARD` | Yeni kod, eski veriyi | | |
| `FORWARD` | Eski kod, yeni veriyi | | |
| `FULL` | Her ikisi | | |
| `NONE` | — | | |

> "Varsayılanı olan alan eklemek" ile "zorunlu alan eklemek" farklıdır. Ayrı ayrı düşünün.

---

## ✅ Ne öğrendik

- Avro mesajı şemayı **taşımaz**, şema **kimliğini** taşır — bant genişliği tasarrufu.
- Schema Registry bir **kapı bekçisidir**: uyumsuz değişikliği üretim anında reddeder.
- `BACKWARD` en yaygın moddur çünkü tüketiciler genelde producer'lardan sonra güncellenir.
- Şemasız (düz JSON) topic'in bedeli, kırılmanın **aylar sonra tüketicide** ortaya çıkmasıdır.

📎 [Çözüm](./solutions/03-schema-evolution.md)
