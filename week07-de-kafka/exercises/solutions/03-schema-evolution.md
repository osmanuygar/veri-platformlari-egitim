# ✅ Çözüm 3: Şema Evrimi

## 3.1 Şema mesajda taşınmıyor

Confluent'ın "wire format"ında her Avro mesajının başında **5 bayt** vardır:

```
[0x00]  [4 bayt: schema id]  [Avro ile kodlanmış gövde]
  ↑            ↑
sihirli    Registry'deki
 bayt       şema kimliği
```

Tüketici bu 4 baytlık kimliği okur, Schema Registry'ye sorar (`GET /schemas/ids/<id>`),
şemayı alır ve önbelleğe koyar. Sonraki mesajlarda ağ çağrısı yapmaz.

Kazanç: her mesajda şemayı taşımak yerine 4 bayt taşınır. Milyonlarca mesajda
bu, bant genişliği ve depolamada ciddi bir fark yaratır.

---

## 3.2 v1 tüketicisi v2 mesajını okuyabiliyor

v1 mesajlarında `channel` **hiç yok**, çıktıda `(v1 — alan yok)` görünür.

`avro_consumer.py` içinde şu satır kritik:

```python
ch = rec.get("channel", "(v1 — alan yok)")
```

Kod çökmedi çünkü:

1. `AvroDeserializer` her mesajı **yazıldığı** şemayla çözer (schema id'den bulur).
2. v1 mesajı v1 şemasıyla çözülür → `channel` alanı sözlükte yoktur.
3. Python tarafında `.get()` ile güvenli erişim yapılır.

Avro'nun asıl gücü ise *schema resolution*'dır: okuyucu şeması (reader schema) ile
yazıcı şeması (writer schema) farklı olabilir. Yeni alanın **varsayılanı** olduğu için,
v2 şemasıyla okumaya kalksanız bile v1 verisi `channel="web"` olarak doldurulur.

---

## 3.3 `bad` şeması neden reddedildi

`BACKWARD` uyumluluk, **yeni şemayla yazılmış veriyi eski şemayla okuyabilmeyi** garanti eder.

`bad` şemasında:
- `sku`, `quantity`, `total`, `created_at` **silindi**
- `amount` adında **varsayılanı olmayan zorunlu** bir alan eklendi

Eski (v1) okuyucu `sku` bekler; yeni veride yok ve varsayılanı da yok → **çözümlenemez**.
Registry bunu üretim anında reddeder:

```
Schema being registered is incompatible with an earlier schema
```

Kritik nokta: hata **veri Kafka'ya yazılmadan önce** alındı. Şemasız JSON kullansaydınız
bu mesaj sorunsuzca yazılır, sorun aylar sonra bir tüketicide `KeyError: 'sku'` olarak patlardı.

---

## 3.4 `NONE` moduna almak

Evet, kabul edilir. Registry artık hiçbir kontrol yapmaz — sadece bir şema deposu olur.

Production'daki bedeli:

- Bozuk şemayla yazılmış mesajlar topic'te **kalıcıdır**. Retention süresi boyunca
  her tüketici onlara çarpar.
- Hata üretim anında değil, **tüketim anında** ve genellikle **başka bir ekipte** ortaya çıkar.
- Geri dönüş yolu yok: topic'i yeniden işlemek (reprocess) ya da mesajları atlamak gerekir.

`NONE` yalnızca geliştirme ortamında veya topic'i baştan yaratmayı göze aldığınız
kontrollü bir migrasyonda anlamlıdır.

---

## 3.5 Uyumluluk tablosu

| Mod | Yeni şemayı kim okuyabilmeli | Alan **eklemek** | Alan **silmek** |
|---|---|---|---|
| `BACKWARD` | Yeni kod, eski veriyi | ✅ varsayılanı varsa | ✅ serbest |
| `FORWARD` | Eski kod, yeni veriyi | ✅ serbest | ✅ varsayılanı varsa |
| `FULL` | Her ikisi | ✅ **sadece** varsayılanı varsa | ✅ **sadece** varsayılanı varsa |
| `NONE` | — | ✅ her şey | ✅ her şey |

### Nasıl akılda tutulur

- **BACKWARD** = "önce tüketiciyi güncelle". Yeni tüketici eski veriyi okuyabilmeli →
  yeni eklenen alanın varsayılanı olmalı ki eski veride bulunamadığında doldurulsun.
- **FORWARD** = "önce producer'ı güncelle". Eski tüketici yeni veriyi okuyabilmeli →
  sildiğiniz alanın varsayılanı olmalı ki eski tüketici onu arayınca doldurabilsin.
- **FULL** = ikisi birden; en katı, en güvenli.

**Varsayılan `BACKWARD`'dır** çünkü gerçek hayatta tüketiciler producer'lardan
önce güncellenir (bir producer, onlarca tüketiciyi besler).

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Wire format | 1 sihirli bayt + 4 bayt schema id + gövde |
| Schema resolution | Yazıcı ve okuyucu şeması farklı olabilir |
| Güvenli ekleme | Yeni alana **her zaman** varsayılan verin |
| `BACKWARD` | Varsayılan ve en yaygın mod |
| `NONE` | Sadece geliştirme; production'da geri dönüşü yok |

**[← Alıştırma 3](../03-schema-evolution.md)**
