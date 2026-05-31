# Homer Dashboard

Dashboard de favoris web accessible depuis le bureau GNOME, servi en local par Docker.

## Architecture

```mermaid
%%{init: {"theme": "base", "themeVariables": {"background": "#ffffff"}}}%%
flowchart LR
    title: Dashboard ALM
    classDef startStop fill:#e1f5fe,stroke:#01579b,color:#000
    classDef data      fill:#fff3e0,stroke:#e65100,color:#000
    classDef logic     fill:#e8eaf6,stroke:#1a237e,color:#000

    A[Brave Browser\nmode app]:::startStop --> B[Homer\n127.0.0.1:8080]:::data
    B --> C[config.yml\nhomer/assets/]:::logic
    C --> D[IA]:::data
    C --> E[Développement]:::data
    C --> F[Outils]:::data
    C --> G[Médias]:::data

    subgraph Legend["Legend"]
        direction LR
        L1([Start / End]):::startStop
        L2[/Data · File/]:::data
        L3[Process]:::logic
    end
```

## Accès rapide

| Service | URL |
|---|---|
| Dashboard Homer | [http://127.0.0.1:8080](http://127.0.0.1:8080) |
| Documentation | `make docs` (port dynamique 8000–8050) |

## Configuration Docker

| Paramètre | Valeur |
|---|---|
| Image | `b4bz/homer:v26.4.2` |
| Port | `127.0.0.1:8080` (localhost uniquement) |
| Restart policy | `unless-stopped` |
| Volume | `homer/assets/ → /www/assets` (lecture/écriture) |
| Utilisateur | `UID 1000` (non-root) |

## Catégories configurées

| Catégorie | Liens |
|---|---|
| Intelligence Artificielle | Claude Chat, Claude API, Claude Pro, Gemini, NotebookLM |
| Développement | GitHub namnetes, Service local :8000 |
| Outils | WiseMapping |
| Médias | YouTube |

## Commandes

```bash
# Démarrer Homer
make homer-start

# Arrêter Homer
make homer-stop

# Voir les logs Homer
make homer-logs

# Lancer la doc MkDocs (dev)
make docs
```
