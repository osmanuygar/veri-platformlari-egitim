# ✅ Çözüm 4: Yanılgı Avı

## 4.1 p-hacking canlı

Varsayılan seed ile **1/20 test "anlamlı" çıkar** — tam olarak beklenen
~%5'lik yanlış pozitif oranıyla uyumlu. Bu testlerin **hiçbirinde** gerçek
bir ilişki yoktur (kod, iki grubu da `N(0,1)`'den bağımsız üretir).

Bir araştırmacı bu 1 testi seçip yayınlasa, okuyucu **tamamen yanıltılmış
olur** — sunulan "bulgu" saf gürültüdür, ama tek başına görüldüğünde
(diğer 19 testten habersiz) meşru bir bilimsel sonuç gibi görünür.

## 4.2 İddia değerlendirmeleri

**İddia 1 — Hatalı.** Korelasyon-nedensellik karıştırması. Ortak neden
(confounder): **yaz mevsimi**. Sıcak havada hem dondurma satışı hem
yüzme/su aktiviteleri (dolayısıyla boğulma riski) artar. Dondurma boğulmaya
neden olmuyor.

**İddia 2 — Hatalı.** Çoklu karşılaştırma / p-hacking. 20 metrik test edilip
sadece 1'i "anlamlı" çıktıysa, bu tam olarak `phacking_demo.py`'nin
gösterdiği şans eseri yanlış pozitif oranıyla uyumludur. Bonferroni/FDR
düzeltmesi olmadan bu "bulguya" güvenilmemeli.

**İddia 3 — Hatalı.** "Neredeyse anlamlı" (p=0.06 iken α=0.05 kullanılıyorsa)
bir kavram DEĞİLDİR — eşik önceden belirlenir, p=0.06 basitçe H0'ın
reddedilemediği anlamına gelir. "Neredeyse" demek, sonradan eşiği
gevşetmenin gizli bir yoludur.

**İddia 4 — Hatalı.** **Peeking problemi.** Veriye tekrar tekrar bakıp ilk
"anlamlı" anda durmak, gerçek yanlış pozitif oranını α'nın çok üzerine
çıkarır — bu, p-hacking'in **zamana yayılmış** versiyonudur. Doğrusu:
önceden hesaplanan (güç analiziyle) örneklem büyüklüğüne ulaşana kadar
beklemek, ya da bunun için tasarlanmış sequential testing yöntemleri kullanmak.

**İddia 5 — Hatalı.** **Regresyona doğru gerileme.** Bir yılın en iyi
performans gösteren şehirleri, kısmen **şans faktörleriyle** de o noktaya
gelmiş olabilir; ertesi yıl bu şans faktörleri devam etmeyeceği için
performansları ortalamaya doğru yakınsar — sıcaklıkla nedensel bir ilgisi
olması gerekmez.

**İddia 6 — Hatalı.** **Seçilim yanlılığı (selection bias).** Özelliği
kendi isteğiyle kullanan kullanıcılar muhtemelen zaten daha aktif/bağlı
kullanıcılardır (özelliği aramak, bulmak, kullanmaya karar vermek bile bir
sinyal). Düşük churn, özelliğin ETKİSİ değil, zaten düşük-churn eğilimli
kullanıcıların özelliği seçmiş olmasından kaynaklanıyor olabilir. Doğru
test: rastgele atanmış bir A/B testi (kullanıcının kendi seçimi değil).

## 4.3 Ortak kalıp

İddia 2 ve 4'ün ortak hatası: **"veriye/sonuçlara tekrar tekrar bakıp uygun
olanı seçmek."** İddia 2 bunu **çok sayıda metrik** üzerinde yapıyor
(çoklu karşılaştırma), İddia 4 bunu **zaman içinde tekrar tekrar** yapıyor
(peeking). İkisi de aynı kökten gelir: **"garden of forking paths"**
(çatallanan yollar bahçesi) — araştırmacının, sonuç "anlamlı" çıkana kadar
farklı analiz seçeneklerini (hangi metrik, ne zaman durmak, hangi alt grup)
denemesi. Önlemi de aynıdır: analiz planını **veriye bakmadan önce**
dondurmak (pre-registration) ve çoklu test yapılıyorsa düzeltme uygulamak.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Korelasyon-nedensellik | Ortak neden (confounder) her zaman aranmalı |
| p-hacking | Çok test + seçici raporlama = şişmiş yanlış pozitif oranı |
| Peeking | Erken durdurma, p-hacking'in zamana yayılmış hali |
| Regresyona doğru gerileme | Aşırı gözlemler doğal olarak ortalamaya yaklaşır |
| Seçilim yanlılığı | Kendi kendine seçilmiş gruplar nedensel yorum için güvenilmez |

**[← Alıştırma 4](../04-fallacy-hunt.md)**
