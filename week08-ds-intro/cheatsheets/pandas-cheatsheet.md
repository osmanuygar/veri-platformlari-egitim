# 📋 pandas EDA Cheatsheet

```python
import pandas as pd, numpy as np
df = pd.read_csv("data-samples/customers_dirty.csv")
```

---

## 🔍 İlk Bakış

```python
df.shape                    # (satır, sütun)
df.head(); df.tail()
df.info()                   # tip + eksik değer sayısı, TEK bakışta
df.describe()               # sayısal sütunlar: ortalama, std, çeyrekler
df.describe(include='all')  # kategorik sütunlar dahil
df.dtypes
df.columns.tolist()
df.sample(5)                 # rastgele 5 satır — head()'den daha temsili
```

---

## ❓ Eksik Değerler

```python
df.isna().sum()                          # sütun başına eksik sayısı
df.isna().sum() / len(df) * 100          # yüzde olarak
df.isna().sum(axis=1).value_counts()     # satır başına kaç eksik var

# Görselleştirme
import seaborn as sns
sns.heatmap(df.isna(), cbar=False)

# Doldurma stratejileri
df['income'].fillna(df['income'].median(), inplace=True)   # sayısal: medyan (ortalamadan çarpıklığa dayanıklı)
df['city'].fillna(df['city'].mode()[0], inplace=True)       # kategorik: mod
df['age'].fillna(df.groupby('segment')['age'].transform('median'), inplace=True)  # gruba göre

# Ya da bırakın
df.dropna(subset=['income'])             # sadece bu sütun eksikse satırı at
df.dropna(thresh=len(df.columns) - 2)    # 2'den fazla eksiği olan satırı at
```

---

## 🎯 Aykırı Değerler

```python
# IQR yöntemi
q1, q3 = df['age'].quantile([0.25, 0.75])
iqr = q3 - q1
lower, upper = q1 - 1.5*iqr, q3 + 1.5*iqr
outliers = df[(df['age'] < lower) | (df['age'] > upper)]

# Z-score yöntemi
from scipy import stats
z = np.abs(stats.zscore(df['age'].dropna()))
outliers = df[z > 3]

# Sınırlama (capping / winsorizing) — atmak yerine sınırlara çek
df['age_capped'] = df['age'].clip(lower=18, upper=90)
```

---

## 🔗 Kopya ve Tutarsızlık

```python
df.duplicated().sum()                    # tam kopya satır sayısı
df[df.duplicated(keep=False)]            # kopyaların hepsini göster
df.drop_duplicates(inplace=True)

# String tutarsızlığı
df['city'] = df['city'].str.strip().str.upper()
df['city'].value_counts()                # "İSTANBUL" ve "istanbul " aynı mı görünüyor?
```

---

## 📊 Gruplama ve Agregasyon

```python
df.groupby('segment')['total_spent'].agg(['mean', 'median', 'count'])
df.groupby(['segment', 'city'])['total_spent'].mean().unstack()

pd.crosstab(df['segment'], df['churned'], normalize='index')  # segment bazında churn oranı
```

---

## 🧮 Korelasyon

```python
df.select_dtypes('number').corr()
sns.heatmap(df.select_dtypes('number').corr(), annot=True, cmap='coolwarm', center=0)

# UYARI: korelasyon nedensellik DEĞİLDİR — bkz. ders notu §5
```

---

## ⚠️ Veri Sızıntısı Avlama

```python
# Şüpheli: bir sütun hedef değişkenle "çok fazla" ilişkili mi?
df.corr(numeric_only=True)['churned'].sort_values(ascending=False)

# %95+ korelasyon → muhtemelen sızıntı (hedefin kendisi ya da
# hedeften SONRA bilinen bir bilgi)
```

---

**[← Hafta 8 README](../README.md)** · **[Görselleştirme Cheatsheet →](./visualization-cheatsheet.md)**
