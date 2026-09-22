# Alıştırma 1: Hipotez Testi — A/B Checkout

**Süre:** ~30 dakika · **Veri:** `data-samples/ab_test_checkout.csv`

---

## 1.1 Hipotezleri kurun

**Görev:** Bu test için H0 (sıfır hipotezi) ve H1 (alternatif hipotez)'i
yazılı olarak ifade edin.

**Soru:** H0'ı "A ve B arasında fark yoktur" diye kurmak ile "B, A'dan
daha iyi değildir" diye kurmak arasındaki fark nedir? (İpucu: iki-yönlü
(two-tailed) ile tek-yönlü (one-tailed) test)

---

## 1.2 Testi çalıştırın

```python
import pandas as pd
from statsmodels.stats.proportion import proportions_ztest

df = pd.read_csv("data-samples/ab_test_checkout.csv")
counts = df.groupby('variant')['converted'].sum()
nobs = df.groupby('variant').size()

stat, p_value = proportions_ztest(counts[['A','B']], nobs[['A','B']])
print(f"p-değeri: {p_value:.4f}")
```

**Görev:** p-değerini kaydedin. α=0.05 eşiğine göre H0'ı reddediyor musunuz?

---

## 1.3 p-değerini doğru yorumlayın

**Soru:** Aşağıdaki iki cümleden hangisi p-değerinin DOĞRU yorumu?

> (a) "B'nin A'dan iyi olma ihtimali %96"
> (b) "Eğer gerçekte A ve B arasında hiçbir fark yoksa, gözlemlediğimiz
>      (ya da daha uç) bir farkı şans eseri görme olasılığı %4"

Doğru olanı seçip, diğerinin neden yanlış olduğunu bir cümleyle açıklayın.

---

## 1.4 Etki büyüklüğü

```python
rates = df.groupby('variant')['converted'].mean()
print(rates)
```

**Soru:** p-değeri "anlamlı" çıksa bile, mutlak fark (`rates['B'] - rates['A']`)
kaç puan? Bu fark, iş açısından **büyük** mü **küçük** mü? p-değeri ile
etki büyüklüğü neden AYRI sorular?

---

## 1.5 Örneklem büyüklüğünün etkisi

**Düşünce deneyi:** Aynı `%11 vs %13` farkını, örneklem 100 kat daha küçük
olsaydı (42 vs 43 kullanıcı) test etseydiniz p-değeri nasıl değişirdi —
büyür mü küçülür mü? Neden? (Alıştırma 2'de bunu sayısal olarak doğrulayacaksınız.)

---

## ✅ Ne öğrendik

- H0/H1'i test etmeden ÖNCE, yazılı olarak kurmak gerekir.
- p-değeri "etkinin gerçek olma olasılığı" DEĞİLDİR — H0 doğruyken bu
  veriyi (ya da daha uçlarını) gözlemleme olasılığıdır.
- İstatistiksel anlamlılık ile iş açısından önemlilik (etki büyüklüğü) FARKLI sorulardır.
- Örneklem büyüklüğü p-değerini doğrudan etkiler — büyük örneklemde çok
  küçük, önemsiz farklar bile "anlamlı" çıkabilir.

📎 [Çözüm](./solutions/01-hypothesis-test.md)
