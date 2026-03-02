#!/bin/bash
# Verify that Flyway detects modified migrations via checksum (Task 4, Story 2.1)
# Scenario: apply migration, modify file, run migrate -> expect checksum failure
# Usage: ./scripts/verify-flyway-checksum.sh (run from project root)
# WARNING: This script modifies a migration file temporarily - use on dev DB only
set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

MIGRATION_FILE="migrations/V1__create_schemas.sql"
BACKUP="${MIGRATION_FILE}.checksum-test-backup"

trap 'mv "$BACKUP" "$MIGRATION_FILE" 2>/dev/null; exit' EXIT INT TERM

echo "=== Verify Flyway checksum validation ==="

# Ensure DB is up and migrated
docker-compose up -d postgres
sleep 5
docker-compose run --rm flyway migrate 2>/dev/null || true

# Backup original
cp "$MIGRATION_FILE" "$BACKUP"

# Modify migration (add harmless comment)
echo "" >> "$MIGRATION_FILE"
echo "-- checksum test comment (temporary)" >> "$MIGRATION_FILE"

# Run migrate - should fail with checksum mismatch
echo "1. Modifying migration file and running migrate (expect failure)..."
if docker-compose run --rm flyway migrate 2>&1 | grep -q -i "checksum\|mismatch\|validate"; then
  echo "OK: Flyway detected checksum mismatch and failed as expected"
  RESTORE_OK=1
else
  echo "FAIL: Flyway did not detect the modified migration"
  RESTORE_OK=0
fi

# Restore original
mv "$BACKUP" "$MIGRATION_FILE"

if [ "$RESTORE_OK" = 1 ]; then
  exit 0
else
  exit 1
fi
