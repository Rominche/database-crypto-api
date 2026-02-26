#!/bin/bash
# Verify that Flyway migrations created schemas sensitive and analytics
# Usage: ./scripts/verify-schemas.sh (run from project root)
set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi
POSTGRES_USER="${POSTGRES_USER:-dbuser}"
POSTGRES_DB="${POSTGRES_DB:-crypto_db}"

SCHEMAS=$(docker-compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c \
  "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('sensitive','analytics') ORDER BY schema_name" 2>/dev/null || true)

if echo "$SCHEMAS" | grep -q sensitive && echo "$SCHEMAS" | grep -q analytics; then
  echo "OK: Schemas sensitive and analytics exist"
  exit 0
else
  echo "FAIL: Missing schemas. Expected sensitive and analytics."
  echo "Found: $SCHEMAS"
  exit 1
fi
