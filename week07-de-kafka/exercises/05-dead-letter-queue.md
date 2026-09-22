# Alıştırma 5: Dead Letter Topic

**Süre:** ~30 dakika · **Dosyalar:** `scripts/dlq_consumer.py`, `scripts/poison_producer.py`

---

## 5.1 Zehirli mesaj (poison pill)

Önce **saf** bir tüketiciyle ne olduğunu görün:

```bash
# Terminal 1
python scripts/consumer.py --group naive

# Terminal 2
python scripts/poison_producer.py --count 10 --bad-rate 1.0
```

**Soru:** `consumer.py` bozuk mesajda ne yaptı? (`try/except` bloğuna bakın.)
Bu davranışın **gizli maliyeti** nedir?

---

## 5.2 DLQ'lu tüketici

```bash
# Terminal 1
python scripts/dlq_consumer.py --group robust

# Terminal 2
python scripts/poison_producer.py --count 30 --bad-rate 0.4
```

**Görev:** Çıktıdaki `→ DLQ` satırlarını sayın ve bozulma türlerine göre gruplayın.

| Bozulma türü | Hangi aşamada yakalandı (`parse` / `validate`) | Adet |
|---|---|---|
| Yarıda kesilmiş JSON | | |
| JSON değil (XML) | | |
| Zorunlu alan eksik | | |
| Negatif quantity | | |
| Tip hatası | | |
| Boş gövde | | |

---

## 5.3 DLQ'yu inceleyin

```bash
python scripts/dlq_consumer.py --inspect
```

**Soru:** DLQ kaydı yalnızca ham mesajı değil, `source_topic`, `source_partition`,
`source_offset`, `failure_stage` ve `failure_reason` alanlarını da saklıyor.
Her biri hata ayıklamada **tam olarak neye** yarar?

---

## 5.4 Yeniden işleme (replay)

Bir bozulma türü aslında düzeltilebilir olsun — diyelim `quantity: "iki"` gibi
tip hataları için bir dönüştürücü yazdınız.

**Görev:** `solutions/dlq_replay.py` dosyasını inceleyin ve çalıştırın:

```bash
python exercises/solutions/dlq_replay.py --dry-run
python exercises/solutions/dlq_replay.py
```

**Soru:** Replay'i çalıştırdığınızda mesajlar `orders` topic'ine **geri** yazılıyor.
Bu, düzeltilemeyen bir mesajda **sonsuz döngü** yaratır mı? Nasıl önlenir?

---

## 5.5 Teslimat garantileri

`dlq_consumer.py` içinde `consumer.commit(msg)` çağrısı **işlemden sonra** yapılıyor.

**Görev:** Üç senaryoyu tamamlayın.

| Senaryo | Commit zamanı | Çökme anı | Sonuç |
|---|---|---|---|
| A | İşlemden **önce** | İşlem sırasında | |
| B | İşlemden **sonra** | Commit'ten önce | |
| C | İşlemden **sonra** | Commit'ten sonra | |

**Soru:** B senaryosunda mesaj yeniden işlenir. Bunu zararsız hale getiren
tasarım ilkesi nedir? (İpucu: aynı mesajı iki kez işlemek sonucu değiştirmemeli)

---

## ✅ Ne öğrendik

- Bozuk mesaj kaçınılmazdır; seçim **çökmek** ile **sessizce kaybetmek** arasında değil,
  **DLQ'ya yazmak** olmalıdır.
- DLQ kaydı, mesajın kendisi kadar **bağlamını** da taşımalıdır.
- Offset'i işlemden sonra commit etmek **at-least-once** verir — yani tekrar mümkündür.
- Tekrarı zararsız kılan şey **idempotent tüketimdir**; exactly-once'ın pratikteki karşılığı budur.

📎 [Çözüm](./solutions/05-dead-letter-queue.md)
