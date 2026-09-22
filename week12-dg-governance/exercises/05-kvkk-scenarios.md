# Alıştırma 5: KVKK Senaryo Analizi

**Süre:** ~20 dakika · **Format:** Yazılı analiz

---

## 5.1 Beş senaryo

Her senaryo için: **İhlal mi, değil mi?** ve **neden?**

**Senaryo 1:** Bir pazarlama ekibi, `raw.customers` tablosundaki tüm
müşterilere, **açık rıza almadan** (bu haftaki `consent_marketing=false`
olan müşteriler dahil) yeni ürün duyurusu e-postası gönderiyor.

**Senaryo 2:** Bir veri bilimci, churn modeli eğitmek için `tckn` sütununu
**özellik olarak** kullanıyor (modelin `tckn`'e bakarak tahmin yapmasına izin veriyor).

**Senaryo 3:** Şirket, müşteri verisini 5 yıl önce hesabını kapatmış ve
hiçbir yasal saklama yükümlülüğü olmayan kullanıcılar için hâlâ **hiç
silmeden** saklıyor.

**Senaryo 4:** Bir geliştirici, production veritabanının **tam bir
kopyasını** (PII dahil, maskelenmemiş) kendi dizüstü bilgisayarına
indirip yerel test ortamında kullanıyor.

**Senaryo 5:** Şirket, müşteriye "verileriniz sadece sipariş takibi için
kullanılacaktır" diyor, ama aynı veriyi üçüncü bir reklam şirketiyle
**ek bir rıza almadan** paylaşıyor.

---

## 5.2 Değerlendirme tablosu

| # | İhlal mi? | İlgili KVKK ilkesi | Düzeltme |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

---

## 5.3 Teknik karşılıkları

**Görev:** Yukarıdaki 5 senaryodan en az 3'ü için, bu haftaki araçlardan
(Great Expectations, Marquez, RLS/maskeleme) **hangisinin** ihlali önlemeye
ya da tespit etmeye yardımcı olabileceğini yazın.

Örnek: *"Senaryo 1, `consent_marketing` alanını kontrol eden bir Great
Expectations kuralıyla (pazarlama e-postası gönderilecek listenin
`consent_marketing=True` olmayan hiçbir satır içermediğini doğrulayan)
otomatik olarak önlenebilir."*

---

## ✅ Ne öğrendik

- KVKK'nın temel ilkeleri (açık rıza, amaç sınırlaması, veri minimizasyonu,
  saklama süresi sınırı) soyut değil, **her gün karşılaşılan somut
  mühendislik kararlarına** dönüşür.
- Bir ihlal genelde kötü niyetten değil, **süreç eksikliğinden** kaynaklanır
  (production verisinin kontrolsüz kopyalanması gibi).
- Bu haftaki teknik araçlar (GE, RLS, maskeleme), yönetişim politikasını
  **otomatik olarak uygulanabilir** hale getirir — politika + teknik kontrol birlikte çalışır.

📎 [Çözüm](./solutions/05-kvkk-scenarios.md)
