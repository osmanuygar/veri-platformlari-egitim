# 📋 pgvector Cheatsheet

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

---

## 🗂 Tablo ve Tip

```sql
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding VECTOR(768)   -- boyut, embedding modelinizle EŞLEŞMELİ
);
```

| Model | Boyut |
|---|---|
| `nomic-embed-text` (Ollama) | 768 |
| OpenAI `text-embedding-3-small` | 1536 |
| OpenAI `text-embedding-3-large` | 3072 |

---

## 📏 Mesafe Operatörleri

```sql
embedding <-> '[1,2,3]'   -- Öklid (L2) mesafesi
embedding <#> '[1,2,3]'   -- negatif iç çarpım (inner product)
embedding <=> '[1,2,3]'   -- kosinüs mesafesi (1 - kosinüs benzerliği)
```

**Metin embedding'lerinde standart tercih `<=>` (kosinüs)** — vektörün
yönü önemlidir, büyüklüğü (uzunluğu) genelde önemsizdir.

```sql
-- Benzerliğe (0-1, yüksek=daha benzer) çevirmek için:
1 - (embedding <=> '[...]') AS similarity
```

---

## 🔍 En Yakın Komşu Araması (KNN)

```sql
SELECT content, embedding <=> '[0.1, 0.2, ...]' AS distance
FROM items
ORDER BY distance
LIMIT 5;
```

---

## ⚡ İndeksleme: HNSW vs IVFFlat

```sql
-- HNSW (Hierarchical Navigable Small World) — ÖNERİLEN
CREATE INDEX ON items USING hnsw (embedding vector_cosine_ops);

-- IVFFlat — daha az bellek, ama build sırasında veri gerektirir
CREATE INDEX ON items USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
```

| | HNSW | IVFFlat |
|---|---|---|
| Arama hızı | Daha hızlı | Orta |
| İndeks build süresi | Daha yavaş | Daha hızlı |
| Bellek kullanımı | Daha yüksek | Daha düşük |
| Veri eklenmeden build edilebilir mi | Evet | Hayır (kümeleri veriden öğrenir) |

Küçük veri setlerinde (<10K satır) indeks olmadan da hızlıdır — bu
haftaki ~200-300 chunk'lık ders notu veri setinde HNSW'nin farkı
gözle görülmez, ama milyonlarca satırda indekssiz arama saniyeler sürer.

---

## 🐍 Python'dan Kullanım

```python
from pgvector.psycopg2 import register_vector
import psycopg2

conn = psycopg2.connect(...)
register_vector(conn)   # Python list <-> VECTOR dönüşümünü otomatikleştirir

with conn.cursor() as cur:
    cur.execute(
        "INSERT INTO items (content, embedding) VALUES (%s, %s)",
        ("merhaba dünya", [0.1, 0.2, ...])   # düz Python list yeterli
    )

    # Arama: register_vector conn seviyesinde ama sorgu parametresinde
    # açık cast (::vector) gerekir
    cur.execute(
        "SELECT content FROM items ORDER BY embedding <=> %s::vector LIMIT 5",
        (query_embedding,)
    )
```

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `operator does not exist: vector <=> numeric[]` | Sorgu parametresi cast edilmemiş | `%s::vector` kullanın |
| `expected N dimensions, not M` | Embedding boyutu tablo tanımıyla uyuşmuyor | Model değiştiyse tabloyu da güncelleyin |
| `object of type 'Vector' has no len()` | `register_vector` sonrası okunan değer `Vector` nesnesi | `.to_list()` ile Python listesine çevirin |
| Arama çok yavaş | İndeks yok, büyük tablo | `CREATE INDEX ... USING hnsw` |

---

**[← Ollama Cheatsheet](./ollama-cheatsheet.md)** · **[Qdrant Cheatsheet →](./qdrant-cheatsheet.md)**
