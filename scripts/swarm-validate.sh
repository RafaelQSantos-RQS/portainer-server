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
    echo "  ║                 SWARM VALIDATE                        ║"
    echo "  ╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "  📋  ARQUIVOS"
    echo "  ────────────────────────────────────────────────────────────────────"
    
    [ -f "$ENV_FILE" ] && check 0 ".env existe" || { check 1 ".env existe"; ((errors++)); }
    [ -f "$PROJECT_DIR/docker-stack.yml" ] && check 0 "docker-stack.yml existe" || { check 1 "docker-stack.yml existe"; ((errors++)); }
    
    echo ""
    echo "  ⚙️  VARIÁVEIS"
    echo "  ────────────────────────────────────────────────────────────────────"
    
    load_env_vars
    
    [ -n "$DOMAIN" ] && check 0 "DOMAIN definido" || { check 1 "DOMAIN definido"; ((errors++)); }
    [ -n "$PORTAINER_COMMUNITY_VERSION" ] && check 0 "PORTAINER_COMMUNITY_VERSION" || { check 1 "PORTAINER_COMMUNITY_VERSION"; ((errors++)); }
    [ -n "$PORTAINER_AGENT_VERSION" ] && check 0 "PORTAINER_AGENT_VERSION" || { check 1 "PORTAINER_AGENT_VERSION"; ((errors++)); }
    
    echo ""
    echo "  ☁️  SWARM"
    echo "  ────────────────────────────────────────────────────────────────────"
    
    docker info 2>/dev/null | grep -q "Swarm: active" && check 0 "Swarm ativo" || { check 1 "Swarm ativo"; ((errors++)); }
    
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