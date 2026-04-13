#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

main() {
    log "Restarting containers..."
    docker compose --env-file "$ENV_FILE" down
    docker compose --env-file "$ENV_FILE" up -d --remove-orphans
    log "Containers restarted"
}

main "$@"