# Alıştırma 4: MLflow — Deney Takibi ve Registry

**Süre:** ~30 dakika · **Dosya:** `scripts/train_all_models.py`, `scripts/optuna_search.py`

---

## 4.1 20 denemeyi üretin

```bash
python scripts/train_all_models.py
```

http://localhost:5500 adresine gidin, **week10-churn-prediction** deneyini açın.

**Görev:** Tüm çalıştırmaları seçip **Compare** butonuna tıklayın.
**Parallel Coordinates Plot**'ta `roc_auc`'ı en yüksek olan modeli bulun.

---

## 4.2 En iyi modeli belirleyin

**Soru:** `roc_auc`'a göre en iyi model ile `f1`'e göre en iyi model
**aynı mı**? Değilse, hangi metriği önceliklendirmeniz gerektiğine nasıl karar verirsiniz?

---

## 4.3 Karar ağacı derinliğinin etkisi

MLflow UI'da `tree_depth*` isimli 4 çalıştırmayı bulun.

**Görev:** `max_depth` arttıkça `roc_auc` nasıl değişiyor — sürekli artıyor
mu, bir noktadan sonra düşüyor mu?

**Soru:** `max_depth=None` (sınırsız derinlik) genelde en iyi **train**
skorunu verir ama en iyi **test** skorunu vermeyebilir. Bu örüntüyü
hafta 10 ders notundaki hangi kavramla açıklarsınız?

---

## 4.4 Optuna ile arama

```bash
python scripts/optuna_search.py --n-trials 30
```

**Görev:** MLflow UI'da `optuna_trial_*` çalıştırmalarını bulun, en iyi
`roc_auc`'ı `train_all_models.py`'nin en iyi sonucuyla karşılaştırın.

**Soru:** Optuna, `train_all_models.py`'deki elle seçilmiş grid'den daha
iyi bir sonuç buldu mu? 30 deneme ile kaç farklı hiperparametre
kombinasyonu **gerçekte** denenmiş oldu — grid search'te aynı kapsamı
taramak için kaç deneme gerekirdi?

---

## 4.5 Model Registry

**Görev:** En iyi çalıştırmayı UI'dan bulup **Register Model** ile
`churn-classifier` adında bir registry kaydı oluşturun. Ardından bu
versiyonu **Production** aşamasına (stage) taşıyın.

```python
import mlflow
model = mlflow.sklearn.load_model("models:/churn-classifier/Production")
```

**Soru:** Bu kod, hangi çalıştırmanın modelini kullandığını **isim üzerinden**
mi yoksa **run_id üzerinden** mi belirliyor? Bunun avantajı nedir — yarın
daha iyi bir model bulduğunuzda kod satırını değiştirmeniz gerekir mi?

---

## ✅ Ne öğrendik

- MLflow, "hangi parametreyle neyi denedim" kaosunu bir arayüzde çözer.
- Karar ağacı derinliği arttıkça bir noktadan sonra test skoru düşer —
  overfitting'in doğrudan gözlemlenebilir kanıtı.
- Optuna'nın Bayesian araması, aynı deneme sayısıyla grid search'ten
  genelde daha iyi sonuç bulur çünkü önceki denemelerden ders çıkarır.
- Model Registry, "Production'daki model" kavramını `run_id`'den soyutlar
  — kod hiç değişmeden yeni bir versiyon terfi ettirilebilir.

📎 [Çözüm](./solutions/04-mlflow-tracking.md)
