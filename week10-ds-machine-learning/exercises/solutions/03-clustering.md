# ✅ Çözüm 3: Kümeleme — Müşteri Segmentasyonu

## 3.1 Neden ölçekleme şart

K-Means, öklid uzaklığına dayanır. Ölçeklemeden `monthly_charge`
(20-120 aralığı, yayılım ~100 birim) ile `support_calls` (0-5 aralığı,
yayılım ~5 birim) birlikte kullanılırsa, uzaklık hesabına **neredeyse
tamamen `monthly_charge` egemen olur** — `support_calls`'taki farklar
uzaklığı pratikte hiç etkilemez. Sonuç: kümeler sadece fatura tutarına
göre oluşur, diğer üç özellik göz ardı edilmiş gibi davranır.
`StandardScaler`, her özelliği ortalama=0, std=1 yaparak bu adaletsizliği ortadan kaldırır.

## 3.2 Dirsek yöntemi

k arttıkça inertia (küme içi kareler toplamı) **monoton azalır** ve
k=n (her nokta kendi kümesi) olduğunda sıfıra iner — ama bu **anlamlı**
bir kümeleme değildir, sadece veriyi ezberlemiştir. "En düşük inertia"yı
seçmek, sınıflandırmada "en yüksek train accuracy"yi seçmekle aynı
hatadır — overfitting'in kümelemedeki karşılığı. Dirsek noktası, ek
kümelerin **marjinal faydasının belirgin şekilde azaldığı** noktadır —
pratik bir ödünleşme, matematiksel bir optimum değil.

## 3.3 Örnek segment yorumları

(Gerçek küme numaraları/istatistikleri seed'e ve veri üretimine göre
değişir; örnek bir yorumlama şablonu:)

| Küme | İsim | Karakteristik | Churn oranı |
|---|---|---|---|
| 0 | "Sadık ve düşük riskli" | Uzun tenure, az destek çağrısı, az geç ödeme | Düşük |
| 1 | "Yeni ve belirsiz" | Kısa tenure, orta harcama | Orta |
| 2 | "Şikayetçi ve riskli" | Çok destek çağrısı, çok geç ödeme | **Yüksek** |
| 3 | "Yüksek harcamalı, memnun" | Yüksek fatura, az şikayet | Düşük-orta |

## 3.4 Kümeleme değerlendirmesinde etiket kullanmak

**Tutarsız değildir.** K-Means algoritmasının kendisi `churned` sütununu
hiç görmedi — sadece 4 sayısal özelliğe bakarak gruplar oluşturdu. Biz
sonradan, tamamen ayrı bir adımda, "bu kümelerin churn ile ilişkisi var
mı?" diye **inceliyoruz** — bu, kümelemenin iş açısından **anlamlı** olup
olmadığını doğrulamanın standart yoludur. Sorun ancak etiketi kümeleme
sürecinin **kendisine** (örn. bir özellik olarak) sokarsak ortaya çıkardı
— o zaman gözetimsiz olmaktan çıkardı.

## 3.5 İş uygulaması

Örnek: "Şikayetçi ve riskli" segmentine (yüksek destek çağrısı + geç
ödeme) proaktif bir müşteri başarı görüşmesi ve esnek ödeme planı sunulabilir
— reaktif bir indirimden çok, **kök nedene** (memnuniyetsizlik + finansal
zorlanma) yönelik bir aksiyon, daha kalıcı bir etki yaratabilir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Ölçekleme | K-Means'te neredeyse her zaman zorunlu ön adım |
| Dirsek yöntemi | En düşük inertia değil, marjinal faydanın azaldığı nokta |
| Etiketle değerlendirme | Kümeleme sürecinden ayrı, sonuçları doğrulamak için meşru |
| İyi segmentasyon | "Kaç küme" değil "her kümeye ne yapmalı" sorusuyla biter |

**[← Alıştırma 3](../03-clustering.md)**
