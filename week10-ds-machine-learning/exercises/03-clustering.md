# Alıştırma 3: Kümeleme — Müşteri Segmentasyonu

**Süre:** ~30 dakika · **Veri:** `data-samples/telco_churn.csv`

---

## 3.1 K-Means uygulayın

```python
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

df = pd.read_csv("data-samples/telco_churn.csv")
features = ["tenure_months", "monthly_charge", "support_calls", "payment_late_count"]
X = StandardScaler().fit_transform(df[features])

kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)
df["cluster"] = kmeans.fit_predict(X)
```

**Soru:** Kümeleme öncesi **neden** `StandardScaler` kullandık? `monthly_charge`
(20-120 aralığı) ile `support_calls` (0-5 aralığı) farklı ölçekte olsaydı,
ölçeklemeden K-Means çalıştırsaydınız hangi özellik kümelemeye **orantısız**
şekilde egemen olurdu?

---

## 3.2 Doğru k'yı seçmek: dirsek yöntemi (elbow method)

```python
import matplotlib.pyplot as plt

inertias = []
for k in range(1, 10):
    km = KMeans(n_clusters=k, random_state=42, n_init=10).fit(X)
    inertias.append(km.inertia_)

plt.plot(range(1, 10), inertias, marker='o')
plt.xlabel("k"); plt.ylabel("Inertia")
```

**Görev:** Grafiği çizin, "dirsek" noktasını (eğimin belirgin şekilde
yavaşladığı nokta) bulun.

**Soru:** k arttıkça inertia her zaman azalır (k=n'de sıfıra iner). Öyleyse
neden "en düşük inertia'yı veren k"yı seçmiyoruz?

---

## 3.3 Segmentleri yorumlayın

```python
df.groupby("cluster")[features + ["churned"]].mean()
```

**Görev:** Her kümeye, verideki karakteristiklerine göre **anlamlı bir isim**
verin (örn. "Yeni, düşük harcamalı, sadık", "Uzun süreli ama şikayetçi" gibi).

| Küme | İsim | Karakteristik | Churn oranı |
|---|---|---|---|
| 0 | | | |
| 1 | | | |
| 2 | | | |
| 3 | | | |

---

## 3.4 Kümeleme ile sınıflandırma farkı

**Soru:** Hafta 10'un ana görevi (churn tahmini) **gözetimli** (supervised)
bir problemdi — `churned` etiketi vardı. Kümeleme **gözetimsizdir** — hiçbir
etiket kullanmadık. Peki kümeleme sonuçlarını değerlendirmek için `churned`
sütununa bakmamız (3.3'te yaptığımız gibi) tutarsız mı? Kümeleme algoritması
bu sütunu **görmedi**, ama biz sonucu yorumlarken kullandık — bu neden sorun değil?

---

## 3.5 İş uygulaması

**Görev:** Bulduğunuz 4 segmentten en yüksek churn riskine sahip olanı
seçin. Bu segment için somut bir **retention (elde tutma) aksiyonu** önerin
(örn. "X segmentine özel indirim", "Y segmentine proaktif destek araması").

---

## ✅ Ne öğrendik

- K-Means, ölçek farklarına duyarlıdır — `StandardScaler` neredeyse her
  zaman zorunlu bir ön adımdır.
- Dirsek yöntemi, "daha fazla küme her zaman daha iyi" tuzağına düşmeden
  makul bir k seçmenin pratik bir yoludur.
- Kümeleme etiketsiz çalışır, ama sonuçları **yorumlarken** elinizdeki
  ek bilgiyi (etiket dahil) kullanmak tamamen meşrudur — kümeleme
  algoritmasının kendisi bu bilgiyi görmedi, siz sadece SONUCU açıklıyorsunuz.
- İyi bir segmentasyon, "kaç küme var" sorusuyla değil, "her kümeye ne
  yapmalıyız" sorusuyla biter.

📎 [Çözüm](./solutions/03-clustering.md)
