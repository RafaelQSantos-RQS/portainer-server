#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

main() {
    log "Deploying Portainer to Swarm..."
    env $(grep -v '^#' "$ENV_FILE" | xargs) docker stack deploy -c docker-stack.yml portainer_server
    log "Portainer deployed to Swarm"
}

main "$@"