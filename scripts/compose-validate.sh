#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}[X]${NC} $message"
    else
        echo -e "${RED}[ ]${NC} $message"
    fi
}

load_env_vars() {
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    fi
}

main() {
    local errors=0
    
    echo ""
    echo "  ╔══════════════════════════════════════════════════════════════════╗"
    echo "  ║                COMPOSE VALIDATE                       ║"
    echo "  ╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "  📋  ARQUIVOS"
    echo "  ────────────────────────────────────────────────────────────────────"
    
    [ -f "$ENV_FILE" ] && check 0 ".env existe" || { check 1 ".env existe"; ((errors++)); }
    [ -f "$PROJECT_DIR/docker-compose.yaml" ] && check 0 "docker-compose.yaml existe" || { check 1 "docker-compose.yaml existe"; ((errors++)); }
    
    echo ""
    echo "  ⚙️  VARIÁVEIS"
    echo "  ────────────────────────────────────────────────────────────────────"
    
    load_env_vars
    
    [ -n "$DOMAIN" ] && check 0 "DOMAIN definido" || { check 1 "DOMAIN definido"; ((errors++)); }
    [ -n "$EXTERNAL_NETWORK_NAME" ] && check 0 "EXTERNAL_NETWORK_NAME" || { check 1 "EXTERNAL_NETWORK_NAME"; ((errors++)); }
    [ -n "$SERVER_DATA_VOLUME_NAME" ] && check 0 "SERVER_DATA_VOLUME_NAME" || { check 1 "SERVER_DATA_VOLUME_NAME"; ((errors++)); }
    [ -n "$PORTAINER_COMMUNITY_VERSION" ] && check 0 "PORTAINER_COMMUNITY_VERSION" || { check 1 "PORTAINER_COMMUNITY_VERSION"; ((errors++)); }
    
    echo ""
    echo "  🌐  RECURSOS"
    echo "  ────────────────────────────────────────────────────────────────────"
    
    docker network inspect "${EXTERNAL_NETWORK_NAME:-web}" >/dev/null 2>&1 && check 0 "Rede '${EXTERNAL_NETWORK_NAME:-web}'" || { check 1 "Rede '${EXTERNAL_NETWORK_NAME:-web}'"; ((errors++)); }
    docker volume inspect "${SERVER_DATA_VOLUME_NAME:-portainer-server-data}" >/dev/null 2>&1 && check 0 "Volume '${SERVER_DATA_VOLUME_NAME:-portainer-server-data}'" || { check 1 "Volume '${SERVER_DATA_VOLUME_NAME:-portainer-server-data}'"; ((errors++)); }
    
    echo ""
    echo "  🐳  IMAGENS"
    echo "  ────────────────────────────────────────────────────────────────────"
    
    docker image inspect "portainer/portainer-ce:${PORTAINER_COMMUNITY_VERSION:-lts}" >/dev/null 2>&1 && check 0 "Imagem portainer-ce" || { check 1 "Imagem portainer-ce"; ((errors++)); }
    
    echo ""
    echo "  ═══════════════════════════════════════════════════════════════════"
    echo ""
    
    if [ "$errors" -eq 0 ]; then
        echo -e "  ${GREEN}✓ Validate OK!${NC} [Enter]"
    else
        echo -e "  ${RED}✗ $errors problema(s)${NC} [Enter]"
    fi
    echo ""
    
    read -r
}

main "$@"