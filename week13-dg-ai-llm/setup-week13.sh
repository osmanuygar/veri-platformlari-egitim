#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }; info(){ echo -e "${BLUE}ℹ️  $*${NC}"; }; warn(){ echo -e "${YELLOW}⚠️  $*${NC}"; }; die(){ echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""; echo "════════════════════════════════════════"; echo "  Hafta 13 — AI ve LLM Çağında Veri Platformları"; echo "════════════════════════════════════════"; echo ""

command -v docker >/dev/null 2>&1 || die "Docker bulunamadı."
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor."
ok "Docker hazır"

AVAIL_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
if [ "$AVAIL_MEM" -gt 0 ] && [ "$AVAIL_MEM" -lt 6000000000 ]; then
  warn "Docker belleği 6 GB altında. Ollama model çalıştırırken en az 4-6 GB önerilir."
fi

[ -f .env ] || { cp .env.example .env; ok ".env oluşturuldu"; }

info "Servisler başlatılıyor…"
docker compose up -d

wait_for() {
  local name="$1" cmd="$2" tries="${3:-40}"
  printf "⏳ %s bekleniyor" "$name"
  for _ in $(seq 1 "$tries"); do
    if eval "$cmd" >/dev/null 2>&1; then echo ""; ok "$name hazır"; return 0; fi
    printf "."; sleep 3
  done
  echo ""; warn "$name zamanında hazır olmadı — 'docker compose logs $name' ile bakın"
}

wait_for "PostgreSQL + pgvector" "docker exec week13_postgres pg_isready -U ai_user -d ai_db"
wait_for "Qdrant" "curl -fsS http://localhost:6333/healthz"
wait_for "Ollama" "curl -fsS http://localhost:11434/api/tags"

info "Ollama modelleri indiriliyor (ilk seferde birkaç dakika sürebilir)…"
info "  • nomic-embed-text (~274 MB) — embedding modeli"
docker exec week13_ollama ollama pull nomic-embed-text && ok "nomic-embed-text hazır"
info "  • llama3.2:1b (~1.3 GB) — sohbet/üretim modeli"
docker exec week13_ollama ollama pull llama3.2:1b && ok "llama3.2:1b hazır"

cat <<SUMMARY

════════════════════════════════════════
  ✅ Hafta 13 ortamı hazır
════════════════════════════════════════

  🖥️  Arayüzler
     Ollama API       http://localhost:11434
     Qdrant Dashboard http://localhost:6333/dashboard
     PostgreSQL+pgvector  localhost:5441  (ai_user / ai_pass / ai_db)

  ▶️  Python bağımlılıkları:
     pip install -r requirements.txt

  🎬 "Wow" demosu (3 adım):
     python scripts/index_course_notes.py     # 14 haftanın ders notlarını göm
     python scripts/rag_query.py "Kafka'da consumer lag nasıl ölçülür?"
     → doğru haftadan alıntılayarak Türkçe cevap alacaksınız

  📖 Ders notu:     ./README.md
  📝 Alıştırmalar:  ./exercises/

  🛑 Kapatma:  docker compose down        (veri kalır, modeller de kalır)
               docker compose down -v     (her şeyi siler, modelleri de)

SUMMARY
