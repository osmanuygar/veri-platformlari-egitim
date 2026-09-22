# Alıştırma 2: Güç Analizi

**Süre:** ~25 dakika · **Dosya:** `scripts/power_analysis.py`

---

## 2.1 Temel hesap

```bash
python scripts/power_analysis.py --baseline 0.11 --mde 0.02
```

**Görev:** Grup başına gereken kullanıcı sayısını not edin. Siteniz günde
500 checkout alıyorsa, bu testi tamamlamak kaç gün sürer?

---

## 2.2 MDE küçüldükçe ne olur?

Script'in çıktısındaki karşılaştırma tablosuna bakın (`MDE=%5.0` → `MDE=%0.2`).

**Soru:** MDE (Minimum Detectable Effect — yakalamak istediğiniz en küçük
fark) 10 kat küçülünce gereken örneklem yaklaşık kaç kat büyüyor? Bu ilişki
doğrusal mı yoksa daha hızlı mı büyüyor?

---

## 2.3 Alıştırma 1'e geri dönüş

Alıştırma 1'deki test **4.200 vs 4.300** kullanıcıyla, **%11 → %13** (2 puanlık)
farkı yakalayabildi.

**Soru:** `power_analysis.py --baseline 0.11 --mde 0.02` çıktısındaki
"gereken örneklem" ile alıştırma 1'in gerçek örneklem büyüklüğü uyumlu mu?
Test, bu farkı yakalamak için **yeterince güçlü** müydü?

---

## 2.4 Yetersiz güç riski

**Düşünce deneyi:** Diyelim testi sadece 500 vs 500 kullanıcıyla çalıştırdınız
ve p-değeri 0.15 çıktı (H0 reddedilmedi).

**Soru:** Bu sonuç size "B, A'dan daha iyi değil" mi söylüyor, yoksa
"bu örneklem büyüklüğüyle bir fark olsa bile göremezdik" mi? İkisi arasındaki
fark neden önemli? (İpucu: "kanıt yokluğu, yokluğun kanıtı değildir")

---

## 2.5 Pratik karar

**Görev:** Ürün ekibiniz "checkout dönüşümünde en az %1'lik bir iyileşme
olmadıkça bu değişikliğe değmez" diyor. Baseline %11.

- Bu MDE için grup başına kaç kullanıcı gerekiyor?
- Günde 200 yeni checkout alan bir site için bu testi tamamlamak kaç gün sürer?
- Bu süre kabul edilebilir mi? Değilse, MDE'yi gevşetmek dışında hangi
  seçenekleriniz var? (İpucu: tek-yönlü test, α'yı gevşetmek — riskleriyle birlikte)

---

## ✅ Ne öğrendik

- Örneklem büyüklüğü, MDE ile **ters orantılı değil** — MDE küçüldükçe
  gereken örneklem karesel bir hızla büyür.
- Testi çalıştırmadan ÖNCE güç analizi yapmak, "yetersiz örneklemle boşuna
  test çalıştırma" hatasını önler.
- **"Anlamlı çıkmadı" ile "fark yok" farklı şeylerdir** — düşük güçlü bir
  test, gerçek bir etkiyi kolayca kaçırabilir (Tip II hata).

📎 [Çözüm](./solutions/02-power-analysis.md)
