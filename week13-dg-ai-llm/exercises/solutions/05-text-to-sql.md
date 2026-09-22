# ✅ Çözüm 5: Text-to-SQL ve Risk Analizi

## 5.1-5.2 Basit ve karmaşık sorular

"Kaç müşteri var?" için model genelde `SELECT count(*) FROM shop.customers;`
gibi doğru bir sorgu üretir. "En çok harcama yapan müşteri" sorusu için
model `shop.customers` → `shop.orders` → `shop.order_items` JOIN
zincirini kurmalı ve `quantity * unit_price` ile toplam harcamayı
hesaplamalıdır — bu, modelin sadece sözdizimini değil **şemadaki
ilişkileri de** doğru yorumlamasını gerektirir.

Model bu JOIN yapısını **`SYSTEM_PROMPT`'taki şema açıklamasından**
öğrenir — özellikle `->` ile belirtilen foreign key ilişkilerinden
(`customer_id -> shop.customers.id` gibi). Şema açıklaması ne kadar
net ve eksiksizse, modelin doğru SQL üretme olasılığı o kadar yüksektir
— bu, "prompt mühendisliğinin" text-to-SQL'deki en kritik uygulamasıdır.

## 5.3 Prompt injection denemesi

`validate_sql()` bunu **yakalamalıdır** — ya modelin ürettiği metinde
`DROP` kelimesi `FORBIDDEN` regex'ine takılır, ya da model iki ayrı
ifade (`;` ile ayrılmış) üretirse "birden fazla ifade" kontrolüne takılır.

Bu doğrulama olmasaydı, `cur.execute()` doğrudan hem SELECT'i hem
DROP'u çalıştırabilirdi (psycopg2 varsayılan olarak birden fazla ifadeyi
tek `execute()` çağrısında çalıştırmaz ama bazı sürücüler/konfigürasyonlar
buna izin verebilir) — tablo **kalıcı olarak silinirdi**.

Bu risk, klasik SQL injection'ın **aynı ailesindendir** ama kaynağı
farklıdır: klasik SQL injection kullanıcı girdisinin sorguya **doğrudan
string birleştirmeyle** karışmasından gelir; burada risk, LLM'in
**kendisinin** (kullanıcı isteğine kanarak ya da hata yaparak) zararlı
SQL üretmesinden gelir — savunma stratejisi benzer olsa da (girdiyi asla
güvenme, doğrula), tehdit kaynağı insan değil modelin kendisidir.

## 5.4 Doğrulamanın sınırları

**Hayır, mevcut `validate_sql()` bunu yakalamaz** — "SELECT ile başlıyor,
yasaklı kelime yok" testini geçen ama `LIMIT` içermeyen, potansiyel
olarak milyonlarca satır döndürecek bir sorgu **geçerli** sayılır.

Ek kontroller:
- **`LIMIT` zorunluluğu:** Sorgu bir `LIMIT` içermiyorsa otomatik ekleyin
  ya da reddedin.
- **`EXPLAIN` ile önceden maliyet tahmini:** Sorguyu çalıştırmadan önce
  `EXPLAIN` ile tahmini satır sayısını/maliyetini kontrol edin, eşiği
  aşarsa reddedin.
- **Zaman aşımı (statement_timeout):** Veritabanı bağlantısında bir
  sorgu süre sınırı ayarlayın.

## 5.5 `readonly=True` neden hâlâ gerekli

Regex tabanlı kontroller **kırılgandır** — örneğin model, yasaklı
kelimeyi farklı bir case'de (`DrOp`), bir yorum içine gizleyerek, ya da
regex'in öngörmediği bir PostgreSQL özel sözdizimiyle (örn. bir fonksiyon
çağrısı içinde gizli bir yan etki) yazabilir. Regex, **bilinen** kalıpları
yakalar; **bilinmeyen** bir bypass'ı yakalayamayabilir.

`conn.set_session(readonly=True)`, bu riski **veritabanı motorunun
kendisi** üzerinden kapatır — uygulama kodundaki bir hata/eksiklik olsa
bile, PostgreSQL bağlantı seviyesinde herhangi bir yazma işlemini
zaten reddeder. Bu, **derinlemesine savunma** (defense in depth) ilkesinin
somut bir uygulamasıdır: tek bir katmana güvenmeyin.

## 5.6 Genel değerlendirme

Text-to-SQL, **insan onayı olmadan** production'a konulmamalıdır — en
azından ilk aşamada. Zorunlu ek katmanlar:
- Sorgu maliyeti/satır sayısı sınırı
- Sadece belirli, önceden onaylanmış şema/tablolara erişim (ayrıca
  salt-okunur, sınırlı yetkili bir DB kullanıcısıyla)
- "Dry-run" modu: üretilen SQL'i önce insana göster, onay bekle, SONRA çalıştır
- Denetim izi (hafta 12'deki audit trail): kim, hangi soruyu sordu,
  hangi SQL üretildi, çalıştırıldı mı

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| LLM üretimi SQL | Asla doğrudan çalıştırılmaz, her zaman doğrulanır |
| Katmanlı savunma | Uygulama seviyesi + veritabanı seviyesi birlikte |
| Regex kırılganlığı | Bilinmeyen bypass'lara karşı tek başına yetersiz |
| Production kullanımı | İnsan onayı + maliyet sınırı + audit trail olmadan önerilmez |

**[← Alıştırma 5](../05-text-to-sql.md)**
