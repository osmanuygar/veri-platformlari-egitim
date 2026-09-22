# ✅ Çözüm 2: Güç Analizi

## 2.1 Temel hesap

`--baseline 0.11 --mde 0.02` için grup başına **~4.137** kullanıcı gerekir
(toplam ~8.275). Günde 500 checkout'un yarısı her varyanta gitse (250/gün),
grup başına 4.137'ye ulaşmak **~17 gün** sürer.

## 2.2 MDE küçüldükçe

Tablodaki örüntü: MDE **10 kat** küçülünce (%5.0 → %0.5), gereken örneklem
**~86 kat** büyüyor (727 → 62.685) — yani ilişki **doğrusal değil, yaklaşık
karesel**dir (MDE yarıya inince örneklem ~4 katına çıkar). Bu, güç
analizinin formülünde etki büyüklüğünün **karesinin** paydada yer almasından
kaynaklanır — küçük etkileri yakalamak orantısız derecede pahalıdır.

## 2.3 Alıştırma 1 ile uyum

Alıştırma 1'in örneklemi (~4.200-4.300 grup başına) hesaplanan gereken
örnekleme (~4.137) **çok yakın** — bu tesadüf değil, veri üretim script'i
bilerek bu büyüklükte tutuldu ki test **yeterince güçlü** olsun ve gerçek
farkı (varsa) yakalayabilsin.

## 2.4 Yetersiz güç riski

**Bu sonuç "fark yok" demez** — "bu örneklem büyüklüğüyle, varsa bile
bu farkı güvenilir şekilde göremezdik" der. Aradaki fark kritik: düşük
güçlü bir test H0'ı reddedemediğinde, bu **H0'ın doğru olduğunun kanıtı
değildir** — sadece testin yeterince "duyarlı" olmadığının göstergesidir
(Tip II hata riski yüksek). "Anlamlı çıkmadı" ile "etki yok" farklı iddialardır
— istatistikte en sık yapılan yorumlama hatalarından biri budur.

## 2.5 Pratik karar

MDE=%1.0 için grup başına **~15.969** kullanıcı gerekir (script çıktısından).
Günde 200 yeni checkout, yarı yarıya bölünse (100/varyant/gün), bu örnekleme
ulaşmak **~160 gün** (~5.3 ay) sürer — çoğu ürün ekibi için kabul edilemez
uzunlukta.

Seçenekler (her birinin bedeli var):
- **MDE'yi gevşetmek** (örn. %1.5'e çıkarmak) — daha büyük etkiyi kaçırma riski daha düşük ama küçük gerçek iyileşmeleri kaçırabilirsiniz
- **Tek yönlü test kullanmak** — aynı örneklemle biraz daha az örneklem yeterli olur, ama sadece baştan tek yönü merak ediyorsanız meşrudur
- **α'yı gevşetmek** (0.05 → 0.10) — daha az örneklem gerekir ama Tip I hata (yanlış pozitif) riski artar
- **Sequential testing** (ardışık test) yöntemleri kullanmak — sabit örneklem yerine, istatistiksel olarak geçerli şekilde erken durdurmaya izin veren daha gelişmiş yöntemler

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| MDE küçülmesi | Gereken örneklemi ~karesel hızla büyütür |
| "Anlamlı çıkmadı" | "Etki yok" DEMEK DEĞİLDİR — güç yetersizliği olabilir |
| Uzun test süresi | MDE, α, tek/iki yönlülük ile dengelenebilir — her biri bir bedel taşır |

**[← Alıştırma 2](../02-power-analysis.md)**
