# Tournoi Romainville

Site web du Tournoi Romainville - Edition 2026

## Stack

- **Front** : HTML / CSS / JS vanilla avec animations
- **Base de donnees** : Supabase (Postgres + Realtime + Auth)
- **Hebergement** : Netlify (deploy auto depuis GitHub)

## Structure

```
tournoi-romainville/
  app/
    index.html        # Site public complet (front)
  supabase/
    migrations/
      001_init.sql    # Schema DB + donnees initiales
  netlify.toml        # Config deploy Netlify
  README.md
```

## Poules

| Poule A | Poule B |
|---|---|
| PSG | Real Madrid |
| Arsenal | Man City |
| Barcelone | Bayern |

Format : aller-retour dans chaque poule (12 matchs au total)

## Acces admin

URL secrete : `[url-du-site]#admin-secret`
Mot de passe configure dans le fichier HTML.

## Deploy

1. Creer un projet sur [supabase.com](https://supabase.com)
2. Executer `supabase/migrations/001_init.sql` dans le SQL Editor
3. Connecter ce repo a [Netlify](https://netlify.com)
4. Publish directory : `app`
5. Remplacer les cles Supabase dans `app/index.html`
6. Generer le QR code vers l URL Netlify
