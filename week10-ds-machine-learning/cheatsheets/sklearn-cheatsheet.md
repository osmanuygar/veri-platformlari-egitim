# 📋 scikit-learn Cheatsheet

```python
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV, StratifiedKFold
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
```

---

## 🔀 Train/Test Ayrımı

```python
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42,
    stratify=y   # ⚠️ dengesiz sınıflarda ŞART — oranı train/test'te korur
)
```

---

## 🧵 Pipeline — Sızıntıyı Önlemenin Tek Güvenilir Yolu

```python
preprocessor = ColumnTransformer([
    ("num", StandardScaler(), numeric_cols),
    ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_cols),
])

pipe = Pipeline([
    ("preprocess", preprocessor),
    ("model", LogisticRegression()),
])

pipe.fit(X_train, y_train)     # preprocessor SADECE X_train'e fit edilir
pipe.predict(X_test)           # X_test'e sadece TRANSFORM uygulanır
```

**Neden Pipeline?** Elle `scaler.fit_transform(X)` yazıp sonra split
yaparsanız, test verisinin istatistikleri (ortalama, std) ölçekleme
parametrelerine sızar. Pipeline, `fit()`'in her zaman sadece train'e
uygulanmasını **yapısal olarak garanti eder** — hafta 10 Alıştırma 5'in konusu tam olarak bu.

---

## ✅ Çapraz Doğrulama

```python
scores = cross_val_score(pipe, X_train, y_train, cv=5, scoring='roc_auc')
print(f"{scores.mean():.3f} ± {scores.std():.3f}")

# Sınıf dengesizliğinde StratifiedKFold kullanın (varsayılan zaten bunu yapar
# classifier + cv=int verildiğinde, ama açıkça belirtmek daha güvenli)
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
cross_val_score(pipe, X_train, y_train, cv=cv, scoring='f1')
```

---

## 📊 Metrikler — Hangisi Ne Zaman

```python
from sklearn.metrics import (accuracy_score, precision_score, recall_score,
                              f1_score, roc_auc_score, average_precision_score,
                              confusion_matrix, classification_report)
```

| Metrik | Ne ölçer | Ne zaman |
|---|---|---|
| `accuracy` | Doğru tahmin oranı | **Dengeli** sınıflarda; dengesizde YANILTICI |
| `precision` | "Pozitif dediklerimin kaçı gerçekten pozitif" | Yanlış pozitifin maliyeti yüksekse |
| `recall` | "Gerçek pozitiflerin kaçını yakaladım" | Yanlış negatifin maliyeti yüksekse (kaçırmak pahalı) |
| `f1` | precision ve recall'ın harmonik ortalaması | İkisini dengelemek istediğinizde |
| `roc_auc` | Sıralama kalitesi, eşikten bağımsız | Genel model kalitesi karşılaştırması |
| `pr_auc` (average_precision) | ROC-AUC'nin dengesiz veri versiyonu | **Ciddi dengesiz** veride ROC-AUC'den daha güvenilir |

```python
print(classification_report(y_test, y_pred))
print(confusion_matrix(y_test, y_pred))
```

---

## 🌲 Yaygın Modeller

```python
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier

# class_weight='balanced' — dengesiz veride sınıf ağırlıklarını otomatik dengeler
LogisticRegression(class_weight='balanced', max_iter=1000)
RandomForestClassifier(class_weight='balanced', n_estimators=200)
```

---

## 🔧 Hiperparametre Arama

```python
# Grid search — küçük parametre uzayında, kesin
from sklearn.model_selection import GridSearchCV
param_grid = {'model__C': [0.01, 0.1, 1, 10]}
grid = GridSearchCV(pipe, param_grid, cv=5, scoring='roc_auc')
grid.fit(X_train, y_train)
grid.best_params_

# Random search — büyük parametre uzayında, daha hızlı
from sklearn.model_selection import RandomizedSearchCV

# Optuna — Bayesian, en verimlisi (bkz. scripts/optuna_search.py)
```

> ⚠️ `GridSearchCV`/`RandomizedSearchCV`'ye **Pipeline** verin, çıplak model
> değil — aksi halde arama sırasında da sızıntı riski doğar.

---

## 📈 Öğrenme Eğrileri (Bias-Variance Teşhisi)

```python
from sklearn.model_selection import learning_curve
train_sizes, train_scores, val_scores = learning_curve(
    pipe, X, y, cv=5, train_sizes=np.linspace(0.1, 1.0, 10), scoring='roc_auc')
```

| Örüntü | Teşhis |
|---|---|
| Train yüksek, val düşük, aralarında büyük boşluk | **Overfitting** (yüksek varyans) |
| Train VE val ikisi de düşük | **Underfitting** (yüksek bias) |
| Train ve val yakınsıyor, ikisi de yüksek | Sağlıklı |
| Val eğrisi hâlâ yükseliyor | Daha fazla veri yardımcı olabilir |

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| Test skoru train'den yüksek | Veri sızıntısı VEYA şanslı split | `Pipeline` kullanın, `cross_val_score` ile doğrulayın |
| Accuracy %95 ama model işe yaramıyor | Dengesiz veri, accuracy tuzağı | `f1`/`roc_auc`/`pr_auc`'a bakın |
| `fit_transform()` çağrısı test'te de var | Sızıntı riski | Test'te SADECE `transform()` |
| GridSearchCV çok yavaş | Parametre uzayı çok büyük | `RandomizedSearchCV` ya da Optuna |
| Kategori "unseen" hatası | `OneHotEncoder` test'te yeni kategori gördü | `handle_unknown='ignore'` |

---

**[← Hafta 10 README](../README.md)** · **[MLflow Cheatsheet →](./mlflow-cheatsheet.md)**
