# Alıştırma 5: Sızıntı Avı

**Süre:** ~20 dakika · **Dosya:** `scripts/leaky_pipeline_demo.py`

---

## 5.1 Demoyu çalıştırın

```bash
python scripts/leaky_pipeline_demo.py
```

**Görev:** Üç skoru (baseline, sızıntılı, doğru) not edin.

---

## 5.2 Sızıntının mekanizması

`leaky_approach()` fonksiyonunu okuyun.

**Soru:** `device_model` sütununun churn ile **gerçekte hiçbir ilişkisi
yok** (veri üretim script'inde rastgele atandı — `generate_churn_dataset.py`
içinde doğrulayın). Buna rağmen sızıntılı yaklaşım, bu sütunu kullanarak
skoru nasıl yükseltebiliyor?

---

## 5.3 Neden yüksek kardinalite bu kadar kritik

**Düşünce deneyi:** `device_model`'in sadece **3** farklı değeri olsaydı
(150 yerine), her kategori ortalama ~1667 satır içerirdi. Sızıntının etkisi
daha büyük mü küçük mü olurdu? (İpucu: bir kategorideki örnek sayısı arttıkça,
o kategorinin "ortalaması" tek bir satırın etiketinden ne kadar bağımsızlaşır?)

**Görev:** `common.py`'deki `CATEGORICAL_FEATURES = ["contract_type"]`
(sadece 3 değerli) ile aynı deneyi tekrarlayıp (kendi kısa script'inizi
yazarak) farkı doğrulayın.

---

## 5.4 Genel prensip

**Soru:** Bu haftanın `make_pipeline()` fonksiyonu (bkz. `common.py`),
`ColumnTransformer` + `Pipeline` kullanarak `StandardScaler` ve
`OneHotEncoder`'ın sızıntısını **otomatik olarak** engelliyor. Peki neden
`leaky_pipeline_demo.py`'deki hedef ortalama kodlama (target mean encoding)
sızıntısı aynı şekilde otomatik engellenemedi — bunu elle mi yazmak gerekti?

*(İpucu: `OneHotEncoder`/`StandardScaler` sadece X'e bakar; target mean
encoding ise y'ye de ihtiyaç duyar — scikit-learn'ün standart transformer
arayüzü `fit(X, y=None)` şeklindedir ama basit `Pipeline` adımları bunu
"sadece train'e" uygulamayı otomatik garanti etmez, özel bir
`TargetEncoder` transformer'ı gerekir.)*

---

## 5.5 Kendi kontrol listenizi yazın

**Görev:** Bundan sonra kuracağınız her ML pipeline'ında sızıntıyı önlemek
için kontrol edeceğiniz **5 maddelik bir liste** yazın.

---

## ✅ Ne öğrendik

- Hedef ortalama kodlama gibi **hedefe bağımlı** dönüşümler, `StandardScaler`
  gibi hedeften bağımsız dönüşümlerden çok daha sinsi bir sızıntı riski taşır.
- Sızıntının büyüklüğü, kategorinin **kardinalitesiyle** doğru orantılıdır
  — az örnekli kategorilerde grup ortalaması neredeyse etiketin kendisi olur.
- scikit-learn'ün `Pipeline`'ı çoğu sızıntı türünü otomatik önler, ama
  hedefe bağımlı özel dönüşümler için ek dikkat (`category_encoders`
  kütüphanesindeki `TargetEncoder` gibi, çapraz doğrulama içinde fit edilen
  versiyonlar) gerekir.

📎 [Çözüm](./solutions/05-leakage-hunt.md)
