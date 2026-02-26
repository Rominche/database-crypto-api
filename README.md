# database-crypto-api

API de base de données pour le projet crypto. PostgreSQL 16 avec Flyway pour les migrations.

## Prérequis

- **Docker** 20+ ([installation](https://docs.docker.com/get-docker/))
- **Docker Compose** v2+ (inclus avec Docker Desktop ou [installable séparément](https://docs.docker.com/compose/install/))

## Variables d'environnement

Copiez `.env.example` vers `.env` et adaptez les valeurs :

| Variable | Description | Exemple |
|----------|-------------|---------|
| `POSTGRES_USER` | Utilisateur PostgreSQL | `dbuser` |
| `POSTGRES_PASSWORD` | Mot de passe (à remplacer) | `changeme_secure_password` |
| `POSTGRES_DB` | Nom de la base | `crypto_db` |
| `POSTGRES_PORT` | Port exposé (optionnel, défaut 5432) | `5432` |
| `POSTGRES_HOST` | Hôte pour Flyway (optionnel, défaut `postgres`) | `postgres` |

Voir [.env.example](.env.example) pour le modèle complet.

## Premier démarrage

**Durée attendue : < 15 minutes**

1. **Cloner le dépôt**
   ```bash
   git clone <url-du-repo> database-crypto-api
   cd database-crypto-api
   ```

2. **Configurer les variables**
   ```bash
   cp .env.example .env
   # Éditer .env avec vos valeurs (POSTGRES_PASSWORD obligatoire)
   ```

3. **Démarrer les services**
   ```bash
   docker-compose up -d
   ```

4. **Vérifier les migrations**
   Les migrations Flyway s'exécutent automatiquement au démarrage. Pour suivre la progression :
   ```bash
   docker-compose logs flyway
   ```
   Attendre la fin des migrations (ex. `Successfully applied 1 migration`).

5. **Vérifier les schémas créés**
   ```bash
   ./scripts/verify-schemas.sh
   ```

## Exemple docker-compose minimal

Le fichier [docker-compose.yml](docker-compose.yml) du projet contient :

- **postgres** : PostgreSQL 16 avec healthcheck
- **flyway** : exécution des migrations au démarrage (dépend de postgres)

Variables à personnaliser via `.env` : `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, éventuellement `POSTGRES_PORT`.

## Connexion de test

### Via psql (ligne de commande)

```bash
psql -h localhost -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB
```

Exemple avec les valeurs par défaut de `.env.example` :
```bash
psql -h localhost -p 5432 -U dbuser -d crypto_db
```

Si `.env` est chargé dans le shell :
```bash
source .env
psql -h localhost -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB
```

### Via outil GUI

- **DBeaver** : Nouvelle connexion PostgreSQL → Host: `localhost`, Port: `5432`, Database: `crypto_db`, User/Password depuis `.env`
- **pgAdmin** : Server → Host: `localhost`, Port: `5432`, Maintenance DB: `crypto_db`

## Migrations

Les migrations Flyway s'exécutent automatiquement au démarrage. Pour suivre la progression :

```bash
docker-compose logs flyway
```

Pour vérifier que les schémas ont été créés :

```bash
./scripts/verify-schemas.sh
```
