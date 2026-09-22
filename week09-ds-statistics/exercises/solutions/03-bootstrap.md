# ✅ Çözüm 3: Bootstrap Güven Aralığı

## 3.1 Medyan CI

Tipik sonuç: medyan ~239 TL, %95 CI yaklaşık **[231, 246]** TL civarında
(tam değerler seed'e göre hafif değişir).

## 3.2 `replace=True` neden şart

`replace=False` (yerine koymadan) örnekleme ile, `size=n` (orijinal veriyle
aynı boyut) seçerseniz elde ettiğiniz örneklem **orijinal verinin bir
permütasyonundan (sırası karışmış hali) ibarettir** — hangi elemanların
seçildiği değişmez, sadece sırası değişir. Bir istatistik (medyan, ortalama)
sıraya duyarlı olmadığı için, her "bootstrap örneklemi" **aynı sonucu**
verir ve `boot_stats` dizisinde **hiç çeşitlilik kalmaz** (varyans = 0).

`replace=True` ile her çekilişte bazı gözlemler **birden fazla kez**,
bazıları **hiç** seçilmez — bu, "eğer farklı bir örneklem çekseydik ne
olurdu" sorusunu simüle eder ve gerçek örnekleme değişkenliğini yansıtır.

## 3.3 Ortalama vs medyan

Ortalamanın güven aralığı **medyandan belirgin şekilde daha geniştir**.
Sebep: `order_values` sağa çarpık (birkaç çok yüksek değer var). Bootstrap
örneklerinden bazıları şans eseri bu yüksek değerlerden daha fazla/az
içerir — ortalama bu değişkenliğe doğrudan duyarlıyken, medyan (sıralı
verinin ortancası) aykırı değerlerin varlığından/yokluğundan çok daha az
etkilenir. Bu, medyanın neden "dayanıklı" (robust) bir istatistik olarak
adlandırıldığının doğrudan kanıtıdır.

## 3.4 Tekrar sayısının etkisi

`n_boot=100` ile aralık sınırları **kayda değer şekilde oynak**tır (farklı
seed'lerde belirgin farklı sonuçlar). `n_boot=2000` civarında sınırlar
**stabilize olmaya başlar**. `n_boot=10000`'de ek tekrarlar sınırları
neredeyse hiç değiştirmez — **azalan getiri** (diminishing returns) bölgesine
girilmiştir. Pratikte 1.000-10.000 arası çoğu uygulama için yeterlidir;
kritik kararlarda (yayın, üst düzey rapor) üst sınıra yakın durmak tercih edilir.

## 3.5 %90 vs %99

Güven düzeyi **arttıkça aralık genişler**. Sezgisel açıklama: "gerçek
değeri kesinlikle içeriyor olmaktan %99 emin olmak" istiyorsanız, olası
değerlerin **daha geniş bir aralığını** kapsamanız gerekir — %90 emin olmak
için daha dar (ve dolayısıyla daha az "güvenli ama daha kesin") bir aralık
yeterlidir. Bu, **kesinlik (precision) ile güven (confidence) arasındaki
klasik ödünleşmedir** — istediğiniz kadar dar VE istediğiniz kadar emin
olamazsınız, ikisi ters orantılıdır.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Bootstrap | Dağılım varsayımı olmadan CI üretir |
| `replace=True` | Örnekleme değişkenliğini simüle etmenin anahtarı |
| Çarpık veride ortalama | Medyandan daha geniş CI — aykırı değerlere duyarlı |
| Tekrar sayısı | ~1.000-10.000'de stabilize olur |
| Güven düzeyi ↑ | Aralık genişler (kesinlik/güven ödünleşmesi) |

**[← Alıştırma 3](../03-bootstrap.md)**
