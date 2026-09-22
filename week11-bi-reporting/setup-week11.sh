#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }; info(){ echo -e "${BLUE}ℹ️  $*${NC}"; }; warn(){ echo -e "${YELLOW}⚠️  $*${NC}"; }; die(){ echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""; echo "════════════════════════════════════════"; echo "  Hafta 11 — İş Zekası & Raporlama Sistemleri"; echo "════════════════════════════════════════"; echo ""

command -v docker >/dev/null 2>&1 || die "Docker bulunamadı."
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor."
ok "Docker hazır"

AVAIL_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
if [ "$AVAIL_MEM" -gt 0 ] && [ "$AVAIL_MEM" -lt 4000000000 ]; then
  warn "Docker belleği 4 GB altında. Metabase + Superset + 3 Postgres ~3.5 GB ister."
fi

[ -f .env ] || { cp .env.example .env; ok ".env oluşturuldu"; }

info "Servisler başlatılıyor (Superset image'i ilk seferde derlenir, birkaç dakika sürebilir)…"
docker compose up -d --build

wait_for() {
  local name="$1" cmd="$2" tries="${3:-40}"
  printf "⏳ %s bekleniyor" "$name"
  for _ in $(seq 1 "$tries"); do
    if eval "$cmd" >/dev/null 2>&1; then echo ""; ok "$name hazır"; return 0; fi
    printf "."; sleep 3
  done
  echo ""; warn "$name zamanında hazır olmadı — 'docker compose logs $name' ile bakın"
}

wait_for "PostgreSQL (veri kaynağı)" "docker exec week11_postgres pg_isready -U bi_user -d bi_db"
wait_for "Metabase" "curl -fsS http://localhost:3001/api/health" 40
wait_for "Superset"  "curl -fsS http://localhost:8098/health" 40

info "Superset admin kullanıcısı oluşturuluyor…"
docker exec week11_superset superset fab create-admin \
  --username admin --firstname Admin --lastname User \
  --email admin@example.com --password admin 2>/dev/null \
  && ok "Superset admin: admin/admin" || warn "Admin zaten var ya da oluşturulamadı"
docker exec week11_superset superset db upgrade >/dev/null 2>&1 || true
docker exec week11_superset superset init >/dev/null 2>&1 || true

cat <<SUMMARY

════════════════════════════════════════
  ✅ Hafta 11 ortamı hazır
════════════════════════════════════════

  🖥️  Arayüzler
     Metabase       http://localhost:3001   (ilk açılışta kurulum sihirbazı ister)
     Superset       http://localhost:8098   (admin / admin)

  🔌 Veri kaynağı (her iki araca da bu bilgilerle bağlanın)
     Host: postgres (container içinden) / localhost (host'tan)
     Port: 5432 (container içinden) / 5439 (host'tan)
     DB:   bi_db   User: bi_user   Pass: bi_pass

  📊 Hazır şema: bi.fact_sales + bi.dim_customer/dim_product/dim_date
     (~2200+ satış satırı, 2 yıllık, mevsimsellikli)

  📖 Ders notu:     ./README.md
  📝 Alıştırmalar:  ./exercises/

  🛑 Kapatma:  docker compose down        (veri kalır)
               docker compose down -v     (her şeyi siler)

SUMMARY
