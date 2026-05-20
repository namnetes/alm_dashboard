# Installation

## Prérequis

- Docker installé et démarré
- Brave Browser
- GNOME Shell (Ubuntu 24.04+)

## 1. Démarrer Homer

Depuis la racine du projet :

```bash
make homer-start
```

Vérification :

```bash
docker ps | grep homer
```

Homer est accessible sur [http://localhost:8080](http://localhost:8080).

!!! info "Configuration Docker appliquée"
    - **Image épinglée** : `b4bz/homer:v26.4.2` — évite les régressions
      silencieuses lors d'un `docker pull` ultérieur.
    - **Port restreint** : `-p 127.0.0.1:8080:8080` — Homer n'est accessible
      que depuis la machine locale, pas depuis le réseau local.

## 2. Icône dans le dock GNOME (mode app)

Crée un fichier `.desktop` pour lancer Homer comme une application native sans
barre de navigation Brave :

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

## 3. Nouvel onglet Brave (optionnel)

Installer l'extension
[New Tab Redirect](https://chrome.google.com/webstore/detail/new-tab-redirect/)
depuis le Chrome Web Store, puis configurer l'URL : `http://localhost:8080`.

## 4. Démarrage automatique avec Docker

Le flag `--restart unless-stopped` dans `make homer-start` garantit que Homer
redémarre automatiquement après un reboot, tant que le daemon Docker est actif.

Pour activer Docker au démarrage :

```bash
sudo systemctl enable docker
```

## 5. Ulauncher — recherche rapide (optionnel)

Ulauncher permet de rechercher dans les favoris Brave avec `Alt+Space`.

```bash
sudo add-apt-repository ppa:agornostal/ulauncher
sudo apt update
sudo apt install ulauncher
```

Démarrage automatique : **Paramètres système** → **Applications au démarrage**
→ ajouter `ulauncher --hide-window`.
