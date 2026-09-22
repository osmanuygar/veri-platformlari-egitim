#!/usr/bin/env python3
"""
Hafta 13 — Alıştırma 4: Aynı embedding'leri Qdrant'a yükle ve karşılaştır

pgvector "Postgres'i vektör veritabanına çeviren" bir uzantıyken, Qdrant
sıfırdan vektör arama için yazılmış, özel amaçlı bir sistemdir. Bu script
aynı ders notu parçalarını Qdrant'a yükler ve pgvector ile aynı soruyu
sorup sonuçları/süreleri karşılaştırmanızı sağlar.

Ön koşul: python scripts/index_course_notes.py  (pgvector'a yazmış olmalı)

Kullanım:
    python scripts/qdrant_demo.py --load          # pgvector'daki veriyi Qdrant'a kopyala
    python scripts/qdrant_demo.py --query "Kafka'da consumer lag nasıl ölçülür?"
"""
import argparse
import sys
import time

import psycopg2
from pgvector.psycopg2 import register_vector

from common import PG, QDRANT_URL, QDRANT_COLLECTION, OLLAMA_URL, OLLAMA_EMBED_MODEL, C, banner, require

require("ollama")
require("qdrant_client")
import ollama
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct


def load_from_pgvector(qdrant: QdrantClient):
    conn = psycopg2.connect(**PG)
    register_vector(conn)
    with conn.cursor() as cur:
        cur.execute("SELECT id, week_no, week_title, section, chunk_text, embedding "
                     "FROM ai.course_chunks")
        rows = cur.fetchall()
    conn.close()

    if not rows:
        print(f"{C.RED}✖ pgvector'da veri yok. Önce: python scripts/index_course_notes.py{C.RESET}")
        sys.exit(1)

    dim = len(rows[0][5].to_list())
    if qdrant.collection_exists(QDRANT_COLLECTION):
        qdrant.delete_collection(QDRANT_COLLECTION)
    qdrant.create_collection(
        collection_name=QDRANT_COLLECTION,
        vectors_config=VectorParams(size=dim, distance=Distance.COSINE),
    )

    points = [
        PointStruct(
            id=row_id,
            vector=embedding.to_list(),
            payload={"week_no": week_no, "week_title": week_title,
                     "section": section, "chunk_text": chunk_text},
        )
        for row_id, week_no, week_title, section, chunk_text, embedding in rows
    ]
    qdrant.upsert(collection_name=QDRANT_COLLECTION, points=points)
    print(f"{C.GREEN}✔{C.RESET} {len(points)} nokta Qdrant'a yüklendi "
          f"(koleksiyon: {QDRANT_COLLECTION}, boyut: {dim})")


def compare_search(qdrant: QdrantClient, question: str, top_k: int = 3):
    client = ollama.Client(host=OLLAMA_URL)
    q_embedding = client.embed(model=OLLAMA_EMBED_MODEL, input=question).embeddings[0]

    # ── Qdrant araması ────────────────────────────────────────
    t0 = time.time()
    qdrant_results = qdrant.query_points(
        collection_name=QDRANT_COLLECTION, query=q_embedding, limit=top_k
    ).points
    qdrant_ms = (time.time() - t0) * 1000

    # ── pgvector araması (karşılaştırma için) ─────────────────
    conn = psycopg2.connect(**PG)
    register_vector(conn)
    t0 = time.time()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT week_no, section, embedding <=> %s::vector AS distance
            FROM ai.course_chunks ORDER BY distance LIMIT %s
        """, (q_embedding, top_k))
        pg_results = cur.fetchall()
    pg_ms = (time.time() - t0) * 1000
    conn.close()

    print(f"\n{C.BOLD}Qdrant{C.RESET}  ({qdrant_ms:.1f} ms)")
    for p in qdrant_results:
        print(f"  Hafta {p.payload['week_no']:<3} {p.payload['section']:<40} "
              f"benzerlik={p.score:.3f}")

    print(f"\n{C.BOLD}pgvector{C.RESET}  ({pg_ms:.1f} ms)")
    for week_no, section, dist in pg_results:
        print(f"  Hafta {week_no:<3} {section:<40} benzerlik={1-dist:.3f}")

    same_weeks = {p.payload["week_no"] for p in qdrant_results} == \
                 {w for w, _, _ in pg_results}
    print(f"\n{C.DIM}Aynı haftalar mı bulundu: "
          f"{'evet ✓' if same_weeks else 'hayır — normal, iki motor da yaklaşık (ANN) arama yapar'}{C.RESET}\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--load", action="store_true", help="pgvector'daki veriyi Qdrant'a kopyala")
    ap.add_argument("--query", help="karşılaştırmalı arama yap")
    ap.add_argument("--top-k", type=int, default=3)
    args = ap.parse_args()

    banner("Qdrant vs pgvector", f"koleksiyon={QDRANT_COLLECTION}  url={QDRANT_URL}")

    qdrant = QdrantClient(url=QDRANT_URL)

    if args.load:
        load_from_pgvector(qdrant)
    if args.query:
        compare_search(qdrant, args.query, args.top_k)
    if not args.load and not args.query:
        print(f"{C.YELLOW}Kullanım: --load ile yükleyin, --query \"...\" ile karşılaştırın{C.RESET}")


if __name__ == "__main__":
    main()
