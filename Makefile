.DEFAULT_GOAL := help

ifneq (,$(wildcard ./.env))
	include ./.env
	export
endif

COMPOSE                 = docker compose
ENV_FILE                = .env
SCRIPTS_DIR           = scripts

LOG = @echo "[$$(date '+%Y-%m-%d %H:%M:%S')]"

.PHONY: help setup compose-up compose-down compose-restart compose-logs compose-status pull \
	swarm-deploy swarm-remove swarm-status swarm-logs \
	sync compose-validate swarm-validate

setup: ## 🛠️ Generate environment from template and create network/volume
	@bash $(SCRIPTS_DIR)/setup.sh

compose-up: ## 🚀 Start containers (Docker Compose)
	@bash $(SCRIPTS_DIR)/compose-up.sh

compose-down: ## 🛑 Stop containers (Docker Compose)
	@bash $(SCRIPTS_DIR)/compose-down.sh

compose-restart: ## 🔄 Restart containers (Docker Compose)
	@bash $(SCRIPTS_DIR)/compose-restart.sh

compose-logs: ## 📜 Show logs in real time (Docker Compose)
	@bash $(SCRIPTS_DIR)/compose-logs.sh

compose-status: ## 📊 Show container status (Docker Compose)
	@bash $(SCRIPTS_DIR)/compose-status.sh

pull: ## 📦 Pull the latest images
	@bash $(SCRIPTS_DIR)/pull.sh

compose-validate: ## ✅ Validate Docker Compose
	@bash $(SCRIPTS_DIR)/compose-validate.sh

swarm-validate: ## ☁️ Validate Docker Swarm
	@bash $(SCRIPTS_DIR)/swarm-validate.sh

swarm-deploy: ## 🐳 Deploy Portainer to Docker Swarm
	@bash $(SCRIPTS_DIR)/swarm-deploy.sh

swarm-remove: ## 🗑️ Remove Portainer from Docker Swarm
	@bash $(SCRIPTS_DIR)/swarm-remove.sh

swarm-status: ## 📊 Show Portainer stack status
	@bash $(SCRIPTS_DIR)/swarm-status.sh

swarm-logs: ## 📜 Show Portainer Swarm logs
	@bash $(SCRIPTS_DIR)/swarm-logs.sh

sync: ## 🔄 Syncs the local code with the remote 'main' branch (discards local changes!)
	@bash $(SCRIPTS_DIR)/sync.sh

help: ## 🤔 Show this help message
	@bash $(SCRIPTS_DIR)/help.sh
