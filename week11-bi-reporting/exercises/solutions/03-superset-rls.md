# ✅ Çözüm 3: Superset + Satır Düzeyi Güvenlik

## 3.3 Native Filter davranışı

Superset'te bir Native Filter eklendiğinde **varsayılan olarak dashboard'daki
tüm chart'lara** uygulanır — Metabase'deki gibi her chart'a elle bağlama
adımı gerekmez. İsterseniz filtre ayarlarından belirli chart'ları hariç
tutabilirsiniz, ama varsayılan davranış "hepsine uygula"dır. Bu, Superset'in
daha "kurumsal/hazır kullanım" odaklı tasarımının bir yansımasıdır.

## 3.4 RLS kuralının etkisi

`marmara_muduru` ile giriş yapıldığında, **aynı dashboard, aynı chart'lar**
görünür ama verinin kendisi otomatik olarak Marmara bölgesiyle sınırlanır.
Bu, dashboard'un **tasarımından tamamen bağımsız** çalışır — RLS kuralı,
Superset'in her SQL sorgusuna kullanıcıya özel bir `WHERE` koşulu ekleyerek
çalışır; dashboard'u tasarlayan kişi bunu bilmek zorunda bile değildir.

## 3.5 RLS'nin ölçeklenebilirlik avantajı

"Her bölge için ayrı dashboard" yaklaşımının maliyeti **doğrusal değil
katlanarak** artar: 10 bölge = 10 ayrı dashboard, her biri ayrı ayrı
güncellenmeli, her yeni chart 10 kez eklenmeli, her tasarım değişikliği
10 kez uygulanmalı. RLS ile **tek bir dashboard** vardır; veri erişimi
kullanıcı bazında otomatik ayarlanır. Bu, "tek kaynak, çok görünüm" (single
source of truth) prensibinin BI'daki karşılığıdır — hafta 12'deki veri
yönetişimi ile doğrudan ilişkilidir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Superset Native Filter | Varsayılan olarak tüm chart'lara otomatik uygulanır |
| RLS | Dashboard tasarımından bağımsız, sorgu seviyesinde çalışır |
| RLS'nin avantajı | N ayrı dashboard yerine 1 dashboard + N erişim kuralı |

**[← Alıştırma 3](../03-superset-rls.md)**
