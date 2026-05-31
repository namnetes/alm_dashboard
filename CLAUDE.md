# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Personal web bookmarks dashboard using **Homer** (Docker) + MkDocs documentation.

- Homer serves a static bookmarks page at `http://127.0.0.1:8080`
- All bookmarks/services are configured in `homer/assets/config.yml`
- Homer auto-reloads config on save — no Docker restart needed for config changes

## Commands

```bash
make                # show all available targets (default goal)
make check-deps     # verify docker, uv, lsof are present

# Homer container
make homer-start    # create and start (prompts if container already exists)
make homer-stop     # stop and remove container
make homer-restart  # restart existing container (faster, keeps the container)
make homer-logs     # follow logs

# Python / MkDocs deps
make install        # uv sync
make lint           # ruff check (no fix)
make format         # ruff format
make check          # alias for lint
```

MkDocs commands (`docs`, `docs-start`, `docs-stop`, `docs-build`) follow the
standard pattern defined in the global CLAUDE.md.

## Architecture

```
homer/
  assets/
    config.yml      ← Homer config: title, columns, services/items (bookmarks)
docs/               ← MkDocs source pages
mkdocs.yml          ← MkDocs config (Material theme)
pyproject.toml      ← MkDocs deps (no application Python code)
Makefile            ← Homer + MkDocs targets
```

## Homer config structure

`homer/assets/config.yml` schema:

```yaml
title: "Dashboard"
subtitle: "Mes favoris"
logo: "logo.png"           # file placed in homer/assets/
header: true
footer: false
columns: "3"
connectivityCheck: false   # keep false — avoids false negatives on localhost

defaults:
  layout: columns
  colorTheme: auto          # auto | light | dark

services:
  - name: "Category name"
    icon: "fas fa-folder"
    items:
      - name: "Link name"
        icon: "fas fa-robot"   # Font Awesome 5: fas (solid) or fab (brand)
        subtitle: "Short description"
        url: "https://..."
        target: "_blank"
```

Replace `icon:` with `logo: "https://example.com/favicon.ico"` to use a remote favicon.

## Docker details

| Parameter | Value |
|---|---|
| Image | `b4bz/homer:v26.4.2` (pinned) |
| Port | `127.0.0.1:8080` (localhost only) |
| Volume | `homer/assets/ → /www/assets` |
| Restart policy | `unless-stopped` |

`HOMER_PORT` is overridable: `make homer-start HOMER_PORT=9090`
