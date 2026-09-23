# ✅ Çözüm 5: Metabase vs Superset — Karşılaştırma Raporu

## 5.2 Senaryo bazlı öneri

| Senaryo | Önerilen araç | Gerekçe |
|---|---|---|
| 15 kişilik startup, teknik olmayan ekip | **Metabase** | Kurulumu ve öğrenme eğrisi çok daha kolay; SQL bilmeden self-service sağlanır |
| 200 kişilik kurum, RLS şart | **Superset** | RLS yerleşik ve güçlü (Metabase'de Enterprise sürüm gerekir); büyük ekiplerde ölçeklenebilirlik önemli |
| Karmaşık SQL, geniş chart çeşitliliği | **Superset** | SQL Lab + Jinja şablonlama + 40'tan fazla chart türü, teknik ekip için çok daha esnek |

Genel prensip: **Metabase basitlik ve hız için, Superset güç ve kontrol
için** optimize edilmiştir. "Hangisi daha iyi" evrensel bir cevap değildir
— ekibin teknik olgunluğu ve gereksinimlerin karmaşıklığı belirleyicidir.

---

## 5.3 Enterprise karşılığı

**1. Microsoft 365 kullanan 200 kişilik kurum → Power BI gerekçeleri**

- Entra ID (Azure AD) ile tek oturum ve grup bazlı yetki kutudan çıkar; kullanıcılar
  Teams/SharePoint içinde rapora ulaşır.
- Excel kullanıcıları için tanıdık arayüz ve "Excel'de analiz et" özelliği → self-service'e geçiş kolaylaşır.
- Kurumun mevcut Microsoft sözleşmesinde lisanslar zaten olabilir; o zaman ek maliyet düşük olur.
- **Kararı değiştirebilecek maliyet:** kullanıcı başı lisans. Rapor *görüntüleyen* herkesin
  lisansa ihtiyacı olabilir; yüzlerce görüntüleyicide bu, Superset'i işletmek için gereken
  altyapı + mühendis maliyetini aşabilir (ya da aşmayabilir — hesaplanmalı).

**2. RLS karşılıkları**

| Araç | RLS nasıl tanımlanır |
|---|---|
| Superset | Row Level Security kuralı: tablo + rol + SQL filtre (`region = '{{ current_username() }}'` gibi) |
| Power BI | Semantik modelde **rol** + DAX filtre ifadesi (`[Region] = USERPRINCIPALNAME()` veya eşleme tablosu); kullanıcılar role Power BI Service'te atanır |
| Looker | LookML'de `access_filter` + kullanıcı özniteliği (user attribute) |

Kavram aynı: **kullanıcı kimliği → filtre koşulu**. Değişen sadece nerede ve hangi dilde yazıldığı.

**3. Geçişte yeniden yapılan işler**

- **Dashboard ve grafikler** neredeyse her zaman sıfırdan kurulur; araçlar arasında taşıma formatı yoktur.
- **Metrik tanımları** BI aracının içindeyse (Superset dataset metriği, Power BI DAX ölçüsü)
  yeniden yazılır. Tanımlar **ambarda veya semantik katmanda** (dbt, Cube) yaşıyorsa
  geçiş çok daha ucuzdur. Vendor lock-in'e karşı en iyi sigorta budur.
- **Yetki ve RLS kuralları** yeni aracın modeliyle yeniden tanımlanır.
- **Kullanıcı eğitimi** genellikle en çok gözden kaçan maliyettir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Araç seçimi | Ekip + gereksinim karmaşıklığına göre, "en iyi" tek cevap yok |
| Metabase | Hız ve basitlik |
| Superset | Güç, esneklik, kurumsal özellikler (RLS gibi) |
| Enterprise BI | Ekosistem uyumu ve destek; maliyet kullanıcı başı lisansla ölçeklenir |
| Geçiş maliyeti | Metrik tanımlarını BI aracının dışında tutmak lock-in'i azaltır |

**[← Alıştırma 5](../05-tool-comparison.md)**
