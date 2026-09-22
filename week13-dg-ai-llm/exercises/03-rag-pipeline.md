# Alıştırma 3: Uçtan Uca RAG

**Süre:** ~40 dakika · **Dosyalar:** `scripts/index_course_notes.py`, `scripts/rag_query.py`

---

## 3.1 Ders notlarını indeksleyin

```bash
python scripts/index_course_notes.py
```

**Görev:** Kaç parça (chunk) üretildiğini ve pgvector'a yazıldığını not edin.

```bash
docker exec week13_postgres psql -U ai_user -d ai_db -c "SELECT week_no, count(*) FROM ai.course_chunks GROUP BY week_no ORDER BY week_no;"
```

---

## 3.2 İlk sorgunuzu sorun

```bash
python scripts/rag_query.py "Kafka'da consumer lag nasıl ölçülür?"
```

**Görev:** Hangi hafta(lar)dan kaynak bulundu? Cevap, gerçekten hafta
7'nin içeriğine dayanıyor mu?

---

## 3.3 Bağlam dışı bir soru sorun

```bash
python scripts/rag_query.py "En iyi pizza tarifi nedir?"
```

**Soru:** Sistem prompt'unda ("Bağlamda olmayan bir şey uydurma") verdiğiniz
talimat işe yaradı mı? Model ne cevap verdi? Bu talimat olmasaydı model
ne yapardı (halüsinasyon riski)?

---

## 3.4 `--show-context` ile şeffaflığı görün

```bash
python scripts/rag_query.py "dbt'de incremental model nasıl çalışır?" --show-context
```

**Soru:** Modele giden HAM bağlamı görüyorsunuz. Model, bu bağlamdaki
bilgiyi **olduğu gibi mi** aktardı, yoksa kendi yorumunu mu kattı? RAG'ın
"temellendirme" (groundedness) kalitesini nasıl değerlendirirsiniz?

---

## 3.5 `top-k`'nın etkisi

```bash
python scripts/rag_query.py "Airflow'da backfill nedir?" --top-k 1
python scripts/rag_query.py "Airflow'da backfill nedir?" --top-k 8
```

**Soru:** `top-k=1` ile cevap ne kadar eksik/dar kaldı? `top-k=8` ile
ne değişti — daha iyi mi, yoksa alakasız bağlam da mı eklendi (bkz.
ders notu "bağlam penceresi yönetimi")?

---

## 3.6 RAG değerlendirmesi: kendi rubric'inizi yazın

**Görev:** 5 farklı soru sorup her birini şu üç boyutta 1-5 arası puanlayın:

| Soru | İsabet (doğru haftayı buldu mu) | Alaka (cevap soruyla ilgili mi) | Temellendirme (cevap bağlamdan mı geldi) |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| ... | | | |

---

## ✅ Ne öğrendik

- RAG'ın iki ayrı başarısızlık modu vardır: **retrieval hatası** (yanlış/
  eksik parça bulundu) ve **generation hatası** (doğru bağlam vardı ama
  model onu doğru kullanmadı).
- Sistem prompt'undaki "sadece bağlamı kullan" talimatı, halüsinasyonu
  **azaltır** ama tamamen ortadan kaldırmaz.
- `top-k` bir ödünleşmedir: çok düşükse eksik bağlam, çok yüksekse
  alakasız/gürültülü bağlam.
- RAG kalitesini değerlendirmek, tek bir "doğru/yanlış" metriği değil,
  çok boyutlu bir değerlendirme gerektirir.

📎 [Çözüm](./solutions/03-rag-pipeline.md)
