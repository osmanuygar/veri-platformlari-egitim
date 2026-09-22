# ✅ Çözüm 4: Dashboard Eleştirisi

## 4.1 Örnek hata listesi

| # | Hata | Düzeltme |
|---|---|---|
| 1 | 8+ dilimli pasta grafikler | Yatay bar grafiğe çevirin — açıları karşılaştırmak zor, uzunlukları kolay |
| 2 | Çift eksenli (dual-axis) çizgi grafikler | İki ayrı panel kullanın — okuyucu ilişkiyi yanlış yorumlayabilir |
| 3 | Y ekseni 0'dan başlamıyor | 0'dan başlatın — aksi halde küçük farklar dramatik gösterilir |
| 4 | Kırmızı-yeşil renk paleti | Mavi-turuncu gibi renk körlüğüne uygun palet kullanın |
| 5 | "Grafik 1", "Grafik 2" başlıkları | Her başlık bir bulguyu özetlesin: "Kasım'da ciro %18 arttı" |
| 6 | Hiç filtre yok | En azından tarih aralığı filtresi ekleyin — statik dashboard hızla eskir |
| 7 | Son güncelleme tarihi görünmüyor | Her dashboard'da "son güncelleme: ..." bilgisi zorunlu olmalı — veri tazeliği belirsizse güven azalır |
| 8 | Tüm grafikler eşit büyüklükte | En kritik metriği (örn. toplam ciro) büyük bir "Big Number" kartıyla öne çıkarın |
| 9 (bonus) | 12 grafik, hiyerarşi yok | En fazla 5-7 kart; "önce özet, sonra detay" hiyerarşisi kurun |

## 4.2 Kendi dashboard'unuz

Bu bölüm kişiye özel — beklenen davranış: en az 3-4 maddeyi kendi
dashboard'unuzda tespit edip düzeltmiş olmanız. En sık atlanan madde
genelde **başlık kalitesi** ("Ciro" yerine "Kasım'da ciro %18 arttı")
ve **eksen sıfır noktası**dır.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Pasta grafik | 4'ten fazla dilimde bar grafiğe tercih edin |
| Başlık | Soruya değil, bulguya cevap versin |
| Hiyerarşi | En önemli metrik görsel olarak öne çıkmalı |

**[← Alıştırma 4](../04-dashboard-critique.md)**
