# Hafta 11: İş Zekası & Raporlama Sistemleri

> 🟧 **İzlek:** İş Zekası (BI) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2.5 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [İş Zekası Nedir?](#1-i̇ş-zekası-nedir)
3. [Metrik ve KPI Tasarımı](#2-metrik-ve-kpi-tasarımı)
4. [Dashboard Tasarımı](#3-dashboard-tasarımı)
5. [Metabase](#4-metabase)
6. [Apache Superset](#5-apache-superset)
7. [Raporlama Operasyonu](#6-raporlama-operasyonu)
8. [Hızlı Başlangıç](#-hızlı-başlangıç)
9. [Pratik Uygulamalar](#-pratik-uygulamalar)
10. [Alıştırmalar](#-alıştırmalar)
11. [Cheatsheet](#-cheatsheet)
12. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

- [ ] İş zekası ile veri bilimi arasındaki rol farkını açıklamak
- [ ] Anlamlı KPI ve metrik tanımlamak, metrik katmanı kurmak
- [ ] Metabase ve Superset ile dashboard üretmek ve ikisini karşılaştırmak
- [ ] Etkili dashboard tasarım ilkelerini uygulamak
- [ ] Self-service BI'ın yönetişim gereksinimlerini kavramak

---

## 1. İş Zekası Nedir?

### 1.1 BI'ın tarihçesi: raporlamadan self-service'e

```
1990'lar          2000'ler              2010'lar              2020'ler
Statik raporlar → IT'nin ürettiği    → Self-service BI     → Gömülü analitik
(basılı, PDF)     dashboard'lar         (Tableau, Looker)     (uygulama içi,
                  (haftalarca sürer)    (iş birimi kendi        API ile)
                                        sorusunu sorar)
```

Bu haftaki araçlar (Metabase, Superset) **self-service** neslinin açık
kaynak temsilcileridir — iş biriminin, her sorusu için IT'ye bilet açmadan
kendi dashboard'unu kurabilmesi fikri.

### 1.2 BI vs veri bilimi vs analytics engineering

Hafta 6 ve 8'de gördüğümüz rol ayrımını hatırlayın:

| Rol | Soru | Bu haftaki karşılığı |
|---|---|---|
| **Analytics Engineer** (hafta 6) | "`revenue` tam olarak nasıl hesaplanmalı?" | `bi.fact_sales` şemasını kurmak |
| **BI/Veri Analisti** (bu hafta) | "Geçen ay hangi bölgede satış düştü?" | Metabase/Superset ile dashboard |
| **Veri Bilimci** (hafta 8-10) | "Önümüzdeki ay hangi müşteri churn eder?" | Tahmine dayalı model |

### 1.3 Rapor, dashboard, veri ürünü ayrımı

| Format | Özellik | Ne zaman |
|---|---|---|
| **Rapor** | Statik, belirli bir ana ait, genelde PDF/e-posta | Yönetim kurulu sunumu, denetim |
| **Dashboard** | Canlı, filtrelenebilir, sürekli güncel | Günlük operasyon takibi |
| **Veri ürünü** | API/uygulama içine gömülü, kullanıcı etkileşimli | Müşteriye açık analitik panel |

---

## 2. Metrik ve KPI Tasarımı

### 2.1 İyi metriğin özellikleri: eyleme geçirilebilir, tek anlamlı, sahipli

- **Eyleme geçirilebilir:** Metrik kötüleştiğinde, "ne yapmalıyım" sorusuna
  bir cevap ima etmeli. "Toplam kullanıcı sayısı" arttı/azaldı bilgisi
  tek başına eyleme dönüşmez; "haftalık aktif kullanıcı oranı" düştü
  bilgisi somut bir araştırma başlatır.
- **Tek anlamlı:** İki kişi aynı metriği farklı yorumlamamalı. "Aktif
  müşteri" belirsizse (bkz. Alıştırma 1.3), rapor güvenilirliğini kaybeder.
- **Sahipli:** Her metriğin, kötüleştiğinde **kimin** harekete geçeceği net olmalı.

### 2.2 Öncü ve gecikmeli göstergeler

| Tür | Tanım | Örnek |
|---|---|---|
| **Öncü (leading)** | Geleceği tahmin eder, erken uyarı verir | Destek çağrısı sayısı artışı → churn'ün habercisi |
| **Gecikmeli (lagging)** | Geçmişi özetler, sonucu ölçer | Aylık ciro, churn oranının kendisi |

İyi bir dashboard **ikisini birden** içerir — sadece gecikmeli göstergelerle
çalışmak, "yangını ancak söndükten sonra fark etmek" gibidir.

### 2.3 Vanity metric tuzağı

Büyüyen ama karar değiştirmeyen metrikler — "toplam kayıtlı kullanıcı",
"sosyal medya takipçisi". Alıştırma 1.2'de bunları ayırt etmeyi pratik edeceğiz.

### 2.4 Metrik katmanı (semantic layer): tek doğru tanım nerede yaşar

Hafta 6'daki dbt modellerini hatırlayın: `customer_segment` tablosu, "segment"
tanımının **tek bir yerde** yaşadığı bir örnekti. BI dünyasında bu fikir
**semantic layer** (Looker'ın LookML'i, Cube, ya da basitçe dbt modelleri +
view'lar) olarak karşımıza çıkar — her dashboard aracı aynı tanıma
başvurur, kimse kendi SQL'inde "aktif müşteri"yi yeniden icat etmez.

---

## 3. Dashboard Tasarımı

### 3.1 Hedef kitleye göre tasarım: yönetici, operasyon, analist

| Kitle | İhtiyaç | Tasarım |
|---|---|---|
| **Yönetici** | 10 saniyede özet | 3-5 büyük sayı + trend oku, detay yok |
| **Operasyon** | Anlık durum, aksiyon tetikleyici | Alarm renkleri, eşik çizgileri, sık yenileme |
| **Analist** | Derinlemesine keşif | Filtrelenebilir tablolar, drill-down, ham veri erişimi |

Aynı dashboard'u her üç kitleye de sunmaya çalışmak, **hiçbirini iyi
hizmet etmeyen** bir orta yol üretir.

### 3.2 Bilgi hiyerarşisi ve görsel yük

**F-deseni / Z-deseni:** Gözler sayfayı belirli örüntülerle tarar — en
kritik bilgi sol üstte ya da büyük ve merkezi olmalı. 12 eşit boyutlu
grafik, hiçbir hiyerarşi kurmaz — okuyucu nereye bakacağını bilmez
(bkz. Alıştırma 4).

### 3.3 Grafik seçimi ve renk kullanımı

Bkz. [Hafta 8 Görselleştirme Cheatsheet](../week08-ds-intro/cheatsheets/visualization-cheatsheet.md)
— aynı ilkeler burada da geçerli, ölçek daha büyük (dashboard = birden
fazla grafiğin birlikte anlatısı).

### 3.4 Erişilebilirlik ve renk körlüğü

Dünya nüfusunun ~%8'i (erkeklerin ~%1'i kadın, çarpıcı bir asimetri) bir
tür renk körlüğüne sahiptir — en yaygını kırmızı-yeşil ayrımını zorlaştırır.
Kırmızı/yeşil "kötü/iyi" kodlaması bu kullanıcılar için **anlamsızlaşır**.
Mavi-turuncu gibi paletler daha güvenlidir; renk yanında **şekil/desen**
farkı da kullanmak (ikinci bir kodlama katmanı) en güvenlisidir.

### 3.5 Yaygın hatalar: pasta grafiği, 3D, çift eksen

Bkz. Alıştırma 4 — bu üç hatayı ve düzeltmelerini uygulamalı göreceksiniz.

---

## 4. Metabase

### 4.1 Kurulum ve veri kaynağı bağlama

Bu hafta Metabase kendi metadata veritabanıyla (`week11_metabase_db`)
ve veri kaynağı olarak `bi.fact_sales` şemasını içeren Postgres'le
(`week11_postgres`) birlikte geliyor. Bkz. [Hızlı Başlangıç](#-hızlı-başlangıç).

### 4.2 Soru (question) ve koleksiyon yapısı

Metabase'in temel birimi **Question**: bir tablo seçip, GUI ile agregasyon/
gruplama/filtre ekleyerek (SQL yazmadan) bir sonuç üretirsiniz. Sorular
**Collection**'larda (klasör) organize edilir.

### 4.3 Modeller ve hesaplanmış sütunlar

**Model**, sık kullanılan bir sorguyu (örn. "sadece tamamlanmış
siparişler") merkezi olarak tanımlamanın yoludur — diğer sorular bu
modelin üzerine inşa edilir. dbt'nin `ref()` fikrinin Metabase'deki
hafif karşılığı.

### 4.4 Zamanlanmış gönderim ve uyarılar (alerts)

- **Subscriptions:** Dashboard'u belirli aralıklarla e-postayla gönderir
- **Alerts:** Bir metrik eşiği aştığında/altına düştüğünde bildirim

---

## 5. Apache Superset

### 5.1 Dataset, chart, dashboard katmanları

```
Database bağlantısı → Dataset (tablo/view/SQL sorgusu) → Chart → Dashboard
```

Superset'te bir **Dataset**, Metabase'deki "tablo"dan daha esnektir —
doğrudan bir SQL sorgusunun sonucu da bir dataset olabilir.

### 5.2 SQL Lab ile keşif

SQL Lab, Superset'in tam SQL editörüdür — karmaşık join'ler, CTE'ler,
pencere fonksiyonları (hafta 5) doğrudan yazılabilir ve sonuç bir dataset
olarak kaydedilebilir.

### 5.3 Sanal dataset ve Jinja şablonları

```sql
SELECT * FROM bi.fact_sales
WHERE date_key >= {{ from_dttm | int }}
```

Jinja şablonlama, dashboard filtrelerinin doğrudan SQL'e enjekte
edilmesini sağlar — GUI'nin yetmediği karmaşık senaryolarda kullanılır.

### 5.4 Satır düzeyi güvenlik (row-level security)

Superset'in en güçlü yanlarından biri: **aynı dashboard, kullanıcıya göre
farklı veri.** Bir kural tanımlanır (`region = current_username()` gibi),
Superset her sorguya bu koşulu otomatik ekler. Alıştırma 3'te uygulamalı işleyeceğiz.

### 5.5 Metabase ile karşılaştırma: ne zaman hangisi

Bkz. [Superset Cheatsheet — Karşılaştırma tablosu](./cheatsheets/superset-cheatsheet.md#-metabase-ile-karşılaştırma)

---

## 6. Raporlama Operasyonu

### 6.1 Yenileme sıklığı ve tazelik (freshness) beklentisi

Her dashboard'un **beklenen tazeliği** açık olmalı: "gerçek zamanlı",
"saatlik", "günlük gece batch'i" (hafta 6). Kullanıcı bunu bilmezse,
eski veriyle karar verip fark etmeyebilir.

### 6.2 Dashboard çoğalması (sprawl) ve envanter yönetimi

Self-service BI'ın karanlık yüzü: herkesin kendi dashboard'unu kurabilmesi,
zamanla **yüzlerce, kimse tarafından bakılmayan** dashboard birikimine yol
açar. Periyodik bir "dashboard envanteri" (kim kullanıyor, ne zaman
güncellendi) olmadan bu, yönetilemez bir karmaşaya dönüşür.

### 6.3 Kullanım takibi: kimse bakmıyorsa kaldır

Hem Metabase hem Superset, dashboard/soru **görüntülenme istatistiklerini**
tutar. Aylık bir gözden geçirmeyle, hiç açılmayan dashboard'ları arşivlemek
sağlıklı bir BI ortamının parçasıdır.

### 6.4 Hafta 12'ye köprü: kim neye erişebilir

Bu haftaki RLS alıştırması (Alıştırma 3), aslında hafta 12'nin ana
konusu olan **veri yönetişiminin** BI katmanındaki uygulamasıdır — "kim
hangi veriyi görebilir" sorusu, sadece BI araçlarıyla değil, organizasyon
genelinde bir politikayla cevaplanmalıdır.

---

## 🚀 Hızlı Başlangıç

```bash
cd week11-bi-reporting
./setup-week11.sh
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| PostgreSQL (veri kaynağı) | `postgres:15` | `5439` | — |
| Metabase | `metabase/metabase` | `3001` | http://localhost:3001 |
| Superset | özel (apache/superset) | `8098` | http://localhost:8098 (admin/admin) |

**Bellek ihtiyacı:** ~3.5 GB (3 Postgres instance + 2 BI aracı).

### Durdurma

```bash
docker compose down        # durdur (veri kalır)
docker compose down -v     # durdur + volume sil
```

---

## 🧪 Pratik Uygulamalar

- Hazır star şema (`bi.fact_sales` + boyutlar) üzerine Metabase dashboard kurmak
- Aynı veriyle Superset dashboard kurup iki aracı karşılaştırmak
- Satır düzeyi güvenlik kurup farklı kullanıcıların farklı veri görmesini sağlamak
- Kötü tasarlanmış bir dashboard'u yeniden tasarlamak

### ✨ Bu Haftanın "Wow" Anı

`bi.fact_sales` şeması ~2200+ satır, hazır, container açılır açılmaz orada.
Metabase'e bağlanıp:

```
+ New → Question → Fact Sales → Summarize: Sum of revenue → Group by: Date (by Month)
```

**10 dakikadan kısa sürede**, aylık ciro trendini gösteren, Kasım-Aralık
sıçramasını net şekilde ortaya koyan bir grafik elde edersiniz. Hafta
4'te haftalarca inşa ettiğiniz star şema, hafta 6'da öğrendiğiniz
dönüşüm katmanı — hepsi nihayet **bir yöneticinin bakabileceği bir
ekrana** dönüşüyor. Bu, tüm veri mühendisliği zincirinin "iş sonucu"
üretme anı.

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [KPI Tasarımı](./exercises/01-kpi-design.md) | 20 dk | Metrik tanımı, sahiplik |
| 2 | [Metabase Dashboard](./exercises/02-metabase-dashboard.md) | 35 dk | Soru, filtre, dashboard |
| 3 | [Superset + RLS](./exercises/03-superset-rls.md) | 35 dk | SQL Lab, satır düzeyi güvenlik |
| 4 | [Dashboard Eleştirisi](./exercises/04-dashboard-critique.md) | 20 dk | Tasarım hataları |
| 5 | [Metabase vs Superset](./exercises/05-tool-comparison.md) | 15 dk | Karşılaştırma raporu |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**Metabase Cheatsheet**](./cheatsheets/metabase-cheatsheet.md)
- 📎 [**Superset Cheatsheet**](./cheatsheets/superset-cheatsheet.md)

---

## 🧯 Sık Karşılaşılan Sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| Superset admin girişi yok | `superset fab create-admin` çalışmadı | `docker exec week11_superset superset fab create-admin ...` |
| Veri kaynağı bağlanamıyor | `localhost` yazılmış | Container ağı içinden `postgres` host adını kullanın |
| Metabase ilk açılışta yavaş | JVM soğuk başlangıcı | 30-60 sn normal, sabırlı olun |
| RLS kuralı çalışmıyor | Kullanıcı role atanmamış | **Settings → List Users**'tan kontrol edin |

---

## 📖 Kaynaklar

- [Metabase Learn](https://www.metabase.com/learn/)
- [Superset Documentation](https://superset.apache.org/docs/intro)
- **"Information Dashboard Design"** — Stephen Few
- **"The Big Book of Dashboards"** — Wexler, Shaffer, Cotgreave
- [Datawrapper Blog — grafik seçimi](https://blog.datawrapper.de/)

---

## 📝 Hafta Özeti

✅ **BI'ın rolü** — self-service, IT darboğazını azaltma
✅ **İyi KPI** — eyleme geçirilebilir, tek anlamlı, sahipli
✅ **Dashboard tasarımı** — hedef kitleye göre, hiyerarşili, erişilebilir
✅ **Metabase** — hızlı, SQL gerektirmez, küçük-orta ekipler için
✅ **Superset** — güçlü, SQL Lab + RLS, teknik ekipler ve kurumsal ihtiyaçlar için
✅ **RLS** — tek dashboard, kullanıcıya göre otomatik farklı veri

> 💡 **Haftanın tek cümlesi:** En iyi dashboard, en çok grafik içeren değil,
> **bakan kişinin 10 saniyede doğru kararı almasını sağlayan** dashboard'dur.

---

**[← Hafta 10: Makine Öğrenmesine Giriş](../week10-ds-machine-learning/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 12: Veri Yaşam Döngüsü ve Veri Yönetişimi →](../week12-dg-governance/README.md)**
