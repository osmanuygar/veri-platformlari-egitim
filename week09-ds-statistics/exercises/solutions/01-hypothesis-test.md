# ✅ Çözüm 1: Hipotez Testi — A/B Checkout

## 1.1 Hipotezler

- **H0:** B'nin dönüşüm oranı, A'nınkiyle aynıdır (`p_B = p_A`).
- **H1:** B'nin dönüşüm oranı, A'nınkinden farklıdır (`p_B ≠ p_A`) — **iki yönlü**.

"A ve B arasında fark yoktur" (iki yönlü) ile "B, A'dan daha iyi değildir"
(tek yönlü) arasındaki fark: iki yönlü test, B'nin A'dan **hem daha iyi
hem daha kötü** çıkma ihtimalini birlikte değerlendirir; tek yönlü test
sadece bir yönü test eder (örn. sadece "B daha iyi mi") ve aynı α ile
**daha kolay anlamlı çıkar** — ama sadece gerçekten baştan sadece o yönü
merak ediyorsanız meşrudur. Sonradan "B kötü çıktı, tek yönlüye çevireyim"
demek p-hacking'in bir türüdür.

## 1.2 Test sonucu

Üretilen veriyle (A≈%11.1, B≈%12.7, n≈8500) tipik p-değeri **~0.01-0.05**
aralığında çıkar (tam değer üretim seed'ine bağlı) — α=0.05 eşiğinde
genelde H0 reddedilir.

## 1.3 Doğru yorum

**Doğru cevap: (b).**

(a) yanlıştır çünkü p-değeri **hipotezin doğru olma olasılığı değildir**
— p-değeri her zaman "H0 DOĞRUYKEN bu veriyi görme olasılığı" hesaplanır,
"H1'in doğru olma olasılığı" hiçbir zaman doğrudan hesaplanmaz (bu, Bayesçi
bir soru olurdu, frequentist p-değeri bunu cevaplamaz).

## 1.4 Etki büyüklüğü

Mutlak fark ~1.6 puan (%11.1 → %12.7). İş açısından büyük/küçük olup
olmadığı **bağlama bağlıdır**: yüksek hacimli bir e-ticaret sitesinde
1.6 puanlık bir dönüşüm artışı yılda milyonlarca TL ek gelir demek olabilir
— aynı fark düşük hacimli bir sitede önemsiz kalabilir.

p-değeri ile etki büyüklüğü ayrı sorulardır çünkü p-değeri **örneklem
büyüklüğünden güçlü şekilde etkilenir** (bkz. 1.5) — çok büyük bir örneklemde
0.1 puanlık, iş açısından anlamsız bir fark bile "istatistiksel olarak
anlamlı" çıkabilir. Karar için her zaman ikisi birlikte değerlendirilmeli.

## 1.5 Örneklem küçülürse

p-değeri **büyürdü** (daha az "anlamlı" görünürdü), aynı gerçek fark
(%11→%13) sabit kalsa bile. Sebep: standart hata (dolayısıyla test
istatistiğinin gürültüsü) örneklem küçüldükçe büyür — aynı sinyali daha
az veriyle ayırt etmek zorlaşır. 42 vs 43 kullanıcıda büyük ihtimalle
p > 0.05 çıkardı, aynı gerçek etki var olsa bile — bu, Alıştırma 2'nin
konusu olan **istatistiksel güç** meselesidir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| H0/H1 | Testten ÖNCE, yazılı olarak kurulmalı |
| p-değeri | "H0 doğruyken bu veriyi görme olasılığı" — hipotezin doğruluk olasılığı DEĞİL |
| Etki büyüklüğü | p-değerinden ayrı, iş açısından ayrıca değerlendirilmeli |
| Örneklem büyüklüğü | p-değerini doğrudan etkiler — küçük örneklem gerçek etkiyi kaçırabilir |

**[← Alıştırma 1](../01-hypothesis-test.md)**
