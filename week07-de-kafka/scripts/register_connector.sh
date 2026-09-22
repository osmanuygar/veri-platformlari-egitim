#!/usr/bin/env bash
# Debezium connector'ını elle kaydet / güncelle / sil
set -euo pipefail
cd "$(dirname "$0")/.."

CONNECT="${CONNECT_URL:-http://localhost:8096}"
NAME="shop-cdc-connector"

case "${1:-register}" in
  register|update)
      echo "→ $NAME kaydediliyor…"
      curl -sS -X PUT -H "Content-Type: application/json" \
           --data @connectors/postgres-source.json \
           "$CONNECT/connectors/$NAME/config" | python3 -m json.tool
      ;;
  status)
      curl -sS "$CONNECT/connectors/$NAME/status" | python3 -m json.tool
      ;;
  list)
      curl -sS "$CONNECT/connectors" | python3 -m json.tool
      ;;
  restart)
      curl -sS -X POST "$CONNECT/connectors/$NAME/restart?includeTasks=true"
      echo "→ yeniden başlatıldı"
      ;;
  delete)
      curl -sS -X DELETE "$CONNECT/connectors/$NAME"
      echo "→ silindi"
      ;;
  *)
      echo "Kullanım: $0 [register|update|status|list|restart|delete]"
      exit 1
      ;;
esac
