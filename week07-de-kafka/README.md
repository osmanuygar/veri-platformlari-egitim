# Hafta 7: Apache Kafka ile Gerçek Zamanlı Veri Akışı

> 🟩 **İzlek:** Veri Mühendisliği (DE) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2.5 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [Gerçek Zamanlı Veri İşleme Neden Gerekli?](#1-gerçek-zamanlı-veri-i̇şleme-neden-gerekli)
3. [Kafka Mimarisi](#2-kafka-mimarisi)
4. [Producer Detayları](#3-producer-detayları)
5. [Consumer Detayları](#4-consumer-detayları)
6. [Şema Yönetimi: Schema Registry](#5-şema-yönetimi-schema-registry)
7. [Kafka Connect ve CDC](#6-kafka-connect-ve-cdc)
8. [Teslimat Garantileri](#7-teslimat-garantileri)
9. [Stream İşleme'ye Bakış](#8-stream-i̇şlemeye-bakış)
10. [Hızlı Başlangıç](#-hızlı-başlangıç)
11. [Pratik Uygulamalar](#-pratik-uygulamalar)
12. [Alıştırmalar](#-alıştırmalar)
13. [Cheatsheet](#-cheatsheet)
14. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

Bu haftanın sonunda şunları yapabiliyor olacaksınız:

- [ ] Kafka'nın temel bileşenlerini (broker, topic, partition, offset, consumer group) açıklamak
- [ ] Python ile producer ve consumer yazıp mesaj üretip tüketmek
- [ ] Partition ve consumer group mantığıyla paralel tüketimi ve yeniden dengelemeyi (rebalance) gözlemlemek
- [ ] Schema Registry ile şema evrimini (schema evolution) yönetmek
- [ ] Debezium ile PostgreSQL'den CDC akışı kurup veritabanı değişikliklerini canlı izlemek
- [ ] Teslimat garantilerini (at-most-once / at-least-once / exactly-once) ayırt etmek ve doğru olanı seçmek

---

## 1. Gerçek Zamanlı Veri İşleme Neden Gerekli?

### 1.1 Batch'in yetmediği yer

Hafta 4 ve 6'da kurduğumuz her şey **batch** çalışıyordu: gece 02:00'de bir DAG tetiklenir,
OLTP'den veri çeker, dönüştürür, ambara yazar. Sabah rapor hazırdır.

Bu model 50 yıldır çalışıyor ve çoğu iş için hâlâ **doğru cevap**. Ama bazı sorular
"yarın sabah" cevabını kabul etmez:

| Senaryo | Batch ile ne olur | Gereken gecikme |
|---|---|---|
| Kredi kartı dolandırıcılığı | Sahte işlem gece raporunda görünür; para çoktan gitmiştir | < 100 ms |
| E-ticarette stok | İki müşteri aynı son ürünü satın alır | < 1 sn |
| Öneri motoru | "Az önce baktığınız ürün" yarın önerilir | < 1 sn |
| IoT sensör alarmı | Makine gece 03:00'te aşırı ısındı, sabah öğrenirsiniz | < 5 sn |
| Canlı operasyon paneli | Kampanya çöktü, 8 saat sonra fark edilir | < 10 sn |

Ortak nokta: **kararın değeri zamanla hızla düşüyor.** Dolandırıcılık tespiti 1 saat
sonra geldiğinde bilgi doğru ama işe yaramaz.

### 1.2 Gecikme bütçesi

Her gerçek zamanlı sistem tasarımı şu soruyla başlar:

> **"Bu olay gerçekleştikten kaç milisaniye sonra karar verilmiş olmalı?"**

Bu sayı **gecikme bütçesidir** (latency budget) ve mimarinin tamamını belirler.
Bütçe küçüldükçe maliyet ve karmaşıklık üstel artar:

```
24 saat    →  gece batch işi                         (ucuz, basit)
1 saat     →  saatlik mikro-batch                    (ucuz, basit)
5 dakika   →  sık çalışan pipeline                   (orta)
10 saniye  →  streaming, Kafka + tüketici            (karmaşık)
100 ms     →  streaming + bellek içi durum + tuning  (pahalı, çok karmaşık)
```

**Tasarım kuralı:** Gecikme bütçesini ihtiyaçtan küçük tutmayın. "Ne kadar hızlı olursa
o kadar iyi" düşüncesi, gerekmediği halde 10 kat maliyetli ve bakımı zor bir sistem doğurur.

### 1.3 Kafka öncesi: mesaj kuyrukları ve sınırları

RabbitMQ, ActiveMQ, IBM MQ gibi klasik **message broker**'lar onlarca yıldır var.
Mantıkları basit: üretici kuyruğa yazar, tüketici kuyruktan alır, **mesaj silinir**.

Bu model üç yerde tıkanır:

**1. Tek tüketici varsayımı.** Mesaj bir kez tüketilir ve gider. Aynı siparişi hem
faturalama hem analitik hem de öneri motorunun görmesi gerekiyorsa, her biri için ayrı
kuyruk ve ayrı yönlendirme kurmanız gerekir. N sistem → N kuyruk → O(N²) entegrasyon karmaşası.

**2. Geçmişe dönülemez.** Tüketicinizde bir hata buldunuz, düzelttiniz. Son 3 günün
mesajlarını yeniden işlemek istiyorsunuz — ama mesajlar silindi. Yeniden üretmek imkânsız.

**3. Ölçek sınırı.** Klasik broker'lar mesajı bellekte veya indeksli bir veritabanında
tutar. Saniyede yüz binlerce mesajda ve terabaytlarca birikimde bu model çöker.

### 1.4 Kafka'nın farklı fikri: log

Kafka bir kuyruk değil, **dağıtık, kalıcı, append-only bir commit log**'dur.

```
Kuyruk (RabbitMQ):                    Log (Kafka):
┌───┬───┬───┐                         ┌───┬───┬───┬───┬───┬───┐
│ D │ C │ B │ → tüketici              │ A │ B │ C │ D │ E │ F │
└───┴───┴───┘   (A tüketildi, silindi) └───┴───┴───┴───┴───┴───┘
                                         ▲           ▲
                                     grup-1      grup-2
                                    (offset 1)  (offset 4)
```

Üç sonuç doğar:

1. **Okumak silmez.** Her tüketici grubu logda kendi işaretçisini (offset) tutar.
   Yeni bir tüketici eklemek, mevcutları hiç etkilemez.
2. **Geçmiş erişilebilir.** Offset'i geri alıp son 3 günü yeniden işleyebilirsiniz.
   Kafka'da "replay" birinci sınıf bir yetenektir, sonradan eklenmiş bir çözüm değil.
3. **Ölçeklenir.** Sıralı diske yazma, işletim sisteminin sayfa önbelleği ve sıfır kopya
   (zero-copy) aktarım sayesinde tek bir broker saniyede yüz binlerce mesaj taşıyabilir.

> **Zihinsel model:** Kafka'yı "mesaj taşıyan boru" değil, **"olayların kalıcı defteri"**
> olarak düşünün. Bu bakış, sonraki her tasarım kararını kolaylaştırır.

---

## 2. Kafka Mimarisi

### 2.1 Bileşenler

```
┌──────────┐   produce    ┌───────────────────────────────┐   consume   ┌──────────┐
│ Producer │ ───────────▶ │          KAFKA CLUSTER        │ ──────────▶ │ Consumer │
└──────────┘              │  ┌─────────┐    ┌─────────┐   │             │  Group   │
                          │  │ Broker1 │    │ Broker2 │   │             └──────────┘
                          │  └─────────┘    └─────────┘   │
                          └───────────────────────────────┘
```

| Bileşen | Nedir |
|---|---|
| **Broker** | Tek bir Kafka sunucusu. Veriyi diskte tutar, istekleri karşılar |
| **Cluster** | Birden fazla broker'ın topluluğu |
| **Controller** | Küme metadata'sını yöneten broker (KRaft ile bir controller quorum'u) |
| **Topic** | Mantıksal olay kategorisi — `orders`, `clicks`, `sensor-readings` |
| **Partition** | Topic'in fiziksel parçası. **Paralelliğin ve sıralamanın birimi** |
| **Offset** | Bir partition içinde mesajın sıra numarası. Monoton artar, asla tekrar etmez |
| **Replica** | Bir partition'ın başka broker'daki kopyası. Dayanıklılık sağlar |
| **ISR** | *In-Sync Replicas* — lideri yakalamış replikalar kümesi |

### 2.2 Topic ve partition

Bir topic, bir veya daha fazla partition'dan oluşur. **Her partition bağımsız bir logdur.**

```
Topic: orders  (3 partition)

partition 0:  [0][1][2][3][4][5] ──▶ yeni mesajlar buraya eklenir
partition 1:  [0][1][2][3]
partition 2:  [0][1][2][3][4][5][6][7]
```

Buradan çıkan **en kritik iki kural**:

> ⚠️ **Sıra garantisi yalnızca partition içinde geçerlidir.**
> Topic genelinde global bir sıra **yoktur**. Farklı partition'lardaki mesajların
> hangi sırayla işleneceği belirsizdir.

> ⚠️ **Paralellik tavanı = partition sayısıdır.**
> Bir grup içinde bir partition'ı yalnızca bir tüketici okur. 3 partition'lı bir
> topic'te 10 tüketici başlatsanız da 7'si boşta bekler.

### 2.3 Key → partition eşlemesi

Producer bir mesaja **key** verirse, partition şöyle seçilir:

```
partition = murmur2(key) % partition_sayısı
```

Aynı key → aynı hash → **her zaman aynı partition** → **sıra korunur**.

Key verilmezse mesajlar partition'lara dengeli dağıtılır (sticky partitioning).

**Pratik sonuç:** Bir siparişin `created → paid → shipped → delivered` olaylarının
doğru sırayla işlenmesini istiyorsanız, hepsini aynı key ile (`order_id`) yazmalısınız.

```python
producer.produce("orders", key=str(order_id).encode(), value=payload)
```

### 2.4 Key seçerken dikkat: hot partition

Key kardinalitesi düşükse partition'lar dengesizleşir:

| Key | Kardinalite | Sonuç |
|---|---|---|
| `order_id` | Çok yüksek | Dengeli dağılım, sipariş bazında sıra ✅ |
| `customer_id` | Orta | Genelde iyi; çok aktif bir müşteri hot partition yaratabilir |
| `country` | Çok düşük | "TR" trafiğin %90'ı ise tek partition tıkanır ❌ |
| `status` | 4-5 değer | Kesinlikle kaçının ❌ |

**Kural:** Key'i, hem sıra gereksiniminizi karşılayan hem de yeterince dağılan
**en ince taneli** alan olarak seçin.

### 2.5 Replikasyon ve ISR

Her partition'ın bir **lideri**, sıfır veya daha fazla **takipçisi** (follower) vardır.
Tüm okuma-yazma liderden geçer; takipçiler lideri kopyalar.

```
partition 0:  Broker1 (LİDER) ◀── yazma
                 │
                 ├──▶ Broker2 (takipçi)  ✅ senkron  → ISR'de
                 └──▶ Broker3 (takipçi)  ⚠️ geride   → ISR dışı
```

**ISR (In-Sync Replicas)**, lideri belirli bir süre içinde yakalamış replikaların kümesidir.
Lider çökerse yeni lider **yalnızca ISR içinden** seçilir — böylece onaylanmış veri kaybolmaz.

`min.insync.replicas=2` ve `acks=all` birlikte kullanıldığında, bir yazma en az
2 replika tarafından alınmadıkça onaylanmaz.

> 📌 Bu haftanın kümesi **tek broker** (`replication.factor=1`). Replikasyon kavramlarını
> öğrenip ayarları görüyoruz ama dayanıklılık farkını gözlemleyemiyoruz. Alıştırma 1.3'te
> bunun neden böyle olduğunu tartışıyoruz.

### 2.6 KRaft: ZooKeeper'ın sonu

Kafka 2023'e kadar küme metadata'sı için **ZooKeeper**'a bağımlıydı: ayrı bir küme,
ayrı işletim yükü, ayrı arıza noktası.

**KRaft** (Kafka Raft) bu bağımlılığı kaldırdı. Metadata artık Kafka'nın kendi içinde,
Raft konsensüs protokolüyle yönetilen özel bir topic'te (`__cluster_metadata`) tutulur.

| | ZooKeeper | KRaft |
|---|---|---|
| Ayrı küme gerekir | Evet | Hayır |
| Desteklenen partition sayısı | ~200 bin | Milyonlarca |
| Controller devralma süresi | Onlarca saniye | Saniyeler |
| Durum | Kafka 4.0'da kaldırıldı | Varsayılan |

Bu haftanın `docker-compose.yml` dosyası KRaft kullanır — ZooKeeper servisi yoktur.

### 2.7 Saklama (retention)

Kafka mesajı okunduğunda silmez. İki politika vardır:

**Zaman/boyut tabanlı silme** (varsayılan):
```
log.retention.hours=168        # 7 gün sonra sil
log.retention.bytes=-1         # boyut sınırı yok
```

**Log compaction:** Her key için **yalnızca en son değeri** sakla.
```
cleanup.policy=compact
```

Compaction, topic'i bir tabloya dönüştürür: "her müşterinin güncel adresi" gibi bir
durum (state) topic'i için idealdir. CDC akışları genelde compacted topic'lerde tutulur
— ve bu yüzden [tombstone](#64-cdc-olay-yapısı) kavramına ihtiyaç duyarız.

---

## 3. Producer Detayları

### 3.1 Asenkron gönderim

`produce()` mesajı bir **yerel kuyruğa** koyar ve hemen döner. Arka planda çalışan
gönderici iş parçacığı bu kuyruktan batch'ler oluşturup broker'a yollar.

```python
producer.produce("orders", key=b"42", value=payload, on_delivery=callback)
producer.poll(0)          # bekleyen teslim callback'lerini işle
...
producer.flush(timeout=10)  # ← ÇIKMADAN ÖNCE ŞART
```

> 🔥 **En sık yapılan hata:** `flush()` çağırmadan programı bitirmek. Kuyrukta bekleyen
> son yüzlerce mesaj **hiç gönderilmez**. Alıştırma 1.4'te bunu canlı yaşayacağız.
>
> `flush()` teslim edilemeyen mesaj sayısını döner — bu değeri **kontrol edin**.

### 3.2 `acks`: dayanıklılık / gecikme ödünleşmesi

| `acks` | Ne bekler | Gecikme | Kayıp riski |
|---|---|---|---|
| `0` | Hiçbir şey — ateşle ve unut | En düşük | **Yüksek**: broker kapalıysa bile fark edilmez |
| `1` | Lider yazdı | Orta | Lider, replikaya geçmeden çökerse kayıp |
| `all` | ISR'deki tüm replikalar yazdı | En yüksek | En düşük |

`acks=all` tek başına yetmez; `min.insync.replicas` ile birlikte anlamlıdır:

```
replication.factor=3 + min.insync.replicas=2 + acks=all
→ en az 2 broker yazmadan onay verilmez
→ 1 broker kaybına dayanır
```

### 3.3 Idempotent producer

Ağ hatası sonrası yeniden deneme, **aynı mesajın iki kez yazılmasına** yol açabilir:

```
Producer ──▶ Broker:  mesaj yazıldı ✅
Producer ◀── ✗ ağ    :  onay kayboldu
Producer ──▶ Broker:  yeniden dene → AYNI MESAJ İKİNCİ KEZ YAZILDI
```

`enable.idempotence=true` bunu çözer: producer'a bir kimlik (PID) ve her mesaja bir
sıra numarası atanır. Broker tekrarı tanır ve sessizce atar.

Gereksinimleri: `acks=all`, `retries>0`, `max.in.flight.requests.per.connection<=5`.
Maliyeti neredeyse sıfırdır — **açık olmalıdır.**

### 3.4 Verim ayarları

| Ayar | Ne yapar | Artırırsanız |
|---|---|---|
| `linger.ms` | Batch dolsun diye bekleme süresi | Verim ↑, gecikme ↑ |
| `batch.size` | Batch üst sınırı (bayt) | Verim ↑ (bellek ↑) |
| `compression.type` | `gzip`/`snappy`/`lz4`/`zstd` | Ağ ve disk ↓, CPU ↑ |
| `buffer.memory` | Yerel kuyruk boyutu | Dalgalanma toleransı ↑ |

`linger.ms=0` (varsayılan) "hemen gönder" demektir — düşük gecikme, düşük verim.
Yüksek hacimli akışlarda `linger.ms=5..20` ciddi kazanç sağlar.

Sıkıştırma seçimi: **`lz4`** en hızlısı, **`zstd`** en iyi oranı verir. Metin ağırlıklı
JSON olaylarda `zstd` ile %70-80 küçülme olağandır.

---

## 4. Consumer Detayları

### 4.1 Consumer group

Aynı `group.id`'yi paylaşan tüketiciler partition'ları **aralarında paylaşır**:

```
Topic: orders (3 partition)

Grup "analytics"                     Grup "audit"
├─ tüketici A → p0                   └─ tüketici X → p0, p1, p2
├─ tüketici B → p1
└─ tüketici C → p2

Her iki grup da TÜM mesajları görür. Grup içinde ise bölüşülür.
```

Bu, Kafka'nın hem **iş kuyruğu** (grup içi paylaşım) hem **yayın** (gruplar arası
bağımsızlık) davranışını aynı anda sağlamasının yoludur.

### 4.2 Offset yönetimi

Offset, grubun "buraya kadar işledim" işaretçisidir ve Kafka'nın içindeki
`__consumer_offsets` topic'inde saklanır.

```python
# Otomatik (varsayılan): 5 saniyede bir arka planda commit
"enable.auto.commit": True

# Manuel: işlemden SONRA commit  → at-least-once
"enable.auto.commit": False
...
process(msg)
consumer.commit(msg, asynchronous=False)
```

> ⚠️ **`auto.offset.reset` en çok yanlış anlaşılan ayardır.**
> `earliest` / `latest` değeri **yalnızca grubun commit edilmiş offset'i yokken**
> devreye girer. Grup bir kez commit ettiyse, bu ayarı değiştirmeniz hiçbir şeyi değiştirmez.
> Baştan okumak için offset'i elle sıfırlamanız gerekir.

### 4.3 Rebalance

Şu durumlarda partition'lar yeniden dağıtılır:

- Gruba yeni tüketici katılır
- Bir tüketici ayrılır veya çöker
- `max.poll.interval.ms` içinde `poll()` çağrılmaz (tüketici "ölü" sayılır)
- Topic'in partition sayısı değişir

| Strateji | Davranış |
|---|---|
| `range` | Topic bazında ardışık partition blokları — dengesiz olabilir |
| `roundrobin` | Tüm partition'ları sırayla dağıtır |
| `sticky` | Mümkün olduğunca eski atamayı korur |
| `cooperative-sticky` | **Artımlı** rebalance — "stop-the-world" duraklaması yok ✅ |

Klasik (eager) rebalance'ta **tüm** tüketiciler **tüm** partition'larını bırakır,
plan hesaplanır, yeniden atanır. Büyük gruplarda bu saniyeler süren tam duraklamadır.

`cooperative-sticky` yalnızca el değiştirmesi gereken partition'ları taşır.
Bu haftanın `consumer.py` dosyası bunu kullanır.

### 4.4 Consumer lag

```
lag = log_end_offset − committed_offset
```

Yani "tüketici kaç mesaj geride". **Tüketici sağlığının birinci göstergesidir.**

| Lag davranışı | Anlamı |
|---|---|
| ~0, sabit | Sağlıklı |
| Dalgalanıyor ama sıfıra dönüyor | Normal; tepe yüklerde birikiyor, sonra kapanıyor |
| **Sürekli artıyor** | **Kapasite sorunu** — tüketici asla yetişemez |
| Aniden sıçradı | Tüketici çöktü ya da rebalance yaşandı |

Sabit büyüyen lag geçici bir dalgalanma değildir; eğim pozitifse sistem matematiksel
olarak yetişemez. Çözüm: partition + tüketici sayısını artırmak ya da işlemi hızlandırmak.

```bash
# Ölçüm
python scripts/lag_monitor.py --group analytics --watch

# ya da CLI ile
docker exec week07_kafka /opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:19092 --describe --group analytics
```

### 4.5 Yavaş tüketici tuzağı

Tüketici `max.poll.interval.ms` (varsayılan 5 dk) içinde `poll()` çağırmazsa grup onu
ölü sayar ve rebalance tetikler. Ama tüketici aslında **çalışıyordur** — sadece yavaştır.

Sonuç: sonsuz rebalance döngüsü. Hiç mesaj işlenmez.

Çözümler:
- `max.poll.records` düşürün (poll başına az mesaj al, sık poll et)
- Ağır işi ayrı bir iş parçacığı havuzuna verin
- `max.poll.interval.ms` artırın (son çare — gerçek çökmelerin tespiti gecikir)

---

## 5. Şema Yönetimi: Schema Registry

### 5.1 Problem

Düz JSON ile bir topic'e yazarsınız. Altı ay sonra bir geliştirici `total` alanını
`amount` olarak yeniden adlandırır. Producer sorunsuz çalışır, mesajlar akar.

Üç hafta sonra analitik ekibinin pipeline'ı `KeyError: 'total'` ile çöker.
O sırada topic'te bozuk şemayla yazılmış 40 milyon mesaj vardır.

**Şemasız topic'in bedeli, hatanın yazma anında değil, aylar sonra ve başka bir ekipte
ortaya çıkmasıdır.**

### 5.2 Çözüm: merkezi şema + kapı bekçisi

**Schema Registry**, şemaları sürümleyerek saklar ve her yeni şemayı uyumluluk
kurallarına göre **doğrular**. Uyumsuz bir değişiklik üretim anında reddedilir.

```
Producer ──▶ Registry: "bu şemayı kaydet"
             Registry: uyumluluk kontrolü
                       ✅ → schema id döner
                       ❌ → hata, mesaj hiç yazılmaz
```

### 5.3 Wire format

Avro mesajının ilk 5 baytı özeldir:

```
┌──────┬────────────────┬──────────────────────┐
│ 0x00 │ schema id (4B) │ Avro kodlanmış gövde │
└──────┴────────────────┴──────────────────────┘
 sihirli    Registry'deki
  bayt        kimlik
```

Şema mesajda **taşınmaz** — yalnızca kimliği taşınır. Tüketici kimliği Registry'ye
sorar, şemayı alır ve önbelleğe koyar. Milyonlarca mesajda bu ciddi bir tasarruftur.

### 5.4 Uyumluluk modları

| Mod | Garanti | Alan **eklemek** | Alan **silmek** |
|---|---|---|---|
| `BACKWARD` ⭐ | Yeni kod, eski veriyi okur | ✅ varsayılanı varsa | ✅ serbest |
| `FORWARD` | Eski kod, yeni veriyi okur | ✅ serbest | ✅ varsayılanı varsa |
| `FULL` | Her ikisi | ✅ varsayılanı varsa | ✅ varsayılanı varsa |
| `NONE` | Yok | ✅ | ✅ |

**Nasıl akılda tutulur:**

- `BACKWARD` = *"önce tüketiciyi güncelle"*. Yeni tüketici eski veriyi okuyabilmeli →
  eklediğiniz alanın varsayılanı olmalı ki eski veride bulunamadığında doldurulsun.
- `FORWARD` = *"önce producer'ı güncelle"*. Eski tüketici yeni veriyi okuyabilmeli →
  sildiğiniz alanın varsayılanı olmalı.

Varsayılan `BACKWARD`'dır, çünkü gerçekte tüketiciler producer'lardan önce güncellenir:
bir producer onlarca tüketiciyi besler.

> 💡 **Altın kural:** Yeni alana **her zaman** varsayılan değer verin. Bu tek alışkanlık,
> şema evriminde karşılaşacağınız sorunların çoğunu baştan engeller.

### 5.5 Avro / Protobuf / JSON Schema

| | Avro | Protobuf | JSON Schema |
|---|---|---|---|
| Boyut | En küçük | Küçük | Büyük |
| Okunabilirlik | Düşük (ikili) | Düşük (ikili) | Yüksek |
| Şema evrimi | Güçlü | Güçlü | Orta |
| Kafka ekosistemi | En yaygın | Yaygın | Yaygın |

Kafka dünyasında **Avro** varsayılandır; Confluent araçları ona göre tasarlanmıştır.
gRPC kullanan bir organizasyonda Protobuf'ta kalmak mantıklıdır.

---

## 6. Kafka Connect ve CDC

### 6.1 Kafka Connect

Connect, Kafka ile dış sistemler arasında **kod yazmadan** veri taşıyan bir çerçevedir.

```
Kaynak sistem ──▶ [Source Connector] ──▶ KAFKA ──▶ [Sink Connector] ──▶ Hedef sistem
  PostgreSQL                                                              Elasticsearch
  MySQL                                                                   S3
  MongoDB                                                                 Snowflake
```

Yüzlerce hazır connector vardır. Yapılandırma, JSON bir dosyadır — REST API ile kaydedilir.

### 6.2 CDC nedir?

**Change Data Capture**, bir veritabanındaki her değişikliği (INSERT/UPDATE/DELETE)
olay olarak yakalamaktır.

İki yaklaşım vardır:

**Periyodik sorgulama (polling):**
```sql
SELECT * FROM orders WHERE updated_at > :son_calisma;
```

**Log tabanlı CDC (Debezium):**
Veritabanının kendi çoğaltma (replication) günlüğünü — PostgreSQL'de WAL, MySQL'de
binlog — okur.

| | Polling | Log tabanlı CDC |
|---|---|---|
| Silmeleri yakalar | ❌ Satır yok olur, fark edilmez | ✅ `op=d` olayı |
| Ara durumları yakalar | ❌ Sadece son hal | ✅ Her değişiklik |
| Kaynağa yük | ⚠️ Her sorgulama gerçek bir sorgu | ✅ Zaten yazılmış logu okur |
| Gecikme | Sorgulama aralığı kadar | Milisaniyeler |
| `updated_at` sütunu gerekir | ✅ Evet | ❌ Hayır |
| Uygulama değişikliği | ❌ Gerekmez | ❌ Gerekmez |

> 📌 **Polling'in sinsi hatası:** Uzun süren bir transaction'da `updated_at` commit'ten
> önce yazılır. Sorgulama commit ile yazma arasına denk gelirse o satır **sonsuza kadar atlanır**.
> Log tabanlı CDC bu problemden yapısal olarak muaftır.

### 6.3 Debezium + PostgreSQL

Gereksinimler:

```sql
-- 1. WAL seviyesi (docker-compose.yml'de ayarlı)
SHOW wal_level;   -- 'logical' olmalı

-- 2. Publication: hangi tablolar yayınlanacak
CREATE PUBLICATION dbz_publication FOR TABLE shop.orders, shop.products;

-- 3. REPLICA IDENTITY: UPDATE'te eski halin ne kadarı WAL'a yazılsın
ALTER TABLE shop.products REPLICA IDENTITY FULL;
```

`REPLICA IDENTITY` seçenekleri:

| Değer | WAL'a yazılan eski hal | `before` alanı |
|---|---|---|
| `DEFAULT` | Sadece primary key | `{"id": 2}` — diğer alanlar yok |
| `FULL` | Tüm sütunlar | Eski satırın tamamı ✅ |
| `NOTHING` | Hiçbir şey | Boş |

`FULL`, WAL boyutunu büyütür. Geniş tablolarda ve yoğun UPDATE'te maliyetlidir —
production'da tablo tablo karar verilir.

### 6.4 CDC olay yapısı

Ham Debezium zarfı:

```json
{
  "before": { "id": 2, "sku": "LPT-002", "price": "54999.00", "stock": 12 },
  "after":  { "id": 2, "sku": "LPT-002", "price": "45000.00", "stock": 5  },
  "source": { "db": "shopdb", "schema": "shop", "table": "products",
              "lsn": 24857392, "ts_ms": 1758531600000 },
  "op": "u",
  "ts_ms": 1758531600123
}
```

`op` kodları:

| Kod | Anlamı | Ne zaman |
|---|---|---|
| `r` | **read** | İlk snapshot — mevcut satırlar |
| `c` | **create** | INSERT |
| `u` | **update** | UPDATE |
| `d` | **delete** | DELETE |
| *(null değer)* | **tombstone** | DELETE'ten hemen sonra |

> `op=r` ile `op=c` farkı önemlidir. Snapshot olaylarını "yeni sipariş geldi" bildirimi
> olarak işlerseniz, connector her yeniden kurulduğunda binlerce sahte bildirim gönderirsiniz.

**Tombstone** neden var? Compacted bir topic'te Kafka her key için son değeri saklar.
Sadece `op=d` olayı olsaydı, compaction onu sonsuza kadar tutardı — kayıt hiç silinmezdi.
**Null değer, compaction'a "bu key'i tamamen kaldır" der.**

### 6.5 ⚠️ Replication slot: CDC'nin 1 numaralı operasyon riski

Debezium bir **replication slot** oluşturur. Slot, "WAL'ı buraya kadar okudum" der.

**PostgreSQL, bir slot'un henüz okumadığı WAL segmentlerini silemez.**

Connector durursa `restart_lsn` ilerlemez, veritabanı yazmaya devam eder, WAL birikir.
Yeterince uzun sürerse **disk dolar ve PostgreSQL yazma kabul etmeyi bırakır**.

Yani: *sadece bir okuyucu kapandı diye production veritabanınız durur.*

```sql
-- Düzenli izleyin
SELECT slot_name, active,
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS geride
FROM pg_replication_slots;

-- Terk edilmiş slot'u MUTLAKA silin
SELECT pg_drop_replication_slot('week07_slot');
```

Korunma: `max_slot_wal_keep_size` ayarlayın (PostgreSQL 13+), slot lag'ine alarm kurun,
sessiz tablolarda `heartbeat.interval.ms` kullanın.

### 6.6 Outbox pattern

Mikroservis dünyasının klasik problemi: uygulama hem kendi veritabanına yazacak
hem de bir olay yayınlayacak. İkisi ayrı sistemde olduğu için atomik değildir —
biri başarılı, diğeri başarısız olabilir.

**Outbox pattern** bunu çözer:

```
1. Uygulama TEK transaction içinde:
   - orders tablosuna yazar
   - outbox tablosuna olayı yazar
   → İkisi de olur ya da ikisi de olmaz (ACID)

2. Debezium outbox tablosunu izler → Kafka'ya basar
```

İş verisi ile olay yayını aynı transaction'da olduğu için tutarsızlık imkânsızdır.
Debezium'un bunun için özel bir SMT'si vardır: `EventRouter`.

---

## 7. Teslimat Garantileri

### 7.1 Üç seviye

| Garanti | Anlamı | Ne zaman |
|---|---|---|
| **At-most-once** | En fazla bir kez — kaybolabilir, tekrarlanmaz | Metrik, log; kaybı tolere edilebilen veri |
| **At-least-once** ⭐ | En az bir kez — kaybolmaz, tekrarlanabilir | Varsayılan tercih |
| **Exactly-once** | Tam olarak bir kez | Finansal işlemler |

### 7.2 Commit zamanlaması her şeyi belirler

| Senaryo | Commit | Çökme anı | Sonuç |
|---|---|---|---|
| A | İşlemden **önce** | İşlem sırasında | **Kaybolur** → at-most-once |
| B | İşlemden **sonra** | Commit'ten önce | **Tekrarlanır** → at-least-once |
| C | İşlemden **sonra** | Commit'ten sonra | Doğru |

Sihirli bir üçüncü yol yoktur. Seçim: **ya kaybet ya da tekrarla.**
Neredeyse her iş için **B** doğrudur — tekrarı yönetmek, kaybı telafi etmekten kolaydır.

### 7.3 İdempotent tüketim: pratikteki exactly-once

Tekrarı zararsız kılan ilke: **aynı mesajı iki kez işlemek, bir kez işlemekle aynı
sonucu vermelidir.**

| ❌ İdempotent değil | ✅ İdempotent |
|---|---|
| `UPDATE hesap SET bakiye = bakiye - 100` | `UPDATE hesap SET bakiye = 900 WHERE bakiye = 1000` |
| `INSERT INTO siparisler …` | `INSERT … ON CONFLICT (order_id) DO NOTHING` |
| `sayac += 1` | işlenmiş id'leri bir kümede tut |
| E-posta gönder | `if not gonderildi(mesaj_id): gonder()` |

Pratik desenler:
- **Doğal anahtar + upsert** — `order_id` primary key, `ON CONFLICT DO UPDATE`
- **İşlenmiş kimlik tablosu** — her `message_id`'yi kaydedin; varsa atlayın
- **Mutlak değer yazın, artış değil** — `bakiye = X`, `bakiye += X` değil

### 7.4 Kafka'nın transaction desteği

`enable.idempotence` + `transactional.id` ile Kafka, **"read-process-write"** kalıbında
gerçek exactly-once sağlar: Kafka'dan okuyup Kafka'ya yazarken tüketim offset'i ve
üretilen mesajlar **tek bir atomik işlemde** commit edilir.

Sınırı şudur: zincirin ucunda Kafka **olmayan** bir sistem varsa (PostgreSQL, bir REST
API, bir e-posta servisi), Kafka'nın garantisi oraya uzanmaz.

> 📌 **Pratikteki formül:**
> **exactly-once = at-least-once + idempotent tüketim**

### 7.5 Dead Letter Topic

Bozuk mesaj kaçınılmazdır. İki kötü seçenek:

1. **Çökmek** → tüketici yeniden başlar, aynı mesajı okur, yine çöker. Sonsuz döngü.
   Akış tamamen durur. Buna **poison pill** denir.
2. **Sessizce atlamak** → veri iz bırakmadan kaybolur. Aylar sonra "rakamlar tutmuyor"
   olarak ortaya çıkar. Çökmekten **daha tehlikelidir**.

Doğrusu üçüncüsüdür: **işlenemeyen mesajı bağlamıyla birlikte DLQ topic'ine yaz,
akışa devam et.**

DLQ kaydı şunları taşımalıdır:

| Alan | Neden |
|---|---|
| `raw_value` | Düzeltip yeniden işlemenin tek kaynağı |
| `source_topic` + `partition` + `offset` | Mesajı orijinal yerinde bulmak; replay için şart |
| `failure_stage` | `parse` (teknik) mi `validate` (semantik) mi — kime gideceğinizi belirler |
| `failure_reason` | Kök nedeni ayırt eder |
| `failed_at` | Belirli bir deploy'la ilişkilendirmek için |

**Replay uyarısı:** Naif bir replay sonsuz döngü yaratır
(`orders → DLQ → replay → orders → DLQ → …`). Korunma: mesaj başlığında bir
`x-retry-count` tutun ve sınırı aşanı terminal bir topic'e taşıyın.
`exercises/solutions/dlq_replay.py` bunu gösterir.

---

## 8. Stream İşleme'ye Bakış

Buraya kadar mesajları **tek tek** işledik. Stream işleme, akış üzerinde
**sürekli sorgu** çalıştırmaktır: birleştirme (join), pencereleme (windowing), durum tutma.

### 8.1 Araçlar

| Araç | Nedir | Ne zaman |
|---|---|---|
| **Kafka Streams** | JVM kütüphanesi — ayrı küme gerekmez | JVM ekosistemi, orta karmaşıklık |
| **ksqlDB** | Akış üzerinde SQL | SQL bilen ekip, hızlı prototip |
| **Apache Flink** | Ayrı dağıtık motor; en güçlü semantik | Karmaşık durum, olay zamanı, yüksek ölçek |
| **Spark Structured Streaming** | Mikro-batch tabanlı | Zaten Spark kullanılıyorsa |

### 8.2 Pencereleme (windowing)

"Son 5 dakikada kaç sipariş" sorusu bir **pencere** gerektirir:

| Tür | Davranış | Örnek |
|---|---|---|
| **Tumbling** | Bitişik, çakışmayan | Her 5 dakikalık dilim |
| **Hopping** | Çakışan | 5 dk'lık pencere, 1 dk'da bir kayar |
| **Session** | Hareketsizlikle biter | Kullanıcı oturumu |

### 8.3 Olay zamanı vs işleme zamanı

| | Tanım | Problem |
|---|---|---|
| **Event time** | Olay gerçekte ne zaman oldu | Geç gelen olaylar |
| **Processing time** | Sistem onu ne zaman gördü | Sonuçlar yeniden üretilemez |

Mobil uygulamada çevrimdışıyken üretilen bir olay saatler sonra gelebilir. İşleme zamanına
göre gruplarsanız o olay yanlış pencereye düşer ve geçmiş raporlarınız değişir.

Doğrusu **olay zamanı** kullanmak ve geç gelenleri **watermark** ile yönetmektir:
"olay zamanı T'den eski olanları artık beklemiyorum".

> Bu konular kendi başına bir haftayı hak eder. Hafta 14'teki
> [IoT Sensör Platformu vakası](../week14-case-studies/) bunları pratikte kullanır.

---

## 🚀 Hızlı Başlangıç

```bash
cd week07-de-kafka

# Tek komutla: servisler + topic'ler + Debezium connector
./setup-week07.sh

# Python bağımlılıkları
pip install -r requirements.txt
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| Kafka (KRaft) | `apache/kafka:3.7.1` | `9092` | — |
| Kafka UI | `provectuslabs/kafka-ui` | `8092` | http://localhost:8092 |
| Schema Registry | `confluentinc/cp-schema-registry:7.6.1` | `8095` | http://localhost:8095/subjects |
| Kafka Connect (Debezium) | `quay.io/debezium/connect:2.7` | `8096` | http://localhost:8096/connectors |
| PostgreSQL (CDC kaynağı) | `postgres:15` | `5437` | — |

**Bellek ihtiyacı:** ~3.5 GB. Docker Desktop / OrbStack'e en az 4 GB ayırın.

### Doğrulama

```bash
docker compose ps                                  # hepsi healthy mi
./scripts/register_connector.sh status             # connector RUNNING mi
docker exec week07_kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:19092 --list        # topic'ler
docker exec week07_postgres psql -U kafka_user -d shopdb \
  -c "SELECT * FROM shop.v_order_summary;"         # veri geldi mi
```

### Durdurma ve Temizlik

```bash
docker compose down        # durdur (veri kalır)
docker compose down -v     # durdur + volume sil (SIFIRDAN başlar)
docker compose logs -f     # canlı log
```

> ⚠️ `down -v` PostgreSQL volume'unu da siler. Replication slot da gider —
> bu aslında **iyi bir şeydir**, terk edilmiş slot kalmaz.

---

## 🧪 Pratik Uygulamalar

| Script | Ne yapar |
|---|---|
| `scripts/producer.py` | Sipariş olayı üretir; `--acks`, `--key-by`, `--rate` ile deney |
| `scripts/consumer.py` | Consumer group üyesi; rebalance'ı canlı gösterir |
| `scripts/lag_monitor.py` | Partition bazında lag; `--watch` ile canlı |
| `scripts/avro_producer.py` | Schema Registry + Avro; `--schema v1/v2/bad` |
| `scripts/avro_consumer.py` | Şemayı Registry'den çözerek okur |
| `scripts/cdc_watch.py` | **CDC akışını canlı izler** |
| `scripts/db_simulator.py` | CDC için veritabanı hareketi üretir |
| `scripts/dlq_consumer.py` | Dayanıklı tüketici + dead letter topic |
| `scripts/poison_producer.py` | Bilerek bozuk mesaj üretir |
| `scripts/register_connector.sh` | Connector kaydet/durum/restart/sil |

### ✨ Bu Haftanın "Wow" Anı

İki terminal açın:

```bash
# Terminal 1
python scripts/cdc_watch.py

# Terminal 2
docker exec -it week07_postgres psql -U kafka_user -d shopdb
```

psql'de yazın:

```sql
UPDATE shop.products SET price = 39999.00 WHERE sku = 'LPT-001';
```

**1. terminale bakın.** Değişiklik milisaniyeler içinde bir Kafka olayı olarak orada.

```
✏️  14:32:07.412  UPDATE   products   id=1  sku=LPT-001  price=39999.00  stock=25
```

Uygulamaya **tek satır kod eklemedik**. Veritabanı bir şey yayınladığından haberdar değil.
Debezium sadece PostgreSQL'in kendi WAL'ını okuyor.

Bir de `python scripts/db_simulator.py` çalıştırıp sürekli akışı izleyin —
ekranda akan şey, hafta 4'te gece batch'iyle taşıdığımız verinin **canlı hali**.

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Producer & Consumer](./exercises/01-producer-consumer.md) | 25 dk | Key seçimi, `acks`, `flush()` |
| 2 | [Partition, Consumer Group ve Lag](./exercises/02-partitions-and-lag.md) | 35 dk | Paralel tüketim, rebalance, lag |
| 3 | [Şema Evrimi](./exercises/03-schema-evolution.md) | 30 dk | Avro, uyumluluk modları |
| 4 | [Debezium ile CDC](./exercises/04-debezium-cdc.md) | 40 dk | Snapshot, zarf, slot bakımı |
| 5 | [Dead Letter Topic](./exercises/05-dead-letter-queue.md) | 30 dk | Bozuk mesaj, teslimat garantileri |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**Kafka Cheatsheet**](./cheatsheets/kafka-cheatsheet.md) — topic, consumer group,
  offset reset, performans testi, sık hatalar
- 📎 [**Debezium & Connect Cheatsheet**](./cheatsheets/debezium-cheatsheet.md) — connector
  REST API, olay yapısı, PostgreSQL slot yönetimi, sorun giderme

---

## 🧯 Sık Karşılaşılan Sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `Connection refused: localhost:9092` | Kafka henüz hazır değil | `docker compose ps` → healthy olmasını bekleyin |
| Tüketici hiç mesaj almıyor | `auto.offset.reset=latest`, grup yeni | `--from-beginning` |
| Connector `FAILED` | Slot çakışması / yetki | `./scripts/register_connector.sh status` → `trace` alanı |
| `wal_level must be logical` | Postgres ayarı gitmiş | `docker compose down -v && ./setup-week07.sh` |
| CDC olayları gelmiyor | Tablo `table.include.list` dışında | `connectors/postgres-source.json` |
| Producer mesajları kayıp | `flush()` çağrılmamış | Çıkmadan önce `producer.flush()` |
| Port 9092/8092 dolu | Başka bir Kafka çalışıyor | [PORTS.md](../PORTS.md) |
| Container'lar OOM ile ölüyor | Docker belleği yetersiz | En az 4 GB ayırın |

---

## 📖 Kaynaklar

### Resmî dokümantasyon
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Debezium Documentation](https://debezium.io/documentation/)
- [Confluent Schema Registry](https://docs.confluent.io/platform/current/schema-registry/index.html)
- [Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html)

### Kitaplar
- **"Kafka: The Definitive Guide" (2. baskı)** — Gwen Shapira, Todd Palino, Rajini Sivaram, Krit Petty
- **"Designing Data-Intensive Applications"**, Bölüm 11 — Martin Kleppmann
- **"Streaming Systems"** — Tyler Akidau, Slava Chernyak, Reuven Lax *(olay zamanı ve watermark için en iyi kaynak)*

### Makaleler
- [The Log: What every software engineer should know…](https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying) — Jay Kreps *(Kafka'nın kurucu fikri; bu hafta anlatılan her şeyin arkasındaki düşünce)*
- [Turning the database inside-out](https://www.confluent.io/blog/turning-the-database-inside-out-with-apache-samza/) — Martin Kleppmann
- [Exactly-once semantics are possible](https://www.confluent.io/blog/exactly-once-semantics-are-possible-heres-how-apache-kafka-does-it/) — Neha Narkhede

### Pratik
- [Confluent Developer](https://developer.confluent.io/) — ücretsiz kurslar
- [Debezium Examples](https://github.com/debezium/debezium-examples)
- [KRaft'a geçiş](https://developer.confluent.io/learn/kraft/)

---

## 📝 Hafta Özeti

✅ **Log fikri** — Kafka bir kuyruk değil, kalıcı bir olay defteri. Okumak silmez.
✅ **Partition** — hem paralelliğin hem sıralamanın birimi. Key onu belirler.
✅ **Consumer group** — grup içi paylaşım, gruplar arası bağımsızlık.
✅ **Lag** — tüketici sağlığının birinci göstergesi; eğim pozitifse kapasite sorunu.
✅ **Schema Registry** — kırılmayı aylar sonra tüketicide değil, üretim anında yakalar.
✅ **CDC** — veritabanının WAL'ını okuyup değişiklikleri olaya çevirir; uygulamaya dokunmaz.
✅ **Teslimat garantileri** — pratikte at-least-once + idempotent tüketim.

> 💡 **Haftanın tek cümlesi:** Gerçek zamanlı sistemlerde asıl zorluk hız değil,
> **tekrarı, sırayı ve şema değişimini yönetmektir.**

---

**[← Hafta 6: Veri Mühendisliğine Giriş ve Modern Veri Ekosistemi](../week06-de-data-engineering/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 8: Veri Bilimine Giriş →](../week08-ds-intro/README.md)**
