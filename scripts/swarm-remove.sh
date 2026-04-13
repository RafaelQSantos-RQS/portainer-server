#!/bin/bash
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

main() {
    log "Removing Portainer from Swarm..."
    docker stack rm portainer_server
    log "Portainer removed from Swarm"
}

main "$@"