# Alıştırma 1: Regresyon — Aylık Ücret Tahmini

**Süre:** ~30 dakika · **Veri:** `data-samples/telco_churn.csv`

---

## 1.1 Basit bir regresyon modeli

```python
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import numpy as np

df = pd.read_csv("data-samples/telco_churn.csv")
X = df[["tenure_months", "support_calls", "has_addons", "payment_late_count"]]
y = df["monthly_charge"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
model = LinearRegression().fit(X_train, y_train)
pred = model.predict(X_test)

mae = mean_absolute_error(y_test, pred)
rmse = np.sqrt(mean_squared_error(y_test, pred))
r2 = r2_score(y_test, pred)
print(f"MAE={mae:.2f}  RMSE={rmse:.2f}  R²={r2:.3f}")
```

**Görev:** Sonuçları not edin.

---

## 1.2 MAE mi RMSE mi?

**Soru:** MAE ve RMSE'nin birimi nedir (TL mi, TL² mi)? RMSE, MAE'den
her zaman **büyük ya da eşittir** — neden? (İpucu: kareleme büyük hataları
orantısız şekilde cezalandırır)

**Görev:** Veri setinde `monthly_charge`'ı çok yüksek olan (aykırı) birkaç
satır bulun/simüle edin. Bu satırlar RMSE'yi mi yoksa MAE'yi mi daha çok etkiler?

---

## 1.3 R² yorumu

**Soru:** `R²=0.35` çıktıysa bu ne anlama gelir? R² **negatif** çıkabilir
mi — çıkarsa ne demektir? (İpucu: R², modelin "ortalamayı tahmin eden
naif bir modelden" ne kadar iyi olduğunu ölçer)

---

## 1.4 Öğrenme eğrisi ile bias/variance teşhisi

```python
from sklearn.model_selection import learning_curve
import numpy as np

train_sizes, train_scores, val_scores = learning_curve(
    LinearRegression(), X, y, cv=5, scoring='r2',
    train_sizes=np.linspace(0.1, 1.0, 10))

print("Train:", train_scores.mean(axis=1))
print("Val:  ", val_scores.mean(axis=1))
```

**Soru:** Train ve val eğrileri birbirine yakın mı, aralarında büyük bir
boşluk mu var? Bu size modelin **underfitting** mi **overfitting** mi
yaptığını, yoksa **sağlıklı** mı olduğunu söylüyor?

---

## ✅ Ne öğrendik

- MAE, hataların ortalama mutlak büyüklüğü — yorumlanması kolay, aynı birimde.
- RMSE, büyük hataları orantısız cezalandırır — aykırı değerlere daha duyarlı.
- R², modelin "sadece ortalamayı tahmin eden" bir modelden ne kadar iyi
  olduğunu gösterir; negatif çıkması modelin bundan bile kötü olduğu anlamına gelir.
- Öğrenme eğrisi, daha fazla veri mi yoksa daha karmaşık bir model mi
  gerektiğini teşhis etmenin ucuz bir yoludur.

📎 [Çözüm](./solutions/01-regression.md)
