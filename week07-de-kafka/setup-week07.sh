#!/usr/bin/env bash
# Hafta 7 — Apache Kafka: tek komutluk kurulum
set -euo pipefail

cd "$(dirname "$0")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✅ $*${NC}"; }
info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }
die()  { echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Hafta 7 — Apache Kafka ile Gerçek Zamanlı Veri Akışı"
echo "════════════════════════════════════════════════════════════"
echo ""

# ─── 1. Ön koşullar ───────────────────────────────────────────
command -v docker >/dev/null 2>&1 || die "Docker bulunamadı. https://docker.com veya https://orbstack.dev"
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli ('docker compose', tire olmadan)."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor. Docker Desktop / OrbStack'i başlatın."
ok "Docker hazır"

AVAIL_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
if [ "$AVAIL_MEM" -gt 0 ] && [ "$AVAIL_MEM" -lt 4000000000 ]; then
  warn "Docker'a ayrılan bellek 4 GB'ın altında. Bu hafta ~3.5 GB ister."
fi

[ -f .env ] || { cp .env.example .env; ok ".env oluşturuldu (.env.example'dan)"; }

# ─── 2. Servisleri başlat ─────────────────────────────────────
info "Servisler başlatılıyor…"
docker compose up -d

# ─── 3. Sağlık bekle ──────────────────────────────────────────
wait_for() {   # wait_for <isim> <komut> <deneme>
  local name="$1" cmd="$2" tries="${3:-60}"
  printf "⏳ %s bekleniyor" "$name"
  for _ in $(seq 1 "$tries"); do
    if eval "$cmd" >/dev/null 2>&1; then echo ""; ok "$name hazır"; return 0; fi
    printf "."
    sleep 2
  done
  echo ""
  die "$name zamanında hazır olmadı. 'docker compose logs $name' ile bakın."
}

wait_for "Kafka"           "docker exec week07_kafka /opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:19092"
wait_for "PostgreSQL"      "docker exec week07_postgres pg_isready -U kafka_user -d shopdb"
wait_for "Schema Registry" "curl -fsS http://localhost:8095/subjects"
wait_for "Kafka Connect"   "curl -fsS http://localhost:8096/connectors" 90

# ─── 4. Topic'leri oluştur ────────────────────────────────────
info "Topic'ler oluşturuluyor…"
create_topic() {
  docker exec week07_kafka /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server localhost:19092 \
    --create --if-not-exists --topic "$1" --partitions "$2" --replication-factor 1 >/dev/null
  echo "   • $1 ($2 partition)"
}
create_topic orders        3
create_topic orders.dlq    1
create_topic stock-events  3
create_topic orders-avro   3
ok "Topic'ler hazır"

# ─── 5. Debezium connector'ı kaydet ───────────────────────────
info "Debezium CDC connector'ı kaydediliyor…"
HTTP=$(curl -s -o /tmp/dbz_resp.txt -w "%{http_code}" -X PUT \
  -H "Content-Type: application/json" \
  --data @connectors/postgres-source.json \
  http://localhost:8096/connectors/shop-cdc-connector/config || echo "000")

case "$HTTP" in
  200|201) ok "Connector kaydedildi" ;;
  409)     warn "Connector zaten var, atlandı" ;;
  *)       warn "Connector kaydedilemedi (HTTP $HTTP). Yanıt:"; cat /tmp/dbz_resp.txt; echo "";
           warn "Elle denemek için: scripts/register_connector.sh" ;;
esac

sleep 5
STATE=$(curl -fsS http://localhost:8096/connectors/shop-cdc-connector/status 2>/dev/null \
        | grep -o '"state":"[A-Z]*"' | head -1 | cut -d'"' -f4 || echo "UNKNOWN")
info "Connector durumu: $STATE"

# ─── 6. Özet ──────────────────────────────────────────────────
cat <<SUMMARY

════════════════════════════════════════════════════════════
  ✅ Hafta 7 ortamı hazır
════════════════════════════════════════════════════════════

  🖥️  Arayüzler
     Kafka UI          http://localhost:8092
     Schema Registry   http://localhost:8095/subjects
     Kafka Connect     http://localhost:8096/connectors

  🔌 Bağlantılar
     Kafka bootstrap   localhost:9092
     PostgreSQL        localhost:5437  (kafka_user / kafka_pass / shopdb)

  ▶️  Sıradaki adım — Python bağımlılıkları:
     pip install -r requirements.txt

  🎬 "Wow" demosu (iki terminal açın):
     Terminal 1:  python scripts/cdc_watch.py
     Terminal 2:  python scripts/db_simulator.py
     → Veritabanındaki değişikliklerin anında Kafka'ya düştüğünü göreceksiniz.

  📖 Ders notu:     ./README.md
  📝 Alıştırmalar:  ./exercises/
  📋 Cheatsheet:    ./cheatsheets/

  🛑 Kapatma:  docker compose down        (veri kalır)
               docker compose down -v     (her şeyi siler)

SUMMARY
