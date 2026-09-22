# ✅ Çözüm 4: pgvector vs Qdrant

## 4.1-4.2 Yükleme ve karşılaştırma

Nokta sayısı iki sistemde de **aynı** olmalı (pgvector'daki tüm satırlar
kopyalanır). Süre karşılaştırmasında, bu küçük veri setinde (~200-300
parça) her iki motor da **milisaniyeler** mertebesinde yanıt verir —
aradaki fark bu ölçekte **anlamlı bir sonuç çıkarmak için çok küçüktür**;
gerçek bir performans farkı, milyonlarca vektörlük veri setinde ortaya
çıkar.

## 4.3 Neden sonuçlar farklı olabilir

HNSW gibi ANN (Approximate Nearest Neighbor) indeksleri, **kesin** en
yakın komşuyu bulmak yerine, çok yüksek olasılıkla doğru olan ama
**garantisi olmayan** bir yaklaşık sonuç üretir — bu, aramayı büyük
ölçüde hızlandıran bilinçli bir tasarım tercihidir. pgvector'ın HNSW
parametreleri ile Qdrant'ın HNSW parametreleri (varsayılan `ef`, `m`
değerleri gibi) farklı olabilir, bu da sınırda kalan (marjinal) sonuçlarda
küçük farklılıklara yol açabilir. Ayrıca küçük veri setlerinde pgvector
indeks bile kullanmayıp tam tarama (exact scan) yapıyor olabilir —
bu durumda pgvector sonucu **kesin**, Qdrant'ınki **yaklaşık** olabilir.

## 4.4 Filtreli arama

pgvector'da aynı filtre:

```sql
SELECT chunk_text, embedding <=> %s::vector AS distance
FROM ai.course_chunks
WHERE week_no = 13
ORDER BY distance LIMIT 3;
```

Performans farkı: pgvector, önce `WHERE week_no = 13` ile satırları
daraltıp SONRA (ya da sorgu planlayıcısına bağlı olarak eş zamanlı)
vektör mesafesini hesaplar — büyük tablolarda bu, planlayıcının seçtiği
stratejiye (indeks kullanımı, sıralama) bağlı olarak değişken performans
gösterebilir. Qdrant, filtre + vektör aramasını **tek bir HNSW geçişinde,
özel olarak optimize edilmiş** şekilde yapar — filtrelenmiş bir alt kümede
bile HNSW indeksinin verimliliğini büyük ölçüde korur. Büyük ölçekte
(milyonlarca nokta, seçici filtreler) bu fark **belirgin** hale gelir.

## 4.5 Ölçek düşüncesi

**pgvector'ın avantajı:** Zaten Postgres kullanan bir organizasyonda ek
bir sistem kurmaya, işletmeye, yedeklemeye gerek kalmaz. Vektör araması,
diğer ilişkisel verilerle (müşteri tablosu, sipariş geçmişi) **aynı
sorguda JOIN edilebilir** — Qdrant'ta bu mümkün değildir, veriyi iki
sistem arasında senkronize etmeniz gerekir.

**Qdrant'ın avantajı:** Milyarlarca vektöre özel olarak tasarlanmış
dağıtık mimarisi, sharding, replikasyon ve gelişmiş filtreleme
özellikleriyle, yüksek hacimli, vektör-öncelikli iş yüklerinde çok daha
iyi ölçeklenir ve daha düşük gecikmeyle çalışır.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Küçük veri setinde | Performans farkı anlamsız, mimari farkları önemli |
| ANN indeksi | Hız için kesinlikten bilinçli feragat |
| Filtreli vektör arama | Qdrant'ın güçlü olduğu bir alan |
| Araç seçimi | Mevcut altyapı + ölçek + hibrit sorgu ihtiyacına göre |

**[← Alıştırma 4](../04-vector-db-comparison.md)**
