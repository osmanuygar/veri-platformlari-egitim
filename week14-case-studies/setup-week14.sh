#!/usr/bin/env bash
# Hafta 14 — Örnek Vakalar
# Bu haftanın KENDİ docker-compose.yml'i yoktur; seçtiğiniz vakaya göre
# önceki haftaların servislerini birlikte kullanırsınız.
# Bu script sadece ortamınızı ve gerekli haftaların varlığını kontrol eder.
set -euo pipefail
cd "$(dirname "$0")"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }; info(){ echo -e "${BLUE}ℹ️  $*${NC}"; }; warn(){ echo -e "${YELLOW}⚠️  $*${NC}"; }; die(){ echo -e "${RED}❌ $*${NC}"; exit 1; }

echo ""; echo "════════════════════════════════════════"; echo "  Hafta 14 — Örnek Vakalar"; echo "════════════════════════════════════════"; echo ""

command -v docker >/dev/null 2>&1 || die "Docker bulunamadı."
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 gerekli."
docker info >/dev/null 2>&1 || die "Docker çalışmıyor."
ok "Docker hazır"

info "Kök dizindeki haftalar taranıyor…"
cd ..
FOUND=0
for d in week0[1-9]-* week1[0-3]-*; do
  if [ -d "$d" ] && [ -f "$d/README.md" ]; then
    FOUND=$((FOUND+1))
  fi
done
[ "$FOUND" -ge 13 ] && ok "$FOUND hafta klasörü bulundu" || warn "$FOUND hafta klasörü bulundu (13 bekleniyordu — eksik olabilir)"

cat <<SUMMARY

════════════════════════════════════════
  ✅ Hafta 14 hazır — sıradaki adım SİZDE
════════════════════════════════════════

  Bu hafta önceki 13 haftanın üzerine inşa edilir. Kendi altyapısı yoktur.

  1️⃣  Bir vaka seçin (README.md'deki 5 vakaya bakın)
  2️⃣  templates/case-study-brief-template.md'yi kopyalayıp doldurun
  3️⃣  templates/adr-template.md ile en az 1 mimari kararı yazılı hale getirin
  4️⃣  Gerekli haftaların servislerini başlatın:
      cheatsheets/combining-weeks-cheatsheet.md → 3 yöntemden birini seçin
  5️⃣  Demonuzu hazırlayın ve sunun

  📖 Ders notu (5 vaka detayı): ./README.md
  📋 Cheatsheet:  ./cheatsheets/combining-weeks-cheatsheet.md
  📝 Şablonlar:   ./templates/

SUMMARY
