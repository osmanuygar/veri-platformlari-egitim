# Hafta 14: Örnek Vakalar

> ⬛ **İzlek:** Bütünleşik &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** Esnek (bir sonraki bölüme bakın)

---

## 📚 İçindekiler

1. [Bu Hafta Farklı](#-bu-hafta-farklı)
2. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
3. [5 Vaka](#-5-vaka)
4. [Mimari Karar Kayıtları (ADR)](#-mimari-karar-kayıtları-adr)
5. [Hızlı Başlangıç](#-hızlı-başlangıç)
6. [Süreç](#-süreç)
7. [Değerlendirme Rubriği](#-değerlendirme-rubriği)
8. [Cheatsheet ve Şablonlar](#-cheatsheet-ve-şablonlar)
9. [Kaynaklar](#-kaynaklar)

---

## 🎯 Bu Hafta Farklı

Hafta 1-13, her biri **yeni bir araç/kavram** öğretti ve kendi izole
Docker ortamında pratik yaptırdı. Bu hafta **hiçbir yeni araç yok** —
amaç, o 13 haftanın parçalarını **tek bir uçtan uca mimaride** birleştirmektir.

Bu yüzden bu hafta:
- ❌ Kendi `docker-compose.yml`'i **yok** — önceki haftaların servislerini kullanırsınız
- ❌ "Alıştırma + hazır çözüm" formatı **yok** — açık uçlu bir capstone projesidir
- ✅ 5 gerçekçi vaka senaryosu **var** — birini seçip uçtan uca inşa edersiniz
- ✅ Mimari Karar Kaydı (ADR) yazma pratiği **var** — gerçek mühendislik ekiplerinin kullandığı bir teknik
- ✅ Sunum ve akran değerlendirmesi **var**

---

## 🎯 Öğrenme Hedefleri

- [ ] 14 haftanın parçalarını tek bir uçtan uca mimaride birleştirmek
- [ ] Gerçek bir iş problemi için mimari kararları gerekçelendirmek
- [ ] Ödünleşmeleri (maliyet, gecikme, karmaşıklık) açıkça tartışmak
- [ ] Bir veri platformu tasarımını sunmak ve savunmak

---

## 🎯 5 Vaka

Her vaka, **seviye**, **tahmini süre**, **kullanılan haftalar** ve bir
**mimari diyagram** ile tanımlanır. Kullandığınız haftaların servislerini
[Hızlı Başlangıç](#-hızlı-başlangıç)'taki yöntemlerden biriyle birlikte çalıştırırsınız.

---

### Vaka 1: E-ticaret Gerçek Zamanlı Analitik

**Seviye:** Orta &nbsp;·&nbsp; **Süre:** 5-6 saat &nbsp;·&nbsp; **Haftalar:** 2, 4, 7, 11

> Bir e-ticaret şirketi, sipariş durumundaki değişiklikleri (oluşturuldu →
> ödendi → kargoya verildi) **gerçek zamanlı** olarak operasyon ekibine
> göstermek istiyor. Şu an bu bilgi sadece gece batch raporunda görünüyor —
> operasyon ekibi "şu an kaç sipariş kargoda" sorusuna saatler sonra cevap alıyor.

```
┌─────────────┐   CDC    ┌───────┐  consume  ┌───────────┐  sorgula  ┌──────────┐
│ PostgreSQL  │─────────▶│ Kafka │──────────▶│ Agregatör │──────────▶│ Metabase │
│ (Hafta 2)   │ Debezium │(Hft 7)│  script    │ (basit    │           │ (Hft 11) │
│ orders      │          │       │            │  Python)  │           │ dashboard│
└─────────────┘          └───────┘            └───────────┘           └──────────┘
```

**Minimum dahil edilmesi gereken:**
- Hafta 2/7'deki gibi bir `orders` tablosu, CDC'ye hazır (`wal_level=logical`)
- Debezium ile sipariş durumu değişikliklerinin Kafka'ya akıtılması
- Bir tüketici script'i, durum değişikliklerini agregasyon tablosuna yazsın
  (örn. "şu an her durumda kaç sipariş var")
- Metabase'de bu agregasyonu gösteren, birkaç saniyede bir yenilenen bir dashboard

**Zorlaştırma (opsiyonel):** Schema Registry ile Avro şema evrimi ekleyin;
dead letter topic ile bozuk olayları yönetin (hafta 7, alıştırma 5).

---

### Vaka 2: Telekom Müşteri Kaybı (Churn) Platformu

**Seviye:** Orta-İleri &nbsp;·&nbsp; **Süre:** 6-8 saat &nbsp;·&nbsp; **Haftalar:** 5, 8, 9, 10

> Bir telekom şirketi, hangi müşterilerin önümüzdeki ay ayrılma riski
> taşıdığını bilmek istiyor. Veri zaten var (hafta 10'daki `telco_churn.csv`
> deseni), ama şu an kimse düzenli olarak model eğitmiyor, sonuçları
> takip etmiyor, hangi modelin ne zaman en iyi performansı verdiğini bilmiyor.

```
┌────────────┐  SQL   ┌──────────────┐  eğitim  ┌────────┐  kayıt  ┌────────────┐
│ PostgreSQL │───────▶│ Özellik      │─────────▶│ Model  │────────▶│ MLflow     │
│ (churn     │ (Hft5) │ mühendisliği │          │ (Hft10)│         │ Registry   │
│  verisi)   │        │ (pandas)     │          │        │         │ (Hft 10)   │
└────────────┘        └──────────────┘          └────────┘         └────────────┘
                                                                          │
                                                                          ▼
                                                                  "Production" model
                                                                  ile yeni müşteri
                                                                  skoru üretme scripti
```

**Minimum dahil edilmesi gereken:**
- Hafta 5'teki gibi ileri SQL ile özellik mühendisliği (window function'larla
  "son 3 aydaki destek çağrısı trendi" gibi özellikler türetin)
- En az 2 farklı modelin MLflow'a kaydedilmesi, karşılaştırılması
- En iyi modelin Model Registry'de "Production" aşamasına alınması
- Yeni bir müşteri için modelin skor ürettiği bir script (`models:/churn-classifier/Production`)

**Zorlaştırma (opsiyonel):** Hafta 9'daki güç analizini kullanarak, model
skorlarına göre oluşturacağınız bir "riskli müşteri" kampanyasının A/B
test örneklem büyüklüğünü hesaplayın.

---

### Vaka 3: Bankacılıkta Veri Yönetişimi

**Seviye:** İleri &nbsp;·&nbsp; **Süre:** 5-6 saat &nbsp;·&nbsp; **Haftalar:** 2, 6, 12

> Bir bankanın iç denetim ekibi, müşteri verisine kimin eriştiğini,
> verinin nereden nereye aktığını ve kalitesinin nasıl garanti edildiğini
> **kanıtlanabilir** şekilde göstermek istiyor (bir denetim öncesi hazırlık senaryosu).

```
┌────────────┐        ┌─────────────┐        ┌──────────────┐
│ PostgreSQL │───────▶│ dbt         │───────▶│ Maskelenmiş  │
│ (PII veri, │  Hft6  │ (staging→   │  Hft6  │ marts        │
│  Hft 2/12) │        │  marts)     │        │ (Hft 12)     │
└────────────┘        └─────────────┘        └──────────────┘
      │                      │                       │
      │ GE doğrulama         │ lineage                │ RBAC + audit
      ▼ (Hft 12)             ▼ (Hft 12, Marquez)       ▼ (Hft 12)
  Data Docs              Soy ağacı grafiği         pg_audit / GRANT
```

**Minimum dahil edilmesi gereken:**
- Hafta 2'deki gibi PII içeren bir müşteri tablosu
- Hafta 6'daki dbt modelleriyle staging → marts dönüşümü
- Hafta 12'deki Great Expectations ile en az 8 veri kalitesi kuralı
- Hafta 12'deki Marquez ile bu pipeline'ın lineage'ının görselleştirilmesi
- Sütun bazlı GRANT ile en az 2 farklı rolün farklı erişim seviyesi

**Zorlaştırma (opsiyonel):** dbt modellerini Airflow DAG'ı içinde
çalıştırıp OpenLineage entegrasyonuyla lineage'ı otomatik toplayın
(elle `emit_lineage.py` çalıştırmak yerine).

---

### Vaka 4: Kurumsal Bilgi Asistanı (RAG)

**Seviye:** İleri &nbsp;·&nbsp; **Süre:** 6-8 saat &nbsp;·&nbsp; **Haftalar:** 1, 12, 13

> Bir şirket içi bilgi tabanı (bu repo gibi düşünün — çeşitli dokümanlar,
> farklı formatlar) var ama kimse arama yapamıyor, herkes ilgili kişiye
> Slack'te soruyor. Bir "sor-cevap" botu istiyorlar — ama hangi dokümanın
> kaynak gösterildiğini bilmek (yönetişim) de şart.

```
┌──────────────┐  chunk+embed  ┌───────────┐   arama   ┌────────┐   kaynak   ┌────────────┐
│ Karma veri   │──────────────▶│ pgvector  │──────────▶│ Ollama │───────────▶│ Kaynaklı   │
│ (CSV+JSON+   │   (Hft 13)    │ (Hft 13)  │           │ (Hft13)│            │ cevap      │
│  XML, Hft 1) │               └───────────┘           └────────┘            └────────────┘
└──────────────┘                     │
                                      ▼
                              Marquez'e "bu embedding
                              hangi kaynak dosyadan
                              geldi" lineage'ı (Hft 12)
```

**Minimum dahil edilmesi gereken:**
- Hafta 1'deki gibi **karma formatlı** (CSV, JSON, XML) veri kaynakları
- Hafta 13'teki gibi chunking + embedding + pgvector ile RAG
- Her cevapta kaynak dokümanın **açıkça belirtilmesi**
- Hafta 12'deki lineage mantığının bu pipeline'a uygulanması: "bu cevap
  hangi ham dosyadan geldi" sorusuna cevap verebilme (basit bir metadata
  tablosu ile de yapılabilir, tam Marquez entegrasyonu şart değil)

**Zorlaştırma (opsiyonel):** Hafta 13, Alıştırma 2'deki 3 chunking
stratejisini bu karma veri üzerinde karşılaştırıp hangisinin daha iyi
sonuç verdiğini raporlayın.

---

### Vaka 5: IoT Sensör Platformu

**Seviye:** İleri &nbsp;·&nbsp; **Süre:** 8-10 saat &nbsp;·&nbsp; **Haftalar:** 3, 4, 7

> Bir fabrika, yüzlerce sensörden gelen sıcaklık/nem verisini hem **anlık**
> (alarm için) hem **geçmişe dönük** (aylık raporlama için) analiz etmek
> istiyor — hafta 6'daki Lambda mimarisi tartışmasının somut uygulaması.

```
                              ┌─────────────┐
                         ┌───▶│ Speed Layer │──▶ Anlık alarm paneli
                         │    │ (Kafka      │    (eşik aşıldığında uyarı)
┌──────────────┐  events │    │  tüketici)  │
│ Sensör       │─────────┤    └─────────────┘    (Hft 7)
│ simülatörü   │  (Hft7) │
│ (Python)     │         │    ┌─────────────┐
└──────────────┘         └───▶│ Batch Layer │──▶ Aylık rapor tablosu
                               │ (Cassandra  │    (zaman serisi sorgu)
                               │  time-series)│
                               └─────────────┘    (Hft 3, 4)
```

**Minimum dahil edilmesi gereken:**
- Python ile sahte sensör verisi üreten bir script (Kafka'ya sürekli olay basan)
- Hafta 3'teki Cassandra ile zaman serisi depolama (fabrika/sensör bazında partition)
- Hafta 7'deki gibi bir "speed layer" tüketicisi: eşik aşıldığında konsola/log'a alarm basan
- Hafta 4'teki gibi bir "batch layer": belirli aralıklarla Cassandra'daki
  veriyi özetleyen bir agregasyon sorgusu/script'i

**Zorlaştırma (opsiyonel):** Hafta 9'daki istatistik bilginizle, "normal"
sıcaklık aralığını sabit bir eşik yerine hareketli ortalama + standart
sapma tabanlı dinamik bir anomali eşiğiyle belirleyin.

---

## 📐 Mimari Karar Kayıtları (ADR)

Her ciddi mühendislik ekibi, "neden bunu böyle yaptık" sorusunun cevabını
**yazılı** tutar — 6 ay sonra kimse hatırlamaz, yeni katılan biri de
bilemez. **ADR (Architecture Decision Record)**, bu hafızayı somutlaştıran
kısa, standart bir formattır.

```
Bağlam → Değerlendirilen Seçenekler → Karar → Sonuçlar
```

Şablon: [`templates/adr-template.md`](./templates/adr-template.md)

**Her vaka için en az 2 ADR yazmanız beklenir.** İyi bir ADR, tek bir
seçeneği anlatmaz — **elediğiniz alternatifleri ve neden elediğinizi** gösterir.

---

## 🚀 Hızlı Başlangıç

```bash
cd week14-case-studies
./setup-week14.sh
```

Bu script kendi servis başlatmaz (bu haftanın kendi altyapısı yoktur) —
sadece ortamınızı kontrol eder ve size yol haritasını gösterir.

### Gerekli haftaların servislerini başlatma

Seçtiğiniz vakaya göre, ilgili haftaların klasörlerine gidip kendi
`setup-weekNN.sh`'lerini çalıştırın:

```bash
# Örnek: Vaka 1 için
cd ../week02-di-rdbms && ./setup-week02.sh 2>/dev/null || docker compose up -d
cd ../week07-de-kafka && ./setup-week07.sh
cd ../week11-bi-reporting && ./setup-week11.sh
```

Birden fazla haftanın servislerini **nasıl birlikte** çalıştıracağınız
(port çakışması, network, container adları) için:
📎 [**Haftaları Birleştirme Cheatsheet**](./cheatsheets/combining-weeks-cheatsheet.md)

---

## 🎬 Süreç

| Aşama | Doküman | Çıktı |
|---|---|---|
| 1. Vaka Seçimi | [exercises/01-case-selection.md](./exercises/01-case-selection.md) | Doldurulmuş vaka özeti |
| 2. Mimari + ADR | [exercises/02-architecture-adr.md](./exercises/02-architecture-adr.md) | Diyagram + 2+ ADR |
| 3. Uygulama | [exercises/03-implementation-demo.md](./exercises/03-implementation-demo.md) | Çalışan sistem + demo senaryosu |
| 4. Sunum | [exercises/04-presentation-peer-review.md](./exercises/04-presentation-peer-review.md) | 15 dk sunum + akran değerlendirmesi |

---

## 📊 Değerlendirme Rubriği

| Kriter | Ağırlık | Neye bakılır |
|---|---|---|
| **Mimari gerekçelendirme** | %25 | ADR'ler, alternatifleri gerçekten karşılaştırıyor mu, yoksa sadece tek seçenek mi anlatılmış |
| **Uçtan uca çalışırlık** | %30 | Aşama 1.4'teki başarı kriteri gerçekten karşılandı mı (demo ile kanıtlandı mı) |
| **Kapsam disiplini** | %15 | "Dahil/Hariç" ayrımı net mi, kapsam kontrolsüzce büyümüş mü |
| **Yönetişim farkındalığı** | %10 | PII varsa maskelendi mi, veri kalitesi kontrol edildi mi (hafta 12 ilkeleri) |
| **Dürüstlük** | %10 | Bilinen sınırlamalar açıkça paylaşıldı mı, abartılı iddia var mı |
| **Sunum netliği** | %10 | Teknik olmayan biri de akışı takip edebildi mi |

**Not:** "Uçtan uca çalışırlık" en yüksek ağırlığa sahip ama **mükemmellik**
beklenmiyor — kısmen çalışan, dürüstçe sınırları belirtilmiş bir sistem,
"her şey mükemmel çalışıyor" diye abartılıp demo'da çöken bir sistemden
**daha yüksek** puan alır.

---

## 📋 Cheatsheet ve Şablonlar

- 📎 [**Haftaları Birleştirme Cheatsheet**](./cheatsheets/combining-weeks-cheatsheet.md)
- 📝 [**ADR Şablonu**](./templates/adr-template.md)
- 📝 [**Vaka Özeti Şablonu**](./templates/case-study-brief-template.md)

---

## 📖 Kaynaklar

- **"Designing Data-Intensive Applications"** — Martin Kleppmann (bu 14
  haftanın neredeyse tamamının teorik temelini tek kitapta bulabilirsiniz)
- **"Fundamentals of Data Engineering"** — Joe Reis & Matt Housley
- [ADR GitHub organizasyonu](https://adr.github.io/) — gerçek şirketlerin ADR pratikleri
- [Netflix Tech Blog](https://netflixtechblog.com/) — büyük ölçekte vaka çalışmaları
- [Uber Engineering Blog](https://eng.uber.com/) — aynı şekilde

---

## 🎓 Programın Sonu — Geriye Dönük Bakış

14 hafta önce **"Veri nedir?"** sorusuyla başladınız (Hafta 1). Bugün:

- İlişkisel ve ilişkisel olmayan veritabanlarını ne zaman seçeceğinizi biliyorsunuz (Hafta 2-3)
- Bir veri ambarı/gölü tasarlayabiliyorsunuz (Hafta 4-5)
- Orkestrasyon ve dönüşüm katmanları kurabiliyorsunuz (Hafta 6)
- Gerçek zamanlı veri akışını yönetebiliyorsunuz (Hafta 7)
- Veriden güvenilir içgörü çıkarabiliyorsunuz (Hafta 8-10)
- Bu içgörüyü doğru şekilde sunabiliyorsunuz (Hafta 11)
- Ve tüm bunları **sorumlu, denetlenebilir, yasaya uygun** şekilde
  yapmayı biliyorsunuz (Hafta 12-13)

Bu hafta, bunların **hepsini bir arada kullanma** pratiğiydi — gerçek
bir veri mühendisinin/bilimcinin günlük işi tam olarak budur: tek bir
araç değil, doğru araçların doğru kombinasyonunu seçmek.

> 💡 **Programın son cümlesi:** İyi bir veri platformu, en yeni teknolojiyi
> kullanan değil, **doğru problemi doğru araçlarla, sorumlu bir şekilde
> çözen** platformdur.

---

**[← Hafta 13: AI ve LLM Çağında Veri Platformları](../week13-dg-ai-llm/README.md) | [🏠 Ana Sayfa](../README.md)**
