# ✅ Çözüm 1: Yerel Model Çalıştırma

## 1.2 Model boyutu ve kalite

3B model genelde **daha tutarlı, daha az tekrar eden, daha "akıllı"
görünen** cevaplar üretir — parametre sayısı arttıkça model daha fazla
örüntü ve dünya bilgisi "sıkıştırabilir". Hız farkı belirgindir: 3B model,
1B modelden CPU'da genelde **2-3 kat daha yavaş** üretim yapar (parametre
sayısı ile hesaplama maliyeti kabaca doğru orantılıdır).

## 1.3 Donanım gerçeği

Bulut modelleri (yüzlerce milyar parametre) özel tasarlanmış **GPU
kümelerinde** (onlarca/yüzlerce GPU, yüksek bant genişlikli birbirine
bağlı) ve **büyük toplu iş (batching)** ile binlerce isteği aynı anda
işleyerek çalışır — maliyeti kullanıcılar arasında paylaştırırlar.
Yerel bir dizüstü bilgisayarın tek CPU'su (ya da entegre GPU'su), bırakın
paralel batching'i, tek bir isteği bile 175B parametreli bir model için
işleyemez (bellek yetmez). Küçük yerel modeller (1-3B), bu donanım
kısıtına **kasıtlı olarak** uyacak şekilde küçültülmüş modellerdir.

## 1.4 Kuantizasyon

Kuantizasyon, bir modelin ağırlıklarını (parametrelerini) daha **az bit**
ile temsil etmektir — orijinal eğitim genelde 16/32-bit float kullanırken,
`Q4_K_M` gibi bir format 4-bit'e sıkıştırır.

**Kazanç:** Model dosyası ~4-8 kat küçülür, RAM kullanımı orantılı düşer,
çıkarım (inference) hızlanır (daha az veri taşınır).

**Risk:** Ağırlıkların hassasiyeti düştüğü için model **hafifçe daha az
doğru** hale gelir — ama modern kuantizasyon teknikleri (K-quant gibi)
bu kayıp/kazanç dengesini çok iyi optimize eder; çoğu kullanım için
kalite kaybı gözle fark edilmeyecek kadar küçüktür.

## 1.5 Yerel vs bulut

| Senaryo | Tercih | Gerekçe |
|---|---|---|
| Hassas/gizli veri, dışarı çıkamaz | **Yerel** | KVKK/ticari sır — veri hiç ağa çıkmamalı |
| En yüksek kalite gerekiyor, bütçe var | **Bulut** | Büyük modeller (100B+) sadece bulutta pratik |
| Offline/kapalı ağ ortamı | **Yerel** | İnternet bağlantısı zaten yok |
| Değişken, düşük hacimli kullanım | **Bulut** | Kullanım-bazlı ödeme, altyapı yönetimi gerekmez |
| Sürekli yüksek hacim, maliyet optimizasyonu | **Yerel** (uzun vadede) | Sabit donanım maliyeti, API başına ödeme yok |

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Model boyutu | Büyüdükçe kalite ↑, hız ↓ (CPU'da özellikle belirgin) |
| Bulut modelleri | GPU kümesi + batching ile ölçeklenir, yerel donanımla kıyaslanamaz |
| Kuantizasyon | Boyut/hız kazancı, küçük kalite bedeli |
| Yerel vs bulut | Mahremiyet/maliyet vs kalite/kolaylık ödünleşmesi |

**[← Alıştırma 1](../01-local-model.md)**
