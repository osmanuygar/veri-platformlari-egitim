# ✅ Çözüm 5: Dead Letter Topic

## 5.1 Zehirli mesaj (poison pill)

`consumer.py` bozuk mesajda **sessizce `<çözümlenemedi>` basar ve devam eder**:

```python
except (json.JSONDecodeError, UnicodeDecodeError):
    label, total = "<çözümlenemedi>", ""
```

Çökmediği için "sorun yok" gibi görünür. **Gizli maliyeti** şudur:

- Mesaj **kaybolmuştur.** Offset commit edildi, kimse bir daha ona bakmayacak.
- Hiçbir **iz** yok: hangi mesajdı, neden bozuktu, kaç tane vardı — bilinmiyor.
- Sessiz veri kaybı, gürültülü çökmeden **daha tehlikelidir**. Çökme fark edilir;
  eksik veri aylar sonra bir raporda "rakamlar tutmuyor" olarak ortaya çıkar.

Diğer uç — `except` olmadan çökmek — daha da kötüdür: tüketici yeniden başlar,
aynı bozuk mesajı okur, yine çöker. Sonsuz döngü. Akış tamamen durur.
Bu yüzden adı **poison pill**: tek bir mesaj tüm boruyu tıkar.

---

## 5.2 Bozulma türleri

30 mesaj, %40 bozuk oranıyla tipik dağılım:

| Bozulma türü | Hangi aşamada yakalandı | Adet (yaklaşık) |
|---|---|---|
| Yarıda kesilmiş JSON | `parse` | 2 |
| JSON değil (XML) | `parse` | 2 |
| Boş gövde | `parse` | 2 |
| Zorunlu alan eksik | `validate` | 2 |
| Negatif quantity | `validate` | 2 |
| Tip hatası (`quantity: "iki"`) | `validate` | 2 |

Ayrım önemlidir:

- **`parse` hataları teknik**tir: byte'lar JSON değil. Genelde producer tarafında
  yanlış serileştirici, yarıda kesilen yazma ya da yanlış topic'e yazma.
- **`validate` hataları semantik**tir: JSON geçerli ama iş kuralına aykırı.
  Genelde yukarı akıştaki bir uygulama hatası ya da eksik doğrulama.

Bu ayrım, DLQ'yu incelerken **kimi arayacağınızı** belirler.

---

## 5.3 DLQ kaydındaki alanlar

| Alan | Neye yarar |
|---|---|
| `source_topic` | Birden fazla topic tek DLQ'ya yazıyorsa ayırt eder |
| `source_partition` + `source_offset` | **Mesajı orijinal yerinde bulmanızı sağlar.** Konsol tüketicisiyle o offset'e gidip ham veriyi, komşularını, zaman damgasını inceleyebilirsiniz. Düzeltme sonrası replay için de şarttır |
| `failure_stage` | `parse` mi `validate` mi — sorunun teknik mi semantik mi olduğunu söyler, hangi ekibe gideceğinizi belirler |
| `failure_reason` | Tam hata metni. "geçersiz quantity: -5" ile "zorunlu alan eksik: sku" tamamen farklı kök nedenlere işaret eder |
| `failed_at` | Zaman damgası. DLQ'ya düşenler belirli bir saatte kümelenmişse, o an yapılan bir deploy'la ilişkilendirirsiniz |
| `raw_value` | Ham gövde. Düzeltip yeniden işlemenin (replay) tek kaynağı |

Kural: **DLQ kaydı, hatayı orijinal akışa dönmeden teşhis edebilmenizi sağlamalıdır.**

---

## 5.4 Replay ve sonsuz döngü

`dlq_replay.py` DLQ'yu okur, düzeltilebilir olanları onarır ve `orders`'a geri yazar.

**Evet, naif bir replay sonsuz döngü yaratır:**

```
orders → dlq_consumer → (bozuk) → orders.dlq → replay → orders → dlq_consumer → …
```

Düzeltilemeyen bir mesaj bu çemberde sonsuza kadar döner ve her turda
DLQ'ya yeni bir kayıt daha ekler.

### Önleme yöntemleri

**1. Deneme sayacı (retry count)** — en yaygın
Mesaj başlığına (header) `retry-count` yazın. Replay her turda artırır.
Sınırı (örn. 3) aşan mesaj `orders.dlq.permanent` gibi bir **terminal** topic'e taşınır
ve bir daha replay edilmez.

**2. Yalnızca düzeltilebilir olanları replay et**
`dlq_replay.py`'nin yaptığı budur: `failure_reason`'a bakıp bilinen ve
onarılabilir hataları (tip dönüşümü gibi) seçer. Tanımadığı hatayı atlar.

**3. Replay'i manuel ve tek seferlik yap**
Otomatik replay hiç kurmayın. DLQ bir alarm tetiklesin, insan baksın,
kök nedeni düzeltsin, sonra elle replay çalıştırsın. Küçük hacimlerde en sağlıklısı.

**4. Ayrı bir replay topic'i kullan**
Düzeltilmiş mesajları `orders`'a değil `orders.replayed`'e yazın. Aynı tüketici
her iki topic'i de dinler ama replay edilmiş mesaj bir daha aynı DLQ'ya dönemez.

---

## 5.5 Teslimat garantileri

| Senaryo | Commit zamanı | Çökme anı | Sonuç |
|---|---|---|---|
| A | İşlemden **önce** | İşlem sırasında | **Mesaj KAYBOLUR** — offset ilerledi, iş yapılmadı. *at-most-once* |
| B | İşlemden **sonra** | Commit'ten önce | **Mesaj TEKRAR işlenir** — iş yapıldı ama offset ilerlemedi. *at-least-once* |
| C | İşlemden **sonra** | Commit'ten sonra | **Doğru** — iş yapıldı, offset ilerledi, tekrar yok |

Kafka'da bu üçünü aynı anda çözen sihirli bir ayar yoktur. Seçim şudur:
**ya kaybet (A) ya da tekrarla (B).** Neredeyse her iş için B tercih edilir —
tekrarı yönetmek, kaybı telafi etmekten kolaydır.

### Tekrarı zararsız kılan ilke: **idempotency**

Aynı mesajı iki kez işlemek, bir kez işlemekle **aynı sonucu** vermelidir.

| ❌ İdempotent değil | ✅ İdempotent |
|---|---|
| `UPDATE hesap SET bakiye = bakiye - 100` | `UPDATE hesap SET bakiye = 900 WHERE bakiye = 1000` |
| `INSERT INTO siparisler …` | `INSERT … ON CONFLICT (order_id) DO NOTHING` |
| `sayac += 1` | `SET islenmis_idler = islenmis_idler ∪ {id}` |
| E-posta gönder | `if not gonderildi(mesaj_id): gonder()` |

Pratik desenler:

- **Doğal anahtar + upsert:** `order_id`'yi primary key yapın, `ON CONFLICT DO UPDATE` kullanın.
- **İşlenmiş kimlik tablosu:** Her `message_id`'yi bir tabloya yazın; varsa atlayın.
  Aynı transaction içinde yaparsanız atomik olur.
- **Mutlak değer yazın, artış değil:** `bakiye = X` yazın, `bakiye += X` değil.

### Peki exactly-once?

Kafka'nın **transactional producer**'ı (`enable.idempotence` + `transactional.id`)
"read-process-write" kalıbında, yani Kafka'dan okuyup Kafka'ya yazarken exactly-once
sağlar. Ama zincirin ucunda Kafka **olmayan** bir sistem varsa (PostgreSQL, bir REST API,
bir e-posta servisi), Kafka'nın garantisi oraya uzanmaz.

Bu yüzden pratikte formül şudur:

> **exactly-once = at-least-once + idempotent tüketim**

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Poison pill | Tek bozuk mesaj tüm akışı tıkayabilir |
| Sessizce atlamak | Çökmekten daha tehlikeli — iz bırakmaz |
| DLQ kaydı | Ham mesaj **+ bağlam** (topic, offset, aşama, sebep) |
| Replay | Deneme sayacı olmadan sonsuz döngü riski |
| at-least-once | Varsayılan tercih; tekrarı idempotency ile çözün |

**[← Alıştırma 5](../05-dead-letter-queue.md)**
