#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
ENV_TEMPLATE="$PROJECT_DIR/.env.template"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

create_network_if_not_exists() {
    local network_name="${EXTERNAL_NETWORK_NAME:-web}"
    log "Checking for network $network_name..."
    if ! docker network inspect "$network_name" >/dev/null 2>&1; then
        log "Network $network_name not found. Creating..."
        docker network create --attachable "$network_name"
    fi
    log "Network $network_name is ready."
}

create_volume_if_not_exists() {
    local volume_name="${SERVER_DATA_VOLUME_NAME:-portainer-server-data}"
    log "Checking for volume $volume_name..."
    if ! docker volume inspect "$volume_name" >/dev/null 2>&1; then
        log "Volume $volume_name not found. Creating..."
        docker volume create "$volume_name"
    fi
    log "Volume $volume_name is ready."
}

main() {
    if [ ! -f "$ENV_FILE" ]; then
        if [ -f "$ENV_TEMPLATE" ]; then
            log "Generating .env from template..."
            cp "$ENV_TEMPLATE" "$ENV_FILE"
            log "⚠️ Please edit $ENV_FILE and run 'make setup' again"
            exit 1
        else
            log "❌ No $ENV_TEMPLATE found. Cannot continue."
            exit 1
        fi
    else
        log ".env already exists"
    fi

    create_network_if_not_exists
    create_volume_if_not_exists

    log "Environment ready"
}

main "$@"