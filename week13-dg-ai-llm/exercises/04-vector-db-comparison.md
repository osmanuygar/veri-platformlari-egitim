# Alıştırma 4: pgvector vs Qdrant

**Süre:** ~25 dakika · **Dosya:** `scripts/qdrant_demo.py`

---

## 4.1 Qdrant'a yükleyin

```bash
python scripts/qdrant_demo.py --load
open http://localhost:6333/dashboard
```

**Görev:** Dashboard'da `course_chunks` koleksiyonunu bulun, nokta
sayısını (`points_count`) pgvector'daki satır sayısıyla karşılaştırın.

---

## 4.2 Karşılaştırmalı arama

```bash
python scripts/qdrant_demo.py --query "Great Expectations ile veri kalitesi nasıl kontrol edilir?"
```

**Görev:** İki motorun bulduğu sonuçları ve süreleri (ms) not edin.

| Motor | Süre (ms) | Bulunan haftalar |
|---|---|---|
| Qdrant | | |
| pgvector | | |

---

## 4.3 Sonuçlar neden (hafifçe) farklı olabilir

**Soru:** İki motor da **aynı** embedding vektörlerini kullanıyor, aynı
kosinüs mesafesini hesaplıyor. Yine de bulunan sonuçlar bazen tam olarak
aynı olmayabilir. Bunun olası bir sebebi nedir? (İpucu: HNSW gibi ANN
indeksleri "yaklaşık" en yakın komşuyu bulur, %100 kesin değildir —
hız için küçük bir doğruluk feragati yapılır.)

---

## 4.4 Filtreli arama (sadece Qdrant'ta kolay)

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Filter, FieldCondition, MatchValue

client = QdrantClient(url="http://localhost:6333")
results = client.query_points(
    collection_name="course_chunks",
    query=[...],  # bir soru embedding'i
    query_filter=Filter(must=[FieldCondition(key="week_no", match=MatchValue(value=13))]),
    limit=3,
).points
```

**Görev:** "Sadece Hafta 13 içinde ara" filtresini deneyin.

**Soru:** Aynı filtreyi pgvector'da nasıl yapardınız (`WHERE week_no = 13`
ekleyerek)? İki yaklaşım arasında **performans** açısından bir fark
bekler misiniz — Qdrant'ın filtre + vektör aramasını "aynı indekste"
optimize etmesi ne anlama gelir?

---

## 4.5 Ölçek düşüncesi

**Soru:** Bu haftaki veri seti ~200-300 parça. Gerçek bir kurumsal RAG
sisteminde milyonlarca doküman parçası olabilir. Bu ölçekte:
- pgvector'ın avantajı ne olurdu? (İpucu: zaten var olan Postgres altyapısı, join'ler)
- Qdrant'ın avantajı ne olurdu? (İpucu: özel optimize edilmiş indeksleme, dağıtık ölçekleme)

---

## ✅ Ne öğrendik

- pgvector ve Qdrant, aynı temel problemi (vektör benzerlik araması)
  farklı mimarilerle çözer — biri "mevcut veritabanına eklenti", diğeri
  "sıfırdan özel sistem".
- ANN (Approximate Nearest Neighbor) indeksleri, %100 kesinlik yerine
  hız kazandırır — bu bir hata değil, bilinçli bir tasarım tercihidir.
- Filtreli vektör arama (hibrit arama), özel amaçlı vektör veritabanlarının
  güçlü olduğu bir alandır.
- Araç seçimi, ölçek ve mevcut altyapıya göre değişir — "her zaman X"
  diye bir kural yoktur.

📎 [Çözüm](./solutions/04-vector-db-comparison.md)
