# Consignes pour Claude Code

Logiciel interne de The Tacos Factory Genève (restaurant). Utilisateurs : le gérant et le chef cuisinier, tous deux administrateurs. Interface et textes en **français (Suisse)**, montants en **CHF**, tutoiement.

## Architecture
- Tout est dans `index.html` : CSS, puis un seul `<script>` (vanilla JS, pas de framework, pas de build).
- `config.js` définit `window.TF_CONFIG` (URL + clé anon Supabase). Vide → mode local (localStorage), pratique pour tester.
- Données : table Supabase `docs (collection, id, data jsonb)`. Accès réservé aux e-mails de `members` (RLS, voir `supabase/schema.sql`).
- Tout passe par l'objet `Store` : `watch(col, cb, filter)`, `set`, `update` (fusion superficielle), `del`, `get`, `all`. Ne pas appeler Supabase ailleurs.
- Collections : `ingredients`, `recipes` (type `sold` ou `prep`), `charges`, `tasks`, `sales` (id = date AAAA-MM-JJ), `team` (id = id utilisateur), `settings` (doc `main`), `journal` (id = `date_utilisateur`, tableau `entries`).
- État en mémoire : `S` (listes) et `IX` (index par id). Vues : fonctions `view*` dans `VIEWS`, actions dans `ACT` via `data-act`.

## Règles
- **Toute modification de données doit appeler `log(action, détail)`** : le journal est une exigence du gérant.
- Les coûts sont HT ; les prix de vente sont TTC (TVA 8.1 % sur place, 2.6 % à l'emporter par défaut).
- Une tâche non cochée est reportée au jour suivant (`carryOver`).
- Couleurs de la marque : noir `#1B1A1A`, rouge `#C8322B`, jaune `#F4E04D`. Garder vert/orange/rouge pour le food cost.
- Mobile d'abord (le chef l'utilise en cuisine sur téléphone), cibles tactiles de 44 px minimum.
- Ne jamais committer de données réelles ni la clé `service_role` : le dépôt est public.
- Vérifier la syntaxe avant de committer : extraire le script et lancer `node --check`.

## Déploiement
Push sur `main` → Cloudflare Pages redéploie automatiquement. Changement de base de données → ajouter le SQL dans `supabase/` et le signaler au gérant (à lancer dans Supabase > SQL Editor).
