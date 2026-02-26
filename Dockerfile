# PostgreSQL 16 - database-crypto-api
# Base image: postgres:16.12-bookworm (pinned minor version for reproducible builds)
# No secrets in image - credentials via .env at runtime (NFR-S2, NFR-R2)
FROM postgres:16.12-bookworm

LABEL org.opencontainers.image.title="database-crypto-api-postgres" \
      org.opencontainers.image.description="PostgreSQL 16 base image for database-crypto-api" \
      org.opencontainers.image.version="1.0.0"

# No extensions required for this story (TimescaleDB optional Phase 1)
# Image is minimal - no hardcoded credentials
