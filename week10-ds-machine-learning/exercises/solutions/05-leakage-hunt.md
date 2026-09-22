# ✅ Çözüm 5: Sızıntı Avı

## 5.1 Sonuçlar

Tipik çıktı: baseline ROC-AUC ~0.72, sızıntılı ~0.74-0.75, doğru ~0.71-0.72
(doğru yaklaşım baseline'a yakın kalır — `device_model`'in gerçek bir
sinyali olmadığı için beklenen budur).

## 5.2 Mekanizma

`device_model`'in 150 farklı değeri, 5000 satıra bölündüğünde kategori
başına ortalama **~33 satır** düşer. Sızıntılı yaklaşımda, bu ortalama
**test satırlarını da içeren** tüm veriden hesaplanıyor — yani bir test
satırının `device_model_encoded` değeri, kısmen **kendi churn etiketinin**
katkısıyla hesaplanmış oluyor. 33 satırlık küçük bir grupta, tek bir
satırın etiketi grup ortalamasını **fark edilir şekilde** kaydırır — model
bu "sahte" sinyali öğrenip test setinde "avantajlı" çıkıyor.

## 5.3 Kardinalitenin etkisi

`device_model`'in sadece 3 değeri olsaydı, her kategori ~1667 satır
içerirdi. Tek bir satırın etiketi, 1667 satırlık bir grubun ortalamasını
**neredeyse hiç değiştirmez** (1/1667'lik bir katkı) — sızıntının etkisi
**çok küçük** olurdu. Nitekim `contract_type` (3 değerli) ile aynı deneyi
yapan Alıştırma metnindeki ilk taslakta (bu README'nin önceki bir
versiyonunda) fark neredeyse sıfırdı — **kardinalite arttıkça sızıntının
şiddeti de artar**, çünkü grup küçüldükçe "ortalama" bireysel etikete daha
çok yaklaşır.

## 5.4 Neden otomatik engellenemedi

`StandardScaler` ve `OneHotEncoder` sadece **X**'e bakar (`fit(X)`) — `y`'ye
hiç ihtiyaç duymazlar. `Pipeline`, `fit()`'i sadece train'e uygulayarak bu
tür dönüşümlerdeki sızıntıyı yapısal olarak engeller.

Hedef ortalama kodlama ise **doğası gereği `y`'ye ihtiyaç duyar**
(`fit(X, y)`). scikit-learn'ün temel `Pipeline`'ı bunu "otomatik doğru"
yapmaz — geliştiricinin ya elle (bu alıştırmada yaptığımız gibi) train/test
ayrımına dikkat etmesi, ya da bunun için özel tasarlanmış bir transformer
(örn. `category_encoders` kütüphanesindeki `TargetEncoder`, ki bu genelde
kendi içinde çapraz doğrulama kullanarak sızıntıyı azaltır) kullanması gerekir.

## 5.5 Kontrol listesi (örnek)

1. Her `fit()`/`fit_transform()` çağrısı sadece **train** verisine mi uygulanıyor?
2. Hedefe (y) bağımlı herhangi bir dönüşüm (encoding, agregasyon) var mı? Varsa, bu dönüşüm split'ten SONRA mı hesaplanıyor?
3. Zaman serisi/olay verisiyse: herhangi bir özellik, tahmin ANINDAN SONRAKİ bir bilgiyi mi taşıyor?
4. Bir özelliğin hedefle korelasyonu "gerçekçi olmayacak kadar" yüksek mi (bkz. Hafta 8)?
5. Aynı varlığın (müşteri, kullanıcı) birden fazla satırı varsa, train ve test'e **karışık** mı dağıldı (grup sızıntısı riski)?

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Hedefe bağımlı dönüşüm | `StandardScaler`'dan farklı, ekstra dikkat gerektirir |
| Kardinalite | Kategori küçüldükçe (az örnekli) sızıntı şiddetlenir |
| `Pipeline` sınırı | Sadece X'e bağımlı dönüşümleri otomatik korur |
| Genel kural | fit() öncesi her zaman "bu adım y'ye mi bağımlı?" diye sorun |

**[← Alıştırma 5](../05-leakage-hunt.md)**
