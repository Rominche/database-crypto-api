#!/bin/bash
# Run Flyway migrations via CLI
# Usage: ./scripts/run-migrations.sh
# Works with postgres running locally or in Docker (cross-platform: Linux, macOS, Windows)
#
# POSTGRES_HOST=localhost → uses host.docker.internal inside container (reaches host's postgres)
# POSTGRES_HOST=postgres → use with: docker run --network <compose_network> to reach compose service
set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_DB="${POSTGRES_DB:-crypto_db}"
POSTGRES_USER="${POSTGRES_USER:-dbuser}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "ERROR: POSTGRES_PASSWORD is required. Set it in .env or export it."
  exit 1
fi

# From inside the Flyway container, localhost/127.0.0.1 must use host.docker.internal
# to reach postgres on the host (Docker Desktop or port-mapped container)
case "$POSTGRES_HOST" in
  localhost|127.0.0.1)
    FLYWAY_CONNECT_HOST="host.docker.internal"
    ;;
  *)
    FLYWAY_CONNECT_HOST="$POSTGRES_HOST"
    ;;
esac

FLYWAY_URL="jdbc:postgresql://${FLYWAY_CONNECT_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

echo "Running Flyway migrations..."
echo "  URL:  ${FLYWAY_URL}"
echo "  User: ${POSTGRES_USER}"

START_TIME=$(date +%s)

docker run --rm \
  -e FLYWAY_URL="${FLYWAY_URL}" \
  -e FLYWAY_USER="${POSTGRES_USER}" \
  -e FLYWAY_PASSWORD="${POSTGRES_PASSWORD}" \
  -v "$(pwd)/flyway.conf:/flyway/conf/flyway.conf:ro" \
  -v "$(pwd)/migrations:/flyway/sql:ro" \
  flyway/flyway:10-alpine migrate

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo "Migrations completed in ${ELAPSED}s"

MAX_SECONDS=300
if [ "$ELAPSED" -gt "$MAX_SECONDS" ]; then
  echo "WARNING: NFR-P2 violation — migration exceeded ${MAX_SECONDS}s threshold (actual: ${ELAPSED}s)"
  exit 1
fi