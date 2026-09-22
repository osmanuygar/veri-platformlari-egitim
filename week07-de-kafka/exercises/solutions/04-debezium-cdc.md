# ✅ Çözüm 4: Debezium ile CDC

## 4.1 CDC vs periyodik sorgulama

`SELECT … WHERE updated_at > ?` yaklaşımının üç temel problemi:

### 1. Silmeleri göremez
Satır `DELETE` edildiğinde sorgu sonucunda **yok**tur. Yokluğu fark etmenin tek yolu
tüm tabloyu karşılaştırmaktır. CDC ise `op=d` olayını doğrudan üretir.

### 2. Ara durumları kaçırır
Bir satır iki sorgulama arasında 5 kez güncellenirse, sorgulama sadece **son hali**
görür. Ara adımlar kaybolur. "Sipariş `created → paid → cancelled → paid` oldu"
bilgisi silinir; CDC her geçişi ayrı olay olarak verir.

### 3. Kaynak veritabanına yük bindirir
Her sorgulama gerçek bir sorgudur. Sıklığı artırdıkça (düşük gecikme için) OLTP
veritabanına yük binerr. CDC ise **WAL'ı okur** — zaten yazılmış olan log dosyasını.
Veritabanına ek sorgu gitmez.

Bonus problemler: `updated_at` sütunu olmayan tablolar, saat kayması (clock skew),
ve uzun süren transaction'larda `updated_at`'in commit'ten önce yazılması nedeniyle
atlanan satırlar.

---

## 4.2 Snapshot ve `op=r`

`op=r` → **read**. Connector ilk kez bağlandığında `snapshot.mode=initial` ile
tablolardaki **mevcut satırların tamamını** okur ve topic'e basar.

Neden `c` (create) değil: o satırlar *şimdi oluşturulmadı*; zaten vardılar.
Debezium dürüst davranıp "bu bir değişiklik değil, mevcut durumun okunması" der.
Tüketici tarafında bu ayrım önemlidir — `r` olaylarını "yeni sipariş geldi"
bildirimi olarak işlerseniz, connector her yeniden kurulduğunda binlerce sahte bildirim gönderirsiniz.

### `snapshot.mode=never`

Mevcut satırlar **akmaz**; sadece connector kurulduktan sonraki değişiklikler gelir.

Doğru olduğu durumlar:
- Hedef sistem zaten dolu (başka yolla yüklendi), sadece değişiklikleri takip etmek istiyorsunuz
- Tablo çok büyük ve snapshot saatler sürecek; ilk yüklemeyi toplu (bulk) bir işle yapıp
  CDC'yi oradan devralmak istiyorsunuz
- Yalnızca "bundan sonra ne oluyor" ilginizi çekiyor (denetim/audit akışı)

---

## 4.3 `before` / `after` ve `REPLICA IDENTITY`

Ham zarf:

```json
{
  "before": {"id": 2, "sku": "LPT-002", "price": "54999.00", "stock": 12, ...},
  "after":  {"id": 2, "sku": "LPT-002", "price": "45000.00", "stock": 5,  ...},
  "source": {"db": "shopdb", "table": "products", "lsn": 24857392, "ts_ms": ...},
  "op": "u",
  "ts_ms": 1758531600123
}
```

**`before`'ı dolduran satır:** `init/01-schema.sql` içindeki

```sql
ALTER TABLE products REPLICA IDENTITY FULL;
```

O satır olmasaydı (varsayılan `DEFAULT`), `before` yalnızca **primary key** içerirdi:

```json
"before": {"id": 2}
```

Çünkü `REPLICA IDENTITY DEFAULT` modunda PostgreSQL WAL'a satırın eski halinden
sadece PK'yı yazar — replikasyon için teknik olarak yeterli olan minimum bilgi budur.
`FULL` dediğimizde tüm eski sütunlar WAL'a yazılır.

Bedeli: **WAL boyutu büyür.** Geniş tablolarda ve yoğun UPDATE'te bu ciddi bir maliyettir.
Production'da tablo tablo karar verilir.

### `before` + `after` ile cevaplanabilen sorular

Sadece `after` ile **cevaplanamayan**, ikisi birlikte olunca cevaplanan sorular:

- **"Hangi sütun değişti?"** — `after` tek başına sadece yeni durumu verir.
  Fiyat mı değişti, stok mu, yoksa sadece `updated_at` mi? Ayırt edemezsiniz.
- **"Değişimin büyüklüğü nedir?"** — "fiyat %18 arttı" gibi bir kural (örn. anormal
  fiyat değişikliği alarmı) eski değere ihtiyaç duyar.
- **"Durum geçişi geçerli mi?"** — `shipped → created` gibi geriye dönüşleri
  yakalamak için önceki durumu bilmek gerekir.
- **Denetim (audit) kaydı** — "kim neyi neden ne yaptı" sorusunda "neden ne"
  kısmı eski değer olmadan eksiktir.

---

## 4.4 Tombstone

DELETE sonrası iki olay gelir:

1. `op=d` — silme olayının kendisi (`before` dolu, `after` null)
2. **tombstone** — aynı key, **null değer**

Tombstone'un sebebi **log compaction**'dır.

Compacted bir topic'te Kafka, her key için yalnızca **en son değeri** saklar; eski
sürümleri temizler. Böylece topic, tablonun anlık görüntüsü gibi davranır.

Ama silinen bir kayıt için "en son değer" ne olmalı? Eğer sadece `op=d` olayı olsaydı,
compaction o olayı sonsuza kadar saklardı — kayıt hiç silinmezdi.

**Null değer, compaction'a "bu key'i tamamen kaldır" der.** Belirli bir gecikme
(`delete.retention.ms`) sonrasında key topic'ten tümüyle silinir.

`tombstones.on.delete=true` ayarı bunu kontrol eder. Compacted topic kullanıyorsanız
**açık olmalı**; yoksa silinen kayıtlar birikir.

---

## 4.5 Replication slot bakımı

`geride` (WAL lag) değeri büyür çünkü:

PostgreSQL, bir replication slot'un **henüz okumadığı** WAL segmentlerini silemez.
Slot "ben buraya kadar okudum" (`restart_lsn`) der; PostgreSQL o noktadan öncesini
temizleyebilir, sonrasını **tutmak zorundadır**.

Connector durduğunda `restart_lsn` ilerlemez. Veritabanı yazmaya devam eder.
WAL birikir.

**Connector haftalarca kapalı kalırsa:** WAL dizini (`pg_wal/`) büyümeye devam eder ve
sonunda **disk dolar**. Disk dolduğunda PostgreSQL **yazma kabul etmeyi bırakır** —
yani CDC'nin kapalı olması, izlediği veritabanını durdurur.

Bu, CDC'nin 1 numaralı operasyon riskidir ve şaşırtıcı gelir: "sadece bir okuyucu
kapandı, neden production veritabanı durdu?"

### Korunma

```sql
-- İzleme: slot'ların ne kadar geride kaldığını düzenli kontrol edin
SELECT slot_name, active,
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS geride
FROM pg_replication_slots;
```

- `max_slot_wal_keep_size` ayarlayın (PostgreSQL 13+): slot bu sınırı aşarsa
  geçersiz kılınır — veritabanı durmaz, sadece o slot bozulur (yeniden snapshot gerekir).
- Terk edilmiş slot'ları **mutlaka** silin: `SELECT pg_drop_replication_slot('week07_slot');`
- Slot lag'i için alarm kurun.
- Sessiz tablolarda `heartbeat.interval.ms` kullanın: hiç değişiklik olmasa bile
  slot ilerlesin diye.

---

## 4.6 Gecikme ve bütünlük

Yerel kurulumda gecikme tipik olarak **10–100 ms** arasındadır — gözle takip
edilemeyecek kadar hızlıdır. `db_simulator.py` 0.05 sn aralıkla yazarken
`cdc_watch.py` neredeyse eşzamanlı basar.

Mesaj sayısı **uyuşmalıdır** (snapshot dahilse başlangıç satırları da sayılır).
Uyuşmuyorsa sebep genellikle:
- Connector bir süre `FAILED` durumundaydı
- `table.include.list` dışında kalan bir tablo
- Topic'in retention süresi dolmuş

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| CDC vs polling | CDC silmeleri, ara durumları yakalar; kaynağa yük bindirmez |
| `op=r` | Snapshot okuması — "yeni kayıt" değil |
| `REPLICA IDENTITY FULL` | `before`'ın dolu gelmesi için şart; WAL maliyeti var |
| Tombstone | Compaction'ın key'i silebilmesi için gerekli |
| Terk edilmiş slot | **Kaynak veritabanının diskini doldurur** — 1 numaralı risk |

**[← Alıştırma 4](../04-debezium-cdc.md)**
