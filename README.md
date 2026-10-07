# Tacos Factory – Gestion interne

Logiciel interne de The Tacos Factory Genève : coûts de revient au gramme près, recettes et marges, ventes, charges, tâches du gérant et du chef, journal de toutes les modifications.

- **Un seul fichier** `index.html`, sans étape de compilation.
- **Base de données et connexion** : Supabase (table `docs`, liste d'accès `members`).
- **Hébergement** : Cloudflare Pages, mis à jour automatiquement à chaque modification sur GitHub.

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | Tout le logiciel (interface, calculs, stockage) |
| `config.js` | Adresse et clé publique du projet Supabase |
| `supabase/schema.sql` | Création de la base et des règles d'accès, à lancer une fois |
| `manifest.json`, `icon-*.png` | Installation sur l'écran d'accueil du téléphone |
| `CLAUDE.md` | Consignes pour Claude Code |

## Mise en ligne (une seule fois, environ 20 minutes)

### 1. Base de données Supabase
1. Crée un compte sur [supabase.com](https://supabase.com), puis **New project**. Région : *Central EU (Frankfurt)* ou *Zurich* si proposée.
2. **SQL Editor > New query** : colle le contenu de `supabase/schema.sql`, remplace les deux e-mails à la fin par le tien et celui du chef, puis **Run**.
3. **Authentication > Sign In / Providers > Email** : désactive **Allow new users to sign up** (personne d'autre ne pourra créer de compte).
4. **Authentication > Users > Add user > Create new user** : crée ton compte et celui du chef (e-mail + mot de passe, coche *Auto Confirm User*).
5. **Project Settings > API** : copie *Project URL* et la clé *anon public* dans `config.js` (sur GitHub : ouvre le fichier, crayon ✏️, colle, *Commit changes*).

### 2. Hébergement Cloudflare Pages
1. Crée un compte sur [dash.cloudflare.com](https://dash.cloudflare.com).
2. **Workers & Pages > Create > Pages > Connect to Git**, choisis le dépôt `TacosInterne`.
3. Réglages de build : *Framework preset* **None**, *Build command* **vide**, *Build output directory* **/**. Puis **Save and Deploy**.
4. Le logiciel est en ligne sur `https://tacosinterne.pages.dev` (ou un nom proche).

### 3. Ton adresse (facultatif)
Dans le projet Pages : **Custom domains > Set up a custom domain**, par ex. `gestion.tacosfactory.ch`, puis ajoute l'entrée CNAME indiquée chez l'hébergeur du domaine.

### 4. Sur les téléphones
Ouvre l'adresse, connecte-toi, puis **Partager > Sur l'écran d'accueil** (iPhone) ou **⋮ > Ajouter à l'écran d'accueil** (Android). Le logiciel s'ouvre ensuite comme une application.

## Ajouter ou retirer une personne
- Ajouter : crée le compte dans **Authentication > Users** et ajoute l'e-mail dans **Table Editor > members**.
- Retirer : supprime la ligne dans `members` (l'accès est coupé immédiatement), puis le compte dans *Users*.

## Faire évoluer le logiciel avec Claude Code
1. Installe Claude Code et ouvre ce dépôt (`git clone https://github.com/Artan47/TacosInterne`).
2. Demande ce que tu veux, par ex. *« ajoute un module de relevés de température HACCP »*.
3. Vérifie le résultat en ouvrant `index.html` dans le navigateur (sans `config.js` rempli, il tourne en mode local avec des données de test).
4. Demande à Claude Code de faire le commit et le push : Cloudflare met le site à jour en une minute environ.

## Sauvegarde
**Réglages > Sauvegarde** : télécharge toutes les données dans un fichier JSON, ou réimporte une sauvegarde. Supabase garde aussi ses propres sauvegardes quotidiennes sur les offres payantes.

> Le dépôt est public : n'y mets jamais de données du restaurant (sauvegardes, exports) ni la clé `service_role`.
