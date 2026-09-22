# Alıştırma 4: Batch vs Streaming Kararı

**Süre:** ~20 dakika · **Format:** Yazılı analiz (kod yok)

---

## 4.1 Gecikme bütçesi analizi

Aşağıdaki 6 senaryo için: (a) gecikme bütçesini tahmin edin, (b) batch mı
streaming mi önerirsiniz, (c) gerekçenizi 1-2 cümleyle yazın.

| # | Senaryo | Gecikme bütçesi | Batch / Streaming | Gerekçe |
|---|---|---|---|---|
| 1 | Aylık finansal kapanış raporu | | | |
| 2 | Kredi kartı dolandırıcılık tespiti | | | |
| 3 | E-ticaret "az önce baktığınız ürünler" | | | |
| 4 | Haftalık müşteri segmentasyonu (hafta 6'daki `customer_segment` gibi) | | | |
| 5 | Fabrika sensöründe aşırı ısınma alarmı | | | |
| 6 | Sosyal medya trend analizi paneli | | | |

---

## 4.2 Maliyet-fayda

Senaryo 4'ü (`customer_segment`) ele alalım. Şu an **günlük batch** ile
çalışıyor (Airflow DAG'ı).

**Soru:** Bunu gerçek zamanlı (her sipariş anında segment güncellenir) hale
getirmenin mühendislik maliyeti nedir? (Kafka kurulumu, stream processing,
durum yönetimi — hafta 7'yi düşünün). Bu maliyete değer mi? Hangi iş
gerekçesi bunu haklı çıkarabilir?

---

## 4.3 Hibrit yaklaşım: Lambda mimarisi

Bazı sistemler ikisini birden kullanır:

```
                    ┌─────────────┐
    Olaylar ──┬────▶│ Speed Layer │──▶ Yaklaşık, ANLIK sonuç
              │     └─────────────┘
              │     ┌─────────────┐
              └────▶│ Batch Layer │──▶ Kesin, GECİKMELİ sonuç
                    └─────────────┘
                           │
                    Gece: speed layer'ın sonucu
                    batch layer'ınkiyle DEĞİŞTİRİLİR
```

**Soru:** Neden iki katman? "Anlık ama yaklaşık" ile "kesin ama gecikmeli"
sonucu neden aynı sistemde birlikte tutmak isteyelim? Hafta 14'teki IoT
vakasında bu deseni nerede kullanabilirsiniz?

---

## 4.4 Karar çerçevesi

Kendi organizasyonunuz (ya da bildiğiniz bir şirket) için gerçek bir veri
akışı düşünün.

**Görev:** Şu soruları cevaplayın:
1. Bu akış için gecikme bütçesi nedir? (Ölçülebilir bir sayı verin: saniye, dakika, saat)
2. Şu an nasıl işleniyor (ya da işlenseydi nasıl işlenirdi)?
3. Streaming'e geçmenin somut iş değeri ne olurdu?
4. Bu değer, ek mühendislik ve operasyon maliyetini karşılar mı?

---

## ✅ Ne öğrendik

- Her veri akışının gerçek bir gecikme bütçesi vardır; bu bütçe belirlenmeden
  mimari kararı vermek, gereksiz karmaşıklığa (ya da yetersiz hıza) yol açar.
- "Ne kadar hızlı olursa o kadar iyi" yanlış bir sezgidir — streaming'in
  mühendislik ve operasyon maliyeti gerçektir ve her zaman karşılığını almaz.
- Lambda mimarisi, "hız" ile "kesinlik" arasında bilinçli bir ödünleşmedir.

📎 [Çözüm](./solutions/04-batch-vs-streaming.md)
