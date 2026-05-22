# Installation

Guide complet pour mettre en œuvre le dashboard sur une nouvelle machine,
de la récupération du projet jusqu'au démarrage automatique au boot.

---

## Prérequis

Vérifier que les outils suivants sont installés avant de commencer :

| Outil | Vérification | Installation |
|---|---|---|
| Git | `git --version` | `sudo apt install git` |
| Docker | `docker --version` | voir [docs.docker.com](https://docs.docker.com/engine/install/ubuntu/) |
| Make | `make --version` | `sudo apt install make` |

---

## Étape 1 — Cloner le dépôt

```bash
git clone git@github.com:namnetes/alm_dashboard.git ~/alm_dashboard
cd ~/alm_dashboard
```

!!! info "Clé SSH requise"
    Le dépôt utilise SSH. Si la commande échoue, vérifier que votre clé SSH
    est bien ajoutée à votre compte GitHub :
    ```bash
    ssh -T git@github.com
    ```
    Réponse attendue : `Hi namnetes! You've successfully authenticated…`

---

## Étape 2 — Démarrer Homer

```bash
make homer-start
```

Vérifier que le conteneur est bien lancé :

```bash
docker ps | grep homer
```

Homer est accessible sur [http://localhost:8080](http://localhost:8080).

!!! info "Configuration Docker appliquée"
    - **Image épinglée** : `b4bz/homer:v26.4.2` — évite les régressions
      silencieuses lors d'un `docker pull` ultérieur.
    - **Port restreint** : `-p 127.0.0.1:8080:8080` — Homer n'est accessible
      que depuis la machine locale, pas depuis le réseau local.
    - **Redémarrage automatique** : `--restart unless-stopped` — Homer
      redémarre automatiquement après un reboot (voir étape 3).

---

## Étape 3 — Démarrage automatique au boot

Le flag `--restart unless-stopped` fait redémarrer Homer automatiquement,
**mais seulement si le daemon Docker est lui-même actif au démarrage**.

Activer Docker au démarrage de la machine (à faire une seule fois) :

```bash
sudo systemctl enable docker
```

Vérifier que Docker est bien activé :

```bash
systemctl is-enabled docker
# Réponse attendue : enabled
```

À partir de là, Homer démarre automatiquement à chaque ouverture de session
sans aucune action manuelle.

!!! warning "Après un `make homer-stop`"
    `make homer-stop` supprime le conteneur. Docker ne peut pas le redémarrer
    automatiquement car il n'existe plus. Pour le relancer :
    ```bash
    make homer-start
    ```

---

## Étape 4 — Icône dans le dock GNOME (mode app)

Crée un raccourci qui ouvre Homer comme une application native dans Brave,
sans barre de navigation :

```bash
cat > ~/.local/share/applications/homer.desktop << 'EOF'
[Desktop Entry]
Name=Dashboard
Comment=Mes favoris
Exec=brave-browser --app=http://localhost:8080
Icon=internet-web-browser
Type=Application
Categories=Network;
StartupWMClass=localhost__8080
EOF
```

Puis dans GNOME : **Activités** → chercher "Dashboard" → clic droit →
**Épingler dans les favoris**.

---

## Étape 5 — Nouvel onglet Brave (optionnel)

Pour que chaque nouvel onglet Brave ouvre automatiquement Homer :

1. Installer l'extension
   [New Tab Redirect](https://chrome.google.com/webstore/detail/new-tab-redirect/)
   depuis le Chrome Web Store.
2. Configurer l'URL de redirection : `http://localhost:8080`.

---

## Étape 6 — Ulauncher — recherche rapide (optionnel)

Ulauncher (`Alt+Space`) permet de rechercher dans les favoris Brave directement
depuis le bureau.

```bash
sudo add-apt-repository ppa:agornostal/ulauncher
sudo apt update
sudo apt install ulauncher
```

Démarrage automatique : **Paramètres système** → **Applications au démarrage**
→ ajouter `ulauncher --hide-window`.

---

## Référence des commandes

| Commande | Effet |
|---|---|
| `make homer-start` | Démarre le conteneur Homer |
| `make homer-stop` | Arrête **et supprime** le conteneur |
| `make homer-restart` | Redémarre le conteneur sans le supprimer |
| `make homer-logs` | Affiche les logs en continu |

!!! tip "Différence stop vs restart"
    - `homer-stop` + `homer-start` : recrée le conteneur — utile si le chemin
      du volume a changé (ex. répertoire du projet déplacé).
    - `homer-restart` : redémarre le conteneur existant sans le recréer — plus
      rapide pour appliquer un changement de config.
