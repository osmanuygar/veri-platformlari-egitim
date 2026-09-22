#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }; info(){ echo -e "${BLUE}ℹ️  $*${NC}"; }; warn(){ echo -e "${YELLOW}⚠️  $*${NC}"; }; die(){ echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""; echo "════════════════════════════════════════"; echo "  Hafta 12 — Veri Yaşam Döngüsü ve Veri Yönetişimi"; echo "════════════════════════════════════════"; echo ""

command -v docker >/dev/null 2>&1 || die "Docker bulunamadı."
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor."
ok "Docker hazır"

AVAIL_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
if [ "$AVAIL_MEM" -gt 0 ] && [ "$AVAIL_MEM" -lt 4000000000 ]; then
  warn "Docker belleği 4 GB altında. Marquez (API+Web+DB) + Postgres ~3 GB ister."
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

wait_for "PostgreSQL (veri kaynağı)" "docker exec week12_postgres pg_isready -U dg_user -d dg_db"
wait_for "Marquez API"  "curl -fsS http://localhost:5003/healthcheck" 40
wait_for "Marquez Web"  "curl -fsS http://localhost:3002" 30

cat <<SUMMARY

════════════════════════════════════════
  ✅ Hafta 12 ortamı hazır
════════════════════════════════════════

  🖥️  Arayüzler
     Marquez Web        http://localhost:3002
     Marquez API         http://localhost:5002
     GE Data Docs        http://localhost:8099  (önce ge_validate.py çalıştırın)

  🔌 Veri kaynağı
     localhost:5440  dg_db  (dg_user / dg_pass)
     Şemalar: raw (PII içeren ham veri) · marts (maskelenmiş görünüm)

  ▶️  Python bağımlılıkları:
     pip install -r requirements.txt

  🎬 "Wow" demosu:
     python scripts/ge_validate.py       # veri kalitesi raporu (10 kural, bazıları KASITLI başarısız)
     python scripts/emit_lineage.py      # Marquez'e lineage gönder
     open http://localhost:3002          # soy ağacını tıklayarak gezin

  📖 Ders notu:     ./README.md
  📝 Alıştırmalar:  ./exercises/

  🛑 Kapatma:  docker compose down        (veri kalır)
               docker compose down -v     (her şeyi siler)

SUMMARY
