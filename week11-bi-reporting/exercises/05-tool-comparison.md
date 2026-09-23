# Alıştırma 5: Metabase vs Superset — Karşılaştırma Raporu

**Süre:** ~15 dakika · **Format:** Kısa yazılı rapor

---

## 5.1 Deneyiminizi özetleyin

Alıştırma 2 (Metabase) ve Alıştırma 3'ü (Superset) tamamladıktan sonra,
**yarım sayfalık** bir karşılaştırma raporu yazın. En az şu soruları cevaplayın:

1. Hangi araçta ilk dashboard'u kurmak daha hızlıydı?
2. SQL bilmeyen bir iş analisti hangisini daha kolay kullanır?
3. Satır düzeyi güvenlik (RLS) hangisinde daha güçlüydü?
4. Hangi araç, karmaşık çok-tablolu bir soruyu daha rahat ifade etmenizi sağladı?

---

## 5.2 Senaryo bazlı öneri

Üç farklı senaryo için hangi aracı önerirsiniz, neden?

| Senaryo | Önerilen araç | Gerekçe |
|---|---|---|
| 15 kişilik bir startup, teknik olmayan ekip, hızlı self-service istiyor | | |
| 200 kişilik bir kurum, farklı departmanlar farklı veri görmeli (RLS şart) | | |
| Veri ekibi karmaşık SQL yazmayı seviyor, chart çeşitliliği önemli | | |

---

## 5.3 Enterprise karşılığı

Kurumların çoğu açık kaynak değil **Power BI, Tableau veya Looker** kullanıyor.
Bu araçları kurmanız gerekmiyor; README'deki [Alternatifler ve Ekosistem](../README.md#-alternatifler-ve-ekosistem)
bölümünü ve üreticilerin dokümantasyonunu okuyarak cevaplayın:

1. 5.2'deki **200 kişilik kurum** senaryosunda kurum zaten Microsoft 365 kullanıyorsa,
   Superset yerine Power BI seçmek için hangi gerekçeler öne çıkar? Hangi maliyet kalemi
   kararı değiştirebilir?
2. Alıştırma 3'te Superset'te kurduğunuz RLS kuralının Power BI veya Looker'daki karşılığı nedir?
3. Açık kaynak bir BI aracından enterprise bir araca (ya da tersine) geçişte
   **en çok neyi yeniden yapmanız gerekir?** (dashboard'lar, metrik tanımları, yetkiler…)

---

## ✅ Ne öğrendik

- Araç seçimi "hangisi daha iyi" değil, "**hangi ekip, hangi ihtiyaç**"
  sorusuna bağlıdır.
- Basitlik (Metabase) ile güç/esneklik (Superset) arasında gerçek bir ödünleşme var.
- Bir BI aracını sadece özellik listesine bakarak değil, **gerçekten
  kullanarak** karşılaştırmak çok daha güvenilir bir karar verdirir.
- Açık kaynak ile enterprise arasındaki seçim çoğu zaman özellikten değil, **mevcut
  ekosistem, lisans modeli ve geçiş maliyetinden** belirlenir.

📎 [Çözüm](./solutions/05-tool-comparison.md)
