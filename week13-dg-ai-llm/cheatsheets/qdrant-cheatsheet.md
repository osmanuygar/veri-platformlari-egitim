# 📋 Qdrant Cheatsheet

Dashboard: **http://localhost:6333/dashboard**

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

client = QdrantClient(url="http://localhost:6333")
```

---

## 🗂 Koleksiyon Oluşturma

```python
client.create_collection(
    collection_name="course_chunks",
    vectors_config=VectorParams(size=768, distance=Distance.COSINE),
)

client.collection_exists("course_chunks")   # var mı kontrol et
client.delete_collection("course_chunks")   # sil
client.get_collection("course_chunks")      # detay bilgisi
```

`Distance` seçenekleri: `COSINE`, `EUCLID`, `DOT`.

---

## 📤 Veri Yükleme (Upsert)

```python
client.upsert(
    collection_name="course_chunks",
    points=[
        PointStruct(id=1, vector=[0.1, 0.2, ...], payload={"week_no": 7, "section": "Kafka Mimarisi"}),
        PointStruct(id=2, vector=[0.3, 0.1, ...], payload={"week_no": 6, "section": "dbt"}),
    ],
)
```

`payload`, ham metadata'dır — SQL'deki diğer sütunlar gibi düşünün.
Filtrelenebilir ve sonuçla birlikte döner.

---

## 🔍 Arama

```python
results = client.query_points(
    collection_name="course_chunks",
    query=[0.15, 0.18, ...],   # sorgu embedding'i
    limit=5,
).points

for p in results:
    print(p.id, p.score, p.payload["section"])
```

### Filtreli arama (metadata + vektör birlikte)

```python
from qdrant_client.models import Filter, FieldCondition, MatchValue

results = client.query_points(
    collection_name="course_chunks",
    query=[0.15, 0.18, ...],
    query_filter=Filter(
        must=[FieldCondition(key="week_no", match=MatchValue(value=7))]
    ),
    limit=5,
).points
```

Bu, "sadece Hafta 7'nin içinde ara" gibi bir hibrit sorguyu tek çağrıda yapar
— pgvector'da bunu `WHERE week_no = 7 ORDER BY embedding <=> ...` ile
yapardınız; Qdrant'ta filtre + vektör araması **aynı indekste optimize
edilmiş** şekilde çalışır.

---

## 🆚 pgvector ile Karşılaştırma

| | pgvector | Qdrant |
|---|---|---|
| Kurulum | Mevcut Postgres'e eklenti | Ayrı bir servis |
| SQL join'leriyle birleştirme | Doğal (aynı veritabanında) | Mümkün değil (ayrı sistem) |
| Filtreli vektör arama performansı | İyi, ama SQL planlayıcısına bağlı | Özel optimize edilmiş |
| Ölçek | Postgres'in ölçeğiyle sınırlı | Milyarlarca vektöre özel tasarlanmış |
| Ne zaman | Zaten Postgres kullanıyorsanız, orta ölçek | Yüksek hacim, vektör-öncelikli iş yükü |

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `Collection doesn't exist` | Henüz oluşturulmamış | `create_collection` çağırın |
| `Vector dimension error` | Boyut uyuşmazlığı | `VectorParams(size=...)` embedding modeliyle eşleşmeli |
| `recreate_collection is deprecated` | Eski API kullanılıyor | `collection_exists` + `create_collection`/`delete_collection` |
| Dashboard boş | Hiç veri yüklenmedi | `python scripts/qdrant_demo.py --load` |

---

**[← pgvector Cheatsheet](./pgvector-cheatsheet.md)** · **[Hafta 13 README →](../README.md)**
