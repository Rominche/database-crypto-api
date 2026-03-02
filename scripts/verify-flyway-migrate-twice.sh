#!/bin/bash
# Verify that Flyway does not re-execute already-applied migrations (Task 3, Story 2.1)
# Scenario: run migrate twice, verify no duplicate execution
# Usage: ./scripts/verify-flyway-migrate-twice.sh (run from project root)
set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

echo "=== Verify Flyway migrate twice (no re-execution) ==="

# Ensure DB is up
docker-compose up -d postgres
echo "Waiting for PostgreSQL to be ready..."
RETRIES=30
until docker-compose exec -T postgres pg_isready -U "${POSTGRES_USER:-dbuser}" -d "${POSTGRES_DB:-crypto_db}" > /dev/null 2>&1; do
  RETRIES=$((RETRIES - 1))
  if [ "$RETRIES" -le 0 ]; then
    echo "ERROR: PostgreSQL did not become ready in time"
    exit 1
  fi
  sleep 2
done

# First migrate
echo "1. First migrate..."
docker-compose run --rm flyway migrate
COUNT1=$(docker-compose exec -T postgres psql -U "${POSTGRES_USER:-dbuser}" -d "${POSTGRES_DB:-crypto_db}" -t -c \
  "SELECT COUNT(*) FROM flyway_schema_history" | tr -d ' ')
if [ -z "$COUNT1" ]; then
  echo "ERROR: Could not query flyway_schema_history after 1st run"
  exit 1
fi
echo "   Migrations in schema_history after 1st run: $COUNT1"

# Second migrate (should not re-execute)
echo "2. Second migrate (should skip already-applied)..."
docker-compose run --rm flyway migrate
COUNT2=$(docker-compose exec -T postgres psql -U "${POSTGRES_USER:-dbuser}" -d "${POSTGRES_DB:-crypto_db}" -t -c \
  "SELECT COUNT(*) FROM flyway_schema_history" | tr -d ' ')
if [ -z "$COUNT2" ]; then
  echo "ERROR: Could not query flyway_schema_history after 2nd run"
  exit 1
fi
echo "   Migrations in schema_history after 2nd run: $COUNT2"

if [ "$COUNT1" = "$COUNT2" ]; then
  echo "OK: No duplicate execution. Count unchanged: $COUNT1"
  exit 0
else
  echo "FAIL: Count changed from $COUNT1 to $COUNT2 - migrations were re-executed"
  exit 1
fi
