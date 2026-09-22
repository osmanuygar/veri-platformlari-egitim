# ✅ Çözüm 3: Maskeleme ve Rol Bazlı Erişim

## 3.1 Kimliklendirici sınıflandırması

| Sütun | Sınıf | Gerekçe |
|---|---|---|
| `full_name` | Doğrudan | Tek başına (yaygın olmayan isimlerde) kişiyi belirleyebilir |
| `tckn` | Doğrudan | Tanım gereği **benzersiz** ve tek başına kişiyi belirler |
| `email` | Doğrudan | Genelde tek bir kişiye ait, birçok sistemde birincil kimlik |
| `phone` | Doğrudan | Email'e benzer şekilde kişiye özgü |
| `birth_date` | Dolaylı | Tek başına yetersiz ama isimle/şehirle birleşince güçlü bir ipucu |
| `city` | Dolaylı | Tek başına zararsız, küçük şehirlerde diğer alanlarla birleşince risk taşır |
| `income_band` | Hassas ama kimliklendirici değil | Kişiyi belirlemez ama ifşası istenmeyen bir bilgidir |

## 3.2 Maskeleme teknikleri

| Sütun | Teknik |
|---|---|
| `tckn_masked` | Kısmi gösterim (ilk 3 + son 2 hane, ortası yıldız) |
| `email_masked` | Kısmi gösterim (ilk karakter + domain) |
| `phone_masked` | Kısmi gösterim (son 4 hane) |
| `birth_year_only` | **Genelleştirme** |

`birth_year_only` bir **genelleştirmedir**, klasik maskeleme değil.
Maskeleme veriyi kısmen **gizler** (yıldızlarla); genelleştirme veriyi
**daha kaba bir çözünürlüğe** indirger (tam tarih yerine sadece yıl).
Genelleştirmenin avantajı: analitik hâlâ mümkündür ("yaş grubu bazında
analiz" yapılabilir), ama tam doğum tarihi (ki bu, diğer bilgilerle
birleşince kimlik hırsızlığı riski taşıyan güçlü bir kimliklendiricidir) ifşa edilmez.

## 3.3 k-anonimlik riski

**Evet, risk vardır.** `city` + `income_band` + `total_spent` kombinasyonu,
özellikle küçük bir şehirde (örn. Trabzon'da "high" gelir grubunda,
belirli bir harcama aralığında) **tek bir kişiyi** işaret edebilir —
bu duruma **k-anonimlik ihlali** denir (bir kombinasyonu paylaşan kişi
sayısı `k`'den azsa, örn. k=1 ise o kişi fiilen "yeniden tanımlanabilir" hale gelir).

Gerçek anonimleştirme için, bir kombinasyonu paylaşan **en az k kişi**
(örn. k≥5) olmasını garanti eden ek teknikler (genelleştirme derecesini
artırma, az örnekli grupları birleştirme, ya da diferansiyel gizlilik
gibi daha ileri yöntemler) gerekir — sadece doğrudan kimliklendiricileri
çıkarmak **yeterli değildir**.

## 3.4 Sütun bazlı GRANT

```sql
SET ROLE support_role;
SELECT income_band FROM raw.customers;
-- ERROR: permission denied for table customers (income_band sütunu için GRANT yok)
RESET ROLE;
```

Sütun bazlı GRANT (`GRANT SELECT (col1, col2) ON tablo TO rol`), rolün
**sadece belirtilen sütunlara** erişmesine izin verir — tablo bazlı GRANT
(`GRANT SELECT ON tablo TO rol`) ise **tüm sütunlara** erişim verir.

Destek ekibinin finansal veriye ihtiyacı yoksa, tablo bazlı erişim vermek
**gereksiz risk** oluşturur çünkü: (1) "en az ayrıcalık" (least privilege)
ilkesini ihlal eder — bir hesap ele geçirilirse saldırgan daha fazla
veriye erişir; (2) ekip büyüdükçe/değiştikçe "kimin neye gerçekten
ihtiyacı var" sorusu netliğini kaybeder; (3) denetimde (audit) "bu rolün
finansal veriye neden erişimi var" sorusuna cevap veremezsiniz.

## 3.5 Denetim izi

PostgreSQL'de seçenekler:
- **`pgaudit` eklentisi**: her SELECT/UPDATE/DELETE'i, hangi kullanıcının
  hangi tabloya eriştiğini içerecek şekilde loglar
- **`log_statement = 'all'`** (daha kaba, tüm sorguları loglar, performans maliyeti yüksek)
- **Uygulama katmanında loglama**: BI aracı (hafta 11) ya da API katmanında
  her sorguyu `kullanıcı, tablo, zaman` üçlüsüyle ayrı bir audit tablosuna yazmak

Pratikte en sürdürülebilir yaklaşım, `pgaudit` gibi veritabanı seviyesinde
çalışan bir çözümdür — uygulama koduna dağılmış, unutulabilir loglama
mantığına güvenmek yerine.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Doğrudan/dolaylı kimliklendirici | Doğrudan her zaman maskele; dolaylı, kombinasyonda risklidir |
| Genelleştirme | Maskelemeden farklı — çözünürlüğü düşürür, analitiği korur |
| k-anonimlik | Bir kombinasyonu paylaşan kişi sayısı k'den az olmamalı |
| Sütun bazlı GRANT | En az ayrıcalık ilkesinin somut uygulaması |
| Audit trail | Maskeleme yetmez, erişimin kendisi de kayıt altında olmalı |

**[← Alıştırma 3](../03-masking-rbac.md)**
