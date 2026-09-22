# Alıştırma 2: Sınıflandırma — Dengesiz Churn Verisi

**Süre:** ~35 dakika · **Veri:** `data-samples/telco_churn.csv`

---

## 2.1 Accuracy tuzağı

```python
import pandas as pd
df = pd.read_csv("data-samples/telco_churn.csv")
print(df['churned'].value_counts(normalize=True))
```

**Görev:** Churn oranını not edin. "Hiç kimse churn etmeyecek" diyen bir
model (hiç eğitim yapmadan) kaç accuracy alır?

```python
from sklearn.dummy import DummyClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score

X = df.drop(columns=['customer_id', 'churned'])
X = pd.get_dummies(X, columns=['contract_type'])
y = df['churned']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

dummy = DummyClassifier(strategy='most_frequent').fit(X_train, y_train)
pred = dummy.predict(X_test)
print(f"Dummy accuracy: {accuracy_score(y_test, pred):.3f}")
print(f"Dummy f1 (churn sınıfı): {f1_score(y_test, pred):.3f}")
```

**Soru:** Dummy modelin accuracy'si yüksek ama f1'i kaç? Bu iki rakam
arasındaki uçurum size ne anlatıyor?

---

## 2.2 Gerçek bir model eğitin

```python
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix

model = LogisticRegression(max_iter=1000, class_weight='balanced').fit(X_train, y_train)
pred = model.predict(X_test)
print(classification_report(y_test, pred))
print(confusion_matrix(y_test, pred))
```

**Görev:** Precision ve recall değerlerini not edin.

**Soru:** `class_weight='balanced'` parametresini kaldırıp tekrar
çalıştırın. Recall nasıl değişti? Bu parametre ne yapıyor?

---

## 2.3 Confusion matrix'i iş diline çevirin

**Görev:** Confusion matrix'in 4 hücresini (TN, FP, FN, TP) churn
bağlamında yorumlayın:

| | Model: churn etmeyecek dedi | Model: churn edecek dedi |
|---|---|---|
| **Gerçek: etmedi** | ? | ? (Yanlış Pozitif) |
| **Gerçek: etti** | ? (Yanlış Negatif) | ? |

**Soru:** Bir müşteriye gereksiz yere indirim göndermenin maliyeti (Yanlış
Pozitif) ile gerçekten ayrılacak bir müşteriyi kaçırmanın maliyeti (Yanlış
Negatif) muhtemelen **eşit değildir**. Sizce hangisi genelde daha pahalıdır?
Bu, hangi metriği (precision mı recall mü) önceliklendirmeniz gerektiğini nasıl etkiler?

---

## 2.4 Eşik (threshold) ayarı

```python
proba = model.predict_proba(X_test)[:, 1]
for threshold in [0.3, 0.5, 0.7]:
    pred_t = (proba >= threshold).astype(int)
    from sklearn.metrics import precision_score, recall_score
    print(f"threshold={threshold}: precision={precision_score(y_test, pred_t):.3f}  "
          f"recall={recall_score(y_test, pred_t):.3f}")
```

**Soru:** Eşiği 0.5'ten 0.3'e düşürünce precision ve recall nasıl değişti?
Bu, "modeli değiştirmeden" iş ihtiyacına göre ayar yapmanın bir yolu mu?

---

## 2.5 ROC-AUC vs PR-AUC

```python
from sklearn.metrics import roc_auc_score, average_precision_score
print(f"ROC-AUC: {roc_auc_score(y_test, proba):.3f}")
print(f"PR-AUC:  {average_precision_score(y_test, proba):.3f}")
```

**Soru:** Bu veri setinde churn oranı ~%25-30 (orta derece dengesiz).
Çok daha dengesiz bir veri setinde (örn. %1 fraud oranı) ROC-AUC neden
yanıltıcı olabilir, PR-AUC neden daha güvenilir bir tercih olur?

---

## ✅ Ne öğrendik

- Dengesiz veride accuracy neredeyse anlamsızdır — her zaman f1/precision/recall/AUC'a bakın.
- `class_weight='balanced'`, azınlık sınıfının hatalarını daha ağır cezalandırarak recall'ı artırır (genelde precision pahasına).
- Confusion matrix'in her hücresinin gerçek bir iş maliyeti vardır — bunları isimlendirmeden metrik seçimi yapılamaz.
- Eşik ayarı, modeli yeniden eğitmeden precision/recall dengesini kaydırmanın ucuz bir yoludur.
- Ciddi dengesiz veride PR-AUC, ROC-AUC'den daha güvenilir bir sinyaldir.

📎 [Çözüm](./solutions/02-classification-imbalance.md)
