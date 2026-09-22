# ✅ Çözüm 1: Producer & Consumer

## 1.1 Consumer'ı sonra başlatmak

**Hayır, göremezdiniz.** `consumer.py` varsayılan olarak `auto.offset.reset=latest`
kullanır. Bu ayar **yalnızca grubun commit edilmiş offset'i yokken** devreye girer ve
"şu andan itibaren oku" anlamına gelir. Producer daha önce yazmışsa o mesajlar atlanır.

Çözüm: `--from-beginning` (yani `auto.offset.reset=earliest`).

> Bu ayarın en çok yanlış anlaşılan yanı: **her başlangıçta** değil, sadece
> **commit edilmiş offset bulunamadığında** çalışır. Grup bir kez commit ettiyse
> `earliest` yazmanız hiçbir şeyi değiştirmez.

---

## 1.2 Key ve partition dağılımı

Tipik sonuç (60 mesaj, 3 partition):

| Key stratejisi | p0 | p1 | p2 | Aynı müşteri hep aynı partition'da mı? |
|---|---|---|---|---|
| `customer` | ~16 | ~28 | ~16 | **Evet** |
| `random` | ~20 | ~20 | ~20 | Hayır |
| `none` | ~20 | ~20 | ~20 | Hayır |

`customer` modunda dağılım eşit değil çünkü sadece 8 farklı key var ve
`hash(key) % 3` bunları eşit bölmüyor. Bu **beklenen** bir durumdur; key kardinalitesi
düşükse partition'lar dengesizleşir (*hot partition* problemi).

**Sıra garantisi için `customer`.** Kafka sırayı **yalnızca partition içinde** garanti eder.
Aynı müşterinin `created → paid → shipped` olayları farklı partition'lara dağılırsa,
tüketici bunları yanlış sırada görebilir — "kargolandı" olayı "oluşturuldu"dan önce işlenir.

Aynı key → aynı hash → aynı partition → sıra korunur.

---

## 1.3 `acks` ödünleşmesi

Tipik ölçüm (tek broker, yerel makine):

| acks | msg/sn | Broker çökerse veri kaybı? |
|---|---|---|
| 0 | ~90.000 | **Evet** — producer onay beklemez, kaybı fark etmez |
| 1 | ~45.000 | Lider yazdıktan sonra replikaya geçmeden çökerse evet |
| all | ~40.000 | Hayır (yeterli replika varsa) |

**Tek broker'da fark gözlemlenemez** çünkü `replication.factor=1`. Tek replika var,
o da liderin kendisi. Yani `acks=all` ile `acks=1` aynı şeyi bekler: "lider yazdı".

Fark, `replication.factor ≥ 3` ve `min.insync.replicas=2` olan gerçek bir kümede ortaya çıkar:
orada `acks=all`, **en az 2 broker'ın** yazdığını garanti eder.

---

## 1.4 `flush()` olmadan

Genellikle **son 100–400 mesaj kaybolur** (`linger.ms=10` ve `batch.size` ayarına bağlı).

Sebep: `produce()` mesajı yerel bir kuyruğa koyar ve hemen döner. Arka plandaki
gönderici iş parçacığı batch'leri broker'a yollar. Program `flush()` çağırmadan biterse,
kuyrukta bekleyen batch'ler **hiç gönderilmez**.

`flush(timeout)` bekleyen tüm mesajlar teslim edilene (ya da süre dolana) kadar bloke eder
ve teslim edilemeyen mesaj sayısını döner — bu dönen değeri **kontrol edin**, sıfır değilse
veri kaybı var demektir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| `auto.offset.reset` | Sadece commit edilmiş offset **yokken** geçerli |
| Key | Partition'ı belirler; sıra garantisinin tek yolu |
| `acks` | Replikasyon olmadan anlamı sınırlı |
| `flush()` | Çıkmadan önce şart; dönüş değerini kontrol edin |

**[← Alıştırma 1](../01-producer-consumer.md)**
