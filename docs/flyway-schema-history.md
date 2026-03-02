# Flyway Schema History et Configuration

Ce document décrit la configuration Flyway pour l'historique des migrations et les comportements associés (Story 2.1).

## Prérequis

- **Docker Compose :** Les scripts et commandes utilisent `docker-compose` (Compose V1). Si vous utilisez Docker Compose V2 (`docker compose`), remplacez `docker-compose` par `docker compose` dans les scripts ou créez un alias : `alias docker-compose='docker compose'`.
- **Windows :** Les scripts de vérification (`scripts/*.sh`) nécessitent WSL (Windows Subsystem for Linux) ou Git Bash. Ils ne sont pas compatibles avec PowerShell ou cmd.exe.

## Table flyway_schema_history

### Création automatique

Flyway crée la table `flyway_schema_history` **automatiquement** lors de la première exécution de `migrate`. Aucun DDL manuel n'est requis.

### Emplacement et schéma

- **Table :** `flyway_schema_history`
- **Schéma par défaut :** `public` (schéma par défaut de la base)
- **Emplacement :** La table est créée dans le schéma défini par `flyway.defaultSchema` (non configuré ici → `public`)

### Colonnes principales

| Colonne | Description |
|---------|-------------|
| `installed_rank` | Ordre d'application (1, 2, 3...) |
| `version` | Version de la migration (ex: 1) |
| `description` | Description extraite du nom du fichier |
| `type` | Type (SQL, etc.) |
| `script` | Nom du fichier de migration |
| `checksum` | CRC32 du contenu (détection de modification) |
| `installed_on` | Date/heure d'application |
| `success` | Indicateur de succès |

### Requête pour inspecter l'historique

```sql
SELECT installed_rank, version, description, script, installed_on, success
FROM flyway_schema_history
ORDER BY installed_rank;
```

---

## Ordre d'exécution des migrations

### Configuration flyway.conf

- **`flyway.outOfOrder=false`** : Les migrations sont exécutées strictement dans l'ordre des versions (V1, V2, V3...). Une migration avec un numéro inférieur à la dernière appliquée ne sera pas exécutée.

### Convention de nommage

Format requis : `V{number}__{description}.sql` (double underscore entre le numéro et la description).

Exemples valides :
- `V1__create_schemas.sql`
- `V2__add_users_table.sql`
- `V10__add_indexes.sql`

Les numéros doivent être strictement croissants ; les trous sont autorisés mais déconseillés.

---

## Non ré-exécution des migrations

Flyway consulte `flyway_schema_history` avant chaque migration. Une migration déjà présente dans la table (même `version`) n'est **jamais ré-exécutée**.

Pour vérifier ce comportement, exécuter le script :
```bash
./scripts/verify-flyway-migrate-twice.sh
```

---

## Validation des checksums

### Configuration

- **`flyway.validateOnMigrate=true`** : À chaque `migrate`, Flyway vérifie que le checksum (CRC32) des fichiers déjà appliqués n'a pas changé.

### Comportement en cas de modification post-application

Si un fichier de migration est modifié **après** avoir été appliqué :

1. **Au prochain `migrate`** : Flyway détecte la différence de checksum et **échoue** avec une erreur du type :
   ```
   Validate failed: Migration checksum mismatch for migration version X
   ```

2. **Commande `validate`** : Permet de vérifier sans exécuter de migration :
   ```bash
   docker-compose run --rm flyway validate
   ```

### Gestion en cas d'échec de checksum

| Situation | Action recommandée |
|-----------|--------------------|
| Migration modifiée par erreur | Restaurer le fichier original depuis le VCS |
| Modification intentionnelle | Créer une **nouvelle** migration (V{n+1}) pour appliquer le changement ; ne jamais modifier une migration déjà appliquée |
| Environnement de dev uniquement | Optionnel : `flyway.repair` pour mettre à jour le checksum (à éviter en production) |

### Script de vérification

Pour tester la détection de checksum :
```bash
./scripts/verify-flyway-checksum.sh
```
