# 📋 Ollama Cheatsheet

```bash
alias oll='docker exec week13_ollama ollama'
```

---

## 📦 Model Yönetimi

```bash
oll pull llama3.2:1b          # model indir
oll pull nomic-embed-text     # embedding modeli indir
oll list                      # kurulu modeller
oll rm llama3.2:1b            # sil (disk boşalt)
oll ps                        # şu an belleğe yüklü modeller
```

| Model | Boyut | Ne için |
|---|---|---|
| `nomic-embed-text` | ~274 MB | Embedding (RAG için) |
| `llama3.2:1b` | ~1.3 GB | Genel sohbet, düşük donanım |
| `llama3.2:3b` | ~2 GB | Daha iyi kalite, orta donanım |
| `qwen2.5:0.5b` | ~350 MB | En hafif, hızlı test |
| `phi3:mini` | ~2.2 GB | Microsoft'un küçük modeli, güçlü |

---

## 💬 CLI'dan Sohbet

```bash
docker exec -it week13_ollama ollama run llama3.2:1b
>>> Merhaba, Kafka nedir?
>>> /bye    # çıkış
```

---

## 🌐 REST API

```bash
# Sohbet
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [{"role": "user", "content": "Merhaba"}],
  "stream": false
}'

# Embedding
curl http://localhost:11434/api/embed -d '{
  "model": "nomic-embed-text",
  "input": "Kafka bir dağıtık log sistemidir"
}'

# Model bilgisi
curl http://localhost:11434/api/show -d '{"model": "llama3.2:1b"}'
```

---

## 🐍 Python İstemcisi

```python
import ollama
client = ollama.Client(host="http://localhost:11434")

# Sohbet
resp = client.chat(model="llama3.2:1b", messages=[
    {"role": "system", "content": "Sen yardımsever bir asistansın."},
    {"role": "user", "content": "Merhaba"},
])
print(resp.message.content)

# Embedding (batch destekler!)
resp = client.embed(model="nomic-embed-text", input=["metin 1", "metin 2"])
print(len(resp.embeddings), len(resp.embeddings[0]))  # 2, 768

# Streaming
for chunk in client.chat(model="llama3.2:1b", messages=[...], stream=True):
    print(chunk.message.content, end="", flush=True)
```

---

## ⚙️ Önemli Parametreler

```python
client.chat(model="llama3.2:1b", messages=[...], options={
    "temperature": 0.2,   # düşük = daha tutarlı/deterministik, RAG için önerilir
    "num_ctx": 4096,      # bağlam penceresi boyutu
    "top_p": 0.9,
})
```

| Parametre | Etki |
|---|---|
| `temperature` | 0 = her zaman en olası cevap, 1+ = daha "yaratıcı"/rastgele |
| `num_ctx` | Modelin "hafızasındaki" token sayısı — RAG bağlamı büyükse artırın |
| `top_p` | Nucleus sampling eşiği |

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `model not found` | Model indirilmemiş | `ollama pull <model>` |
| Çok yavaş yanıt | CPU'da büyük model çalışıyor | Daha küçük model seçin (`1b`, `0.5b`) |
| `connection refused` | Container henüz hazır değil | `docker compose ps`, healthcheck bekleyin |
| Bellek yetersiz / container OOM | Model + Postgres + Qdrant birlikte çok RAM istiyor | Docker belleğini artırın (≥6 GB) ya da daha küçük model kullanın |

---

**[← Hafta 13 README](../README.md)** · **[pgvector Cheatsheet →](./pgvector-cheatsheet.md)**
