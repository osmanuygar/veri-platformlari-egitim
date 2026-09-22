#!/usr/bin/env python3
"""
Hafta 13 — Alıştırma 3: 14 haftanın ders notlarını göm (embed) ve pgvector'a yaz

Bu, bu haftanın "wow" demosunun ilk adımıdır. Tüm week*/README.md
dosyalarını okur, başlık bazında parçalar, Ollama'nın embedding
modeliyle vektöre çevirir ve PostgreSQL + pgvector'a yazar.

Kullanım:
    python scripts/index_course_notes.py
    python scripts/index_course_notes.py --strategy fixed   # farklı parçalama
"""
import argparse
import sys
import time

import psycopg2
from psycopg2.extras import execute_values
from pgvector.psycopg2 import register_vector

from common import PG, OLLAMA_URL, OLLAMA_EMBED_MODEL, C, banner, require
from chunking import find_week_readmes, week_meta, STRATEGIES

require("ollama")
import ollama


def embed_texts(client, texts, batch_size=16):
    """Ollama embed API'sini batch'ler halinde çağırır."""
    all_embeddings = []
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        resp = client.embed(model=OLLAMA_EMBED_MODEL, input=batch)
        all_embeddings.extend(resp.embeddings)
    return all_embeddings


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--strategy", choices=list(STRATEGIES), default="heading")
    args = ap.parse_args()

    banner("Ders Notlarını Gömme (Embedding) → pgvector",
           f"strateji={args.strategy}  model={OLLAMA_EMBED_MODEL}")

    files = find_week_readmes()
    if not files:
        print(f"{C.RED}✖ Hiç week*/README.md bulunamadı.{C.RESET}")
        sys.exit(1)
    print(f"{C.DIM}Bulunan hafta dosyası: {len(files)}{C.RESET}")

    chunk_fn = STRATEGIES[args.strategy]
    all_chunks = []
    for f in files:
        week_no, slug = week_meta(f)
        text = f.read_text(encoding="utf-8")
        title_line = text.splitlines()[0].lstrip("# ").strip()
        for c in chunk_fn(text):
            all_chunks.append({
                "week_no": week_no,
                "week_title": title_line,
                "section": c["section"],
                "text": c["text"],
            })
    print(f"{C.DIM}Toplam parça (chunk): {len(all_chunks)}{C.RESET}\n")

    client = ollama.Client(host=OLLAMA_URL)
    try:
        client.list()
    except Exception as e:
        print(f"{C.RED}✖ Ollama'ya bağlanılamadı: {e}{C.RESET}")
        print(f"{C.DIM}  docker compose up -d ollama  ile başlatıp modeli indirin:\n"
              f"  docker exec week13_ollama ollama pull {OLLAMA_EMBED_MODEL}{C.RESET}")
        sys.exit(1)

    print(f"{C.DIM}Embedding üretiliyor (ilk seferde biraz sürebilir)…{C.RESET}")
    t0 = time.time()
    texts = [c["text"] for c in all_chunks]
    embeddings = embed_texts(client, texts)
    dt = time.time() - t0
    print(f"{C.GREEN}✔{C.RESET} {len(embeddings)} embedding üretildi "
          f"({dt:.1f} sn, {len(embeddings)/dt:.1f} chunk/sn)\n")

    conn = psycopg2.connect(**PG)
    register_vector(conn)   # Python list <-> pgvector VECTOR tipi dönüşümünü otomatikleştirir
    with conn, conn.cursor() as cur:
        cur.execute("TRUNCATE ai.course_chunks RESTART IDENTITY")
        rows = [
            (c["week_no"], c["week_title"], c["section"], c["text"], emb)
            for c, emb in zip(all_chunks, embeddings)
        ]
        execute_values(
            cur,
            "INSERT INTO ai.course_chunks (week_no, week_title, section, chunk_text, embedding) VALUES %s",
            rows,
        )
    conn.close()

    print(f"{C.BOLD}✅ {len(rows)} parça pgvector'a yazıldı (ai.course_chunks){C.RESET}")
    print(f"{C.DIM}Şimdi sorgulayın: python scripts/rag_query.py \"Kafka'da consumer lag nasıl ölçülür?\"{C.RESET}\n")


if __name__ == "__main__":
    main()
