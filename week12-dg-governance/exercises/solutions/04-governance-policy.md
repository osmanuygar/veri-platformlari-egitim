# ✅ Çözüm 4: Veri Yönetişimi Politikası Yazımı

## 4.1 Örnek politika taslağı

### 1. Kapsam ve Amaç
Bu politika, `raw.customers` ve `raw.orders` tablolarında tutulan tüm
müşteri kişisel verilerini ve bu verilere erişen tüm sistemleri
(BI araçları, veri bilimi ortamları, üçüncü taraf entegrasyonlar) kapsar.

### 2. Roller
- **Veri Sahibi:** Müşteri İlişkileri Direktörü — verinin iş amacından ve
  toplanma gerekçesinden sorumlu
- **Veri Yöneticisi:** Analytics Engineering Lead — veri kalitesi
  kurallarından (bu haftaki GE suite'i), tanım tutarlılığından sorumlu
- **Veri Koruyucusu:** Veri Mühendisliği Ekibi — altyapı, erişim kontrolü,
  yedekleme, maskeleme uygulamasından sorumlu

### 3. Veri Sınıflandırması

| Seviye | Sütunlar | Erişim kuralı |
|---|---|---|
| **Kısıtlı** | `tckn`, `email`, `phone` (ham hali) | Sadece `data_engineering` rolü; herkes başkası maskelenmiş görünüm kullanır |
| **Dahili** | `city`, `income_band`, `birth_date` | Analist rolleri, iş amacıyla sınırlı |
| **Genel** | `id` (referans), agregasyonlar (`total_spent` gibi) | Tüm çalışanlar, dashboard'lar |

### 4. Saklama Süresi
Aktif müşteri verisi süresiz saklanır (sözleşme ilişkisi devam ettiği
sürece). Hesap kapatıldıktan sonra: **3 yıl** (yasal saklama yükümlülükleri
—örn. vergi/muhasebe mevzuatı— dikkate alınarak) tutulur, sonra **kalıcı
olarak silinir/anonimleştirilir**. (Somut süre, gerçek bir kurumda hukuk
danışmanlığıyla belirlenmelidir — bu bir eğitim örneğidir.)

### 5. Veri Kalitesi Beklentisi
Hafta 12 Alıştırma 1'deki `customers_quality_suite` (10 GE kuralı)
buraya referans verilir: her `dbt run` sonrası bu suite **otomatik**
çalıştırılır (hafta 6'daki Airflow entegrasyonu ile), `success_percent`
%100'ün altındaysa Veri Yöneticisi'ne bildirim gider.

## 4.2 Eleştirel değerlendirme

Bir politika, sadece bir Confluence/Notion sayfasında kalırsa **uygulanamaz**
— kimse her gün ona bakıp manuel kontrol yapmaz. Gerçek uygulanabilirlik,
politikanın **teknik kontrollere gömülmesiyle** gelir:

- "Kısıtlı" sınıflandırması → PostgreSQL'de sütun bazlı GRANT (Alıştırma 3)
- "Veri kalitesi beklentisi" → Great Expectations suite'i, CI/CD'de otomatik çalışır (Alıştırma 1)
- "Saklama süresi" → zamanlanmış bir Airflow DAG'ı (hafta 6), süresi dolan kayıtları otomatik anonimleştirir
- "Kim eriştiği" → `pgaudit` ile denetim izi (Alıştırma 3.5)

Politika **doküman** olarak başlar, **kod** olarak biter — aksi halde
"kağıt üzerinde iyi niyet" olmaktan öteye geçmez.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Rol ayrımı | Sahip/yönetici/koruyucu net olmalı, belirsizlik hesap verebilirliği öldürür |
| Sınıflandırma | Somut sütun listesi + somut erişim kuralı |
| Uygulanabilirlik | Politika teknik kontrole gömülmeden sadece iyi niyettir |

**[← Alıştırma 4](../04-governance-policy.md)**
