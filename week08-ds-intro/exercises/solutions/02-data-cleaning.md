# ✅ Çözüm 2: Veri Temizleme

## 2.1 Eksik değer stratejisi

| Sütun | Eksik % | Strateji | Gerekçe |
|---|---|---|---|
| `income` | ~%8 | Medyanla doldur | Çarpık dağılımda ortalama yanıltır; medyan aykırı değerlere dayanıklı |
| `city` | ~%3 | Mod ile doldur ya da "Bilinmiyor" kategorisi | Düşük oranda kayıp; segment analizini bozmaz |
| `age` | ~%3 (genel), ~%25 (65+) | **Gruba göre** medyan (örn. segment bazında) VEYA ayrı bir "eksik" flag'i | Eksiklik rastgele değil — MAR |

`age` sütunundaki eksiklik **MAR** (Missing At Random, gözlemlenen başka bir
değişkene — burada yaşın kendisine, ki bu biraz döngüsel ama pratikte "yüksek
yaş grubunda form doldurmama eğilimi" gibi bir dış değişkene bağlı olduğunu
varsayabiliriz).

Sadece genel medyanla doldurmak **güvenli değildir**: genel medyan (~38)
ile doldurulan değerler, gerçekte 65+ olması gereken kayıtları yapay olarak
gençleştirir ve yaş dağılımını çarpıtır. Daha doğrusu: eksikliğin yoğunlaştığı
grubu ayrı ele almak (örn. bir "yaş bilinmiyor, muhtemelen 65+" flag'i
eklemek) ya da hiç doldurmadan modelin bunu ayrı bir kategori olarak
görmesini sağlamaktır.

## 2.2 Aykırı değer tespiti

IQR yöntemi 150, -5, 999 gibi değerleri **kesinlikle yakalar** (normal yaş
aralığının çok dışında). 90 yaşındaki gerçek bir müşteri de sınırda
yakalanabilir çünkü IQR sınırları veri dağılımına göre otomatik hesaplanır.

**Ayırt etme:** Fiziksel olarak imkânsız değerler (yaş > 120, negatif yaş)
**kesinlikle hata**dır ve otomatik düzeltilebilir/silinebilir. Sınırda kalan
makul ama nadir değerler (90 yaş) için **alan bilgisi** (domain knowledge)
kullanılmalı — otomatik silme yerine ayrı işaretleyip elle incelemek daha
güvenlidir. Kural: **imkânsız → otomatik temizle, nadir ama mümkün → işaretle
ve incele.**

## 2.3 Kopya satırlar

Bu veri setinde kopyalar `df.sample(frac=0.02)` ile üretildi — yani
**tam kopya** satırlardır (her sütun dahil `customer_id` bile aynı).
Temizleme: `df.drop_duplicates()` yeterlidir.

Gerçek hayatta ikinci tür ("customer_id aynı, diğer alanlar farklı" — örneğin
aynı müşterinin iki farklı zamanda güncellenmiş kaydı) çok daha sık görülür
ve `drop_duplicates()` bunu yakalamaz; bunun yerine "en güncel kaydı tut"
mantığıyla (`sort_values('updated_at').drop_duplicates('customer_id', keep='last')`)
temizlenmesi gerekir.

## 2.4 Tutarsız kategorik değerler

Normalizasyon **öncesi** `nunique()` genelde gerçek şehir sayısından (8)
daha yüksektir (~%5 satırda büyük harf + boşluk varyantı var, bu bazı şehirler
için ek "sahte" kategoriler yaratır). Normalizasyon **sonrası** tam 8'e iner.

Normalize etmeden `groupby('city')` yapılsaydı, örneğin "İstanbul" ve
"İSTANBUL  " **ayrı gruplar** olarak sayılır, her ikisinin toplamı ayrı ayrı
küçük görünür — İstanbul'un gerçek payı **olduğundan düşük** raporlanır.

## 2.5 Temiz veri seti

Beklenen: ~40 kopya satır silinir (2040 → ~2000), eksik değerler dolduğulur
veya işaretlenir, aykırı değerler düzeltilir/işaretlenir, `city` normalize edilir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Eksiklik mekanizması | Doldurma stratejisini belirler (MCAR/MAR/MNAR) |
| IQR/z-score | Aday bulur; imkânsız/nadir ayrımını alan bilgisi yapar |
| Tam kopya vs kayıt tekrarı | Farklı problemler, farklı temizleme mantığı |
| String normalizasyonu | Atlanırsa `groupby` sonuçları sessizce yanlış çıkar |

**[← Alıştırma 2](../02-data-cleaning.md)**
