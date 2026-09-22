# Alıştırma 2: Parçalama Stratejilerini Karşılaştırma

**Süre:** ~30 dakika · **Dosya:** `scripts/chunking.py`

---

## 2.1 Üç stratejiyi çalıştırın

```python
from scripts.chunking import find_week_readmes, chunk_by_heading, chunk_by_fixed_size, chunk_by_paragraph

files = find_week_readmes()
text = files[6].read_text(encoding="utf-8")  # Hafta 7 - Kafka

for name, fn in [("heading", chunk_by_heading), ("fixed", chunk_by_fixed_size), ("paragraph", chunk_by_paragraph)]:
    chunks = fn(text)
    sizes = [len(c["text"]) for c in chunks]
    print(f"{name}: {len(chunks)} parça, ort={sum(sizes)//len(sizes)}, min={min(sizes)}, max={max(sizes)}")
```

**Görev:** Üç stratejinin parça sayısını ve ortalama boyutunu karşılaştırın.

---

## 2.2 Bir parçanın ortasından kesilme riski

```python
fixed_chunks = chunk_by_fixed_size(text, size=800, overlap=100)
for c in fixed_chunks[:5]:
    print(repr(c["text"][:80]))
    print("...")
    print(repr(c["text"][-80:]))
    print("---")
```

**Görev:** En az bir chunk'ın bir cümlenin ya da kod bloğunun **ortasından**
kesildiğini bulun.

**Soru:** Bu chunk, RAG aramasında bulunsa bile, LLM'e verilen bağlam
ne kadar **anlaşılır** olur? Cümlenin yarısı, tam bağlamı taşır mı?

---

## 2.3 Başlık bazlı stratejinin avantajı

```python
heading_chunks = chunk_by_heading(text)
for c in heading_chunks[:3]:
    print(c["section"], "->", len(c["text"]), "karakter")
```

**Soru:** `chunk_by_heading`'in ürettiği her parça, doğal olarak nerede
başlayıp nerede bitiyor? Bu, hangi RAG sorununu (2.2'deki) yapısal olarak önlüyor?

---

## 2.4 Başlık stratejisinin kendi sorunu

**Düşünce deneyi:** Hafta 7'nin "2.4 Sızıntılı..." gibi bir bölümü **çok
uzunsa** (örn. 5000 karakter), `chunk_by_heading` bunu **tek bir dev
parça** olarak bırakır.

**Soru:** Bu parça, embedding modeline verildiğinde ne olur — embedding,
parçanın **tüm** içeriğini eşit ağırlıkla mı temsil eder, yoksa uzun
parçalarda "seyrelme" (dilution) riski var mı? İdeal bir chunking
stratejisi hem başlık sınırlarına hem de bir **maksimum boyuta** nasıl
saygı gösterebilir?

---

## 2.5 Kendi stratejinizi tasarlayın

**Görev:** `chunking.py`'ye, başlık sınırlarına saygı gösteren AMA çok
uzun bölümleri de alt parçalara bölen bir `chunk_hybrid()` fonksiyonu
yazın (ipucu: önce `chunk_by_heading`, sonra her parçayı `max_chars`'ı
aşıyorsa `chunk_by_paragraph` ile tekrar bölün).

---

## ✅ Ne öğrendik

- Sabit boyutlu (fixed) parçalama en basittir ama bağlamı rastgele keser.
- Başlık bazlı parçalama daha anlamlıdır ama parça boyutu tutarsız olabilir
  (çok kısa ya da çok uzun parçalar).
- Gerçek dünya RAG sistemleri genelde **hibrit** stratejiler kullanır:
  anlamsal sınırlara (başlık, paragraf) saygı gösterip, gerektiğinde
  ek olarak boyut sınırı da uygularlar.
- Chunking kararı, RAG kalitesinin belki de **en az konuşulan ama en
  etkili** parametresidir.

📎 [Çözüm](./solutions/02-chunking-strategies.md)
