#!/bin/bash
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

main() {
    log "Syncing with the remote repository (origin/main)..."
    git fetch origin
    git reset --hard origin/main
    log "Sync completed. Directory is clean and up-to-date."
}

main "$@"