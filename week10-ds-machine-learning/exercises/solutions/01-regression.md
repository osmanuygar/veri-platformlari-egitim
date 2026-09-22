# ✅ Çözüm 1: Regresyon — Aylık Ücret Tahmini

## 1.1 Sonuçlar

Bu özelliklerle (tenure, support_calls, has_addons, payment_late_count)
`monthly_charge`'ı tahmin etmek zordur çünkü veri üretim script'inde
`monthly_charge` **rastgele** (`rng.uniform`) üretildi — diğer özelliklerle
gerçek bir ilişkisi yok. Beklenen sonuç: **düşük R² (0'a yakın, hatta
negatif), yüksek MAE/RMSE** — bu BEKLENEN ve öğretici bir sonuçtur.

## 1.2 MAE vs RMSE

Birimler: MAE **TL**, RMSE de **TL** (RMSE hesaplanırken önce kareleniyor
[TL²] sonra karekök alınıyor [TL'ye geri dönüyor] — MSE'nin kendisi TL² olurdu).

RMSE ≥ MAE her zaman doğrudur çünkü RMSE büyük hataları **karesi** ile
cezalandırır — 10 birimlik bir hata, 2 birimlik bir hatadan 25 kat (5²)
daha fazla RMSE'ye katkıda bulunur, MAE'ye ise sadece 5 kat.

Aykırı değerler (çok yüksek `monthly_charge` içeren satırlar) **RMSE'yi**
çok daha fazla etkiler — bu yüzden aykırı değere duyarlı olmak istemiyorsanız
MAE'yi tercih edin; büyük hataları özellikle cezalandırmak istiyorsanız RMSE.

## 1.3 R² yorumu

R²=0.35, modelin **varyansın %35'ini açıkladığı** anlamına gelir — geri
kalan %65 açıklanamıyor (gürültü ya da modelde olmayan özellikler).

R² **negatif** olabilir — bu, modelin "sadece ortalamayı tahmin eden" naif
bir modelden **daha kötü** olduğu anlamına gelir. Bu genelde modelin
gürültülü/ilgisiz özelliklerle eğitildiğinin işaretidir — bu alıştırmadaki
senaryo tam olarak budur, çünkü `monthly_charge` gerçekte kullanılan
özelliklerden bağımsız üretildi.

## 1.4 Öğrenme eğrisi

Bu senaryoda train VE val skorları **ikisi de düşük** kalır ve birbirine
yakındır (büyük bir boşluk yoktur) — bu **underfitting** değil, aslında
"öğrenilecek gerçek bir ilişki yok" durumudur. Klasik underfitting
(basit model, karmaşık gerçek ilişki) ile bu durumu (karmaşık model,
ilişkinin kendisi yok) ayırt etmek için alan bilgisine (burada: verinin
nasıl üretildiğini bilmeye) ihtiyaç vardır — sadece eğriye bakarak ayırt
etmek her zaman mümkün olmayabilir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| MAE | Ortalama mutlak hata, orijinal birimde, aykırı değere dayanıklı |
| RMSE | Büyük hataları orantısız cezalandırır, MAE'den her zaman ≥ |
| R² < 0 | Model, ortalamayı tahmin eden naif modelden daha kötü |
| Train≈Val, ikisi de düşük | Muhtemelen özellikler hedefle gerçekten ilişkisiz |

**[← Alıştırma 1](../01-regression.md)**
