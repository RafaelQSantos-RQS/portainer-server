#!/bin/bash

echo ""
echo """
    ██████╗  ██████╗ ██████╗ ████████╗ █████╗ ██╗███╗   ██╗███████╗██████╗ 
    ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝██╔══██╗
    ██████╔╝██║   ██║██████╔╝   ██║   ███████║██║██╔██╗ ██║█████╗  ██████╔╝
    ██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║██║██║╚██╗██║██╔══╝  ██╔══██╗
    ██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║██║██║ ╚████║███████╗██║  ██║
    ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
    """
echo ""
echo "  📋  GENERAL"
echo "  ────────────────────────────────────────────────────────────────────"
echo "    make setup         Generate environment and create resources"
echo "    make sync        Sync with remote 'main' branch"
echo "    make compose-validate  Validate Docker Compose"
echo "    make swarm-validate    Validate Docker Swarm"
echo ""
echo "  🐳  DOCKER COMPOSE"
echo "  ────────────────────────────────────────────────────────────────────"
echo "    make compose-up        Start containers"
echo "    make compose-down     Stop containers"
echo "    make compose-restart  Restart containers"
echo "    make compose-logs     Show logs in real time"
echo "    make compose-status  Show container status"
echo ""
echo "  📦  IMAGES"
echo "  ────────────────────────────────────────────────────────────────────"
echo "    make pull           Pull the latest images"
echo ""
echo "  ☁️  DOCKER SWARM"
echo "  ────────────────────────────────────────────────────────────────────"
echo "    make swarm-deploy     Deploy Portainer to Swarm"
echo "    make swarm-remove   Remove Portainer from Swarm"
echo "    make swarm-status   Show stack status"
echo "    make swarm-logs    Show Swarm logs"
echo ""
echo "  ────────────────────────────────────────────────────────────────────"
echo ""