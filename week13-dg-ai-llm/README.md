# Hafta 13: AI ve LLM Çağında Veri Platformları

> 🟥 **İzlek:** Veri Yönetişimi (DG) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2.5 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [LLM Çağında Veri Platformu](#1-llm-çağında-veri-platformu)
3. [Gömme (Embedding) ve Vektör Arama](#2-gömme-embedding-ve-vektör-arama)
4. [Vektör Veritabanları](#3-vektör-veritabanları)
5. [RAG Mimarisi](#4-rag-mimarisi)
6. [Text-to-SQL](#5-text-to-sql)
7. [Yerel Model Çalıştırma](#6-yerel-model-çalıştırma)
8. [AI Çağında Yönetişim](#7-ai-çağında-yönetişim)
9. [Alternatifler ve Ekosistem](#-alternatifler-ve-ekosistem)
10. [Hızlı Başlangıç](#-hızlı-başlangıç)
11. [Pratik Uygulamalar](#-pratik-uygulamalar)
12. [Alıştırmalar](#-alıştırmalar)
13. [Cheatsheet](#-cheatsheet)
14. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

- [ ] LLM'lerin veri platformlarını nasıl değiştirdiğini somut örneklerle açıklamak
- [ ] Gömme (embedding) ve vektör veritabanı mantığını kavramak
- [ ] pgvector ve Qdrant ile benzerlik araması yapmak
- [ ] Uçtan uca bir RAG (Retrieval-Augmented Generation) hattı kurmak
- [ ] Text-to-SQL çözümlerinin gücünü ve sınırlarını değerlendirmek
- [ ] AI çağında veri yönetişimi risklerini (sızıntı, halüsinasyon, telif) yönetmek

---

## 1. LLM Çağında Veri Platformu

### 1.1 Yapılandırılmamış verinin yeniden değerlenmesi

Hafta 1'de veriyi yapısal/yarı-yapısal/yapısal olmayan diye sınıflandırmıştık.
2020 öncesinde, yapısal olmayan veri (metin, PDF, ses) veri platformlarının
**kenarında** kalıyordu — asıl değer, hafta 2-11'de gördüğümüz yapısal/
ilişkisel dünyadaydı.

LLM'lerin yükselişiyle bu değişti: artık bir şirketin **PDF sözleşmeleri,
destek talebi metinleri, toplantı notları** da sorgulanabilir, aranabilir,
özetlenebilir bir varlık haline geldi. Bu hafta, bu dönüşümün teknik
altyapısını kuruyoruz.

### 1.2 AI-hazır veri (AI-ready data) ne demek

Bir organizasyonun verisi "AI-hazır" sayılması için:
- **Erişilebilir** olmalı (hafta 4'teki data lake/lakehouse mimarisi)
- **Kaliteli** olmalı (hafta 12'deki Great Expectations kontrolleri)
- **İzlenebilir** olmalı (hafta 12'deki lineage — bir LLM'in hangi veriyi
  "gördüğünü" bilmek, hafta 12'de öğrendiğiniz kadar kritik)
- **Doğru granülerlikte parçalanmış** olmalı (bu haftanın "chunking" konusu)

### 1.3 Veri platformunun LLM uygulamalarındaki rolü

```
Ham dokümanlar ──▶ [Veri Platformu]  ──▶ RAG / Text-to-SQL / Ajan
  (PDF, wiki,        chunking, embedding,    (bu hafta kurduğumuz sistem)
   destek talebi)     vektör depolama
```

LLM'in kendisi "akıllı" olsa da, **doğru bilgiye erişemezse** işe
yaramaz — bu hafta, veri mühendisliğinin (hafta 6) LLM uygulamalarındaki
karşılığını inşa ediyoruz: RAG'ın "R" kısmı (Retrieval), aslında bir
**veri boru hattıdır**.

### 1.4 Maliyet ve gecikme gerçekleri

Bulut LLM API'leri **token başına ücretlendirilir** — büyük bir bağlamı
(context) her sorguda tekrar göndermek maliyetlidir. Yerel modeller
(bu haftanın odağı) sabit donanım maliyetiyle çalışır ama gecikme
(latency) ve kalite ödünleşmesi taşır — hafta 7'deki "gecikme bütçesi"
kavramını burada da uygularız.

---

## 2. Gömme (Embedding) ve Vektör Arama

### 2.1 Metni vektöre çevirmek: gömme modelleri

Bir **embedding**, bir metnin anlamsal içeriğini sabit boyutlu bir sayı
dizisine (vektöre) sıkıştıran bir temsildir. Benzer anlamlı metinler,
vektör uzayında **birbirine yakın** konumlanır.

```
"Kafka bir mesajlaşma sistemidir"     → [0.12, -0.45, 0.78, ..., 0.03]  (768 boyut)
"Apache Kafka olay akışı platformu"   → [0.15, -0.41, 0.75, ..., 0.02]  (YAKIN vektör)
"Pizza tarifi nasıl yapılır"          → [-0.62, 0.33, -0.11, ..., 0.55]  (UZAK vektör)
```

Bu haftaki `nomic-embed-text` modeli (Ollama üzerinden), her metni
768 boyutlu bir vektöre çevirir.

### 2.2 Benzerlik ölçütleri: kosinüs, öklid, iç çarpım

| Ölçüt | Ne ölçer | Metin embedding'lerinde |
|---|---|---|
| **Kosinüs** | Vektörler arasındaki AÇI | ✅ Standart tercih — büyüklükten bağımsız, yön önemli |
| **Öklid (L2)** | İki nokta arasındaki DÜZ mesafe | Görüntü embedding'lerinde daha yaygın |
| **İç çarpım** | Yön + büyüklük birlikte | Öneri sistemlerinde (popülerlik sinyali istenirse) |

Bu haftaki tüm scriptler **kosinüs** mesafesini kullanır
(`embedding <=> query` pgvector'da, `Distance.COSINE` Qdrant'ta).

### 2.3 ANN indeksleri: HNSW, IVFFlat

Milyonlarca vektör arasında **kesin** en yakın komşuyu bulmak
(brute-force) çok yavaştır. **ANN** (Approximate Nearest Neighbor)
indeksleri, %100 kesinlikten küçük bir ödün vererek aramayı **kat kat
hızlandırır**. Bkz. [pgvector cheatsheet](./cheatsheets/pgvector-cheatsheet.md#-i̇ndeksleme-hnsw-vs-ivfflat).

### 2.4 Parçalama (chunking) stratejileri ve neden en kritik karar

Bu haftanın **en az konuşulan ama en etkili** kararı: bir dokümanı
embedding'e vermeden önce nasıl parçalara böldüğünüz. Alıştırma 2,
üç farklı stratejiyi (`sabit boyut`, `başlık bazlı`, `paragraf bazlı`)
gerçek ders notlarınız üzerinde karşılaştırmanızı sağlar.

---

## 3. Vektör Veritabanları

### 3.1 pgvector: Postgres'i vektör veritabanına çevirmek

```sql
CREATE EXTENSION vector;
CREATE TABLE items (id SERIAL, embedding VECTOR(768));
CREATE INDEX ON items USING hnsw (embedding vector_cosine_ops);
```

Tek bir `CREATE EXTENSION` ile, hafta 2'de kurduğunuz PostgreSQL bilgisi
doğrudan vektör aramaya uygulanabilir hale gelir — yeni bir sistem
öğrenmeye gerek yok.

### 3.2 Qdrant, Weaviate, Milvus, Pinecone karşılaştırması

| Araç | Tip | Not |
|---|---|---|
| **pgvector** | Postgres eklentisi | Mevcut altyapıya entegrasyon kolaylığı |
| **Qdrant** | Özel amaçlı, açık kaynak | Bu haftaki ikinci seçeneğimiz |
| **Weaviate** | Özel amaçlı, açık kaynak | Zengin metadata filtreleme, GraphQL API |
| **Milvus** | Özel amaçlı, açık kaynak | Çok büyük ölçek (milyarlarca vektör) için optimize |
| **Pinecone** | Yönetilen SaaS | Kurulumsuz, ama ücretli ve veri bulutta |

### 3.3 Ne zaman ayrı vektör DB, ne zaman pgvector yeter

Bkz. [Alıştırma 4.5](./exercises/04-vector-db-comparison.md) — ölçek ve
mevcut altyapı, kararı belirleyen iki ana faktördür.

### 3.4 Hibrit arama: anahtar kelime + vektör

Saf vektör araması, **anlamsal** olarak yakın ama **kelime olarak**
tamamen farklı metinleri bulur (güçlü yanı) ama bazen tam kelime
eşleşmesi gereken durumlarda (ürün kodu, kişi adı) zayıf kalabilir.
**Hibrit arama**, vektör benzerliğini geleneksel anahtar kelime aramasıyla
(BM25 gibi) birleştirerek her ikisinin güçlü yanını kullanır — bu haftaki
kapsamın ötesinde, ama üretim sistemlerinde yaygın bir tekniktir.

---

## 4. RAG Mimarisi

### 4.1 Indexing hattı: yükle → parçala → gömle → sakla

```
week*/README.md ──▶ chunk_by_heading() ──▶ Ollama embed() ──▶ pgvector INSERT
   (14 dosya)          (~200-300 parça)      (768 boyutlu vektör)
```

Bu, `scripts/index_course_notes.py`'nin yaptığı tam olarak budur —
Alıştırma 3'te çalıştıracaksınız.

### 4.2 Retrieval hattı: sorgu → arama → yeniden sıralama (rerank) → bağlam

```
"Kafka'da lag nasıl ölçülür?" ──▶ embed() ──▶ pgvector KNN ──▶ top-k parça
```

Gelişmiş sistemler burada bir **rerank** adımı da ekler (ilk aramadan
gelen 20 sonucu, daha pahalı ama daha isabetli bir modelle yeniden
sıralayıp en iyi 3-5'ini seçer) — bu hafta bunu atlıyoruz, basit top-k ile çalışıyoruz.

### 4.3 Prompt kurgusu ve bağlam penceresi yönetimi

```python
SYSTEM_PROMPT = """SADECE verilen bağlamı kullan. Uydurma. Kaynak belirt."""
```

`scripts/rag_query.py`'deki sistem prompt'u, RAG'ın en kritik güvenlik
katmanıdır — modelin kendi "dünya bilgisine" değil, **verilen bağlama**
sadık kalmasını ister. `num_ctx` parametresi (Ollama), modelin toplam
"hafıza" kapasitesini belirler — bağlam çok büyükse, ya `top_k`'yı
düşürmeniz ya da `num_ctx`'i artırmanız gerekir.

### 4.4 RAG değerlendirmesi: isabet, alaka, temellendirme

| Boyut | Soru |
|---|---|
| **İsabet (retrieval)** | Doğru parçalar bulundu mu? |
| **Alaka (relevance)** | Cevap, soruyla gerçekten ilgili mi? |
| **Temellendirme (groundedness)** | Cevap, verilen bağlamdan mı geldi, yoksa model kendi bilgisini mi kattı? |

Alıştırma 3.6'da kendi rubric'inizle bunu ölçeceksiniz.

### 4.5 RAG'ın yetmediği yer: ince ayar (fine-tuning) ne zaman

RAG, modele **dış bilgi** sağlar ama modelin **davranışını/üslubunu**
değiştirmez. Eğer ihtiyacınız "modelin belirli bir formatta, belirli bir
tonda, tutarlı şekilde" cevap vermesiyse (RAG'ın çözemediği bir problem),
**fine-tuning** (modelin ağırlıklarını kendi verinizle yeniden eğitmek)
gerekebilir — bu, çok daha maliyetli ve karmaşık bir süreçtir, bu
haftanın kapsamı dışındadır.

---

## 5. Text-to-SQL

### 5.1 Şema bilgisini modele vermek

```python
SCHEMA_DESCRIPTION = """
TABLO: shop.customers (id, full_name, city, segment)
TABLO: shop.orders (id, customer_id, order_date, status)
  customer_id -> shop.customers.id
...
"""
```

Model, SQL üretmek için şemayı **görmelidir** — hafta 5'te öğrendiğiniz
JOIN mantığını, model bu açıklamadan çıkarır.

### 5.2 Az örnekli (few-shot) öğrenme ve örnek sorgu havuzu

Bu haftaki basit kurulum "zero-shot" çalışır (hiç örnek vermeden). Gerçek
sistemlerde, prompt'a birkaç **örnek soru-SQL çifti** eklemek (few-shot)
doğruluğu belirgin şekilde artırır — modelin "bu tür sorularda nasıl bir
SQL üretmem bekleniyor" örüntüsünü görmesini sağlar.

### 5.3 Doğrulama katmanı: üretilen SQL güvenli mi

```python
FORBIDDEN = re.compile(r"\b(insert|update|delete|drop|...)\b", re.IGNORECASE)
```

`scripts/text_to_sql.py`'deki `validate_sql()` fonksiyonu, üretilen SQL'i
**çalıştırmadan önce** çok katmanlı kontrolden geçirir — bu haftanın en
kritik güvenlik dersi. Alıştırma 5, bu katmanın olmadığı bir senaryoyu
hayal etmenizi ister.

### 5.4 Gerçek doğruluk oranları ve insan onayı gerekliliği

Akademik benchmark'larda bile en iyi modeller karmaşık sorgularda
**%70-85** doğruluk civarındadır — geri kalan yüzde, ya yanlış SQL ya
da çalışmayan SQL üretir. Bu, text-to-SQL'in **insan onayı olmadan**
production'a konulmaması gerektiğinin sayısal kanıtıdır.

---

## 6. Yerel Model Çalıştırma

### 6.1 Ollama ile yerel LLM

```bash
docker exec week13_ollama ollama pull llama3.2:1b
docker exec -it week13_ollama ollama run llama3.2:1b
```

Ollama, model indirme, çalıştırma ve API sunma işlemlerini tek bir
araçta birleştirir — Docker'ın modeller için yaptığı işi (paketleme,
dağıtım, çalıştırma) LLM'lere uygulamış gibi düşünebilirsiniz.

### 6.2 Model boyutu, kuantizasyon, donanım gereksinimi

Bkz. [Alıştırma 1](./exercises/01-local-model.md) — model boyutu ile
donanım gereksinimi, kalite ile hız arasındaki ödünleşmeyi uygulamalı işliyoruz.

### 6.3 Veri mahremiyeti açısından yerel vs bulut

Bir hastane, banka ya da hukuk firması, hasta/müşteri verisini bir bulut
LLM API'sine **gönderemeyebilir** (KVKK/GDPR, hafta 12). Yerel model,
verinin **hiç ağa çıkmamasını** garanti eder — bu, bazı sektörlerde
"yerel model" seçiminin tek meşru yolu olmasının sebebidir.

### 6.4 Açık ağırlıklı modeller ve lisansları

Llama, Qwen, Mistral gibi modellerin **ağırlıkları** (parametreleri)
indirilebilir ve yerel çalıştırılabilir — ama her birinin **farklı bir
lisansı** vardır (bazıları ticari kullanımı kısıtlar, bazıları serbest
bırakır). Bir modeli production'da kullanmadan önce lisansını okumak,
tıpkı bir açık kaynak kütüphanesini kullanmadan önce lisansını
kontrol etmek gibi zorunludur.

---

## 7. AI Çağında Yönetişim

### 7.1 Prompt'a giden veride PII sızıntısı

Bir çalışanın, müşteri PII'si (hafta 12) içeren bir metni bir **bulut**
LLM API'sine yapıştırması, o veriyi üçüncü bir tarafa **aktarmak**
anlamına gelebilir — KVKK madde 5-9 kapsamında ek bir rıza/sözleşme
gerektirebilir. Bu haftaki yerel model kurulumu, bu riski tamamen ortadan kaldırır.

### 7.2 Halüsinasyon riski ve sorumluluk

Bir LLM, emin olmadığı bir konuda bile **akıcı ve inandırıcı** bir cevap
üretebilir (halüsinasyon). RAG bu riski **azaltır** ama sıfırlamaz
(Alıştırma 3.3). Bir müşteri hizmetleri botunun yanlış bilgi vermesi,
gerçek bir sorumluluk (hatta hukuki) riski taşır.

### 7.3 Telif ve eğitim verisi tartışması

Büyük dil modelleri, internetteki (çoğu telif hakkıyla korunan) metinlerle
eğitilir — bu, aktif bir hukuki/etik tartışma konusudur. Bir organizasyon
LLM tabanlı bir ürün geliştirirken, kullandığı modelin eğitim verisi
kaynağını ve lisans şartlarını bilmelidir.

### 7.4 AI kullanım politikası nasıl yazılır

Hafta 12'deki veri yönetişimi politikası şablonunu (Alıştırma 4)
hatırlayın — bir "AI kullanım politikası" benzer yapıdadır: hangi
veri LLM'lere gönderilebilir, hangi modeller onaylı, kim onay verir,
üretilen içerik nasıl denetlenir.

### 7.5 AB AI Act ve yaklaşan düzenlemeler

Avrupa Birliği'nin AI Act'i, yapay zeka sistemlerini **risk seviyesine**
göre sınıflandırıp (minimal, sınırlı, yüksek, kabul edilemez risk) her
seviyeye farklı yükümlülükler getiriyor. Türkiye'de de benzer düzenlemeler
gündemde — hafta 12'deki KVKK bilginiz, bu yeni düzenlemeleri anlamak
için doğrudan bir temel oluşturur.

### 7.6 Veri platformunun denetlenebilirliği

Bu haftaki `ai.course_chunks` tablosu ve Marquez'deki (hafta 12) lineage
mantığı birleştirilirse: *"Bu RAG cevabı hangi kaynak dokümandan geldi?"*
sorusu sadece teknik bir merak değil, bir **denetlenebilirlik** gereğidir
— özellikle regüle edilmiş sektörlerde (finans, sağlık) AI çıktılarının
kaynağını gösterebilmek yasal bir zorunluluk haline geliyor.

---

## 🔄 Alternatifler ve Ekosistem

Vektör veritabanlarını §3.2'de karşılaştırdık. Bu tablo haftanın diğer katmanlarını da ekliyor:

| Kullandığımız | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|
| **Ollama** | llama.cpp, vLLM, Hugging Face TGI, LocalAI · LM Studio (ücretsiz, açık kaynak değil) | NVIDIA NIM, bulut GPU hizmetleri | Çok kullanıcılı yüksek throughput (vLLM), masaüstü arayüz (LM Studio) |
| **Yerel açık ağırlıklı model** | Llama, Mistral, Qwen, Gemma | Anthropic Claude, OpenAI, Google Gemini · Amazon Bedrock, Azure OpenAI, Google Vertex AI | Kalite kritikse bulut API; veri kesinlikle dışarı çıkamıyorsa yerel |
| **pgvector / Qdrant** | Weaviate, Milvus, Chroma, OpenSearch, LanceDB | Pinecone, Zilliz Cloud, Qdrant Cloud, MongoDB Atlas Vector Search, Azure AI Search | Bkz. §3.2–3.3 |
| **Ollama embedding modeli** | sentence-transformers, BGE, E5 (çok dilli) | Voyage AI, Cohere, OpenAI, Google embedding API'leri | Türkçe/alan özelinde arama kalitesi |
| **Python ile elle RAG** | LlamaIndex, LangChain, Haystack | Amazon Bedrock Knowledge Bases, Vertex AI Search, Azure AI Search | Hızlı prototip vs. tam kontrol; yönetilen RAG |
| **Elle değerlendirme** (§4.4) | Ragas, DeepEval, promptfoo | LangSmith, Arize, W&B Weave | Üretimde kalite izleme, regresyon testleri |

**Değerlendirirken bakılacaklar:** veri gizliliği ve KVKK (veri nerede işleniyor, sağlayıcı eğitimde kullanıyor mu?), model kalitesi (özellikle Türkçe), token başı maliyet vs. GPU maliyeti, gecikme, model lisansı (§6.4), sağlayıcı bağımlılığı (API'yi soyutlayan bir katman kullanmak geçişi kolaylaştırır).

> ⚖️ **Lisans notu:** Açık ağırlıklı her model açık kaynak değildir. Bazı modellerin lisansları
> kullanım kısıtları veya kullanıcı sayısı eşiği içerir (§6.4). Elasticsearch 2021'de SSPL'e geçtiği için
> **OpenSearch** fork'u doğdu; vektör arama için ikisi de kullanılabilir.

📎 Tüm katmanların haritası ve lisans rehberi: [ALTERNATIVES.md](../ALTERNATIVES.md#-ai--llm-hafta-13)

---

## 🚀 Hızlı Başlangıç

```bash
cd week13-dg-ai-llm
./setup-week13.sh
pip install -r requirements.txt
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| Ollama | `ollama/ollama` | `11434` | — (API) |
| PostgreSQL + pgvector | `pgvector/pgvector:pg16` | `5441` | — |
| Qdrant | `qdrant/qdrant` | `6333` / `6334` | http://localhost:6333/dashboard |

**Bellek ihtiyacı:** ~4-6 GB (Ollama model boyutuna göre değişir).
**Disk:** ~2 GB (model indirmeleri).

### Durdurma

```bash
docker compose down        # durdur (veri + indirilen modeller kalır)
docker compose down -v     # durdur + volume sil (modelleri de yeniden indirmeniz gerekir)
```

---

## 🧪 Pratik Uygulamalar

| Script | Ne yapar |
|---|---|
| `scripts/chunking.py` | 3 parçalama stratejisi (heading/fixed/paragraph) |
| `scripts/index_course_notes.py` | 14 haftanın ders notlarını göm, pgvector'a yaz |
| `scripts/rag_query.py` | **Uçtan uca RAG** — soru sor, kaynaklı cevap al |
| `scripts/qdrant_demo.py` | Aynı veriyi Qdrant'a yükle, pgvector ile karşılaştır |
| `scripts/text_to_sql.py` | Doğal dil → SQL → doğrulama → çalıştırma |

### ✨ Bu Haftanın "Wow" Anı

```bash
python scripts/index_course_notes.py
python scripts/rag_query.py "Kafka'da consumer lag nasıl ölçülür?"
```

14 haftanın **tüm** ders notları gömülür. Türkçe bir soru sorduğunuzda,
sistem doğru haftayı (Hafta 7) bulur ve **o haftanın gerçek içeriğinden**
alıntılayarak, kaynak göstererek Türkçe bir cevap üretir — tamamen yerel
makinenizde, hiçbir veri dışarı çıkmadan:

```
Cevap:
Consumer lag, log_end_offset ile committed_offset arasındaki farktır...
python scripts/lag_monitor.py --group analytics --watch ile ölçülebilir...
(Kaynak: Hafta 7)
```

Bu repoyu haftalarca inşa ettiniz — şimdi ona **doğal dilde soru sorabiliyorsunuz.**

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Yerel Model Çalıştırma](./exercises/01-local-model.md) | 20 dk | Ollama, model boyutu |
| 2 | [Parçalama Stratejileri](./exercises/02-chunking-strategies.md) | 30 dk | Chunk boyutu, bağlam bütünlüğü |
| 3 | [Uçtan Uca RAG](./exercises/03-rag-pipeline.md) | 40 dk | Embedding, arama, üretim |
| 4 | [pgvector vs Qdrant](./exercises/04-vector-db-comparison.md) | 25 dk | Performans, mimari |
| 5 | [Text-to-SQL ve Risk Analizi](./exercises/05-text-to-sql.md) | 30 dk | Doğrulama, güvenlik |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**Ollama Cheatsheet**](./cheatsheets/ollama-cheatsheet.md)
- 📎 [**pgvector Cheatsheet**](./cheatsheets/pgvector-cheatsheet.md)
- 📎 [**Qdrant Cheatsheet**](./cheatsheets/qdrant-cheatsheet.md)

---

## 🧯 Sık Karşılaşılan Sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `model not found` | Model indirilmedi | `docker exec week13_ollama ollama pull <model>` |
| RAG çok yavaş | CPU'da büyük model | `llama3.2:1b` gibi küçük model kullanın |
| `operator does not exist: vector <=> numeric[]` | Cast eksik | Sorguda `%s::vector` kullanın |
| Container'lar OOM | Docker belleği yetersiz | En az 6 GB ayırın, gerekirse `llama3.2:1b`'ye düşün |
| Qdrant boş | `--load` çalıştırılmadı | `python scripts/qdrant_demo.py --load` |

---

## 📖 Kaynaklar

- [pgvector](https://github.com/pgvector/pgvector)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Ollama](https://ollama.com/)
- [Ollama Python Library](https://github.com/ollama/ollama-python)
- [Anthropic — Contextual Retrieval](https://www.anthropic.com/news/contextual-retrieval)
- [AB AI Act](https://artificialintelligenceact.eu/)
- [OpenAI Cookbook — RAG best practices](https://cookbook.openai.com/)

---

## 📝 Hafta Özeti

✅ **Embedding** — metni anlamsal vektöre çevirmek, kosinüs benzerliği
✅ **Chunking** — RAG kalitesinin en az konuşulan, en etkili kararı
✅ **pgvector vs Qdrant** — entegrasyon kolaylığı vs özel amaçlı ölçek
✅ **RAG** — retrieval + generation, ikisinin de ayrı başarısızlık modu var
✅ **Text-to-SQL** — güç kadar risk, katmanlı doğrulama zorunlu
✅ **Yönetişim** — hafta 12'nin tüm ilkeleri, AI çağında yeniden ve daha acil

> 💡 **Haftanın tek cümlesi:** LLM'ler "akıllı" görünür, ama bir RAG
> sisteminin gerçek kalitesi, LLM'in kendisinden çok, **onu besleyen veri
> platformunun** (chunking, arama, yönetişim) kalitesine bağlıdır.

---

**[← Hafta 12: Veri Yaşam Döngüsü ve Veri Yönetişimi](../week12-dg-governance/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 14: Örnek Vakalar →](../week14-case-studies/README.md)**
