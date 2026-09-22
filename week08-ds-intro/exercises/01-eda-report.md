# Alıştırma 1: EDA Raporu

**Süre:** ~40 dakika · **Veri:** `data-samples/customers_dirty.csv`

---

## 1.1 İlk keşif

`notebooks/01-eda-starter.ipynb`'yi açın ve ilk 4 hücreyi çalıştırın.

**Görev:** `df.info()` çıktısından şu üç soruyu cevaplayın:
1. Kaç satır, kaç sütun var?
2. Hangi sütunlarda eksik değer var, kaç tanesinde?
3. `income` sütununun tipi neden `float64` (int değil)?

---

## 1.2 Merkezi eğilim ölçüleri

```python
df['income'].mean(), df['income'].median()
```

**Soru:** İki değer birbirinden ne kadar farklı? Bu fark size `income`
dağılımının **çarpıklığı** (skewness) hakkında ne söylüyor?

```python
df['income'].skew()
```

---

## 1.3 Dağılım görselleştirme

Notebook'taki histogram hücresini çalıştırın (ham vs log-dönüştürülmüş).

**Soru:** Log dönüşümü dağılımı neden daha "normal" görünümlü hale getirdi?
Bu dönüşümü hangi durumlarda (örn. bir sonraki modelleme haftasında) yapmak isteriz?

---

## 1.4 Segment bazında karşılaştırma

```python
df.groupby('segment')['total_spent'].agg(['mean', 'median', 'count'])
```

**Görev:** Üç segmentin (`bronze`/`silver`/`gold`) ortalama harcamasını karşılaştırın.
Beklediğiniz sıralamayla eşleşiyor mu?

---

## 1.5 10 bulgu

**Görev:** Notebook'u serbestçe keşfedip veri setiyle ilgili **10 somut bulgu**
yazın. Her biri şu formatta olsun:

> "`<gözlem>` çünkü `<kanıt>`"

Örnek: *"`age` sütununda 65 yaş üstü müşterilerde eksik değer oranı belirgin
şekilde daha yüksek (%25), genel eksiklik oranından (%3) çok daha fazla."*

---

## ✅ Ne öğrendik

- `df.info()` + `df.describe()` her EDA'nın ilk 60 saniyesi olmalı.
- Ortalama ile medyan arasındaki fark, çarpıklığın ucuz bir göstergesidir.
- Bulgu yazarken **kanıt** zorunlu — "öyle görünüyor" yeterli değil.

📎 [Çözüm](./solutions/01-eda-report.md)
