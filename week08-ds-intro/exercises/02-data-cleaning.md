# Alıştırma 2: Veri Temizleme

**Süre:** ~35 dakika · **Veri:** `data-samples/customers_dirty.csv`

---

## 2.1 Eksik değer stratejisi

```python
df.isna().sum()
```

**Görev:** Her eksik sütun için bir strateji seçin ve **gerekçelendirin**:
doldur (hangi değerle?) / at / olduğu gibi bırak.

| Sütun | Eksik % | Strateji | Gerekçe |
|---|---|---|---|
| `income` | | | |
| `city` | | | |
| `age` | | | |

**Soru:** `age` sütunundaki eksiklik 65 yaş üstünde yoğunlaşıyor (bkz. Alıştırma 1.5).
Bu **MCAR** (tamamen rastgele) mı yoksa **MAR** (gözlemlenen başka bir değişkene
bağlı rastgele) mı? Medyanla doldurmak bu durumda güvenli mi?

---

## 2.2 Aykırı değer tespiti

```python
def iqr_outliers(s):
    q1, q3 = s.quantile([0.25, 0.75]); iqr = q3-q1
    return s[(s < q1-1.5*iqr) | (s > q3+1.5*iqr)]

iqr_outliers(df['age'].dropna())
```

**Görev:** `age` sütununda IQR yöntemiyle bulunan aykırı değerleri listeleyin.
150 ve -5 gibi değerler yakalandı mı?

**Soru:** IQR yöntemi 150 yaşı yakalar ama gerçek (nadir de olsa mümkün) bir
90 yaşındaki müşteriyi de "aykırı" işaretleyebilir. Bu iki durumu nasıl ayırt
edersiniz? Otomatik silme ile elle inceleme arasında nasıl karar verirsiniz?

---

## 2.3 Kopya satırlar

```python
df.duplicated().sum()
df[df.duplicated(keep=False)].sort_values('customer_id').head(10)
```

**Soru:** Bulduğunuz kopyalar **tam kopya** mı (her sütun aynı) yoksa
**customer_id aynı, diğer alanlar farklı** mı? İkisi farklı temizleme
stratejileri gerektirir — hangisi?

---

## 2.4 Tutarsız kategorik değerler

```python
df['city'].value_counts()
```

**Görev:** `"İSTANBUL  "` gibi tutarsız yazımları bulun ve normalize edin:

```python
df['city_clean'] = df['city'].str.strip().str.upper()
```

**Soru:** Normalizasyon öncesi ve sonrası `df['city'].nunique()` değerleri
ne kadar farklı? Bu fark, normalize etmeden yapılacak bir `groupby('city')`
analizini nasıl yanıltırdı?

---

## 2.5 Temiz veri setini kaydedin

**Görev:** Tüm düzeltmeleri uygulayıp `data-samples/customers_clean.csv`
olarak kaydedin. Kaç satır/hücre değişti, özetleyin.

---

## ✅ Ne öğrendik

- Eksik değer stratejisi **mekanizmaya** (MCAR/MAR/MNAR) göre değişir —
  tek bir "doğru" yöntem yoktur.
- IQR/z-score aykırı değer **adaylarını** bulur; kesin kararı bağlam verir.
- "Kopya satır" ile "aynı kişinin farklı kayıtları" farklı problemlerdir.
- String normalizasyonu atlanırsa gruplama sonuçları sessizce yanlış çıkar.

📎 [Çözüm](./solutions/02-data-cleaning.md)
