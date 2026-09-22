# 📋 Görselleştirme Cheatsheet

```python
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_theme(style="whitegrid")
```

---

## 🗺 Hangi Soru → Hangi Grafik

| Soru | Grafik | Kod |
|---|---|---|
| Tek değişkenin dağılımı | Histogram | `df['age'].hist(bins=30)` |
| Tek değişkenin dağılımı (aykırı değer dahil) | Boxplot | `sns.boxplot(x=df['income'])` |
| İki sayısal değişken ilişkisi | Scatter | `sns.scatterplot(data=df, x='age', y='income')` |
| Kategori bazında karşılaştırma | Bar / Box | `sns.boxplot(data=df, x='segment', y='total_spent')` |
| Zaman içindeki trend | Çizgi | `df.set_index('date')['value'].plot()` |
| Çok değişkenli korelasyon | Heatmap | `sns.heatmap(df.corr(), annot=True)` |
| İki kategorik değişken ilişkisi | Stacked bar / crosstab | `pd.crosstab(...).plot(kind='bar', stacked=True)` |
| Dağılım + kategori birlikte | Violin / strip | `sns.violinplot(data=df, x='segment', y='age')` |

---

## 🚫 Kaçının

| Grafik | Neden kötü | Yerine ne |
|---|---|---|
| **3D grafik** | Perspektif değerleri çarpıtır, okunmaz | 2D + renk/boyut kodlaması |
| **Pasta grafiği (>4 dilim)** | Açıları karşılaştırmak göze zor | Yatay bar grafik |
| **Çift eksen (dual axis)** | İki farklı ölçeği aynı çizgide göstermek yanıltır | İki ayrı panel |
| **0'dan başlamayan bar grafik** | Farkı abartır | Y eksenini 0'dan başlatın (çizgi grafikte esnek olabilir) |
| **Kırmızı-yeşil renk kodlama** | Renk körlüğü olanlar ayırt edemez | Mavi-turuncu gibi erişilebilir paletler |

---

## 🎨 Hızlı Reçeteler

```python
# Dağılım + aykırı değer birlikte
fig, ax = plt.subplots(1, 2, figsize=(10, 4))
df['income'].hist(bins=50, ax=ax[0]); ax[0].set_title('Histogram')
sns.boxplot(x=df['income'], ax=ax[1]); ax[1].set_title('Boxplot')

# Segment bazında karşılaştırma
sns.boxplot(data=df, x='segment', y='total_spent', order=['bronze','silver','gold'])

# Korelasyon matrisi
sns.heatmap(df.select_dtypes('number').corr(), annot=True, fmt='.2f', cmap='coolwarm', center=0)

# Çarpık dağılımı log ile düzelt
import numpy as np
sns.histplot(np.log1p(df['income'].clip(lower=0)))

# Gruplu çizgi grafik
sns.lineplot(data=df, x='month', y='revenue', hue='segment')
```

---

## 🧭 Anlatım İlkeleri

1. **Bir grafik, bir mesaj.** "Her şeyi göster" grafiği kimse okumaz.
2. **Başlık bir soruya cevap versin** — "Satış Grafiği" değil, "Mayıs'ta satışlar %12 düştü".
3. **Önce sonucu vurgulayın**, sonra detayları. Rengi/kalınlığı öne çıkarılacak seriye verin.
4. **Eksen etiketleri ve birimler her zaman görünür olsun.**
5. **Teknik olmayan izleyici için:** jargon yerine "müşteri kaybı" deyin, "churn" değil.

---

**[← pandas Cheatsheet](./pandas-cheatsheet.md)** · **[Hafta 8 README →](../README.md)**
