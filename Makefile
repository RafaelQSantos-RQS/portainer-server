.DEFAULT_GOAL := help

ifneq (,$(wildcard ./.env))
	include ./.env
	export
endif

COMPOSE                 = docker compose
ENV_FILE                = .env
ENV_TEMPLATE            = .env.template
EXTERNAL_NETWORK_NAME   ?= web
SERVER_DATA_VOLUME_NAME ?= portainer-server-data

LOG = @echo "[$$(date '+%Y-%m-%d %H:%M:%S')]"

.PHONY: help setup compose-up compose-down compose-restart compose-logs compose-status compose-pull \
	swarm-deploy swarm-remove swarm-status swarm-logs \
	sync validate \
	_create-network-if-not-exists _create-volume-if-not-exists

setup: ## 🛠️ Generate environment from template and create network/volume
	@if [ ! -f $(ENV_FILE) ]; then \
		if [ -f $(ENV_TEMPLATE) ]; then \
			echo "==> Generating $(ENV_FILE) from template"; \
			cp $(ENV_TEMPLATE) $(ENV_FILE); \
			echo "⚠️ Please edit $(ENV_FILE) and run 'make setup' again"; \
			exit 1; \
		else \
			echo "❌ No $(ENV_TEMPLATE) found. Cannot continue."; \
			exit 1; \
		fi \
	else \
		echo "==> $(ENV_FILE) already exists"; \
	fi

	@$(MAKE) _create-network-if-not-exists
	@$(MAKE) _create-volume-if-not-exists

	$(LOG) "Environment ready"

_create-network-if-not-exists:
	$(LOG) "Checking for network $(EXTERNAL_NETWORK_NAME)..."
	@docker network inspect $(EXTERNAL_NETWORK_NAME) >/dev/null 2>&1 || \
		($(LOG) "Network $(EXTERNAL_NETWORK_NAME) not found. Creating..." && docker network create --attachable $(EXTERNAL_NETWORK_NAME))
	$(LOG) "Network $(EXTERNAL_NETWORK_NAME) is ready."

_create-volume-if-not-exists:
	$(LOG) "Checking for volume $(SERVER_DATA_VOLUME_NAME)..."
	@docker volume inspect $(SERVER_DATA_VOLUME_NAME) >/dev/null 2>&1 || \
		($(LOG) "Volume $(SERVER_DATA_VOLUME_NAME) not found. Creating..." && docker volume create $(SERVER_DATA_VOLUME_NAME))
	$(LOG) "Volume $(SERVER_DATA_VOLUME_NAME) is ready."

compose-up: ## 🚀 Start containers (Docker Compose)
	$(LOG) "Starting containers..."
	@$(COMPOSE) --env-file $(ENV_FILE) up -d --remove-orphans
	$(LOG) "Containers started"

compose-down: ## 🛑 Stop containers (Docker Compose)
	$(LOG) "Stopping containers..."
	@$(COMPOSE) --env-file $(ENV_FILE) down
	$(LOG) "Containers stopped"

compose-restart: compose-down compose-up ## 🔄 Restart containers (Docker Compose)

compose-logs: ## 📜 Show logs in real time (Docker Compose)
	@$(COMPOSE) --env-file $(ENV_FILE) logs -f

compose-status: ## 📊 Show container status (Docker Compose)
	@$(COMPOSE) --env-file $(ENV_FILE) ps

compose-pull: ## 📦 Pull the latest images (Docker Compose)
	$(LOG) "Pulling latest images..."
	@$(COMPOSE) pull
	$(LOG) "Images pulled"

validate: ## ✅ Validate the Docker Compose configuration syntax
	@$(COMPOSE) --env-file $(ENV_FILE) config

swarm-deploy: ## 🐳 Deploy Portainer to Docker Swarm
	$(LOG) "Deploying Portainer to Swarm..."
	@env $(cat $(ENV_FILE) | grep -v '^#' | xargs) docker stack deploy -c docker-stack.yml portainer_server
	$(LOG) "Portainer deployed to Swarm"

swarm-remove: ## 🗑️ Remove Portainer from Docker Swarm
	$(LOG) "Removing Portainer from Swarm..."
	@docker stack rm portainer_server
	$(LOG) "Portainer removed from Swarm"

swarm-status: ## 📊 Show Portainer stack status
	@docker stack ps portainer_server

swarm-logs: ## 📜 Show Portainer Swarm logs
	@docker service logs portainer_server_server -f --tail 100

sync: ## 🔄 Syncs the local code with the remote 'main' branch (discards local changes!)
	$(LOG) "Syncing with the remote repository (origin/main)..."
	@git fetch origin
	@git reset --hard origin/main
	$(LOG) "Sync completed. Directory is clean and up-to-date."

help: ## 🤔 Show this help message
	@echo ""
	@echo "  ╔══════════════════════════════════════════════════════════════════╗"
	@echo "  ║                    PORTAINER MANAGEMENT                           ║"
	@echo "  ╚══════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "  📋  GENERAL"
	@echo "  ────────────────────────────────────────────────────────────────────"
	@echo "    make setup             Generate environment and create resources"
	@echo "    make sync              Sync with remote 'main' branch"
	@echo "    make validate          Validate Docker Compose configuration"
	@echo ""
	@echo "  🐳  DOCKER COMPOSE"
	@echo "  ────────────────────────────────────────────────────────────────────"
	@echo "    make compose-up        Start containers"
	@echo "    make compose-down      Stop containers"
	@echo "    make compose-restart   Restart containers"
	@echo "    make compose-logs      Show logs in real time"
	@echo "    make compose-status    Show container status"
	@echo "    make compose-pull      Pull the latest images"
	@echo ""
	@echo "  ☁️  DOCKER SWARM"
	@echo "  ────────────────────────────────────────────────────────────────────"
	@echo "    make swarm-deploy     Deploy Portainer to Swarm"
	@echo "    make swarm-remove     Remove Portainer from Swarm"
	@echo "    make swarm-status     Show stack status"
	@echo "    make swarm-logs      Show Swarm logs"
	@echo ""
	@echo "  ────────────────────────────────────────────────────────────────────"
	@echo ""
