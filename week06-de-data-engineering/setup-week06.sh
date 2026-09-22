#!/usr/bin/env bash
# Hafta 6 — Veri Mühendisliğine Giriş: tek komutluk kurulum
set -euo pipefail
cd "$(dirname "$0")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✅ $*${NC}"; }
info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }
die()  { echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Hafta 6 — Veri Mühendisliğine Giriş ve Modern Veri Ekosistemi"
echo "════════════════════════════════════════════════════════════"
echo ""

command -v docker >/dev/null 2>&1 || die "Docker bulunamadı."
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor."
ok "Docker hazır"

[ -f .env ] || { cp .env.example .env; ok ".env oluşturuldu"; }

info "Servisler başlatılıyor (Airflow image'i ilk seferde derlenecek, birkaç dakika sürebilir)…"
docker compose up -d --build

wait_for() {
  local name="$1" cmd="$2" tries="${3:-60}"
  printf "⏳ %s bekleniyor" "$name"
  for _ in $(seq 1 "$tries"); do
    if eval "$cmd" >/dev/null 2>&1; then echo ""; ok "$name hazır"; return 0; fi
    printf "."; sleep 3
  done
  echo ""; die "$name zamanında hazır olmadı. 'docker compose logs $name'"
}

wait_for "PostgreSQL" "docker exec week06_postgres pg_isready -U de_user -d de_db"
wait_for "Airflow"    "curl -fsS http://localhost:8090/health" 60

info "dbt bağımlılıkları kuruluyor (container içinde)…"
docker exec week06_airflow bash -lc \
  "cd /opt/dbt_project && DBT_PROFILES_DIR=./profiles dbt deps" \
  && ok "dbt deps tamam" || warn "dbt deps başarısız — elle deneyin (cheatsheet'e bakın)"

info "İlk dbt çalıştırması yapılıyor (seed + run + test)…"
docker exec week06_airflow bash -lc \
  "cd /opt/dbt_project && DBT_PROFILES_DIR=./profiles dbt seed && DBT_PROFILES_DIR=./profiles dbt run" \
  && ok "dbt run tamam" || warn "dbt run başarısız — 'docker exec -it week06_airflow bash' ile elle deneyin"

cat <<SUMMARY

════════════════════════════════════════════════════════════
  ✅ Hafta 6 ortamı hazır
════════════════════════════════════════════════════════════

  🖥️  Arayüzler
     Airflow UI     http://localhost:8090   (admin / admin)

  🔌 Bağlantılar
     PostgreSQL     localhost:5436  (de_user / de_pass / de_db)
     Şemalar:       raw (kaynak) · analytics (dbt çıktısı)

  ▶️  Python bağımlılıkları (host'ta dbt/DuckDB komutları için):
     pip install -r requirements.txt

  🎬 "Wow" demosu:
     cd dbt_project && DBT_PROFILES_DIR=./profiles dbt docs generate \\
       && DBT_PROFILES_DIR=./profiles dbt docs serve --port 8091
     → tarayıcıda soy ağacını (lineage) tıklayarak gezin

  📖 Ders notu:     ./README.md
  📝 Alıştırmalar:  ./exercises/
  📋 Cheatsheet:    ./cheatsheets/

  🛑 Kapatma:  docker compose down        (veri kalır)
               docker compose down -v     (her şeyi siler)

SUMMARY
