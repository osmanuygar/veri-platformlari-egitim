# Alıştırma 4: Veri Yönetişimi Politikası Yazımı

**Süre:** ~25 dakika · **Format:** Yazılı doküman

---

## 4.1 Senaryo

Küçük bir e-ticaret şirketi (bu haftaki `raw.customers`/`raw.orders`
şemasına sahip) için **2 sayfalık** bir veri yönetişimi politikası yazın.

**Görev:** Aşağıdaki bölümleri içeren bir doküman hazırlayın:

### 1. Kapsam ve Amaç
Bu politika hangi verileri, hangi sistemleri kapsıyor?

### 2. Roller ve Sorumluluklar
- **Veri Sahibi (Owner):** Kim? (İpucu: genelde iş birimi lideri)
- **Veri Yöneticisi (Steward):** Kim? (İpucu: günlük kalite/tanım sorumlusu)
- **Veri Koruyucusu (Custodian):** Kim? (İpucu: teknik altyapıyı işleten, genelde veri mühendisliği)

### 3. Veri Sınıflandırması
`raw.customers` tablosundaki sütunları en az 3 hassasiyet seviyesine ayırın
(örn. Genel / Dahili / Kısıtlı) ve her seviye için erişim kuralını yazın.

### 4. Saklama Süresi
Müşteri verisi ne kadar süre saklanmalı? Hesap kapatıldıktan sonra ne olmalı?
(Somut bir süre önerin ve gerekçelendirin.)

### 5. Veri Kalitesi Beklentisi
Hafta 12 Alıştırma 1'deki hangi GE kuralları bu politikaya referans
gösterilebilir?

---

## 4.2 Eleştirel değerlendirme

**Soru:** Yazdığınız politika, gerçekte **uygulanabilir** mi? Kim, nasıl
denetleyecek? Bir politika yazmak ile onu **operasyonel hale getirmek**
arasındaki fark nedir — bu haftaki Great Expectations ve Marquez kurulumları
bu politikanın hangi parçalarını **otomatikleştirebilir**?

---

## ✅ Ne öğrendik

- Bir veri yönetişimi politikası, soyut ilkelerden ibaret olamaz —
  **somut roller, somut süreler, somut kurallar** içermelidir.
- Politikanın gerçek değeri, **teknik kontrollerle** (GE testleri, RLS,
  RBAC) desteklendiğinde ortaya çıkar — aksi halde sadece bir belge olarak kalır.
- Veri sahibi/yönetici/koruyucu ayrımı, "bu veriden kim sorumlu" sorusuna
  net bir cevap verir — belirsizlik, hesap verebilirliğin düşmanıdır.

📎 [Çözüm](./solutions/04-governance-policy.md)
