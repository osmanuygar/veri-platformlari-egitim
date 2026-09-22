
# Hafta 9: Temel İstatistik ile Veri Okuryazarlığı

> 🟨 **İzlek:** Veri Bilimi (DS) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [Betimsel İstatistik](#1-betimsel-istatistik)
3. [Olasılık ve Dağılımlar](#2-olasılık-ve-dağılımlar)
4. [Örnekleme](#3-örnekleme)
5. [Hipotez Testi](#4-hipotez-testi)
6. [Güven Aralıkları](#5-güven-aralıkları)
7. [A/B Testi](#6-ab-testi)
8. [İstatistiksel Yanılgılar](#7-istatistiksel-yanılgılar)
9. [Hızlı Başlangıç](#-hızlı-başlangıç)
10. [Pratik Uygulamalar](#-pratik-uygulamalar)
11. [Alıştırmalar](#-alıştırmalar)
12. [Cheatsheet](#-cheatsheet)
13. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

- [ ] Betimsel ve çıkarımsal istatistiği ayırt etmek
- [ ] Olasılık dağılımlarını tanımak ve hangi veride hangisinin uygun olduğunu söylemek
- [ ] Hipotez testi kurup p-değerini doğru yorumlamak
- [ ] Güven aralığı hesaplamak ve anlamını açıklamak
- [ ] A/B testi tasarlamak, örneklem büyüklüğü hesaplamak
- [ ] İstatistiksel yanılgıları (p-hacking, çoklu karşılaştırma, korelasyon-nedensellik) tanımak

---

## 1. Betimsel İstatistik

### 1.1 Merkezi eğilim: ortalama, medyan, mod ve hangisi ne zaman

| Ölçü | Tanım | Ne zaman güvenilir |
|---|---|---|
| **Ortalama** | Tüm değerlerin toplamı / sayısı | Simetrik dağılımlarda |
| **Medyan** | Sıralanmış verinin ortanca değeri | Çarpık dağılımlarda, aykırı değer varken |
| **Mod** | En sık görülen değer | Kategorik veride, çok tepeli dağılımlarda |

### 1.2 Yayılım: varyans, standart sapma, IQR

```python
df['income'].var()    # varyans — birimlerin KARESİ (yorumlanması zor)
df['income'].std()    # standart sapma — orijinal birimde
df['income'].quantile([0.25, 0.75])   # IQR = Q3 - Q1, aykırı değere dayanıklı
```

### 1.3 Çarpıklık (skewness) ve basıklık (kurtosis)

```
Simetrik (skew≈0)      Sağa çarpık (skew>0)       Sola çarpık (skew<0)
     ╱╲                      ╱╲                          ╱╲
    ╱  ╲                    ╱  ╲___                  ___╱  ╲
   ╱    ╲                  ╱      ╲___              ╱      ╲
```

Gelir, harcama, bekleme süresi gibi çoğu gerçek dünya değişkeni **sağa
çarpıktır**. Hafta 8'de gördüğünüz `income` sütunu bunun tipik bir örneğiydi.

### 1.4 Ortalama neden yalan söyler: gelir dağılımı örneği

"Ortalama çalışan maaşı 45.000 TL" cümlesi kulağa iyi gelebilir, ama
dağılımın **çoğu** çalışanı bu sayının altında kalıyor olabilir — birkaç
üst düzey yönetici maaşı ortalamayı yukarı çeker. **Medyan**, "tam ortadaki
kişinin ne kazandığını" gösterdiği için bu durumda çok daha dürüst bir
özet istatistiktir. Bu ayrımı unutmayın: *"Ortalama"yı duyduğunuzda,
"medyan ne diyor?" diye sorun.*

---

## 2. Olasılık ve Dağılımlar

### 2.1 Yaygın dağılımlar

| Dağılım | Ne zaman ortaya çıkar | Örnek |
|---|---|---|
| **Normal (Gauss)** | Çok sayıda küçük, bağımsız etkinin toplamı | Boy, ölçüm hatası |
| **Binom** | Sabit sayıda bağımsız deneme, iki sonuç | Dönüşüm/dönüşmeme (A/B test) |
| **Poisson** | Belirli zaman/alanda nadir olay sayısı | Saatte gelen sipariş sayısı |
| **Üstel** | Olaylar arası bekleme süresi | İki sipariş arası geçen süre |
| **Uniform** | Her değer eşit olasılıklı | Rastgele örnekleme |

### 2.2 Merkezi limit teoremi

> **Yeterince büyük örneklemlerde, örneklem ORTALAMALARININ dağılımı, orijinal
> verinin dağılımı ne olursa olsun, normale yaklaşır.**

Bu, istatistikte en güçlü teoremlerden biridir çünkü t-test gibi birçok
yöntemin **normal dağılım varsayımını**, orijinal veri normal olmasa bile
geçerli kılar — yeter ki örneklem yeterince büyük olsun (genelde n≥30
kabaca yeterli sayılır, ama dağılımın çarpıklığına göre değişir).

### 2.3 Büyük sayılar yasası

Örneklem büyüklüğü arttıkça, örneklem ortalaması gerçek (popülasyon)
ortalamaya **yakınsar**. Bu, "neden daha fazla veri daha güvenilir tahmin
verir" sorusunun matematiksel temelidir — ve hafta 6/9'daki güç analizinin
neden büyük örneklemde daha "kesin" sonuç verdiğinin de açıklamasıdır.

---

## 3. Örnekleme

### 3.1 Rastgele, tabakalı, küme örnekleme

| Yöntem | Nasıl | Ne zaman |
|---|---|---|
| **Basit rastgele** | Her birim eşit olasılıkla seçilir | Popülasyon homojen |
| **Tabakalı (stratified)** | Alt gruplardan (şehir, segment) orantılı örnek | Alt grupların temsilini garanti etmek istiyorsanız |
| **Küme (cluster)** | Rastgele küme seçilir, kümenin tamamı alınır | Maliyet düşürmek için (örn. rastgele mağaza seç, o mağazadaki tüm müşterileri al) |

### 3.2 Örnekleme yanlılığı ve hayatta kalma yanlılığı

**Hayatta kalma yanlılığı (survivorship bias):** İkinci Dünya Savaşı'nda
dönen uçaklardaki kurşun deliklerine bakıp "en çok orası vuruluyor, orayı
zırhlayalım" demek yanlıştır — çünkü **dönemeyen** uçaklar örnekleme hiç
girmemiştir. Gerçekte zırhlanması gereken yer, dönen uçaklarda **hasar
GÖRMEYEN** bölgelerdir — çünkü o bölgeden vurulanlar dönemedi.

İş dünyasında karşılığı: sadece **hâlâ müşteri olan** kullanıcılara anket
göndermek, churn eden kullanıcıların görüşünü sistematik olarak dışarıda bırakır.

### 3.3 Örneklem büyüklüğü nasıl belirlenir

Bkz. §6.2 (A/B Testi — güç analizi). Kısaca: yakalamak istediğiniz **en
küçük etki büyüklüğü** (MDE) ne kadar küçükse, gereken örneklem o kadar
hızlı (yaklaşık karesel oranda) büyür.

---

## 4. Hipotez Testi

### 4.1 H0 ve H1 kurulumu

- **H0 (sıfır hipotezi):** "Etki yok / fark yok" — varsayılan, çürütülmeye çalışılan iddia
- **H1 (alternatif hipotez):** "Etki var / fark var" — ispatlamaya çalıştığınız iddia

Test, H0'ı **doğrudan ispatlamaz veya çürütmez** — sadece "H0 doğruyken bu
veriyi gözlemleme ihtimali ne kadar düşük" sorusuna cevap verir.

### 4.2 Tip I ve Tip II hata, güç (power)

|  | H0 gerçekte DOĞRU | H0 gerçekte YANLIŞ |
|---|---|---|
| **H0'ı reddet** | Tip I hata (yanlış pozitif) — olasılığı **α** | Doğru karar ✅ |
| **H0'ı reddetme** | Doğru karar ✅ | Tip II hata (yanlış negatif) — olasılığı **β** |

**Güç (power) = 1 - β** — gerçek bir etki varken onu **yakalama** olasılığı.
Hafta 9'un Alıştırma 2'sinde bunu hesaplayacaksınız.

### 4.3 t-test, ki-kare, ANOVA, Mann-Whitney

| Test | Ne için | Varsayım |
|---|---|---|
| **t-test** | İki grubun ortalaması farklı mı | Yaklaşık normal dağılım |
| **Mann-Whitney U** | t-test'in parametrik olmayan hali | Dağılım varsayımı gerektirmez |
| **ki-kare** | İki kategorik değişken bağımsız mı | Yeterli hücre sayısı (genelde ≥5) |
| **ANOVA** | 3+ grup ortalaması farklı mı | Normal dağılım + eşit varyans |

### 4.4 p-değeri gerçekte ne söyler, ne söylemez

> **p-değeri = H0 DOĞRUYKEN, gözlemlenen (ya da daha uç) bir sonucu şans
> eseri elde etme olasılığı.**

**p-değeri DEĞİLDİR:**
- ❌ "H1'in doğru olma olasılığı"
- ❌ "Etkinin büyüklüğü"
- ❌ "Sonucun iş açısından önemi"

Bu ayrım, hafta 9'un en sık yanlış anlaşılan konusudur — Alıştırma 1'de
üzerine derinlemesine gideceğiz.

---

## 5. Güven Aralıkları

### 5.1 %95 güven aralığının doğru yorumu

> **"Bu prosedürü defalarca tekrarlasak, üretilen aralıkların yaklaşık %95'i
> gerçek (popülasyon) değerini içerirdi."**

**YANLIŞ yorum:** "Gerçek değerin bu aralıkta olma olasılığı %95" — bu,
gerçek değeri **rastgele bir değişken** gibi ele alır, oysa o sabittir;
rastgele olan, hesapladığımız **aralığın kendisidir**.

### 5.2 Bootstrap ile güven aralığı

Medyan gibi metriklerin kapalı-form güven aralığı formülü yoktur/zordur.
**Bootstrap**, veriyi kendisinden tekrar tekrar (yerine koyarak) örnekleyip
istatistiğin dağılımını ampirik olarak inşa eder — hiçbir dağılım
varsayımı gerektirmez. Alıştırma 3'te `scripts/bootstrap_ci.py` ile
uygulamalı göreceğiz.

### 5.3 Etki büyüklüğü neden p-değerinden önemli

p-değeri "tesadüf mü değil mi" sorusuna cevap verir; **etki büyüklüğü**
"ne kadar önemli" sorusuna cevap verir. Çok büyük bir örneklemde, iş
açısından anlamsız derecede küçük bir fark bile p<0.05 çıkabilir — bu
yüzden **her zaman etki büyüklüğünü ve güven aralığını birlikte** raporlayın,
sadece p-değerini değil.

---

## 6. A/B Testi

### 6.1 Deney tasarımı: kontrol, tedavi, randomizasyon

- **Kontrol grubu:** Mevcut deneyim (A)
- **Tedavi grubu:** Yeni deneyim (B)
- **Randomizasyon:** Kullanıcıların gruplara **rastgele** atanması — nedensel
  çıkarımın (correlation'dan farklı olarak) temel şartı. Randomizasyon
  olmadan yaptığınız karşılaştırma, hafta 8'deki `cancellation_flag_POST_CHURN`
  gibi bir sızıntı riskine değil ama **seçilim yanlılığı** riskine açıktır
  (bkz. Alıştırma 4, İddia 6).

### 6.2 Örneklem büyüklüğü ve test süresi hesabı

```bash
python scripts/power_analysis.py --baseline 0.11 --mde 0.02
```

Dört girdi birbiriyle bağlıdır: **baseline oranı**, **MDE** (yakalamak
istediğiniz en küçük fark), **α**, **güç**. Bunlardan üçünü sabitlerseniz
dördüncüsünü (genelde örneklem büyüklüğünü) hesaplayabilirsiniz.

### 6.3 Peeking problemi ve erken durdurma

Bir testi **her gün kontrol edip "anlamlı" olduğu an durdurmak**, gerçek
yanlış pozitif oranını α'nın çok üzerine çıkarır — bu, p-hacking'in zamana
yayılmış halidir (bkz. §7.4 ve Alıştırma 4, İddia 4). Doğrusu: önceden
hesaplanan örneklem büyüklüğüne ulaşana kadar beklemek.

### 6.4 Çoklu karşılaştırma düzeltmesi

Birden fazla metrik/varyant test ediyorsanız (Bonferroni, FDR) eşiğinizi
düzeltmezseniz, sadece şans eseri "anlamlı" çıkan sonuçlarla karşılaşma
riskiniz katlanarak artar (bkz. §7.2, `phacking_demo.py`).

---

## 7. İstatistiksel Yanılgılar

### 7.1 p-hacking ve HARKing

**p-hacking:** Çok sayıda test/analiz denemesi yapıp sadece "anlamlı"
çıkanı raporlamak.

**HARKing** (Hypothesizing After Results are Known): Sonuçları gördükten
SONRA, sanki baştan o hipotezi test ediyormuş gibi sunmak. İkisi de
bilimsel dürüstlüğün temel ilkesini ihlal eder: **hipotez, veriyi görmeden
önce belirlenmelidir.**

### 7.2 Korelasyon ≠ nedensellik

Hafta 8'de Simpson paradoksuyla, bu haftada dondurma-boğulma örneğiyle
gördüğümüz gibi, iki değişken arasındaki güçlü bir istatistiksel ilişki,
aralarında **doğrudan nedensel bir bağ** olduğu anlamına gelmez. Üçüncü
bir ortak neden (confounder) her ikisini de etkiliyor olabilir.

### 7.3 Simpson paradoksu

Bkz. [Hafta 8, §4.3](../week08-ds-intro/README.md#4-keşifçi-veri-analizi-eda) —
bu haftanın temellerini kurduğu konu, orada somut bir örnekle işlendi.

### 7.4 Regresyon yanılgısı (regression to the mean)

Aşırı bir gözlem (en iyi/en kötü performans gösteren birim), bir sonraki
ölçümde **doğal olarak ortalamaya yaklaşma eğilimindedir** — bu bir "etki"
değil, istatistiksel bir olgudur. "Geçen ay en kötü performans gösteren
mağazaya koçluk verdik, bu ay iyileşti!" iddiası genelde bu yanılgıyı
içerir — koçluk olmasa da mağaza muhtemelen ortalamaya yaklaşırdı.

---

## 🚀 Hızlı Başlangıç

```bash
cd week09-ds-statistics
./setup-week09.sh
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| Jupyter Lab | `jupyter/scipy-notebook` | `8890` | http://localhost:8890/lab?token=week09 |

---

## 🧪 Pratik Uygulamalar

| Script | Ne yapar |
|---|---|
| `scripts/generate_datasets.py` | A/B test ve sipariş tutarı veri setlerini üretir |
| `scripts/power_analysis.py` | Örneklem büyüklüğü / güç hesaplar |
| `scripts/bootstrap_ci.py` | Bootstrap ile güven aralığı üretir |
| `scripts/phacking_demo.py` | **p-hacking'i canlı simüle eder** |

### ✨ Bu Haftanın "Wow" Anı

```bash
python scripts/phacking_demo.py
```

20 test çalıştırılır — **hepsi tamamen ilintisiz, rastgele üretilmiş
verilerdir.** Yine de α=0.05 eşiğiyle ortalama olarak her 20 testten biri
"anlamlı" çıkar, sırf şans eseri:

```
Test  11:  p = 0.0421   🔴 ANLAMLI (yanlış pozitif!)
...
Sonuç: 1/20 test 'anlamlı' çıktı (α=0.05)
```

Bu, bir araştırmacının (ya da bir büyüme ekibinin) 20 farklı metriği test
edip sadece "anlamlı" çıkanı sunma alışkanlığının **neden bu kadar tehlikeli**
olduğunun, soyut bir uyarı değil **canlı, tekrarlanabilir bir kanıtıdır**.

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Hipotez Testi: A/B Checkout](./exercises/01-hypothesis-test.md) | 30 dk | t-test, p-değeri yorumu |
| 2 | [Güç Analizi](./exercises/02-power-analysis.md) | 25 dk | Örneklem büyüklüğü, MDE |
| 3 | [Bootstrap Güven Aralığı](./exercises/03-bootstrap.md) | 25 dk | Dağılımsız CI, medyan |
| 4 | [Yanılgı Avı](./exercises/04-fallacy-hunt.md) | 20 dk | p-hacking, çoklu karşılaştırma |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**scipy.stats Cheatsheet**](./cheatsheets/scipy-stats-cheatsheet.md)

---

## 📖 Kaynaklar

- [scipy.stats Reference](https://docs.scipy.org/doc/scipy/reference/stats.html)
- **"Practical Statistics for Data Scientists"** — Peter Bruce, Andrew Bruce, Peter Gedeck
- **"Statistics Done Wrong"** — Alex Reinhart (ücretsiz online)
- [Seeing Theory — görsel istatistik](https://seeing-theory.brown.edu/)
- [Evan Miller — A/B Test Calculator](https://www.evanmiller.org/ab-testing/)
- [statsmodels Power Analysis](https://www.statsmodels.org/stable/stats.html#power-and-sample-size-calculations)

---

## 📝 Hafta Özeti

✅ **Ortalama vs medyan** — çarpık dağılımlarda medyan daha güvenilir
✅ **Merkezi limit teoremi** — neden birçok test normal dağılım varsayabiliyor
✅ **p-değeri** — "H0 doğruyken bu veriyi görme olasılığı", hipotezin doğruluk olasılığı DEĞİL
✅ **Güç analizi** — testi çalıştırmadan önce yeterli örneklemi hesaplamak
✅ **Bootstrap** — dağılım varsayımı olmadan güven aralığı üretmek
✅ **Yanılgılar** — p-hacking, peeking, korelasyon≠nedensellik, regresyona doğru gerileme

> 💡 **Haftanın tek cümlesi:** İstatistik, "evet/hayır" cevabı veren bir
> makine değildir — **belirsizliği dürüstçe ölçmenin** bir yoludur.

---

**[← Hafta 8: Veri Bilimine Giriş](../week08-ds-intro/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 10: Makine Öğrenmesine Giriş →](../week10-ds-machine-learning/README.md)**
