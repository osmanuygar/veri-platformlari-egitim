# Hafta 10: Makine Öğrenmesine Giriş

> 🟨 **İzlek:** Veri Bilimi (DS) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2.5 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [Makine Öğrenmesi Nedir?](#1-makine-öğrenmesi-nedir)
3. [Gözetimli Öğrenme](#2-gözetimli-öğrenme)
4. [Gözetimsiz Öğrenme](#3-gözetimsiz-öğrenme)
5. [Özellik Mühendisliği](#4-özellik-mühendisliği)
6. [Model Değerlendirme](#5-model-değerlendirme)
7. [Bias-Variance Ödünleşmesi](#6-bias-variance-ödünleşmesi)
8. [Hiperparametre Optimizasyonu](#7-hiperparametre-optimizasyonu)
9. [Deney Takibi ve MLOps'a Giriş](#8-deney-takibi-ve-mlopsa-giriş)
10. [Hızlı Başlangıç](#-hızlı-başlangıç)
11. [Pratik Uygulamalar](#-pratik-uygulamalar)
12. [Alıştırmalar](#-alıştırmalar)
13. [Cheatsheet](#-cheatsheet)
14. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

- [ ] Gözetimli ve gözetimsiz öğrenmeyi ayırt etmek
- [ ] Bir sınıflandırma ve bir regresyon modelini uçtan uca eğitmek
- [ ] Aşırı öğrenme (overfitting) ve yetersiz öğrenmeyi (underfitting) teşhis etmek
- [ ] Doğru değerlendirme metriğini iş problemine göre seçmek
- [ ] Çapraz doğrulama ve hiperparametre araması yapmak
- [ ] MLflow ile deneyleri kaydetmek ve modelleri karşılaştırmak

---

## 1. Makine Öğrenmesi Nedir?

### 1.1 Kural tabanlı sistemlerden öğrenen sistemlere

Klasik yazılım: `if support_calls > 5 and payment_late_count > 2: risky = True`
— kuralları **siz** yazarsınız.

Makine öğrenmesi: modele binlerce geçmiş örnek ve bunların gerçek sonuçlarını
(`churned`) verirsiniz, model **kuralları kendisi çıkarır**. Kural sayısı
arttıkça, hangi kombinasyonun riskli olduğu insan gözüyle karmaşıklaştıkça,
ML kural yazmaktan daha pratik hale gelir.

### 1.2 Üç ana yaklaşım

| Tür | Veri | Örnek |
|---|---|---|
| **Gözetimli (supervised)** | Girdi + doğru cevap (etiket) birlikte | Churn tahmini (bu hafta) |
| **Gözetimsiz (unsupervised)** | Sadece girdi, etiket yok | Müşteri segmentasyonu (bu hafta) |
| **Pekiştirmeli (reinforcement)** | Ödül/ceza sinyaliyle deneme-yanılma | Oyun oynayan ajanlar, öneri sistemleri (kapsam dışı) |

### 1.3 ML ne zaman doğru çözüm değildir

Hafta 8'de sorduğumuz soruyu hatırlayın: *"Bu soruyu bir `GROUP BY` ile
cevaplayabilir miyim?"* ML şu durumlarda **yanlış** araçtır:

- Kural zaten basit ve net (`if stock == 0: out_of_stock = True`)
- Veri çok az (birkaç yüz satırdan az) — model genellemeyi öğrenemez
- Karar tamamen açıklanabilir olmalı ve yasal/etik zorunluluk var (bkz. hafta 12)
- Basit bir SQL sorgusu ya da istatistiksel test (hafta 9) yeterli

---

## 2. Gözetimli Öğrenme

### 2.1 Regresyon: sürekli bir değer tahmin etmek

```python
from sklearn.linear_model import LinearRegression, Ridge, Lasso
```

- **Doğrusal regresyon:** En basit, en yorumlanabilir başlangıç noktası
- **Ridge (L2 düzenlileştirme):** Katsayıları küçültür, overfitting'i azaltır
- **Lasso (L1 düzenlileştirme):** Bazı katsayıları **tam sıfıra** iter —
  otomatik özellik seçimi gibi davranır

### 2.2 Sınıflandırma: bir kategori tahmin etmek

```python
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
```

| Model | Güçlü yanı | Zayıf yanı |
|---|---|---|
| **Lojistik Regresyon** | Hızlı, yorumlanabilir, iyi baseline | Doğrusal olmayan ilişkileri yakalayamaz |
| **Karar Ağacı** | Yorumlanabilir, doğrusal olmayanı yakalar | Tek başına kolayca overfit eder |
| **Random Forest** | Çok sayıda ağacın ortalaması — dayanıklı | Yorumlanması daha zor, daha yavaş |
| **Gradient Boosting** | Genelde en yüksek doğruluk | Hiperparametre hassasiyeti yüksek, overfitting riski |

Bu haftaki `scripts/train_all_models.py` dördünü de eğitip MLflow'a kaydeder
— Alıştırma 4'te doğrudan karşılaştıracaksınız.

### 2.3 Özellik önem dereceleri (feature importance)

```python
model.feature_importances_    # ağaç tabanlı modellerde
model.coef_                    # doğrusal modellerde (katsayılar)
```

⚠️ Özellik önemi **nedensellik değildir** — sadece modelin tahmin yaparken
o özelliğe ne kadar "güvendiğini" gösterir. Hafta 9'daki korelasyon-nedensellik
ayrımı burada da geçerlidir.

---

## 3. Gözetimsiz Öğrenme

### 3.1 Kümeleme: K-Means, DBSCAN, hiyerarşik

```python
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering
```

| Algoritma | Küme sayısını | Küme şekli | Ne zaman |
|---|---|---|---|
| **K-Means** | Siz belirlersiniz (k) | Küresel, benzer boyutlu | Genel amaçlı, hızlı |
| **DBSCAN** | Otomatik bulur | Herhangi bir şekil | Gürültülü veri, aykırı değer tespiti |
| **Hiyerarşik** | Dendrogram'dan seçersiniz | Esnek | Küçük veri, iç içe geçmiş yapılar |

Bu hafta **K-Means** ile müşteri segmentasyonu yapıyoruz (Alıştırma 3).

### 3.2 Boyut indirgeme: PCA, t-SNE, UMAP

Çok sayıda özelliği (yüksek boyut) 2-3 boyuta indirip görselleştirmek ya da
modelin işini kolaylaştırmak için kullanılır. **PCA** doğrusal ve hızlıdır;
**t-SNE**/**UMAP** doğrusal olmayan yapıları daha iyi yakalar ama daha
yavaştır ve sonuçları "mesafe" olarak yorumlamak yanıltıcı olabilir.

### 3.3 Anomali tespiti

Normal örüntüden **önemli ölçüde sapan** gözlemleri bulmak (fraud tespiti,
arıza öngörüsü). `IsolationForest`, `DBSCAN`'in gürültü noktaları, ya da
basitçe hafta 8'deki IQR/z-score yöntemleri kullanılabilir.

---

## 4. Özellik Mühendisliği

### 4.1 Ölçekleme, kodlama, etkileşim terimleri

```python
from sklearn.preprocessing import StandardScaler, OneHotEncoder, PolynomialFeatures
```

- **Ölçekleme:** Mesafe tabanlı modellerde (K-Means, KNN, SVM) ve
  düzenlileştirilmiş doğrusal modellerde **şart**; ağaç tabanlı modellerde
  (Random Forest, Gradient Boosting) gerekli değildir.
- **Kodlama:** Kategorik değişkenleri sayıya çevirmek — `OneHotEncoder`
  (düşük kardinalite), hedef kodlama (yüksek kardinalite, ama sızıntı riski — bkz. §4.3).

### 4.2 Tarih/zaman özellikleri

```python
df['signup_month'] = df['signup_date'].dt.month
df['days_since_signup'] = (pd.Timestamp.now() - df['signup_date']).dt.days
df['is_weekend'] = df['order_date'].dt.dayofweek >= 5
```

### 4.3 Hedef kodlama (target encoding) ve sızıntı riski

```python
category_mean = df.groupby('category')[target].mean()   # ⚠️ TÜM veri üzerinde hesaplanırsa SIZINTI
```

Bu, bu haftanın **en kritik** ders notudur ve Alıştırma 5'in tamamı
buna ayrılmıştır. Kısaca: bu dönüşüm `y`'ye bağımlıdır, bu yüzden
`StandardScaler` gibi `Pipeline`'ın otomatik koruduğu dönüşümlerden farklı
olarak **elle dikkat** gerektirir — hesaplama SADECE train verisi üzerinde yapılmalıdır.

### 4.4 Pipeline ile sızıntısız dönüşüm

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer

preprocessor = ColumnTransformer([
    ("num", StandardScaler(), numeric_cols),
    ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_cols),
])
pipe = Pipeline([("preprocess", preprocessor), ("model", LogisticRegression())])
pipe.fit(X_train, y_train)   # preprocessor SADECE X_train'e fit edilir
```

`Pipeline`, `fit()`'in her zaman sadece eğitim verisine uygulanmasını
**yapısal olarak** garanti eder — bu hafta 8'deki `cancellation_flag_POST_CHURN`
gibi bariz sızıntılardan, daha sinsi ölçekleme sızıntılarına kadar geniş
bir sınıfı otomatik önler.

---

## 5. Model Değerlendirme

### 5.1 Train/validation/test ayrımı

```
┌──────────────────────┬─────────────┬──────────┐
│        TRAIN (%60)   │  VAL (%20)  │ TEST(%20)│
└──────────────────────┴─────────────┴──────────┘
   model burada öğrenir   burada       burada SADECE
                          hiperparam.  BİR KEZ, en sonda
                          seçilir      ölçülür
```

**Test seti kutsal alandır** — hiperparametre seçerken, özellik seçerken
ASLA test setine bakılmaz. Bir kez bakıldığında (ve o bilgiye göre karar
değiştirildiğinde), test seti artık gerçek genellemeyi ölçmez —
dolaylı bir sızıntı biçimidir.

### 5.2 K-fold ve stratified çapraz doğrulama

```python
from sklearn.model_selection import cross_val_score, StratifiedKFold
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(pipe, X_train, y_train, cv=cv, scoring='roc_auc')
```

Tek bir train/val ayrımı yerine veriyi **5 parçaya** bölüp her parçayı
sırayla validation yaparak 5 skor elde edersiniz — tek bir "şanslı ya da
şanssız" ayrımın sonucu çarpıtmasını önler. **Stratified**, her katmanda
sınıf oranının (churn oranı gibi) korunmasını sağlar — dengesiz veride önemlidir.

### 5.3 Sınıflandırma metrikleri

Bkz. [scikit-learn Cheatsheet](./cheatsheets/sklearn-cheatsheet.md) —
tam bir "hangi metrik ne zaman" tablosu içerir. Özet:

| Metrik | Sorusu |
|---|---|
| Accuracy | "Kaçını doğru bildim" — dengesiz veride yanıltıcı |
| Precision | "Pozitif dediklerimin kaçı gerçekten pozitif" |
| Recall | "Gerçek pozitiflerin kaçını yakaladım" |
| F1 | Precision/recall dengesi |
| ROC-AUC | Genel sıralama kalitesi |
| PR-AUC | Ciddi dengesiz veride ROC-AUC'den daha güvenilir |

### 5.4 Regresyon metrikleri

| Metrik | Birim | Özellik |
|---|---|---|
| MAE | Orijinal birim | Aykırı değere dayanıklı, yorumlanması kolay |
| RMSE | Orijinal birim | Büyük hataları orantısız cezalandırır |
| R² | Birimsiz (0-1, negatif olabilir) | "Naif ortalama modelinden ne kadar iyi" |

### 5.5 Dengesiz veri setinde accuracy tuzağı

Bu haftanın churn veri setinde (`~%25-30` churn oranı), "kimse churn
etmeyecek" diyen bir model **%70-75 accuracy** alır — hiçbir şey öğrenmeden.
Alıştırma 2, bu tuzağı doğrudan canlı gösterir.

### 5.6 Karmaşıklık matrisini iş maliyetine çevirmek

Her hücrenin (TN, FP, FN, TP) gerçek bir maliyeti vardır. Bir churn
modelinde genelde **Yanlış Negatif (FN — kaçırılan müşteri) daha pahalıdır**
— bu da recall'ı önceliklendirmeyi haklı çıkarır. Ama bu **evrensel bir
kural değildir**, her problem için maliyetler somut olarak hesaplanmalıdır.

---

## 6. Bias-Variance Ödünleşmesi

### 6.1 Öğrenme eğrileri (learning curves) okumak

```python
from sklearn.model_selection import learning_curve
```

```
Yüksek Bias (Underfitting)        Yüksek Variance (Overfitting)      Sağlıklı
Score                              Score                              Score
  │  val ─────────                  │  train ─────────                │  train ──┐
  │  train ───────                  │                                 │          ├─ yakın
  │  (ikisi de düşük)                │  val ╱                          │  val   ──┘
  │                                  │     ╱ (büyük boşluk)            │  (ikisi de yüksek)
  └──────────── n                   └──────────── n                   └──────────── n
```

### 6.2 Düzenlileştirme ve erken durdurma

- **Düzenlileştirme** (Ridge/Lasso'daki L1/L2, ağaçlarda `max_depth`,
  `min_samples_leaf`): Modelin karmaşıklığını **cezalandırarak** overfitting'i azaltır.
- **Erken durdurma** (gradient boosting'de): Validation skoru düşmeye
  başladığı anda eğitimi durdurur.

### 6.3 Model karmaşıklığı ve veri miktarı ilişkisi

Daha karmaşık bir model, daha fazla veriyle "hak edilir". Az veriyle
karmaşık bir model (derin bir ağaç, çok parametreli bir ağ) neredeyse
kesinlikle overfit eder — Alıştırma 4'te `max_depth=None` ile bunu
doğrudan gözlemleyeceksiniz.

---

## 7. Hiperparametre Optimizasyonu

### 7.1 Grid search, random search, Bayesian optimizasyon

| Yöntem | Nasıl | Ne zaman |
|---|---|---|
| **Grid search** | Tüm kombinasyonları dener | Küçük parametre uzayı, kesinlik önemli |
| **Random search** | Rastgele örnekler | Büyük uzay, grid'den daha verimli |
| **Bayesian (Optuna)** | Önceki denemelerden ders çıkarır | En verimli, büyük/karmaşık uzaylarda |

### 7.2 Optuna ile pratik arama

```bash
python scripts/optuna_search.py --n-trials 30
```

Optuna'nın **TPE (Tree-structured Parzen Estimator)** örnekleyicisi, hangi
bölgelerin daha iyi sonuç verdiğini öğrenip **sonraki denemeleri o
bölgelere yönlendirir** — kör bir ızgara taraması değil, akıllı bir arama.

### 7.3 Arama sırasında sızıntıdan kaçınmak

Hiperparametre araması `GridSearchCV`/`RandomizedSearchCV`/Optuna ile
yapılırken **her deneme kendi çapraz doğrulamasını** çalıştırmalı —
tüm veriye bakıp "en iyi" parametreyi seçtikten SONRA test setinde
değerlendirme yapmak, dolaylı bir sızıntı biçimidir (test setine "gizlice"
birden fazla kez bakmış olursunuz).

---

## 8. Deney Takibi ve MLOps'a Giriş

### 8.1 MLflow: tracking, model registry

```
┌──────────┐  log_run()  ┌─────────────┐         ┌──────────────┐
│ Script/  │────────────▶│   MLflow    │────────▶│ PostgreSQL   │  (metrik, param)
│ Notebook │             │   Server    │         └──────────────┘
└──────────┘             └──────┬──────┘
                                 │              ┌──────────────┐
                                 └─────────────▶│ MinIO (S3)   │  (model, artifact)
                                                 └──────────────┘
```

Bu haftaki ortam, tam bir MLflow kurulumunu (backend store + artifact
store ayrı) çalıştırır — tek makinede `mlflow.db` dosyasıyla başlamaktan
gerçek bir üretim mimarisine geçişin küçük ölçekli bir örneği.

### 8.2 Yeniden üretilebilirlik (reproducibility)

MLflow her çalıştırmada **parametreleri, metrikleri, kod versiyonunu
(git commit hash) ve ortamı** kaydeder. "Geçen ay hangi parametrelerle
%85 almıştık?" sorusunun cevabı artık hafızada değil, UI'da.

### 8.3 Model kayması (drift) ve izleme

Production'a alınan bir model, zamanla **kayabilir** — dünya değişir,
modelin öğrendiği örüntüler geçerliliğini yitirir (örn. pandemi sonrası
tüketici davranışı). Bu, bu haftanın kapsamı dışında ama hafta 12'de
veri kalitesi/izleme bağlamında değineceğimiz bir konudur.

### 8.4 Hafta 13'e köprü: klasik ML ve LLM nerede ayrışır

Bu haftaki modeller **yapılandırılmış, sayısal/kategorik veri** üzerinde
çalışıyor — sabit sayıda özellik, net bir hedef değişken. Hafta 13'te
göreceğimiz LLM'ler **yapılandırılmamış metin** üzerinde çalışır ve
"özellik mühendisliği" kavramı neredeyse tamamen "prompt mühendisliği"ne
dönüşür — ama değerlendirme metriği seçimi, overfitting riski, ve deney
takibi ihtiyacı (MLflow benzeri araçlarla) aynı kalır.

---

## 🚀 Hızlı Başlangıç

```bash
cd week10-ds-machine-learning
./setup-week10.sh
pip install -r requirements.txt
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| Jupyter Lab | `jupyter/scipy-notebook` | `8891` | http://localhost:8891/lab?token=week10 |
| MLflow | özel (mlflow server) | `5500` | http://localhost:5500 |
| PostgreSQL (MLflow backend) | `postgres:15` | `5438` | — |
| MinIO (artifact store) | `minio/minio` | `9000` / `9001` | http://localhost:9001 |

**Bellek ihtiyacı:** ~3 GB.

### Durdurma

```bash
docker compose down        # durdur (veri kalır)
docker compose down -v     # durdur + volume sil
```

---

## 🧪 Pratik Uygulamalar

| Script | Ne yapar |
|---|---|
| `scripts/generate_churn_dataset.py` | Dengesiz churn veri seti üretir |
| `scripts/train_all_models.py` | **4 algoritma × varyasyon → MLflow'a 20 deneme** |
| `scripts/optuna_search.py` | Bayesian hiperparametre araması |
| `scripts/leaky_pipeline_demo.py` | Hedef kodlama sızıntısını canlı gösterir |

### ✨ Bu Haftanın "Wow" Anı

```bash
python scripts/train_all_models.py
```

Script bittiğinde http://localhost:5500 adresine gidin. **20 farklı
deneme** (lojistik regresyon, karar ağacı, random forest, gradient
boosting — her biri birkaç hiperparametre varyasyonuyla) yan yana
duruyor. Hepsini seçip **Compare**'e tıklayın, **Parallel Coordinates
Plot**'ta hangi hiperparametrenin hangi metriği nasıl etkilediğini
görsel olarak izleyin — "hangi parametreyle neyi denemiştim" kaosunun
sonu.

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Regresyon: Aylık Ücret Tahmini](./exercises/01-regression.md) | 30 dk | MAE/RMSE, öğrenme eğrisi |
| 2 | [Sınıflandırma: Dengesiz Veri](./exercises/02-classification-imbalance.md) | 35 dk | Accuracy tuzağı, doğru metrik |
| 3 | [Kümeleme: Segmentasyon](./exercises/03-clustering.md) | 30 dk | K-Means, segment yorumu |
| 4 | [MLflow: Deney Takibi](./exercises/04-mlflow-tracking.md) | 30 dk | Karşılaştırma, registry |
| 5 | [Sızıntı Avı](./exercises/05-leakage-hunt.md) | 20 dk | Hedef kodlama sızıntısı |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**scikit-learn Cheatsheet**](./cheatsheets/sklearn-cheatsheet.md)
- 📎 [**MLflow Cheatsheet**](./cheatsheets/mlflow-cheatsheet.md)

---

## 🧯 Sık Karşılaşılan Sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| MLflow UI açılmıyor | Postgres/MinIO henüz hazır değil | `docker compose ps`, birkaç dakika bekleyin |
| `NoSuchBucket` | MinIO init tamamlanmadı | `docker compose logs minio-init` |
| `mlflow.exceptions.MlflowException: Connection refused` | `MLFLOW_TRACKING_URI` yanlış | `.env` dosyasını kontrol edin |
| Model eğitimi çok yavaş | `n_jobs=-1` kullanılmıyor | Random Forest/Gradient Boosting'de ekleyin |
| Test skoru şüpheli yüksek | Veri sızıntısı | `scripts/leaky_pipeline_demo.py`'yi inceleyin |

---

## 📖 Kaynaklar

- [scikit-learn User Guide](https://scikit-learn.org/stable/user_guide.html)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [Optuna Documentation](https://optuna.readthedocs.io/)
- **"Hands-On Machine Learning with Scikit-Learn, Keras & TensorFlow"** — Aurélien Géron
- **"Designing Machine Learning Systems"** — Chip Huyen
- [Google's Machine Learning Crash Course](https://developers.google.com/machine-learning/crash-course)

---

## 📝 Hafta Özeti

✅ **Gözetimli vs gözetimsiz** — etiket var mı yok mu ayrımı
✅ **Doğru metrik** — accuracy dengesiz veride yanıltıcı, iş maliyetine göre seçim yapın
✅ **Pipeline** — sızıntısız dönüşümün yapısal garantisi
✅ **Hedef kodlama sızıntısı** — `Pipeline`'ın otomatik koruyamadığı, en sinsi risk
✅ **Bias-variance** — öğrenme eğrisi ile underfitting/overfitting teşhisi
✅ **MLflow** — "hangi parametreyle neyi denemiştim" kaosunun sonu

> 💡 **Haftanın tek cümlesi:** İyi bir makine öğrenmesi pratiği, en yüksek
> skoru bulan değil, **o skorun neden güvenilir olduğunu ispatlayabilen** pratiktir.

---

**[← Hafta 9: Temel İstatistik ile Veri Okuryazarlığı](../week09-ds-statistics/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 11: İş Zekası & Raporlama Sistemleri →](../week11-bi-reporting/README.md)**
