# ✅ Çözüm 2: Partition, Consumer Group ve Lag

## 2.1 Paralel tüketim

3 partition, 3 tüketici → her birine **birer** partition:

| Tüketici | Atanan partition'lar |
|---|---|
| 1 | [0] |
| 2 | [1] |
| 3 | [2] |

(Hangi tüketiciye hangisinin düştüğü sıraya göre değişir.)

**Dördüncü tüketici boşta kalır** — `⇄ ATAMA  bu tüketiciye düşen partition'lar: — (boşta)`.

Kural: **Bir grup içinde bir partition'ı en fazla bir tüketici okur.** Bu yüzden
bir gruptaki etkin paralellik tavanı = partition sayısı. 4. tüketici sadece
yedek (failover) olarak bekler; biri düşerse rebalance'ta devreye girer.

---

## 2.2 Rebalance

2. tüketici kapanınca:

```
⇄ GERİ ALMA  bırakılan partition'lar: [1]      (kapanan tüketici)
⇄ ATAMA      bu tüketiciye düşen partition'lar: [0, 1]   (kalanlardan biri devralır)
```

**Klasik (eager) rebalance'ta işleme durur:** tüm tüketiciler *tüm* partition'larını
bırakır, yeni plan hesaplanır, sonra yeniden atanır. Bu "stop-the-world" duraklamasıdır
ve büyük gruplarda saniyeler sürebilir.

`cooperative-sticky` (bu haftada kullandığımız) bunu **artımlı** yapar: sadece
gerçekten el değiştirmesi gereken partition'lar bırakılır. Diğer tüketiciler
kesintisiz çalışmaya devam eder. Ayrıca "sticky" olması sayesinde bir tüketici
rebalance sonrası mümkün olduğunca **aynı** partition'ları korur — yerel önbellek boşa gitmez.

---

## 2.3 Farklı gruplar

**Evet, her iki grup da 10 mesajın tamamını aldı.**

Klasik mesaj kuyruğunda (RabbitMQ'nun work queue'su) bir mesajı bir tüketici alır ve
mesaj kuyruktan **silinir**. Kafka'da mesaj okunduğunda silinmez — Kafka bir
**dağıtık commit log**'dur. Her grup logda kendi işaretçisini (offset) tutar.

Pratik sonucu: `analytics` grubu veriyi işlerken `audit` grubu aynı veriyi
bağımsız olarak arşivleyebilir. Yeni bir tüketici eklemek mevcutları etkilemez.
Bu, Kafka'nın entegrasyon omurgası olarak kullanılmasının temel sebebidir.

---

## 2.4 Lag üretmek

Beklenen: producer 200/sn, consumer ~10/sn (100 ms × 1 mesaj) → **lag saniyede ~190 artar**.

| Saniye | Toplam lag |
|---|---|
| 0 | ~0 |
| 10 | ~1.900 |
| 20 | ~3.800 |
| 30 | ~5.700 |

Ölçümünüz biraz farklı çıkabilir: consumer `max.poll.records` kadar mesajı toplu alır,
producer `--rate` hedefine tam ulaşmayabilir. Ama **doğrusal artış eğilimi** aynıdır.

Kritik nokta: **sabit büyüyen lag bir kapasite sorunudur, geçici bir dalgalanma değil.**
Lag grafiğinin eğimi sıfırın üstündeyse sistem asla yetişemez.

---

## 2.5 Lag'i kapatmak

3 tüketici → her biri 1 partition → toplam ~30 mesaj/sn. Hâlâ 200/sn üretimin altında,
yani lag büyümeye devam eder ama **daha yavaş**.

**4. tüketici hiçbir şey değiştirmez** — boşta kalır. Bu topic'te paralelliğin üst sınırı
**3'tür**, çünkü 3 partition var.

### Partition artırmak

```bash
kafka-topics.sh --alter --topic orders --partitions 6
```

**Evet, sıra garantisini bozar.** Partition seçimi `hash(key) % partition_sayısı`
ile yapılır. Bölen 3'ten 6'ya çıkınca aynı key farklı bir partition'a düşer:

```
hash("42") % 3 = 0        →  p0'da eski olaylar
hash("42") % 6 = 3        →  p3'te yeni olaylar
```

42 numaralı müşterinin geçmiş olayları p0'da, yeni olayları p3'te. İki farklı
partition'ın okunma sırası garanti değil → **sıra kırıldı**.

Bu yüzden partition sayısı baştan planlanır. Pratik kural: beklenen tepe yükün
2–3 katını karşılayacak kadar partition açın; azaltmak zaten mümkün değildir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Paralellik tavanı | = partition sayısı (grup başına) |
| Fazla tüketici | Boşta bekler, failover görevi görür |
| Farklı `group.id` | Aynı veriyi bağımsız okur |
| Lag eğimi > 0 | Kapasite sorunu; tüketici asla yetişmez |
| Partition artırma | Key→partition eşlemesini bozar |

**[← Alıştırma 2](../02-partitions-and-lag.md)**
