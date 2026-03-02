#!/bin/bash
# Test: validate run-migrations.sh script properties and behavior
# Usage: ./scripts/test-run-migrations.sh (run from project root)
set -e
cd "$(dirname "$0")/.."

PASS=0
FAIL=0
SCRIPT="scripts/run-migrations.sh"

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "pass" ]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Tests: run-migrations.sh ==="
echo ""

[ -f "$SCRIPT" ] \
  && check "script exists at $SCRIPT" "pass" \
  || check "script exists at $SCRIPT" "fail"

[ -x "$SCRIPT" ] \
  && check "script is executable" "pass" \
  || check "script is executable" "fail"

bash -n "$SCRIPT" 2>/dev/null \
  && check "bash syntax valid" "pass" \
  || check "bash syntax valid" "fail"

grep -q 'POSTGRES_HOST:-localhost' "$SCRIPT" \
  && check "defaults POSTGRES_HOST to localhost" "pass" \
  || check "defaults POSTGRES_HOST to localhost" "fail"

grep -q 'POSTGRES_PORT:-5432' "$SCRIPT" \
  && check "defaults POSTGRES_PORT to 5432" "pass" \
  || check "defaults POSTGRES_PORT to 5432" "fail"

grep -q 'POSTGRES_DB' "$SCRIPT" && grep -q 'POSTGRES_USER' "$SCRIPT" && grep -q 'POSTGRES_PASSWORD' "$SCRIPT" \
  && check "reads POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD" "pass" \
  || check "reads POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD" "fail"

grep -q 'jdbc:postgresql://' "$SCRIPT" \
  && check "builds FLYWAY_URL as jdbc:postgresql://" "pass" \
  || check "builds FLYWAY_URL as jdbc:postgresql://" "fail"

grep -q 'MAX_SECONDS=300' "$SCRIPT" \
  && check "NFR-P2: 5-min threshold check (MAX_SECONDS=300)" "pass" \
  || check "NFR-P2: 5-min threshold check (MAX_SECONDS=300)" "fail"

grep -q 'flyway/flyway:10-alpine' "$SCRIPT" \
  && check "uses flyway/flyway:10-alpine image" "pass" \
  || check "uses flyway/flyway:10-alpine image" "fail"

grep -q 'flyway.conf' "$SCRIPT" \
  && check "mounts flyway.conf into container" "pass" \
  || check "mounts flyway.conf into container" "fail"

grep -q '/flyway/sql' "$SCRIPT" \
  && check "mounts migrations/ to /flyway/sql" "pass" \
  || check "mounts migrations/ to /flyway/sql" "fail"

grep -q 'source .env' "$SCRIPT" \
  && check "loads .env if present" "pass" \
  || check "loads .env if present" "fail"

grep -qE 'flyway/flyway:[0-9]+-alpine migrate' "$SCRIPT" \
  && check "runs flyway migrate command" "pass" \
  || check "runs flyway migrate command" "fail"

grep -q 'POSTGRES_PASSWORD is required' "$SCRIPT" \
  && check "validates POSTGRES_PASSWORD is set" "pass" \
  || check "validates POSTGRES_PASSWORD is set" "fail"

grep -q 'host.docker.internal' "$SCRIPT" \
  && check "uses host.docker.internal for localhost (cross-platform)" "pass" \
  || check "uses host.docker.internal for localhost (cross-platform)" "fail"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1