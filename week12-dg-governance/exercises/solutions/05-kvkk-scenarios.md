# ✅ Çözüm 5: KVKK Senaryo Analizi

## 5.1-5.2 Senaryo değerlendirmeleri

| # | İhlal mi? | İlgili ilke | Düzeltme |
|---|---|---|---|
| 1 | **Evet** | Açık rıza (madde 5) | Sadece `consent_marketing=true` olan müşterilere gönderim yapılmalı |
| 2 | **Riskli / muhtemelen gereksiz** | Veri minimizasyonu (madde 4) | TCKN, churn tahmini için gerekli bir bilgi DEĞİLDİR — amaçla ilgisiz özel veri kullanımı; ayrıca hafta 8/10'daki "sızıntı" riskini de taşır (TCKN kimliği doğrudan belirlediği için model "ezberleyebilir") |
| 3 | **Evet** | Saklama süresi sınırlaması | Yasal zorunluluk yoksa, makul bir süre (örn. 3 yıl) sonunda silinmeli/anonimleştirilmeli |
| 4 | **Evet** | Veri güvenliği, amaç sınırlaması | Production PII'sinin maskelenmemiş kopyası, kontrolsüz bir ortama (kişisel dizüstü) taşınmamalı; test için maskelenmiş/sentetik veri kullanılmalı |
| 5 | **Evet** | Açık rıza, amaç sınırlaması | Belirtilen amaç dışında (üçüncü tarafla reklam amaçlı paylaşım) kullanım için **ayrı ve açık** rıza gerekir |

## 5.3 Teknik karşılıklar

- **Senaryo 1:** Pazarlama listesi üretilirken bir **Great Expectations
  kuralı** (`expect_column_values_to_be_in_set` benzeri, ya da özel bir
  SQL testi) listenin `consent_marketing=False` olan hiçbir satır
  içermediğini doğrular — bu kural pipeline'a (hafta 6) eklenirse, ihlal
  **üretim öncesinde** otomatik yakalanır.

- **Senaryo 2:** Model eğitim pipeline'ında, `tckn` gibi doğrudan
  kimliklendiricilerin **özellik listesinde bulunmadığını** doğrulayan
  bir kontrol (basit bir Python assert ya da GE kuralı) eklenebilir.
  Ayrıca Marquez'deki **lineage grafiği**, `tckn`'in hangi modellere/
  pipeline'lara "aktığını" görünür kılar — kullanımını denetlemeyi kolaylaştırır.

- **Senaryo 3:** Zamanlanmış bir **Airflow DAG'ı** (hafta 6), saklama
  süresi dolan kayıtları düzenli olarak tarayıp anonimleştirir/siler;
  bu işlemin kendisi de Marquez'e loglanarak **ne zaman, kaç kaydın
  silindiği** denetlenebilir hale gelir.

- **Senaryo 4:** RLS/sütun bazlı GRANT (Alıştırma 3), production
  veritabanına doğrudan erişimi zaten sınırlar; geliştiricilere test
  için **maskelenmiş bir görünüm** (`marts.customers_masked`) veya
  tamamen sentetik veri (bu haftaki `init/02-sample-data.sql`'in kendisi
  gibi) sağlanmalıdır.

- **Senaryo 5:** Üçüncü taraf paylaşımı, ayrı bir **rıza kaydı** (yeni
  bir `consent_third_party_sharing` sütunu gibi) ile takip edilmeli ve
  paylaşım pipeline'ı bu kaydı **GE ile doğrulamalıdır**.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Açık rıza | Amaç bazında AYRI olmalı — pazarlama rızası ≠ üçüncü taraf paylaşım rızası |
| Veri minimizasyonu | "Faydalı olabilir" yeterli değil — amaçla doğrudan ilişkili olmalı |
| Saklama süresi | Yasal zorunluluk yoksa süresiz saklama savunulamaz |
| Teknik kontrol | Her ilke, GE/RLS/Airflow gibi somut bir mekanizmaya bağlanabilir |

**[← Alıştırma 5](../05-kvkk-scenarios.md)**
