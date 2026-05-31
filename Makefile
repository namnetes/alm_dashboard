SHELL       := /bin/bash
.SHELLFLAGS := -euo pipefail -c

PID_FILE    := .mkdocs.pid
LOG_FILE    := .mkdocs.log
HOST        := 127.0.0.1
PORT        := $(shell \
    for p in $$(seq 8000 8050); do \
        lsof -ti:$$p >/dev/null 2>&1 || { echo $$p; break; }; \
    done)

HOMER_PORT  ?= 8080
HOMER_IMAGE := b4bz/homer:v26.4.2
HOMER_NAME  := homer

export DISABLE_MKDOCS_2_WARNING := true

RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[0;33m
BOLD   := \033[1m
RESET  := \033[0m

.DEFAULT_GOAL := help
.PHONY: help check-deps \
        homer-start homer-stop homer-restart homer-logs \
        docs docs-start docs-stop docs-build \
        install lint format check

# ── Macros internes ───────────────────────────────────────────────────────────

define require_cmd
	@command -v $(1) >/dev/null 2>&1 || { \
		printf "$(RED)Erreur$(RESET) : '$(1)' introuvable dans PATH.\n"; \
		exit 1; \
	}
endef

define check_docker_daemon
	@docker info >/dev/null 2>&1 || { \
		printf "$(RED)Erreur$(RESET) : le daemon Docker ne répond pas.\n"; \
		printf "  → Lancez-le : systemctl start docker\n"; \
		exit 1; \
	}
endef

define check_container_exists
	@docker ps -a --format '{{.Names}}' | grep -q "^$(HOMER_NAME)$$" || { \
		printf "$(RED)Erreur$(RESET) : aucun conteneur '$(HOMER_NAME)' trouvé.\n"; \
		printf "  → Lancez d'abord : make homer-start\n"; \
		exit 1; \
	}
endef

define check_mkdocs_yml
	@[ -f mkdocs.yml ] || { \
		printf "$(RED)Erreur$(RESET) : mkdocs.yml introuvable" \
		    " dans le répertoire courant.\n"; \
		exit 1; \
	}
endef

define check_port_available
	@[ -n "$(PORT)" ] || { \
		printf "$(RED)Erreur$(RESET) : aucun port libre" \
		    " disponible entre 8000 et 8050.\n"; \
		exit 1; \
	}
endef

# ── Aide ──────────────────────────────────────────────────────────────────────

help:
	@printf "$(BOLD)Homer Dashboard$(RESET) — cibles disponibles\n\n"
	@printf "  $(BOLD)homer-start$(RESET)    Démarre le conteneur Homer\n"
	@printf "  $(BOLD)homer-stop$(RESET)     Arrête et supprime" \
	    " le conteneur Homer\n"
	@printf "  $(BOLD)homer-restart$(RESET)  Redémarre le conteneur Homer\n"
	@printf "  $(BOLD)homer-logs$(RESET)     Affiche les logs Homer en continu\n\n"
	@printf "  $(BOLD)docs$(RESET)           Lance MkDocs en mode" \
	    " développement (foreground)\n"
	@printf "  $(BOLD)docs-start$(RESET)     Lance MkDocs en arrière-plan\n"
	@printf "  $(BOLD)docs-stop$(RESET)      Arrête MkDocs lancé en arrière-plan\n"
	@printf "  $(BOLD)docs-build$(RESET)     Compile la documentation statique\n\n"
	@printf "  $(BOLD)check-deps$(RESET)     Vérifie que les outils" \
	    " requis sont disponibles\n\n"
	@printf "  $(BOLD)install$(RESET)        Installe les dépendances" \
	    " Python (uv sync)\n"
	@printf "  $(BOLD)lint$(RESET)           Lint ruff\n"
	@printf "  $(BOLD)format$(RESET)         Formate avec ruff\n"
	@printf "  $(BOLD)check$(RESET)          Exécute lint\n"

# ── Vérification des dépendances ──────────────────────────────────────────────

check-deps:
	$(call require_cmd,docker)
	$(call require_cmd,uv)
	$(call require_cmd,lsof)
	@printf "$(GREEN)OK$(RESET) Toutes les dépendances sont disponibles.\n"

# ── Homer ─────────────────────────────────────────────────────────────────────

homer-start:
	$(call require_cmd,docker)
	$(call check_docker_daemon)
	@[ -d "$(CURDIR)/homer/assets" ] || { \
		printf "$(RED)Erreur$(RESET) : répertoire assets introuvable.\n"; \
		printf "  → Attendu : $(CURDIR)/homer/assets\n"; \
		exit 1; \
	}
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(HOMER_NAME)$$"; then \
		printf "$(YELLOW)Attention$(RESET) : le conteneur" \
		    " '$(HOMER_NAME)' existe déjà.\n"; \
		printf "Redémarrer ? [o/N] "; \
		read answer </dev/tty; \
		if [ "$$answer" = "o" ] || [ "$$answer" = "O" ]; then \
			docker restart $(HOMER_NAME) >/dev/null || { \
				printf "$(RED)Erreur$(RESET) : échec du redémarrage.\n"; exit 1; \
			}; \
			printf "$(GREEN)OK$(RESET) Homer redémarré" \
			    " → http://127.0.0.1:$(HOMER_PORT)\n"; \
		else \
			printf "Annulé.\n"; \
		fi; \
	else \
		docker run -d \
			--name $(HOMER_NAME) \
			--restart unless-stopped \
			-p 127.0.0.1:$(HOMER_PORT):8080 \
			-v $(CURDIR)/homer/assets:/www/assets \
			$(HOMER_IMAGE) >/dev/null || { \
				printf "$(RED)Erreur$(RESET) : échec du" \
				    " démarrage du conteneur.\n"; exit 1; \
			}; \
		sleep 1; \
		docker ps --filter "name=^$(HOMER_NAME)$$" --format '{{.Names}}' \
			| grep -q "^$(HOMER_NAME)$$" || { \
				printf "$(RED)Erreur$(RESET) : le conteneur a planté au démarrage.\n"; \
				printf "  → Consultez les logs : docker logs $(HOMER_NAME)\n"; \
				exit 1; \
			}; \
		printf "$(GREEN)OK$(RESET) Homer démarré" \
		    " → http://127.0.0.1:$(HOMER_PORT)\n"; \
	fi

homer-stop:
	$(call require_cmd,docker)
	$(call check_docker_daemon)
	@if ! docker ps -a --format '{{.Names}}' | grep -q "^$(HOMER_NAME)$$"; then \
		printf "$(YELLOW)Attention$(RESET) : conteneur '$(HOMER_NAME)' absent.\n"; \
		exit 0; \
	fi
	@docker stop $(HOMER_NAME) >/dev/null || { \
		printf "$(RED)Erreur$(RESET) : impossible d'arrêter '$(HOMER_NAME)'.\n"; \
		printf "  → Forcer l'arrêt : docker kill $(HOMER_NAME)\n"; \
		exit 1; \
	}
	@docker rm $(HOMER_NAME) >/dev/null || { \
		printf "$(RED)Erreur$(RESET) : impossible de supprimer '$(HOMER_NAME)'.\n"; \
		exit 1; \
	}
	@printf "$(GREEN)OK$(RESET) Homer arrêté et supprimé.\n"

homer-restart:
	$(call require_cmd,docker)
	$(call check_docker_daemon)
	$(call check_container_exists)
	@docker restart $(HOMER_NAME) >/dev/null || { \
		printf "$(RED)Erreur$(RESET) : échec du redémarrage de '$(HOMER_NAME)'.\n"; \
		printf "  → Consultez les logs : docker logs $(HOMER_NAME)\n"; \
		exit 1; \
	}
	@printf "$(GREEN)OK$(RESET) Homer redémarré → http://127.0.0.1:$(HOMER_PORT)\n"

homer-logs:
	$(call require_cmd,docker)
	$(call check_docker_daemon)
	$(call check_container_exists)
	@docker ps --filter "name=^$(HOMER_NAME)$$" --format '{{.Names}}' \
		| grep -q "^$(HOMER_NAME)$$" || { \
			printf "$(YELLOW)Attention$(RESET) : '$(HOMER_NAME)' n'est pas actif.\n"; \
			printf "  → Démarrez-le : make homer-start\n"; \
			exit 1; \
		}
	docker logs -f $(HOMER_NAME)

# ── Python / uv ───────────────────────────────────────────────────────────────

install:
	$(call require_cmd,uv)
	uv sync

lint:
	$(call require_cmd,uv)
	uv run --no-project ruff check .

format:
	$(call require_cmd,uv)
	uv run --no-project ruff format .

check: lint
	@printf "$(GREEN)OK$(RESET) Tous les contrôles ont réussi.\n"

# ── MkDocs ────────────────────────────────────────────────────────────────────

docs:
	$(call require_cmd,uv)
	$(call check_mkdocs_yml)
	$(call check_port_available)
	uv run mkdocs serve --dev-addr $(HOST):$(PORT)

docs-start:
	$(call require_cmd,uv)
	$(call check_mkdocs_yml)
	$(call check_port_available)
	@if [ -f $(PID_FILE) ] && kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
		printf "$(YELLOW)Attention$(RESET) : MkDocs tourne déjà" \
		    " (PID $$(cat $(PID_FILE))).\n"; \
		printf "  → Arrêtez-le d'abord : make docs-stop\n"; \
	else \
		rm -f $(PID_FILE); \
		uv run mkdocs serve --dev-addr $(HOST):$(PORT) > $(LOG_FILE) 2>&1 & \
		echo $$! > $(PID_FILE); \
		sleep 1; \
		if kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
			printf "$(GREEN)OK$(RESET) MkDocs démarré → http://$(HOST):$(PORT)\n"; \
		else \
			printf "$(RED)Erreur$(RESET) : MkDocs a planté au démarrage.\n"; \
			printf "  → Consultez les logs : cat $(LOG_FILE)\n"; \
			rm -f $(PID_FILE); \
			exit 1; \
		fi; \
	fi

docs-stop:
	@if [ ! -f $(PID_FILE) ]; then \
		printf "$(YELLOW)Attention$(RESET) : aucun PID — MkDocs ne tourne pas.\n"; \
		exit 0; \
	fi
	@PID=$$(cat $(PID_FILE)); \
	if kill -0 $$PID 2>/dev/null; then \
		kill $$PID && printf "$(GREEN)OK$(RESET) MkDocs arrêté (PID $$PID).\n"; \
	else \
		printf "$(YELLOW)Attention$(RESET) : processus $$PID" \
		    " introuvable (déjà arrêté ?).\n"; \
	fi; \
	rm -f $(PID_FILE)

docs-build:
	$(call require_cmd,uv)
	$(call check_mkdocs_yml)
	@uv run mkdocs build || { \
		printf "$(RED)Erreur$(RESET) : la compilation a échoué." \
		    " Voir la sortie ci-dessus.\n"; \
		exit 1; \
	}
	@printf "$(GREEN)OK$(RESET) Documentation compilée dans site/\n"
