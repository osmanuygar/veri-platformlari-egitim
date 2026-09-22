# ✅ Çözüm 2: Metabase Dashboard

## 2.2 Aylık ciro trendi

Kasım-Aralık aylarında ciro/sipariş sayısında görünür bir artış olmalı —
`init/02-sample-data.sql`'deki veri üretim mantığı bu aylarda işlem
olasılığını (`0.35 → 0.55`) kasıtlı olarak yükseltiyor. Bu, gerçek
e-ticaret verilerindeki "kampanya sezonu" (Kasım'daki indirim günleri,
yılbaşı alışverişi) etkisini simüle eder.

## 2.5 Filtre bağlama

Bir dashboard filtresi bir karta **bağlanmazsa**, o kart filtre
değiştiğinde **hiç güncellenmez** — eski, filtrelenmemiş veriyi göstermeye
devam eder. Bu genelde fark edilmeyen bir hatadır: dashboard'u kullanan
kişi filtreyi değiştirdiğini düşünür ama bazı kartlar sessizce eski veriyi
gösterir.

Metabase'de her kartı elle bağlamanız gerekmesinin sebebi, Metabase'in
**basitlik önceliğiyle** tasarlanmış olmasıdır — her filtrenin her karta
otomatik uygulanması, bazı kartların o filtreyle **hiç ilgisi olmayan**
bir tablodan gelmesi durumunda (örn. bir "toplam çalışan sayısı" kartı,
"tarih aralığı" filtresinden etkilenmemeli) yanlış davranışa yol açabilir.
Superset'in Native Filters'ı bu riski, "hangi chart'lara uygulanacağını"
filtre bazında **ayarlanabilir** yaparak çözer (varsayılan: hepsine, ama
değiştirilebilir).

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Metabase soru | Agregasyon + gruplama + filtre, SQL gerektirmez |
| Filtre bağlama | Her karta elle yapılmalı — unutulursa sessiz hata |

**[← Alıştırma 2](../02-metabase-dashboard.md)**
