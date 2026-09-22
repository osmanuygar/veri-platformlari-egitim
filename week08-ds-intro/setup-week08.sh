#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }; info(){ echo -e "${BLUE}ℹ️  $*${NC}"; }; die(){ echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""; echo "════════════════════════════════════════"; echo "  Hafta 8 — Veri Bilimine Giriş"; echo "════════════════════════════════════════"; echo ""

command -v docker >/dev/null 2>&1 || die "Docker bulunamadı."
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor."
ok "Docker hazır"

[ -f .env ] || { cp .env.example .env; ok ".env oluşturuldu"; }

info "Örnek veri seti üretiliyor…"
python3 scripts/generate_dataset.py 2>/dev/null || echo "  (Python host'ta yoksa Jupyter içinden çalıştırın)"

info "Jupyter Lab başlatılıyor…"
docker compose up -d

for i in $(seq 1 30); do
  curl -fsS http://localhost:8889/api >/dev/null 2>&1 && break
  sleep 2
done
ok "Jupyter Lab hazır"

cat <<SUMMARY

════════════════════════════════════════
  ✅ Hafta 8 ortamı hazır
════════════════════════════════════════

  🖥️  Jupyter Lab   http://localhost:8889/lab?token=week08

  📓 Başlangıç defteri: notebooks/01-eda-starter.ipynb
  📖 Ders notu:         ./README.md
  📝 Alıştırmalar:      ./exercises/

  🛑 Kapatma:  docker compose down

SUMMARY
