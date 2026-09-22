# ✅ Çözüm 1: EDA Raporu

## 1.1 İlk keşif

Üretim script'iyle: **2040 satır** (2000 gerçek + %2 kasıtlı kopya), **11 sütun**.
Eksik değerler `income` (~%8), `city` (~%3), `age` (~%3 genel, ama 65+ yaşta ~%25).

`income` neden `float64`: gelir değerleri `np.random.lognormal` ile sürekli
(ondalıklı) üretildi — "38500.47 TL" gibi. Gerçek dünyada da gelir genelde
tam sayı olmaz (kuruş farkları vb.), bu yüzden `float` doğal bir tiptir.

## 1.2 Merkezi eğilim

Ortalama, medyandan **belirgin şekilde yüksek** çıkar (lognormal dağılımın
doğası: birkaç çok yüksek gelirli müşteri ortalamayı yukarı çeker, medyan
etkilenmez). `skew()` pozitif ve büyükçe bir değer verir (~1.5-2.5) —
**sağa çarpık** dağılım.

## 1.3 Log dönüşümü

Gelir gibi çarpık dağılımlarda birkaç aşırı büyük değer, histogramın büyük
kısmını "sıkıştırır" — çoğu veri tek bir çubukta toplanır. Logaritma, büyük
değerleri oransal olarak küçültüp küçük farkları büyütür; sonuç çan eğrisine
yakınsar. Hafta 10'da doğrusal regresyon gibi normal dağılım varsayımına
duyarlı yöntemlerde bu dönüşüm sık kullanılır.

## 1.4 Segment karşılaştırması

Beklenen sıralama `gold > silver > bronze` olsa da, bu veri setinde segment
ile `total_spent` **bağımsız** üretildi (segment rastgele atandı, harcama
ayrı bir dağılımdan geldi) — yani gerçek veride beklenen monotonik ilişkiyi
göremeyebilirsiniz. Bu kasıtlı bir tuzak değil, sentetik veri üretiminin bir
sınırlaması; gerçek bulgunuz "segment ataması ile harcama arasında güçlü bir
ilişki yok" olabilir — bu da geçerli ve raporlanması gereken bir bulgudur.

## 1.5 Örnek bulgular

1. "`income` sütununda ortalama medyandan ~1.4x yüksek — sağa çarpık dağılım."
2. "`age` eksikliği 65+ yaşta %25, genelde %3 — rastgele değil (MAR)."
3. "2040 satırın 40'ı tam kopya (%2) — muhtemelen bir veri toplama hatası."
4. "`income` sütununda birkaç negatif değer var — veri girişi hatası, geçersiz."
5. "`city` sütununda `'İSTANBUL  '` gibi tutarsız yazımlar `nunique()`'i şişiriyor."

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Ortalama vs medyan farkı | Çarpıklığın ucuz göstergesi |
| Log dönüşümü | Sağa çarpık dağılımı normale yakınsatır |
| Bulgu yazma | Her bulgu somut bir kanıtla desteklenmeli |

**[← Alıştırma 1](../01-eda-report.md)**
