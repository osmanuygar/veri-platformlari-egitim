# ✅ Çözüm 2: Parçalama Stratejilerini Karşılaştırma

## 2.1 Karşılaştırma

Tipik sonuç (Hafta 7 README'si, ~36.000 karakter):

| Strateji | Parça sayısı | Ortalama boyut |
|---|---|---|
| `heading` | ~17 | ~2100 |
| `fixed` (800/100) | ~52 | ~790 |
| `paragraph` | ~27 | ~1330 |

`fixed` en çok parçayı üretir (sabit boyutta böldüğü için), `heading`
en büyük ama en az sayıda parçayı üretir (bazı bölümler uzun).

## 2.2 Ortadan kesilme

`fixed` stratejisiyle üretilen parçaların **çoğunda** bir cümlenin ya
da kod bloğunun ortasından kesildiğini göreceksiniz — 800 karakterlik
sınır, metnin doğal yapısını (cümle, paragraf, kod bloğu sınırları)
hiç dikkate almaz.

Bu chunk, RAG aramasında bulunsa bile, LLM'e verilen bağlam **eksik ve
kafa karıştırıcı** olur — örneğin bir kod örneğinin sadece ilk yarısını
görmek, LLM'in yanlış bir yorum yapmasına yol açabilir.

## 2.3 Başlık bazlı stratejinin avantajı

`chunk_by_heading`'in her parçası bir `##`/`###` başlığında başlar ve
bir sonraki başlıktan hemen önce biter — yani **her parça kendi başına
anlamlı bir "konu birimi"dir**. Bu, 2.2'deki "cümle ortasından kesilme"
sorununu **yapısal olarak** önler çünkü kesim noktaları her zaman yazarın
zaten belirlediği mantıksal sınırlardır.

## 2.4 Uzun bölümlerde seyrelme riski

Evet, **seyrelme (dilution) riski vardır**. Embedding modelleri, bir
metnin **genel anlamsal özünü** tek bir sabit boyutlu vektöre sıkıştırır.
5000 karakterlik bir parçada 3 farklı alt konu varsa, üretilen embedding
bu üç konunun bir **ortalaması/karışımı** gibi davranır — hiçbirini tam
olarak temsil edemez. Bu yüzden, o parçayı tam olarak eşleştirmesi
gereken dar bir soru (örn. sadece alt konulardan birine ait), aramada
düşük bir benzerlik skoru alabilir ve **kaçırılabilir**.

İdeal strateji: önce başlık sınırlarına böl, SONRA her parça belirlenen
bir `max_chars`'ı aşıyorsa, o parçayı da (paragraf sınırlarına saygı
göstererek) alt parçalara ayır — tam olarak Alıştırma 2.5'in istediği
`chunk_hybrid()` fonksiyonu budur.

## 2.5 Örnek `chunk_hybrid()`

```python
def chunk_hybrid(text: str, max_chars: int = 1200, min_chars: int = 200):
    hybrid_chunks = []
    for c in chunk_by_heading(text, min_chars=min_chars):
        if len(c["text"]) <= max_chars:
            hybrid_chunks.append(c)
        else:
            # Uzun bölümü paragraf sınırlarına göre alt parçalara böl
            sub_chunks = chunk_by_paragraph(c["text"], min_chars=min_chars, max_chars=max_chars)
            for i, sc in enumerate(sub_chunks):
                sc["section"] = f"{c['section']} (parça {i+1}/{len(sub_chunks)})"
            hybrid_chunks.extend(sub_chunks)
    return hybrid_chunks
```

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| `fixed` | Basit ama bağlamı rastgele keser |
| `heading` | Anlamsal olarak tutarlı ama boyut değişken |
| Uzun parçada seyrelme | Embedding, birden fazla konuyu "ortalar" — arama hassasiyeti düşer |
| Hibrit strateji | Anlamsal sınır + maksimum boyut birlikte |

**[← Alıştırma 2](../02-chunking-strategies.md)**
