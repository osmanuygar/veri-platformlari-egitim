#!/usr/bin/env python3
"""
Hafta 13 — ✨ WOW DEMOSU: Uçtan uca RAG (Retrieval-Augmented Generation)

Türkçe bir soru sorun; script:
  1. Soruyu embedding'e çevirir (aynı model, aynı vektör uzayı)
  2. pgvector'da cosine mesafesiyle en yakın K parçayı bulur (RETRIEVAL)
  3. Bulunan parçaları prompt'a bağlam olarak ekler
  4. Ollama'nın chat modeline sorup Türkçe, kaynaklı bir cevap üretir (GENERATION)

Ön koşul: python scripts/index_course_notes.py

Kullanım:
    python scripts/rag_query.py "Kafka'da consumer lag nasıl ölçülür?"
    python scripts/rag_query.py "dbt'de incremental model nasıl yazılır?" --top-k 5
    python scripts/rag_query.py "..." --show-context   # ham bağlamı da göster
"""
import argparse
import sys

import psycopg2
from pgvector.psycopg2 import register_vector

from common import PG, OLLAMA_URL, OLLAMA_CHAT_MODEL, OLLAMA_EMBED_MODEL, C, banner, require

require("ollama")
import ollama


SYSTEM_PROMPT = """Sen bir Veri Platformları eğitim asistanısın. Sana verilen
BAĞLAM parçalarını kullanarak öğrencinin sorusunu Türkçe cevapla.

Kurallar:
- SADECE verilen bağlamdaki bilgiyi kullan. Bağlamda olmayan bir şey uydurma.
- Bağlam yetersizse "Bu ders notlarında bu konuya dair yeterli bilgi bulamadım" de.
- Cevabının sonunda, bilgiyi hangi HAFTA(LAR)DAN aldığını belirt: "(Kaynak: Hafta N)"
- Kısa ve öz ol, gereksiz tekrar yapma.
"""


def retrieve(cur, query_embedding, top_k=3):
    cur.execute("""
        SELECT week_no, week_title, section, chunk_text,
               embedding <=> %s::vector AS distance
        FROM ai.course_chunks
        ORDER BY distance
        LIMIT %s
    """, (query_embedding, top_k))
    return cur.fetchall()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("question")
    ap.add_argument("--top-k", type=int, default=3)
    ap.add_argument("--show-context", action="store_true")
    args = ap.parse_args()

    banner("RAG: Retrieval-Augmented Generation", f"Soru: \"{args.question}\"")

    client = ollama.Client(host=OLLAMA_URL)

    # ── 1) Soruyu göm ────────────────────────────────────────
    print(f"{C.DIM}[1/3] Soru embedding'e çevriliyor ({OLLAMA_EMBED_MODEL})…{C.RESET}")
    try:
        q_embedding = client.embed(model=OLLAMA_EMBED_MODEL, input=args.question).embeddings[0]
    except Exception as e:
        print(f"{C.RED}✖ Ollama hatası: {e}{C.RESET}")
        sys.exit(1)

    # ── 2) pgvector'da en yakın parçaları bul ─────────────────
    print(f"{C.DIM}[2/3] pgvector'da en yakın {args.top_k} parça aranıyor…{C.RESET}")
    conn = psycopg2.connect(**PG)
    register_vector(conn)
    with conn.cursor() as cur:
        results = retrieve(cur, q_embedding, args.top_k)
    conn.close()

    if not results:
        print(f"{C.RED}✖ Hiç sonuç yok. Önce: python scripts/index_course_notes.py{C.RESET}")
        sys.exit(1)

    print(f"{C.GREEN}✔ Bulunan kaynaklar:{C.RESET}")
    for week_no, week_title, section, text, dist in results:
        print(f"  {C.MAGENTA}Hafta {week_no}{C.RESET} — {section}  "
              f"{C.DIM}(benzerlik={1-dist:.3f}){C.RESET}")
        if args.show_context:
            print(f"    {C.DIM}{text[:200]}…{C.RESET}")

    # ── 3) Bağlamla birlikte modele sor ───────────────────────
    context = "\n\n---\n\n".join(
        f"[Hafta {w}: {t} — {s}]\n{txt}" for w, t, s, txt, _ in results
    )
    print(f"\n{C.DIM}[3/3] {OLLAMA_CHAT_MODEL} ile cevap üretiliyor…{C.RESET}\n")

    response = client.chat(model=OLLAMA_CHAT_MODEL, messages=[
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": f"BAĞLAM:\n{context}\n\nSORU: {args.question}"},
    ])

    print(f"{C.CYAN}{'─'*62}{C.RESET}")
    print(f"{C.BOLD}Cevap:{C.RESET}\n")
    print(response.message.content)
    print(f"{C.CYAN}{'─'*62}{C.RESET}\n")


if __name__ == "__main__":
    main()
