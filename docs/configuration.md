# Configuration

Le fichier de configuration Homer se trouve dans `homer/assets/config.yml`.
Homer recharge automatiquement la config sans redémarrage Docker.

## Structure du fichier

```yaml
title: "Dashboard"       # Titre affiché en haut
subtitle: "Mes favoris"  # Sous-titre
columns: "3"             # Nombre de colonnes (ou "auto")
connectivityCheck: false # Désactivé — évite les faux négatifs sur localhost

services:
  - name: "Nom de la catégorie"
    icon: "fas fa-icon"
    items:
      - name: "Nom du lien"
        icon: "fas fa-icon"
        subtitle: "Description courte"
        url: "https://..."
        target: "_blank"   # Ouvre dans un nouvel onglet
```

## Ajouter une catégorie

```yaml
  - name: "Ma nouvelle catégorie"
    icon: "fas fa-folder"
    items:
      - name: "Mon site"
        icon: "fas fa-globe"
        subtitle: "Description"
        url: "https://example.com"
        target: "_blank"
```

## Ajouter un lien dans une catégorie existante

Ajouter un bloc `- name:` dans la liste `items:` de la catégorie cible :

```yaml
      - name: "Nouveau lien"
        icon: "fas fa-link"
        subtitle: "Description"
        url: "https://..."
        target: "_blank"
```

## Icônes disponibles

Homer utilise [Font Awesome 5](https://fontawesome.com/v5/search). Deux préfixes :

| Préfixe | Usage | Exemple |
|---|---|---|
| `fas` | Icônes solides (générales) | `fas fa-robot` |
| `fab` | Icônes de marques | `fab fa-github`, `fab fa-youtube` |

Icônes fréquentes pour ce dashboard :

```
fas fa-robot        IA générique
fas fa-comments     Chat
fas fa-chart-bar    Statistiques / consommation
fas fa-crown        Premium / Pro
fas fa-gem          Gemini
fas fa-book-open    NotebookLM
fab fa-github       GitHub
fas fa-code         Développement
fas fa-server       Service local
fas fa-sitemap      Arborescence / mind maps
fab fa-youtube      YouTube
fas fa-tools        Outils
```

## Utiliser un logo à la place d'une icône

Pour un service avec un favicon personnalisé, remplacer `icon:` par `logo:` :

```yaml
      - name: "Mon service"
        logo: "https://example.com/favicon.ico"
        subtitle: "Description"
        url: "https://example.com"
        target: "_blank"
```

## Appliquer les changements

Homer détecte les modifications du fichier et recharge automatiquement la page.
Si le rechargement ne se produit pas :

```bash
docker restart homer
```
