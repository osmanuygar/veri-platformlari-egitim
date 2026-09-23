# Hafta 12: Veri Yaşam Döngüsü ve Veri Yönetişimi

> 🟥 **İzlek:** Veri Yönetişimi (DG) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2.5 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [Veri Yaşam Döngüsü](#1-veri-yaşam-döngüsü)
3. [Veri Yönetişimi Çerçevesi](#2-veri-yönetişimi-çerçevesi)
4. [Veri Kalitesi](#3-veri-kalitesi)
5. [Metadata ve Veri Kataloğu](#4-metadata-ve-veri-kataloğu)
6. [Soy Ağacı (Data Lineage)](#5-soy-ağacı-data-lineage)
7. [Güvenlik ve Mahremiyet](#6-güvenlik-ve-mahremiyet)
8. [Uyumluluk: KVKK ve GDPR](#7-uyumluluk-kvkk-ve-gdpr)
9. [Alternatifler ve Ekosistem](#-alternatifler-ve-ekosistem)
10. [Hızlı Başlangıç](#-hızlı-başlangıç)
11. [Pratik Uygulamalar](#-pratik-uygulamalar)
12. [Alıştırmalar](#-alıştırmalar)
13. [Cheatsheet](#-cheatsheet)
14. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

- [ ] Veri yaşam döngüsünün tüm aşamalarını ve her aşamadaki sorumlulukları tanımlamak
- [ ] Veri yönetişimi çerçevesi kurmak: sahiplik, politika, süreç
- [ ] Great Expectations ile otomatik veri kalitesi kontrolleri yazmak
- [ ] OpenLineage/Marquez ile soy ağacı (lineage) toplamak ve okumak
- [ ] KVKK ve GDPR'ın veri platformuna somut teknik yansımalarını uygulamak

---

## 1. Veri Yaşam Döngüsü

### 1.1 Üretim → toplama → saklama → işleme → kullanım → arşiv → imha

```
Üretim ──▶ Toplama ──▶ Saklama ──▶ İşleme ──▶ Kullanım ──▶ Arşiv ──▶ İmha
(müşteri    (formdan,   (raw şema,  (dbt,      (BI,          (soğuk    (KVKK
 formu       API'den)    hafta 4-6) hafta 6)    hafta 11)     depolama) madde 7)
 doldurur)
```

Bu haftaya kadar öğrendiğiniz her şey, bu döngünün **bir kesiti**ydi:
hafta 2-4 saklama, hafta 6 işleme, hafta 11 kullanım. Bu hafta, döngünün
**tamamını** ve her aşamadaki riski ele alıyoruz.

### 1.2 Her aşamada risk ve kontrol noktaları

| Aşama | Risk | Kontrol |
|---|---|---|
| Toplama | Aşırı veri toplama (gereksiz alanlar) | Veri minimizasyonu ilkesi |
| Saklama | Yetkisiz erişim | RLS, sütun bazlı GRANT (Alıştırma 3) |
| İşleme | Sessiz kalite bozulması | Great Expectations (Alıştırma 1) |
| Kullanım | Amaç dışı kullanım | Lineage ile izlenebilirlik (Alıştırma 2) |
| İmha | Süresiz saklama | Zamanlanmış silme/anonimleştirme |

### 1.3 Saklama süresi (retention) politikaları

"Ne kadar saklamalıyım?" sorusunun cevabı **asla "süresiz"** olmamalıdır.
Yasal bir zorunluluk (vergi mevzuatı gibi) yoksa, veri **amacını
tamamladığında** silinmeli ya da anonimleştirilmelidir (Alıştırma 4).

### 1.4 Güvenli imha (right to be forgotten)

KVKK madde 7 ve GDPR'ın "unutulma hakkı", bir bireyin talebi üzerine
kişisel verisinin silinmesini gerektirir. Bu, sadece `DELETE FROM
customers` demek değildir — o kişinin verisi **yedeklerde, log'larda,
BI önbelleklerinde, ML eğitim setlerinde** de olabilir. Gerçek bir "unutma"
işlemi, bu haftaki **lineage grafiğinin** (Alıştırma 2) tam olarak
cevapladığı bir soruyu gerektirir: *"Bu kişinin verisi hangi sistemlere,
hangi tablolara aktı?"*

---

## 2. Veri Yönetişimi Çerçevesi

### 2.1 Veri sahibi, veri yöneticisi, veri koruyucusu

| Rol (İngilizce) | Türkçe | Sorumluluk |
|---|---|---|
| **Owner** | Veri Sahibi | Verinin iş amacından, toplanma gerekçesinden sorumlu (genelde iş birimi lideri) |
| **Steward** | Veri Yöneticisi | Günlük kalite, tanım tutarlılığı, metrik katmanı (hafta 11'deki "semantic layer" kavramını hatırlayın) |
| **Custodian** | Veri Koruyucusu | Teknik altyapı: erişim kontrolü, yedekleme, şifreleme (genelde veri mühendisliği) |

Bu üçlü ayrım olmadan, "bu tablo bozulduğunda kim sorumlu" sorusu
belirsiz kalır — Alıştırma 4'te kendi politikanızda bu rolleri
somutlaştıracaksınız.

### 2.2 Politika, standart, prosedür hiyerarşisi

```
Politika    →  "Kişisel veriler açık rıza olmadan pazarlama amaçlı kullanılamaz"  (İLKE, nadiren değişir)
Standart    →  "consent_marketing=true olmayan müşteri pazarlama listesine giremez"  (SOMUT KURAL)
Prosedür    →  "Pazarlama listesi her ayın 1'inde şu SQL sorgusuyla + GE kontrolüyle üretilir"  (ADIM ADIM UYGULAMA)
```

### 2.3 Veri sözleşmeleri (data contracts)

Bir veri sözleşmesi, bir tablonun/API'nin **üreticisi ile tüketicisi**
arasında şema, kalite ve SLA beklentisini netleştiren bir anlaşmadır.
Bu haftaki Great Expectations suite'i, aslında `raw.customers`'ın
**üreticisiyle** (kaynak sistem) **tüketicileri** (dbt modelleri, BI
araçları) arasındaki dolaylı bir sözleşmenin **teknik ifadesidir**.

### 2.4 Merkezi vs federe yönetişim; Data Mesh bağlantısı

| Model | Nasıl çalışır | Ne zaman |
|---|---|---|
| **Merkezi** | Tek bir veri ekibi tüm kalite/erişim kararlarını verir | Küçük organizasyon, tek bir "doğru" tanım kolay korunur |
| **Federe (Data Mesh)** | Her iş alanı kendi verisinin sahibi, merkezi ekip sadece standart belirler | Büyük organizasyon, tek merkezi ekip darboğaz haline gelir |

Hafta 4'te değindiğimiz **Data Mesh** mimarisi, yönetişimi de
**merkezsizleştirir** — her "veri ürünü" kendi kalite/erişim
sorumluluğunu taşır, merkezi ekip sadece ortak standartları (nasıl bir
GE suite'i olmalı, nasıl bir lineage aracı kullanılmalı) belirler.

---

## 3. Veri Kalitesi

### 3.1 Altı boyut

| Boyut | Soru | Bu haftaki örnek |
|---|---|---|
| **Doğruluk** | Değer gerçeği yansıtıyor mu? | TCKN formatı doğru mu |
| **Eksiksizlik** | Zorunlu alanlar dolu mu? | `email` null değil mi |
| **Tutarlılık** | Farklı kaynaklardaki aynı veri uyumlu mu? | `orders.customer_id`, `customers.id`'de var mı |
| **Zamanlılık** | Veri yeterince güncel mi? | (hafta 6'daki freshness kavramı) |
| **Geçerlilik** | Format/aralık kurallarına uyuyor mu? | Doğum tarihi gelecekte olamaz |
| **Benzersizlik** | Kopya kayıt var mı? | `id` unique mi |

### 3.2 Great Expectations ile beklenti (expectation) yazma

```python
validator.expect_column_values_to_match_regex("tckn", r"^[1-9][0-9]{10}$")
validator.expect_column_values_to_not_be_null("email")
validator.expect_column_values_to_be_between("birth_date",
    min_value=pd.Timestamp("1920-01-01"), max_value=pd.Timestamp("2010-01-01"))
```

Bu haftaki `scripts/ge_validate.py`, `raw.customers`'a **10 beklenti**
uygular. Veri **kasıtlı olarak** birkaç kalite sorunu içeriyor — bazı
testlerin başarısız olması, hafta 8'deki EDA felsefesiyle aynıdır:
sorunu **görmek**, çözmenin ilk adımıdır.

### 3.3 Kalite kapıları (quality gates) pipeline'a nasıl gömülür

```
extract → dbt run → [GE VALIDATE] → dbt test → dashboard'a yansı
                          │
                    başarısızsa: DURDUR ya da UYAR
                    (bkz. Alıştırma 1.5)
```

Hafta 6'daki Airflow DAG'ına bir `ge_validate` task'ı eklemek, bu kapının
**her pipeline çalıştırmasında otomatik** işlemesini sağlar — tek seferlik
bir kontrol değil, sürekli bir güvencedir.

### 3.4 Kalite skoru raporlama ve SLA

Great Expectations'ın `success_percent` metriği, zaman içinde izlenirse
(her run'ın sonucu bir tabloya/Marquez'e loglanırsa), bir "veri kalitesi
SLA'sı" tanımlanabilir: *"customers_quality_suite her zaman ≥%95 başarı
oranına sahip olmalı, düşerse alarm."*

---

## 4. Metadata ve Veri Kataloğu

### 4.1 Teknik, iş ve operasyonel metadata

| Tür | Örnek |
|---|---|
| **Teknik** | Sütun tipi, tablo boyutu, indeks bilgisi |
| **İş** | "`segment` kolonunun tanımı: son 90 günde ≥2 sipariş = 'gold'" |
| **Operasyonel** | Son güncelleme zamanı, hangi pipeline'ın ürettiği, kaç kez sorgulandığı |

### 4.2 Veri kataloğu: DataHub, OpenMetadata, Amundsen

Bu araçlar, bir organizasyondaki **tüm** tabloları/dataset'leri arama
motoru gibi keşfedilebilir hale getirir — "müşteri geliri" ararsanız,
hangi tabloda, hangi sütunda, kim tarafından bakımı yapılan bir alan
olduğunu bulursunuz. Bu hafta küçük ölçekte **Marquez**'i kullanıyoruz
(o da bir tür katalog + lineage aracıdır); büyük organizasyonlarda
DataHub/OpenMetadata gibi daha kapsamlı araçlar tercih edilir.

### 4.3 Veri sözlüğü (business glossary)

"Aktif müşteri", "churn", "segment" gibi terimlerin **tek, resmi**
tanımının yaşadığı belge/araç — hafta 11'deki "semantic layer"
kavramının kurumsal versiyonu.

### 4.4 Keşfedilebilirlik: "bu tabloyu kim kullanıyor?"

Marquez'in lineage grafiği, bu soruyu tam olarak cevaplar: bir dataset'in
**aşağı akışına** (downstream) bakarak, onu okuyan tüm job'ları/tabloları
görebilirsiniz (Alıştırma 2.2).

---

## 5. Soy Ağacı (Data Lineage)

### 5.1 Tablo ve sütun seviyesi lineage

Bu hafta **tablo seviyesi** lineage ile çalışıyoruz (`raw.customers` →
`marts.customers_masked`). Daha gelişmiş araçlar **sütun seviyesi**
lineage de sunar (`raw.customers.tckn` özellikle hangi çıktı sütununa
katkı sağladı) — bu, KVKK "hangi kişisel veri nereye gitti" sorusunu
çok daha kesin cevaplar.

### 5.2 OpenLineage standardı ve Marquez

**OpenLineage**, lineage bilgisini standart bir formatta (JSON, RunEvent/
Job/Dataset yapıları) tanımlayan açık bir spesifikasyondur — Airflow,
dbt, Spark gibi birçok araç bu standardı destekler. **Marquez**, bu
standardı **toplayıp görselleştiren** referans uygulamadır.

```python
from openlineage.client import OpenLineageClient
from openlineage.client.run import RunEvent, RunState, Run, Job, Dataset
```

Bu haftaki `scripts/emit_lineage.py`, bu mekanizmayı elle tetikleyerek
3 adımlı bir pipeline'ın (`extract_customers` → `transform_customer_marts`
→ `export_to_bi`) lineage'ını üretir.

### 5.3 Etki analizi: şemayı değiştirirsem ne kırılır

Alıştırma 2.2'nin konusu — bir sütunu yeniden adlandırmadan/silmeden
önce, lineage grafiğinde **aşağı akışa** bakarak hangi job'ların/
dashboard'ların (hafta 11) etkileneceğini önceden görürsünüz.

### 5.4 Kök neden analizi: bu rapor neden yanlış

Alıştırma 2.4'ün konusu — bir dashboard'daki (hafta 11) yanlış bir sayıdan
geriye doğru, hangi ham tablodaki hangi soruna kadar **tek tıkla**
izleyebilirsiniz.

---

## 6. Güvenlik ve Mahremiyet

### 6.1 Erişim kontrolü: RBAC, ABAC, satır/sütun düzeyi

| Model | Nasıl | Bu haftaki/geçmiş örnek |
|---|---|---|
| **RBAC** (Role-Based) | Rol → izin eşlemesi | `GRANT SELECT (email) TO support_role` (Alıştırma 3) |
| **ABAC** (Attribute-Based) | Kullanıcının/verinin özelliklerine göre dinamik kural | Hafta 11'deki Superset RLS (`region = current_username()`) |
| **Satır düzeyi (RLS)** | Aynı tablo, kullanıcıya göre farklı satırlar | Hafta 11, Alıştırma 3 |
| **Sütun düzeyi** | Aynı tablo, kullanıcıya göre farklı sütunlar | Bu hafta, Alıştırma 3 |

### 6.2 Maskeleme, tokenizasyon, şifreleme (at rest / in transit)

| Teknik | Ne yapar | Geri döndürülebilir mi |
|---|---|---|
| **Maskeleme** | Kısmi gösterim (`***@example.com`) | Hayır — orijinal değer kayboldu |
| **Tokenizasyon** | Gerçek değeri rastgele bir token'la değiştirir, eşleme ayrı bir güvenli yerde tutulur | Evet (yetkiliyseniz) |
| **Şifreleme (at rest)** | Diskte şifreli saklama | Evet (anahtarla) |
| **Şifreleme (in transit)** | Ağda şifreli iletim (TLS) | Evet (anahtarla) |

### 6.3 PII tespiti ve sınıflandırma

Alıştırma 3.1'de elle yaptığınız "doğrudan/dolaylı kimliklendirici"
sınıflandırmasını, büyük organizasyonlarda otomatik PII tarama araçları
(regex + ML tabanlı) yapar — binlerce tabloyu elle taramak pratik değildir.

### 6.4 Denetim izi (audit trail)

Alıştırma 3.5'te gördüğümüz gibi, **kim, ne zaman, hangi veriye eriştiğinin**
kaydı, maskeleme/RLS kadar kritik bir kontroldür — erişim kısıtlansa bile,
kısıtlı erişimin **kendisinin** izlenmesi gerekir.

---

## 7. Uyumluluk: KVKK ve GDPR

### 7.1 Kişisel veri tanımı ve özel nitelikli veri

**KVKK madde 3:** Kişisel veri, "kimliği belirli veya belirlenebilir
gerçek kişiye ilişkin her türlü bilgi"dir — TCKN, email, hatta IP adresi
bile bu tanıma girer. **Özel nitelikli veri** (madde 6) ise ırk, etnik
köken, sağlık, cinsel hayat gibi daha sıkı korunan bir alt kümedir —
bu haftaki verimizde özel nitelikli veri **yok**, ama `income_band` gibi
hassas ama özel nitelikli olmayan veriler de dikkatli ele alınmalıdır.

### 7.2 Açık rıza, aydınlatma yükümlülüğü, VERBİS

- **Açık rıza:** Belirli bir konuda, bilgilendirilmiş ve özgür iradeyle
  verilen onay (bu haftaki `consent_marketing` sütunu bunun basit bir örneği)
- **Aydınlatma yükümlülüğü:** Veri toplanırken kişiye "hangi veri, hangi
  amaçla, kime aktarılacak" bilgisinin verilmesi
- **VERBİS:** Veri Sorumluları Sicil Bilgi Sistemi — belirli ölçekteki
  veri sorumlularının kayıt olma zorunluluğu

### 7.3 Veri minimizasyonu ve amaç sınırlaması

**Veri minimizasyonu:** Sadece amacınız için **gerekli olan** veriyi
toplayın/işleyin — "ileride işe yarar" gerekçesiyle veri biriktirmek
ilkeye aykırıdır (Alıştırma 5, Senaryo 2).

**Amaç sınırlaması:** Bir amaçla toplanan veri, **farklı bir amaçla**
(ek rıza olmadan) kullanılamaz (Alıştırma 5, Senaryo 5).

### 7.4 Sınır ötesi veri aktarımı

KVKK, kişisel verinin yurt dışına aktarımını belirli şartlara bağlar
(yeterli korumaya sahip ülke, yazılı taahhüt, Kurul izni vb.). Bulut
sağlayıcı seçimi (hafta 4'teki "build vs buy" tartışmasını hatırlayın)
bu açıdan da değerlendirilmelidir — verinin fiziksel olarak nerede
saklandığı önemlidir.

### 7.5 İhlal bildirimi süreçleri

Bir veri ihlali tespit edildiğinde, KVKK Kurulu'na **72 saat içinde**
bildirim yapılması gerekir (GDPR'da da benzer bir süre). Bu haftaki
**audit trail** (Alıştırma 3.5) ve **lineage** (Alıştırma 2), "ihlal
tam olarak neyi, ne kadarını etkiledi" sorusunu hızla cevaplamanın
teknik altyapısıdır — bu soruyu 72 saat içinde cevaplayamamak, ihlalin
kendisi kadar ciddi bir sorundur.

### 7.6 Teknik karşılıkları: hangi kontrol hangi maddeye cevap veriyor

| KVKK/GDPR İlkesi | Bu haftaki teknik karşılık |
|---|---|
| Açık rıza | `consent_marketing` sütunu + GE kuralı ile doğrulama |
| Veri minimizasyonu | Model/rapor için gereksiz PII sütununu hiç çekmemek |
| Amaç sınırlaması | RLS/RBAC ile "kim hangi amaçla erişebilir" sınırı |
| Saklama süresi | Zamanlanmış silme DAG'ı (hafta 6) |
| Güvenli imha | `marts.customers_masked` gibi geri döndürülemez maskeleme |
| Hesap verebilirlik | Audit trail + lineage (Marquez) |
| İhlal bildirimi | Lineage ile "ne etkilendi" sorusunun hızlı cevabı |

---

## 🔄 Alternatifler ve Ekosistem

Bu hafta kullandığımız araçlar tek seçenek değil. Aynı işi yapan açık kaynak ve
enterprise/yönetilen alternatifler:

| Kullandığımız | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|
| **Great Expectations** | Soda Core, dbt tests, Pandera, Deequ (Spark), Elementary | GX Cloud, Soda Cloud, Monte Carlo, Bigeye, Anomalo, Informatica Data Quality | Kural yazmak yerine otomatik anomali tespiti (data observability), iş kullanıcısı arayüzü |
| **Marquez / OpenLineage** | OpenMetadata, DataHub, Apache Atlas, Amundsen | Collibra, Alation, Atlan, Microsoft Purview, Databricks Unity Catalog, Google Dataplex | Sütun seviyesi lineage, iş sözlüğü, veri sahipliği iş akışları, denetim raporları |
| **PostgreSQL rol + view ile maskeleme** | Apache Ranger, Open Policy Agent, PostgreSQL Anonymizer | Immuta, Privacera, Snowflake/BigQuery yerleşik maskeleme politikaları, Unity Catalog | Çok sayıda motor üzerinde tek merkezden politika, KVKK denetim kanıtı |
| **PII tespiti** (§6.3) | Microsoft Presidio | Google Sensitive Data Protection (DLP), Amazon Macie, BigID, Microsoft Purview | Yapılandırılmamış veride ve büyük ölçekte otomatik sınıflandırma |

**Değerlendirirken bakılacaklar:** kaç kaynak sisteme bağlanacağı (konektör kapsamı), iş kullanıcılarının kullanıp kullanmayacağı, OpenLineage gibi açık standart desteği, denetim ve raporlama (KVKK/VERBİS kanıtı), yerinde kurulum imkânı (veri yurt dışına çıkmamalıysa).

> 💡 Yönetişim araçlarında en sık hata, aracı süreçten önce almaktır. Pahalı bir katalog, sahibi
> belirlenmemiş tablolarla dolu bir arama motoruna dönüşür. Önce §2'deki roller ve politikalar,
> sonra araç.

📎 Tüm katmanların haritası ve lisans rehberi: [ALTERNATIVES.md](../ALTERNATIVES.md#-yönetişim-kalite-ve-katalog-hafta-12)

---

## 🚀 Hızlı Başlangıç

```bash
cd week12-dg-governance
./setup-week12.sh
pip install -r requirements.txt
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| PostgreSQL (PII veri kaynağı) | `postgres:15` | `5440` | — |
| Marquez API | `marquezproject/marquez` | `5002` / `5003` | http://localhost:5002 |
| Marquez Web | `marquezproject/marquez-web` | `3002` | http://localhost:3002 |
| GE Data Docs | statik dosya sunucusu | `8099` | http://localhost:8099 |

**Bellek ihtiyacı:** ~3 GB.

### Durdurma

```bash
docker compose down        # durdur (veri kalır)
docker compose down -v     # durdur + volume sil
```

---

## 🧪 Pratik Uygulamalar

| Script | Ne yapar |
|---|---|
| `scripts/ge_validate.py` | `raw.customers`'a 10 GE kuralı uygular, Data Docs üretir |
| `scripts/emit_lineage.py` | 3 adımlı sahte pipeline'ın lineage'ını Marquez'e gönderir |

### ✨ Bu Haftanın "Wow" Anı

```bash
python scripts/emit_lineage.py
open http://localhost:3002
```

Marquez Web'de `transform_customer_marts` job'una tıklayın. Bir dashboard'da
gördüğünüz **tek bir sayının**, hangi ham tablolardan, hangi dönüşüm
adımlarından geçerek oraya ulaştığını — **4 adım öteden** — görsel bir
grafikte takip edin. "Bu rakam neden yanlış?" sorusunun cevabı artık
Slack'te ekip aramak değil, tek bir tıklama.

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Great Expectations ile Kalite Kontrolü](./exercises/01-great-expectations.md) | 30 dk | 10 beklenti, Data Docs |
| 2 | [Marquez ile Soy Ağacı](./exercises/02-lineage.md) | 30 dk | OpenLineage, etki analizi |
| 3 | [Maskeleme ve Rol Bazlı Erişim](./exercises/03-masking-rbac.md) | 30 dk | PII, maskeleme, GRANT |
| 4 | [Veri Yönetişimi Politikası Yazımı](./exercises/04-governance-policy.md) | 25 dk | Politika, sahiplik |
| 5 | [KVKK Senaryo Analizi](./exercises/05-kvkk-scenarios.md) | 20 dk | Uyum, ihlal tespiti |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**Great Expectations Cheatsheet**](./cheatsheets/great-expectations-cheatsheet.md)
- 📎 [**Marquez & OpenLineage Cheatsheet**](./cheatsheets/marquez-cheatsheet.md)

---

## 🧯 Sık Karşılaşılan Sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| Marquez Web boş sayfa | API henüz hazır değil | `docker compose logs marquez-api`, biraz bekleyin |
| `emit_lineage.py` bağlanamıyor | Marquez API portu yanlış | `.env`'de `MARQUEZ_URL=http://localhost:5002` |
| GE `TypeError: same type` hatası | Tarih sütunu `datetime64[ns]` değil | `.astype("datetime64[ns]")` uygulayın |
| Data Docs 8099'da açılmıyor | `ge_validate.py` hiç çalıştırılmadı | Önce script'i host'ta çalıştırın |
| `SET ROLE` hata veriyor | Rol `raw.customers`'a GRANT edilmemiş | Alıştırma 3.4'teki GRANT'i çalıştırın |

---

## 📖 Kaynaklar

- [Great Expectations Docs](https://docs.greatexpectations.io/)
- [OpenLineage](https://openlineage.io/)
- [Marquez](https://marquezproject.ai/)
- [KVKK Resmî Sitesi](https://www.kvkk.gov.tr/)
- [GDPR Metni](https://gdpr-info.eu/)
- **"Data Governance: The Definitive Guide"** — Evren Eryurek ve diğerleri

---

## 📝 Hafta Özeti

✅ **Veri yaşam döngüsü** — üretimden imhaya, her aşamanın kendi riski var
✅ **Sahip/yönetici/koruyucu** — belirsizlik olmadan net sorumluluk
✅ **Great Expectations** — veri kalitesi kod olarak, sürekli güvence
✅ **Marquez/OpenLineage** — etki analizi ve kök neden analizi tek tıkla
✅ **Maskeleme ve RBAC** — en az ayrıcalık ilkesinin somut uygulaması
✅ **KVKK/GDPR** — soyut ilkelerin somut teknik kontrollere dönüşümü

> 💡 **Haftanın tek cümlesi:** İyi bir veri yönetişimi, veriyi
> **kilitleyen** değil, **kime, ne zaman, hangi koşulda erişilebileceğini
> net ve denetlenebilir kılan** bir sistemdir.

---

**[← Hafta 11: İş Zekası & Raporlama Sistemleri](../week11-bi-reporting/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 13: AI ve LLM Çağında Veri Platformları →](../week13-dg-ai-llm/README.md)**
