# Hafta 8: Veri Bilimine Giriş

> 🟨 **İzlek:** Veri Bilimi (DS) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [Veri Bilimi Nedir?](#1-veri-bilimi-nedir)
3. [Veri Bilimi Yaşam Döngüsü (CRISP-DM)](#2-veri-bilimi-yaşam-döngüsü-crisp-dm)
4. [İş Problemini Soruya Çevirmek](#3-iş-problemini-soruya-çevirmek)
5. [Keşifçi Veri Analizi (EDA)](#4-keşifçi-veri-analizi-eda)
6. [Veri Temizleme](#5-veri-temizleme)
7. [Görselleştirme ve Anlatım](#6-görselleştirme-ve-anlatım)
8. [Hızlı Başlangıç](#-hızlı-başlangıç)
9. [Pratik Uygulamalar](#-pratik-uygulamalar)
10. [Alıştırmalar](#-alıştırmalar)
11. [Cheatsheet](#-cheatsheet)
12. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

- [ ] Veri bilimi yaşam döngüsünü (CRISP-DM) uçtan uca anlatmak
- [ ] İş problemini analiz edilebilir bir soruya çevirmek
- [ ] pandas ile keşifçi veri analizi (EDA) yapmak
- [ ] Eksik veri, aykırı değer ve veri sızıntısı (data leakage) problemlerini tanımak
- [ ] Bulguları görselleştirip anlaşılır bir hikâyeye dönüştürmek

---

## 1. Veri Bilimi Nedir?

### 1.1 Veri bilimi, analitik ve makine öğrenmesi arasındaki fark

Üç terim sık karıştırılır ama farklı sorulara cevap verir:

| Disiplin | Soru | Örnek |
|---|---|---|
| **İş zekası / analitik** | "Ne oldu?" (betimleyici) | "Geçen ay satışlar %8 düştü" |
| **Veri bilimi** | "Neden oldu? Ne olacak?" (açıklayıcı + tahmine dayalı) | "Düşüş, X şehrindeki kampanya bitişinden kaynaklandı; önümüzdeki ay da devam edecek" |
| **Makine öğrenmesi** | "Otomatik olarak nasıl tahmin ederiz?" | Churn tahmin modeli, öneri sistemi (hafta 10) |

Veri bilimi bu üçünü kapsayan **geniş bir disiplindir**: istatistik, programlama
ve alan bilgisini (domain knowledge) birleştirerek veriden karar destekleyici
içgörü üretir. Makine öğrenmesi, veri biliminin **bir aracıdır**, tamamı değil.

### 1.2 Ne zaman veri bilimine ihtiyaç var, ne zaman basit bir SQL sorgusu yeter

> "Geçen ay en çok satan 10 ürün neydi?" → **SQL yeter.** Bu betimsel bir sorudur.

> "Önümüzdeki ay hangi ürünler öne çıkacak?" → **Veri bilimi gerekir.** Bu
> tahmine dayalı bir sorudur, geçmiş örüntülerden çıkarım ister.

Veri biliminin gereksiz yere kullanılması yaygın bir hatadır: karmaşık bir
model kurmak, çoğu zaman hafta 5'te öğrendiğiniz iyi yazılmış bir SQL
sorgusundan **daha yavaş, daha kırılgan ve daha az anlaşılır** bir çözümdür.
İlk soru her zaman: *"Bu soruyu bir `GROUP BY` ile cevaplayabilir miyim?"*

### 1.3 Başarısız veri bilimi projelerinin ortak nedenleri

Sektör araştırmaları, veri bilimi projelerinin büyük kısmının production'a
hiç ulaşmadığını gösteriyor. En sık nedenler:

1. **Yanlış soru.** Teknik olarak mükemmel bir model, yanlış iş sorusuna cevap veriyor.
2. **Veri kalitesi.** "Garbage in, garbage out" — bu haftanın ana teması.
3. **Paydaş iletişimi eksikliği.** Sonuç teknik ekipte kalıyor, karar vericiye ulaşmıyor.
4. **Production'a taşıma planı yok.** Jupyter notebook'ta çalışan bir model,
   canlı sistemde çalışan bir model değildir (hafta 10'da bu farkı işleyeceğiz).

Bu haftanın odağı **1 ve 2**'dir — doğru soruyu sormak ve veriyi güvenilir hale getirmek.

---

## 2. Veri Bilimi Yaşam Döngüsü (CRISP-DM)

### 2.1 Altı adım

**CRISP-DM** (Cross-Industry Standard Process for Data Mining), 1990'larda
ortaya çıkmış ama hâlâ en yaygın kullanılan çerçevedir:

```
┌──────────────┐   ┌──────────────┐   ┌───────────┐   ┌────────────┐   ┌──────────────┐   ┌───────────┐
│ İş Anlayışı  │──▶│ Veri Anlayışı│──▶│ Hazırlık  │──▶│ Modelleme  │──▶│ Değerlendirme│──▶│ Dağıtım   │
│ (Business    │   │ (Data        │   │ (Data     │   │ (Modeling) │   │ (Evaluation) │   │(Deployment)│
│ Understanding)│   │ Understanding)│  │Preparation)│   │            │   │              │   │           │
└──────────────┘   └──────────────┘   └───────────┘   └────────────┘   └──────────────┘   └───────────┘
        ▲                                                                                          │
        └──────────────────────────────  geri bildirim döngüsü  ─────────────────────────────────┘
```

Bu hafta **ilk üç adıma** odaklanıyoruz (iş anlayışı, veri anlayışı, hazırlık).
Modelleme hafta 10'da, dağıtım kavramları hafta 10 ve 12'de.

### 2.2 Gerçek zaman dağılımı

Sektörde sıkça alıntılanan bir gözlem: veri bilimcilerin zamanının
**%60-80'i** veri toplama, temizleme ve hazırlıkla geçer — "sexy" kısım
olan modelleme genelde toplam sürenin küçük bir parçasıdır.

```
İş Anlayışı      ████░░░░░░░░░░░░░░░░  %10
Veri Anlayışı    ████████░░░░░░░░░░░░  %20
Veri Hazırlığı   ████████████████░░░░  %50
Modelleme        ██░░░░░░░░░░░░░░░░░░  %10
Değerlendirme    ██░░░░░░░░░░░░░░░░░░  %5
Dağıtım          ██░░░░░░░░░░░░░░░░░░  %5
```

Bu hafta göreceğiniz alıştırmaların EDA ve temizlemeye bu kadar ağırlık
vermesinin sebebi tam olarak budur — gerçekçi bir veri bilimi haftası, bir
"model kur" haftası değildir.

### 2.3 Yinelemeli (iterative) doğa

CRISP-DM bir düz çizgi değil, bir **döngüdür**. Veri anlayışı aşamasında
beklenmedik bir örüntü bulursanız (örn. hafta 8'deki Simpson paradoksu gibi),
iş anlayışı aşamasına geri dönüp soruyu yeniden çerçevelemeniz gerekebilir.

---

## 3. İş Problemini Soruya Çevirmek

### 3.1 Hedef değişken seçimi

Bir iş sorusunu ("müşteri kaybını azaltmak istiyoruz") ölçülebilir bir hedefe
çevirmek, veri biliminin en kritik ve en çok atlanan adımıdır.

| Belirsiz iş sorusu | Ölçülebilir hedef değişken |
|---|---|
| "Müşteri kaybını azaltmak istiyoruz" | `churned` (0/1): müşteri son 90 günde hiç sipariş vermedi mi? |
| "Satışları artırmak istiyoruz" | `next_month_revenue`: gelecek ay tahmini ciro |
| "En değerli müşterileri bulmak istiyoruz" | `customer_lifetime_value`: tahmini yaşam boyu değer |

Her tanım bir **varsayım** içerir ("90 gün" neden 90, 60 değil?) — bu
varsayımlar **yazılı hale getirilmeli** ve paydaşlarla onaylanmalıdır.

### 3.2 Başarı metriğinin iş metriğiyle hizalanması

Bir churn modelinin "doğruluğu" (accuracy) %95 olabilir ama bu, iş için
**yanlış** metrik olabilir. Hafta 9 ve 10'da göreceğimiz gibi, dengesiz bir
veri setinde (örn. müşterilerin %95'i churn etmiyor) sürekli "churn etmeyecek"
diyen bir model bile %95 doğruluk elde eder — hiçbir işe yaramadan.

Doğru soru: *"Bu modelin bir hatası (yanlış pozitif/negatif) işe ne kadara
mal olur?"* Bir churn modelinde bir müşteriyi kaçırmanın maliyeti (kayıp
gelir) ile yanlışlıkla "riskli" işaretlemenin maliyeti (gereksiz indirim
gönderme) genelde **eşit değildir** — metrik seçimi bunu yansıtmalıdır.

### 3.3 Varsayımların yazılı hale getirilmesi

İyi bir veri bilimi projesi, kod yazmadan önce şu soruları yazılı cevaplar:

- Hedef değişken tam olarak nasıl tanımlanıyor?
- Hangi veri kaynakları kullanılacak, ne kadar geriye gidiyor?
- Başarı nasıl ölçülecek — hangi sayı, ne kadar iyileşirse "başarılı" sayılır?
- Bu modelin sonucu kim, nasıl kullanacak?

---

## 4. Keşifçi Veri Analizi (EDA)

### 4.1 Tek değişkenli, iki değişkenli, çok değişkenli analiz

| Seviye | Soru | Araç |
|---|---|---|
| **Tek değişkenli** | Bu sütun nasıl dağılıyor? | Histogram, `describe()` |
| **İki değişkenli** | İki sütun nasıl ilişkili? | Scatter, `groupby`, korelasyon |
| **Çok değişkenli** | Birden fazla değişken birlikte nasıl davranıyor? | Heatmap, pairplot, segmentasyon (bkz. Simpson paradoksu) |

EDA'ya her zaman **tek değişkenli** analizle başlayın — her sütunun kendi
dağılımını anlamadan iki değişken arasındaki ilişkiyi yorumlamak yanıltıcıdır.

### 4.2 Dağılım, merkezi eğilim, yayılım

```python
df['income'].mean()     # ortalama — aykırı değerlere DUYARLI
df['income'].median()   # medyan — aykırı değerlere DAYANIKLI
df['income'].std()      # standart sapma
df['income'].skew()     # çarpıklık: 0'a yakın = simetrik, pozitif = sağa çarpık
```

**Ortalama ile medyan arasındaki fark**, dağılımın çarpıklığının ucuz ama
etkili bir göstergesidir. Gelir, harcama, bekleme süresi gibi çoğu gerçek
dünya değişkeni **sağa çarpıktır** (birkaç aşırı büyük değer ortalamayı
yukarı çeker).

### 4.3 Korelasyon ve nedensellik ayrımı

```python
df.corr(numeric_only=True)
```

Yüksek korelasyon, **birlikte değişme**yi gösterir, **neden-sonuç** ilişkisi
değildir. Klasik örnek: dondurma satışı ile boğulma vakaları yüksek korelasyon
gösterir — ikisinin de gerçek nedeni **sıcak hava**dır (karıştırıcı
değişken). Bu hafta Alıştırma 4'te bunun somut bir örneğini (Simpson
paradoksu) canlı olarak göreceğiz.

### 4.4 Hızlı bakış: `ydata-profiling`

```python
from ydata_profiling import ProfileReport
ProfileReport(df, title="Müşteri Verisi Profili").to_notebook_iframe()
```

Bu araç, `describe()`'ın yaptığının çok ötesinde otomatik bir rapor üretir:
her sütun için dağılım, eksik değer, aykırı değer, korelasyon — tek komutla.
**Uyarı:** Bu bir **başlangıç noktasıdır**, EDA'nın yerini tutmaz — otomatik
raporlar bağlamı (domain knowledge) bilmez, sizin yorumunuza ihtiyaç duyar.

---

## 5. Veri Temizleme

### 5.1 Eksik veri türleri ve doldurma stratejileri

| Tür | Anlamı | Örnek | Strateji |
|---|---|---|---|
| **MCAR** (Missing Completely At Random) | Eksiklik tamamen rastgele, hiçbir değişkenle ilişkili değil | Sistem hatası, rastgele kayıp form alanı | Basit doldurma (medyan/mod) güvenli |
| **MAR** (Missing At Random) | Eksiklik, GÖZLEMLENEN başka bir değişkenle ilişkili | Yaşlı kullanıcılar formu daha az dolduruyor | Gruba göre doldurma, ya da ayrı bir "eksik" işareti |
| **MNAR** (Missing Not At Random) | Eksiklik, DEĞERİN KENDİSİYLE ilişkili | Yüksek gelirli kişiler geliri bildirmek istemiyor | En zor durum; basit doldurma sistematik hata üretir |

Bu haftaki `customers_dirty.csv`'de `age` sütunu **MAR** örneğidir (65+
yaşta eksiklik yoğunlaşmış) — Alıştırma 2'de bunu ele alıyoruz.

### 5.2 Aykırı değer tespiti

```python
# IQR yöntemi — çarpık dağılımlarda daha güvenli
q1, q3 = df['age'].quantile([0.25, 0.75])
iqr = q3 - q1
outliers = df[(df['age'] < q1 - 1.5*iqr) | (df['age'] > q3 + 1.5*iqr)]

# z-score yöntemi — normal dağılıma yakın verilerde uygun
from scipy import stats
z = stats.zscore(df['age'].dropna())
```

**Önemli ayrım:** Bir değer istatistiksel olarak "aykırı" (outlier) olabilir
ama **imkânsız değil** (90 yaşında bir müşteri nadir ama mümkün). Bir başka
değer imkânsızdır (yaş = 150) — bu bir **veri girişi hatasıdır**, istatistiksel
bir aykırılık değil. İkisi farklı işlem gerektirir.

### 5.3 Tip dönüşümleri, tarih işleme, kategorik kodlama

```python
df['signup_date'] = pd.to_datetime(df['signup_date'])
df['signup_year'] = df['signup_date'].dt.year
df['city'] = df['city'].str.strip().str.upper()   # tutarlılık
df['segment'] = df['segment'].astype('category')   # bellek + performans
```

### 5.4 Veri sızıntısı (data leakage): en sinsi hata

**Tanım:** Bir modelin eğitiminde, gerçek hayatta tahmin yapma anında
**henüz bilinmeyecek** bir bilgi kullanılması.

Bu haftaki `customers_dirty.csv`'deki `cancellation_flag_POST_CHURN` sütunu
kasıtlı bir örnektir — adının içinde bile ipucu var. Ama gerçek hayatta
sızıntı çok daha ince olabilir:

| Sızıntı türü | Örnek |
|---|---|
| **Doğrudan hedef sızıntısı** | Hedefin kendisinin (ya da neredeyse aynısının) özellik olarak verilmesi |
| **Zaman sızıntısı** | Tahmin anından SONRAKİ bir dönemin verisiyle hesaplanan özellik |
| **Eğitim/test karışması** | Aynı müşterinin bir kısmı eğitimde, bir kısmı testte (hafta 10'da detaylandırılacak) |

**Belirti:** Model eğitimde şaşırtıcı derecede iyi performans gösterir
(%99+ doğruluk gibi), ama production'a alındığında işe yaramaz. Bu haftaki
Alıştırma 3, bu sinyali tanımayı öğretir.

---

## 6. Görselleştirme ve Anlatım

### 6.1 Grafik türü seçimi: hangi soru hangi grafik

Bkz. [Görselleştirme Cheatsheet](./cheatsheets/visualization-cheatsheet.md) —
soru tipine göre hazır bir eşleştirme tablosu içerir.

### 6.2 matplotlib / seaborn / plotly

| Kütüphane | Ne zaman |
|---|---|
| **matplotlib** | Tam kontrol gerektiğinde, temel katman |
| **seaborn** | Hızlı, güzel istatistiksel grafikler (matplotlib üzerine kurulu) |
| **plotly** | Etkileşimli grafik (hover, zoom) gerektiğinde, dashboard'larda (hafta 11) |

Bu hafta seaborn'u tercih ediyoruz — az kodla çok bilgi taşıyan grafikler üretir.

### 6.3 Yanıltıcı grafikler ve nasıl kaçınılır

En sık görülen üç hata:

1. **Y ekseni 0'dan başlamıyor** → küçük bir farkı dramatik gösterir
2. **Çift eksen (dual axis)** → iki farklı ölçekli seri aynı grafikte,
   okuyucu ilişkiyi yanlış yorumlar
3. **Pasta grafiğinde çok fazla dilim** → açıları karşılaştırmak insan
   gözü için zordur; bar grafik neredeyse her zaman daha iyi bir seçimdir

### 6.4 Bulguyu teknik olmayan paydaşa anlatmak

- **Jargon çevirin:** "churn" değil "müşteri kaybı", "outlier" değil "aykırı/şüpheli kayıt"
- **Sayıyı bağlama oturtun:** "%12 arttı" değil "%12 arttı, bu da yaklaşık
  450.000 TL ek gelir demek"
- **Önce sonuç, sonra yöntem:** Paydaş nasıl hesapladığınızı değil, ne
  bulduğunuzu ve ne yapması gerektiğini duymak ister

---

## 🚀 Hızlı Başlangıç

```bash
cd week08-ds-intro
./setup-week08.sh
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| Jupyter Lab | `jupyter/scipy-notebook` | `8889` | http://localhost:8889/lab?token=week08 |

### Durdurma

```bash
docker compose down
```

---

## 🧪 Pratik Uygulamalar

- `data-samples/customers_dirty.csv` üzerinde uçtan uca EDA
- Eksik ve aykırı değerleri tespit edip gerekçeli strateji uygulamak
- 5 grafikle veri hikâyesi sunumu hazırlamak
- Bilerek sızıntı içeren veri setinde sızıntıyı bulmak

### ✨ Bu Haftanın "Wow" Anı

```python
import pandas as pd
camp = pd.read_csv("data-samples/campaign_simpsons.csv")

print(camp.groupby('campaign')['converted'].mean())
# campaign
# A    0.181   ← A daha iyi GÖRÜNÜYOR
# B    0.120

print(camp.groupby(['campaign','device'])['converted'].mean())
# campaign  device
# A         masaüstü   0.20   ← B her ikisinde de
#           mobil      0.01      A'dan daha iyi!
# B         masaüstü   0.30
#           mobil      0.10
```

Aynı veriden çıkarılan iki tablo, **birbirinin tam tersini** söylüyor. Bu
bir hata değil — **Simpson Paradoksu**. B kampanyası her tek segmentte A'dan
daha iyi olduğu halde, genel rakamda A önde görünüyor çünkü trafiğin karışımı
(hangi kampanya hangi cihaza daha çok gösterildi) farklı. Gerçek hayattaki
A/B test raporlarının neden "genel rakamla" yetinilmemesi gerektiğinin en
çarpıcı kanıtı.

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [EDA Raporu](./exercises/01-eda-report.md) | 40 dk | Dağılım, merkezi eğilim, bulgu yazma |
| 2 | [Veri Temizleme](./exercises/02-data-cleaning.md) | 35 dk | Eksik/aykırı değer, kopya, tutarsızlık |
| 3 | [Veri Sızıntısı Avı](./exercises/03-data-leakage-hunt.md) | 20 dk | Sinsi hatayı tanımak |
| 4 | [Simpson Paradoksu](./exercises/04-simpsons-paradox.md) | 25 dk | Karıştırıcı değişken, segmentli analiz |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**pandas EDA Cheatsheet**](./cheatsheets/pandas-cheatsheet.md)
- 📎 [**Görselleştirme Cheatsheet**](./cheatsheets/visualization-cheatsheet.md)

---

## 📖 Kaynaklar

- [pandas Documentation](https://pandas.pydata.org/docs/)
- [seaborn Tutorial](https://seaborn.pydata.org/tutorial.html)
- **"Python for Data Analysis"** — Wes McKinney (pandas'ın yaratıcısı)
- **"Storytelling with Data"** — Cole Nussbaumer Knaflic
- [CRISP-DM 1.0 (orijinal metin)](https://www.the-modeling-agency.com/crisp-dm.pdf)
- [Kaggle Learn — Pandas & Data Cleaning](https://www.kaggle.com/learn)
- [Simpson's Paradox — Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/paradox-simpson/)

---

## 📝 Hafta Özeti

✅ **CRISP-DM** — veri biliminin zamanının çoğu hazırlıkta geçer, modellemede değil
✅ **İş sorusunu ölçülebilir hedefe çevirmek** — belirsizlik projenin en büyük riski
✅ **EDA** — tek değişkenliden çok değişkenliye, her zaman dağılımla başlamak
✅ **Eksik veri mekanizması** (MCAR/MAR/MNAR) — doldurma stratejisini belirler
✅ **Veri sızıntısı** — "laboratuvarda mükemmel, production'da işe yaramıyor" sinyali
✅ **Simpson Paradoksu** — genel rakam tek başına asla yeterli kanıt değildir

> 💡 **Haftanın tek cümlesi:** İyi bir veri bilimci, ilginç bir model kuran
> değil, **doğru soruyu soran ve veriye güvenip güvenemeyeceğini bilen** kişidir.

---

**[← Hafta 7: Apache Kafka ile Gerçek Zamanlı Veri Akışı](../week07-de-kafka/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 9: Temel İstatistik ile Veri Okuryazarlığı →](../week09-ds-statistics/README.md)**
