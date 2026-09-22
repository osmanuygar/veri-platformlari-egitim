# ✅ Çözüm 2: Sınıflandırma — Dengesiz Churn Verisi

## 2.1 Accuracy tuzağı

Churn oranı ~%25-30 olduğu için, "hiç kimse churn etmeyecek" diyen dummy
model **~%70-75 accuracy** alır — hiçbir şey öğrenmeden. Aynı modelin
churn sınıfı için f1 skoru **0.0**'dır (hiç pozitif tahmin yapmadığı için
recall=0, dolayısıyla f1=0). Bu uçurum, accuracy'nin dengesiz veride
neden tek başına anlamsız olduğunu net gösterir.

## 2.2 `class_weight='balanced'`in etkisi

Bu parametre olmadan model, çoğunluk sınıfına (churn etmeyecek) yönelik
bir eğilim gösterir — **recall düşer** (churn eden müşterilerin çoğunu
kaçırır). `class_weight='balanced'` her sınıfın hatasını, o sınıfın
frekansıyla ters orantılı ağırlıklandırır — azınlık sınıfının (churn)
yanlış sınıflandırılması daha ağır cezalandırılır, bu da **recall'ı
artırır** (genelde precision'dan biraz ödün vererek).

## 2.3 Confusion matrix yorumu

| | Model: churn etmeyecek dedi | Model: churn edecek dedi |
|---|---|---|
| **Gerçek: etmedi** | Doğru Negatif (TN) — doğru tahmin | **Yanlış Pozitif (FP)** — gereksiz indirim/müdahale |
| **Gerçek: etti** | **Yanlış Negatif (FN)** — kaçırılan müşteri | Doğru Pozitif (TP) — doğru yakalama |

Genelde **Yanlış Negatif (FN) daha pahalıdır**: kaybedilen bir müşterinin
yaşam boyu değeri (LTV), gereksiz gönderilen bir indirimin maliyetinden
çoğu zaman kat kat fazladır. Bu durumda **recall**'ı önceliklendirmek
mantıklıdır — "riskli olabilecek herkesi yakala, birkaç fazladan indirim
göndermek pahalı değil."

(Not: Bazı işlerde tam tersi olabilir — örn. çok agresif bir retention
kampanyası marka algısını zedeliyorsa, precision daha kritik olabilir.
Kural evrensel değildir, maliyetler somut olarak hesaplanmalıdır.)

## 2.4 Eşik ayarı

Eşiği 0.5'ten 0.3'e düşürmek modeli "daha kolay churn tahmin eden" hale
getirir: **recall artar** (daha çok gerçek churn yakalanır), **precision
düşer** (daha çok yanlış alarm). Bu, modeli yeniden eğitmeden, sadece
karar sınırını kaydırarak iş ihtiyacına (FN'in mi FP'nin mi daha pahalı
olduğuna) göre ayarlama yapmanın standart yoludur.

## 2.5 ROC-AUC vs PR-AUC

Ciddi dengesiz veride (örn. %1 fraud), ROC-AUC'nin paydasındaki "gerçek
negatif oranı" (true negative rate) çok kolay yüksek çıkar çünkü negatif
sınıf zaten ezici çoğunlukta — model kötü olsa bile ROC eğrisi "iyi"
görünebilir. **PR-AUC** (precision-recall eğrisinin altındaki alan) sadece
pozitif sınıfa odaklanır ve dengesizlikten çok daha az etkilenir — bu
yüzden ciddi dengesiz problemlerde tercih edilir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Accuracy | Dengesiz veride tek başına anlamsız |
| `class_weight='balanced'` | Recall'ı artırır, genelde precision pahasına |
| FN vs FP maliyeti | İş bağlamına göre hangi metriğin öncelikli olduğunu belirler |
| Eşik ayarı | Modeli değiştirmeden precision/recall dengesini kaydırır |
| PR-AUC | Ciddi dengesiz veride ROC-AUC'den daha güvenilir |

**[← Alıştırma 2](../02-classification-imbalance.md)**
