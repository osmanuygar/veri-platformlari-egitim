# ✅ Çözüm 4: MLflow — Deney Takibi ve Registry

## 4.1-4.2 En iyi model

`roc_auc`'a göre en iyi model ile `f1`'e göre en iyi model **genelde aynı
değildir** — biri sıralama kalitesini (ROC-AUC, tüm eşiklerde ortalama
performans), diğeri belirli bir eşikteki (varsayılan 0.5) dengeyi ölçer.
Hangi metriği önceliklendireceğiniz **iş sorusuna** bağlıdır: modeli farklı
eşiklerle esnek kullanacaksanız ROC-AUC/PR-AUC, sabit bir eşikte
production'a alacaksanız o eşikteki f1/precision/recall daha belirleyicidir.

## 4.3 Karar ağacı derinliği

Tipik örüntü: `roc_auc`, `max_depth` küçükken (2, 4) hızla artar, orta
derinlikte (8 civarı) tepe yapar, `max_depth=None` (sınırsız) olduğunda
**düşer veya platoya girer**. Sınırsız derinlikte ağaç, eğitim verisinin
gürültüsünü bile ezberler (train skoru neredeyse mükemmel olur) ama bu
ezber test verisine **genellemez** — klasik **overfitting / yüksek
varyans** örneğidir (bkz. ders notu §"Bias-Variance Ödünleşmesi").

## 4.4 Optuna karşılaştırması

Optuna, genelde `train_all_models.py`'nin elle seçilmiş grid'inden (4
`n_estimators` × sabit diğer parametreler) **biraz daha iyi** bir sonuç
bulur çünkü TPE (Tree-structured Parzen Estimator) örnekleyicisi önceki
denemelerin sonuçlarından ders çıkararak bir sonraki denemeyi **akıllıca**
seçer — rastgele ya da sabit ızgara yerine.

30 Optuna denemesi, 5 boyutlu bir parametre uzayını (n_estimators, max_depth,
min_samples_split, min_samples_leaf, max_features) örnekler. Aynı kapsamı
klasik grid search ile taramak (her boyut için sadece 5 değer denense bile)
5⁵ = **3.125 deneme** gerektirirdi — Optuna, çok daha az denemeyle
karşılaştırılabilir (genelde daha iyi) sonuçlara ulaşır.

## 4.5 Model Registry

Kod `models:/churn-classifier/Production` şeklinde **isim + aşama (stage)**
üzerinden yükleme yapıyor, `run_id` üzerinden değil. Bu ayrım kritiktir:
yarın daha iyi bir model bulup onu Production'a terfi ettirdiğinizde,
**bu kod satırı hiç değişmeden** yeni modeli kullanmaya başlar — çünkü
"Production" bir **işaretçidir** (pointer), belirli bir çalıştırmaya
sabitlenmiş bir referans değildir. Bu, production kodunuzu belirli bir
deney çalıştırmasından **soyutlamanın** standart yoludur.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Metrik seçimi | İş kullanım senaryosuna göre değişir, tek "doğru" metrik yok |
| Sınırsız ağaç derinliği | Overfitting'in doğrudan gözlemlenebilir kanıtı |
| Optuna | Aynı deneme sayısıyla grid search'ten genelde daha iyi |
| Model Registry stage | Production kodunu belirli bir run_id'den bağımsızlaştırır |

**[← Alıştırma 4](../04-mlflow-tracking.md)**
