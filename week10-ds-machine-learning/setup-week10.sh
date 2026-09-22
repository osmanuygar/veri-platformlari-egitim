#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }; info(){ echo -e "${BLUE}ℹ️  $*${NC}"; }; warn(){ echo -e "${YELLOW}⚠️  $*${NC}"; }; die(){ echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""; echo "════════════════════════════════════════"; echo "  Hafta 10 — Makine Öğrenmesine Giriş"; echo "════════════════════════════════════════"; echo ""

command -v docker >/dev/null 2>&1 || die "Docker bulunamadı."
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor."
ok "Docker hazır"

AVAIL_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
if [ "$AVAIL_MEM" -gt 0 ] && [ "$AVAIL_MEM" -lt 4000000000 ]; then
  warn "Docker belleği 4 GB altında. Bu hafta MLflow+MinIO+Postgres+Jupyter ile ~3 GB ister."
fi

[ -f .env ] || { cp .env.example .env; ok ".env oluşturuldu"; }

info "Örnek veri seti üretiliyor…"
python3 scripts/generate_churn_dataset.py 2>/dev/null || echo "  (host'ta Python yoksa Jupyter içinden çalıştırın)"

info "Servisler başlatılıyor (ilk seferde MLflow image'i derlenir)…"
docker compose up -d --build

wait_for() {
  local name="$1" cmd="$2" tries="${3:-40}"
  printf "⏳ %s bekleniyor" "$name"
  for _ in $(seq 1 "$tries"); do
    if eval "$cmd" >/dev/null 2>&1; then echo ""; ok "$name hazır"; return 0; fi
    printf "."; sleep 3
  done
  echo ""; die "$name zamanında hazır olmadı. 'docker compose logs $name'"
}

wait_for "PostgreSQL" "docker exec week10_postgres pg_isready -U mlflow_user -d mlflow_db"
wait_for "MinIO"      "curl -fsS http://localhost:9000/minio/health/live"
wait_for "MLflow"     "curl -fsS http://localhost:5500/health" 40
wait_for "Jupyter"    "curl -fsS http://localhost:8891/api"

cat <<SUMMARY

════════════════════════════════════════
  ✅ Hafta 10 ortamı hazır
════════════════════════════════════════

  🖥️  Arayüzler
     Jupyter Lab    http://localhost:8891/lab?token=week10
     MLflow UI      http://localhost:5500
     MinIO Console  http://localhost:9001  (minio_admin / minio_password)

  ▶️  Python bağımlılıkları (host'ta script çalıştırmak için):
     pip install -r requirements.txt

  🎬 "Wow" demosu:
     python scripts/train_all_models.py
     → MLflow UI'da http://localhost:5500 adresine gidip
       20 denemeyi metriklerine göre sıralayın

  📖 Ders notu:     ./README.md
  📝 Alıştırmalar:  ./exercises/

  🛑 Kapatma:  docker compose down        (veri kalır)
               docker compose down -v     (her şeyi siler)

SUMMARY
