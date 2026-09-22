# ✅ Çözüm 4: Batch vs Streaming Kararı

## 4.1 Gecikme bütçesi analizi

| # | Senaryo | Gecikme bütçesi | Karar | Gerekçe |
|---|---|---|---|---|
| 1 | Aylık finansal kapanış raporu | Günler | **Batch** | Doğruluk ve denetlenebilirlik hızdan önemli; ayda bir çalışması yeterli |
| 2 | Kredi kartı dolandırıcılığı | < 100 ms – birkaç saniye | **Streaming** | Kararın değeri saniyeler içinde sıfırlanır; işlem onaylanmadan önce durdurulmalı |
| 3 | "Az önce baktığınız ürünler" | < 1–5 saniye | **Streaming** (hafif) | Kullanıcı deneyimi anlık olmalı; ama tam Kafka+Flink şart değil, session store + hızlı okuma yeterli olabilir |
| 4 | Haftalık müşteri segmentasyonu | Saatler–günler | **Batch** | Segment, davranışın uzun vadeli özetidir; günlük/haftalık güncellenmesi yeterli |
| 5 | Fabrika sensörü aşırı ısınma alarmı | < 1–5 saniye | **Streaming** | Fiziksel güvenlik riski; gecikme donanım hasarına yol açabilir |
| 6 | Sosyal medya trend paneli | Saniyeler–dakikalar | **Streaming** (ama gevşek) | "Trend" kavramı zaten bir pencereleme gerektirir; kesin anlık olmasa da yakın olmalı |

---

## 4.2 Maliyet-fayda: `customer_segment`'i gerçek zamanlı yapmak

Mühendislik maliyeti:

- Kafka kümesi kurmak ve işletmek (hafta 7)
- Sipariş/ödeme olaylarını CDC ile yakalamak (Debezium)
- Stream processing katmanı (Kafka Streams / Flink) ile **durum tutan**
  (stateful) bir agregasyon yazmak — "bu müşterinin şimdiye kadarki toplam
  harcaması" gibi bir değeri sürekli güncel tutmak, batch'teki tek seferlik
  `GROUP BY`'dan çok daha karmaşıktır (state store, checkpoint, fault tolerance)
- İzleme, alarm, operasyon yükü eklenir

**Bu maliyete değer mi?** Çoğu organizasyon için **hayır**. Müşteri segmenti
gibi davranışsal bir özet, günlük güncellense de iş kararlarını (kampanya
hedefleme, öncelik sırası) pratikte etkilemez — "gold" bir müşteri sabah
segment güncellenene kadar "silver" görünse bile iş sonucu değişmez.

**Haklı çıkarabilecek gerekçe:** Segment, gerçek zamanlı bir **fiyatlandırma**
veya **erişim kontrolü** kararını tetikliyorsa (örn. "gold müşteriye anında
VIP destek hattı aç") — o zaman gecikme, doğrudan müşteri deneyimini etkiler
ve yatırım haklı olabilir.

---

## 4.3 Lambda mimarisi

İki katmanın bir arada olmasının sebebi, **hız** ile **kesinlik**'in genelde
birbirini dışlamasıdır:

- **Speed layer** (streaming) hızlıdır ama yaklaşıktır: geç gelen olaylar,
  düzeltmeler, tekrarlanan mesajlar tam olarak ele alınamayabilir.
- **Batch layer** yavaştır ama kesindir: tüm veri elde olduğu için tam,
  yeniden üretilebilir bir hesaplama yapılır.

Gece batch layer, speed layer'ın "tahmini" sonucunun üzerine **kesin** sonucu
yazarak düzeltir. Kullanıcı gün içinde yaklaşık ama güncel veri görür, ertesi
gün doğru veriye "senkronize" olur.

**Hafta 14 IoT vakasında** bu desen şöyle kullanılabilir: sensörlerden gelen
anlık sıcaklık verisi speed layer'da "şu an ortalama sıcaklık" panelini
besler (yaklaşık, hızlı); aynı ham veri batch layer'da gece toplu işlenip
"günlük sıcaklık raporu" ve arıza analiz tablolarını kesin olarak üretir.

---

## 4.4 Karar çerçevesi

Bu soru kişiye özeldir — beklenen format:

1. **Gecikme bütçesi** somut bir sayı olmalı ("2 saat" gibi), "hızlı olsun"
   gibi belirsiz bir ifade değil.
2. Mevcut durum tarif edilmeli.
3. İş değeri **ölçülebilir** olmalı (örn. "dolandırıcılık kaybını %X azaltır",
   "müşteri terk oranını %Y düşürür") — "daha iyi olur" yeterli değildir.
4. Karşılaştırma **açık** yapılmalı: ek mühendislik/operasyon maliyeti
   (kişi-ay, altyapı maliyeti) karşısında tahmini kazanç.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Gecikme bütçesi | Somut bir sayı olmalı; mimariyi bu sayı belirler |
| Streaming maliyeti | Gerçektir — her zaman karşılığını almaz |
| Lambda mimarisi | Hız ile kesinlik arasında bilinçli bir ödünleşme |
| Karar çerçevesi | Bütçe → mevcut durum → ölçülebilir değer → maliyet karşılaştırması |

**[← Alıştırma 4](../04-batch-vs-streaming.md)**
