# 📋 scipy.stats Cheatsheet

```python
from scipy import stats
import numpy as np
```

---

## 📏 Betimsel İstatistik

```python
np.mean(x); np.median(x); np.std(x, ddof=1)   # ddof=1: örneklem std sapması
stats.skew(x)       # çarpıklık: 0=simetrik, >0=sağa çarpık
stats.kurtosis(x)   # basıklık: 0=normal (fazladan)
np.percentile(x, [25, 50, 75])
```

---

## 🧪 Hipotez Testleri

```python
# İki bağımsız grubun ortalaması farklı mı? (t-test)
stats.ttest_ind(group_a, group_b)
stats.ttest_ind(group_a, group_b, equal_var=False)   # Welch's t-test (varyanslar eşit değilse — GÜVENLİ VARSAYILAN)

# Eşleştirilmiş örneklemler (aynı kişi öncesi/sonrası)
stats.ttest_rel(before, after)

# Normal dağılım varsayımı yapamıyorsanız (parametrik olmayan alternatif)
stats.mannwhitneyu(group_a, group_b)   # t-test'in parametrik olmayan karşılığı
stats.wilcoxon(before, after)          # paired t-test'in parametrik olmayan karşılığı

# İki oranı karşılaştırma (dönüşüm oranı A/B testi)
from statsmodels.stats.proportion import proportions_ztest
count = [conv_a, conv_b]; nobs = [n_a, n_b]
proportions_ztest(count, nobs)

# Kategorik değişkenler bağımsız mı? (ki-kare)
table = pd.crosstab(df['segment'], df['churned'])
stats.chi2_contingency(table)

# 3+ grup ortalaması farklı mı? (ANOVA)
stats.f_oneway(group_a, group_b, group_c)

# Normallik testi
stats.shapiro(x)          # n < 5000 için
stats.normaltest(x)       # D'Agostino-Pearson, büyük n için
```

---

## 📐 Güven Aralığı

```python
# Ortalama için (t-dağılımı, normallik varsayımıyla)
stats.t.interval(0.95, df=len(x)-1, loc=np.mean(x), scale=stats.sem(x))

# Oran için (Wilson skoru — küçük örneklemde normal yaklaşımdan güvenilir)
from statsmodels.stats.proportion import proportion_confint
proportion_confint(count=45, nobs=400, method='wilson')

# Bootstrap (dağılım varsayımı GEREKTİRMEZ — medyan gibi metrikler için)
# bkz. scripts/bootstrap_ci.py
```

---

## 🔋 Güç Analizi / Örneklem Büyüklüğü

```python
from statsmodels.stats.power import NormalIndPower, TTestIndPower
from statsmodels.stats.proportion import proportion_effectsize

# Oranlar için (dönüşüm A/B testi)
effect_size = proportion_effectsize(0.11, 0.13)   # baseline, hedef
NormalIndPower().solve_power(effect_size=effect_size, alpha=0.05, power=0.8)

# Sürekli değişkenler için (Cohen's d)
from statsmodels.stats.power import TTestIndPower
TTestIndPower().solve_power(effect_size=0.3, alpha=0.05, power=0.8)  # d=0.3 küçük-orta etki
```

| Cohen's d | Etki büyüklüğü |
|---|---|
| 0.2 | Küçük |
| 0.5 | Orta |
| 0.8 | Büyük |

---

## 🎯 p-değerini Doğru Okumak

| p-değeri | YANLIŞ yorum | DOĞRU yorum |
|---|---|---|
| p = 0.03 | "%97 ihtimalle etki gerçek" | "Eğer GERÇEKTEN etki yoksa, bu kadar (ya da daha uç) bir sonucu şans eseri görme olasılığı %3" |
| p = 0.20 | "Etki yok" | "Bu veriyle H0'ı reddetmek için yeterli kanıt yok — etki olmadığının KANITI değil" |
| p < 0.05 | "Sonuç önemli/büyük" | "Sonuç, tesadüf olma ihtimali düşük — büyüklüğü AYRI bir sorudur (effect size'a bakın)" |

---

## ⚠️ Çoklu Karşılaştırma Düzeltmesi

20 testten birini "anlamlı" bulmak sürpriz değildir (bkz. `phacking_demo.py`).
Birden fazla hipotez test ediyorsanız eşiği düzeltin:

```python
from statsmodels.stats.multitest import multipletests

p_values = [0.01, 0.04, 0.03, 0.20, 0.002]

# Bonferroni: en katı, basit (α / test sayısı)
reject, p_corrected, _, _ = multipletests(p_values, alpha=0.05, method='bonferroni')

# Benjamini-Hochberg (FDR): daha az katı, çoğu A/B test platformunun tercihi
reject, p_corrected, _, _ = multipletests(p_values, alpha=0.05, method='fdr_bh')
```

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| "p < 0.05, demek ki etki büyük" | p-değeri ile etki büyüklüğü karıştırılıyor | Her zaman effect size + CI birlikte raporlayın |
| Testi her gün tekrar tekrar bakıp "anlamlı çıktı, durduralım" | Peeking problemi | Önceden belirlenen örneklem büyüklüğüne kadar bekleyin |
| 10 metrik test edip birini öne çıkarmak | p-hacking / çoklu karşılaştırma | Bonferroni/FDR düzeltmesi uygulayın |
| Çarpık veride t-test | Normallik varsayımı ihlali | Mann-Whitney U ya da bootstrap kullanın |
| "İstatistiksel olarak anlamlı değil = etki yok" | p ile "kanıt yokluğu" karıştırılıyor | Güç analizi yapıp örneklem yeterliliğini kontrol edin |

---

**[← Hafta 9 README](../README.md)**
