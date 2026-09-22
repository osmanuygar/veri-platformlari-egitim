# Alıştırma 4: Yanılgı Avı

**Süre:** ~20 dakika · **Format:** Yazılı analiz

---

## 4.1 p-hacking'i canlı görün

```bash
python scripts/phacking_demo.py
```

**Görev:** Kaç testten kaçı "anlamlı" çıktı? Bu testlerin GERÇEKTE hiçbir
ilişki taşımadığını biliyoruz (kod, iki grubu da aynı dağılımdan üretiyor).

**Soru:** Bir araştırmacı bu 20 testi çalıştırıp sadece "anlamlı" çıkanı
makalesine koysa, okuyucu ne kadar yanıltılmış olur?

---

## 4.2 Aşağıdaki 6 iddiayı değerlendirin

Her biri için: **Hatalı mı, değil mi?** ve **neden?**

**İddia 1:** "Dondurma satışı arttıkça boğulma vakaları da artıyor
(r=0.87, p<0.001). Dondurmayı yasaklamalıyız."

**İddia 2:** "20 farklı pazarlama metriğini test ettik, 'sosyal medya
paylaşım sayısı' p=0.04 ile anlamlı çıktı. Bütçemizi oraya kaydırıyoruz."

**İddia 3:** "Testimiz p=0.06 çıktı, yani neredeyse anlamlıydı, etkinin
var olduğunu varsayarak devam ediyoruz."

**İddia 4:** "A/B testini her gün kontrol ediyoruz; 3. günde p<0.05'e
düştüğü an testi durdurup B'yi kazanan ilan ettik."

**İddia 5:** "Geçen yıl en yüksek performans gösteren şehirlerin ortalama
sıcaklığı da yüksekti. Şehirleri daha sıcak yerlere taşımalıyız."
*(İpucu: regresyona doğru gerileme — bu şehirler zaten "iyi" bir yıl geçirmiş
olabilir, gelecek yıl ortalamaya yakınsaması olağan bir istatistiksel olgudur.)*

**İddia 6:** "Yeni özelliği kullanan kullanıcıların churn oranı daha düşük
(%5 vs %15). Bu özellik churn'ü azaltıyor, herkese zorunlu yapalım."
*(İpucu: Bu özelliği kendi isteğiyle kullananlar zaten daha bağlı/aktif
kullanıcılar olabilir mi? — seçilim yanlılığı, selection bias)*

---

## 4.3 Genel kalıp

**Soru:** İddia 2 ve 4'ün ortak istatistiksel hatası nedir? (İpucu: her
ikisi de "veriye tekrar tekrar bakıp uygun anı/sonucu seçme" kalıbına
uyuyor — bu genel olarak ne diye adlandırılır?)

---

## ✅ Ne öğrendik

- **Korelasyon ≠ nedensellik**: iki değişken birlikte hareket edebilir çünkü
  üçüncü bir ortak neden (confounder) ikisini de etkiliyordur.
- **p-hacking**: çok sayıda test yapıp "anlamlı" çıkanı seçmek, yanlış
  pozitif oranını ciddi şekilde şişirir.
- **Peeking**: bir A/B testini erken durdurmak (veriye tekrar tekrar bakıp
  "anlamlı" olduğu an durdurmak), p-hacking'in zamana yayılmış bir türüdür.
- **Regresyona doğru gerileme** (regression to the mean): aşırı bir gözlem,
  bir sonraki ölçümde ortalamaya yaklaşma eğilimindedir — bu bir "etki"
  değil, istatistiksel bir olgudur.
- **Seçilim yanlılığı** (selection bias): bir grubu kendi seçimiyle
  ayrışan kullanıcılardan oluşturmak, nedensel yorumu geçersiz kılar.

📎 [Çözüm](./solutions/04-fallacy-hunt.md)
