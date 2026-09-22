# 📝 Hafta 13 Alıştırmaları

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Yerel Model Çalıştırma](./01-local-model.md) | 20 dk | Ollama, model boyutu, hız |
| 2 | [Parçalama Stratejilerini Karşılaştırma](./02-chunking-strategies.md) | 30 dk | Chunk boyutu, bağlam bütünlüğü |
| 3 | [Uçtan Uca RAG](./03-rag-pipeline.md) | 40 dk | Embedding, arama, üretim |
| 4 | [pgvector vs Qdrant](./04-vector-db-comparison.md) | 25 dk | Performans, mimari farkları |
| 5 | [Text-to-SQL ve Risk Analizi](./05-text-to-sql.md) | 30 dk | Doğrulama katmanı, güvenlik |

**Ön koşul:** `./setup-week13.sh` çalıştı (Ollama modelleri indirildi) ve
`pip install -r requirements.txt` yapıldı.

```bash
docker compose ps
curl -s http://localhost:11434/api/tags | python3 -m json.tool
```

---

**[← Hafta 13 README](../README.md)**
