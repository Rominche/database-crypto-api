# Contraintes légales et conformité — database-crypto-api

**Projet :** database-crypto-api  
**Date :** 2025-02-26  
**Auteur :** RomainLAMBERT  
**Statut :** Document de référence — à valider par un juriste/conseil juridique

---

## 1. Vue d'ensemble

Ce document recense les contraintes légales et réglementaires applicables à l'application database-crypto-api (agrégation de portefeuille crypto) et les mesures mises en place pour y répondre.

| Réglementation | Périmètre | Niveau d'impact |
|----------------|-----------|-----------------|
| RGPD (GDPR) | Données personnelles (UE) | Obligatoire |
| MiCA | Actifs crypto (UE) | À qualifier |
| ANSSI | Chiffrement (France) | Recommandé |
| DORA | Résilience financière (UE) | Probablement hors périmètre |

---

## 2. RGPD (Règlement Général sur la Protection des Données)

### 2.1 Références

- **Texte :** Règlement (UE) 2016/679 (GDPR)
- **Source :** [EUR-Lex - 32016R0679](https://eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32016R0679)
- **Transposition France :** Loi n° 2018-493 du 20 juin 2018, Loi Informatique et Libertés modifiée
- **Autorité :** CNIL (Commission Nationale de l'Informatique et des Libertés)

### 2.2 Contraintes applicables

| Article | Exigence | Application au projet |
|---------|----------|------------------------|
| **Art. 5** | Licéité, loyauté, transparence ; limitation des finalités ; minimisation des données | Collecte limitée aux données nécessaires à l'agrégation du portefeuille |
| **Art. 25** | Protection des données dès la conception (Privacy by Design) | Architecture avec chiffrement et clés par utilisateur dès la conception |
| **Art. 32** | Mesures techniques et organisationnelles appropriées pour assurer la sécurité | Chiffrement des PII et credentials ; clés gérées via OpenBao/Infisical |
| **Art. 33-34** | Notification des violations de données sous 72h | Procédure à définir ; journalisation des accès pour traçabilité |

### 2.3 Actions mises en place

| Action | Description | Statut |
|--------|-------------|--------|
| Chiffrement des PII | Chiffrement applicatif (AES-256) pour toute donnée permettant d'identifier une personne | À implémenter |
| Chiffrement des credentials | Clés API et tokens stockés chiffrés ; jamais en clair en base | À implémenter |
| Clé par utilisateur | Chaque utilisateur dispose d'une clé dédiée ; admin n'a pas accès | Conçu |
| Minimisation des accès | Aucun rôle admin ne peut déchiffrer les données utilisateurs | Conçu |
| AIPD | Réaliser une Analyse d'Impact relative à la Protection des Données (AIPD) avant mise en production | À réaliser |
| Registre des traitements | Tenir un registre des activités de traitement (Art. 30) | À réaliser |
| Politique de confidentialité | Informer les utilisateurs des traitements et de leurs droits | À rédiger |

### 2.4 Références complémentaires

- [EDPB - SME Data Protection Guide](https://www.edpb.europa.eu/sme-data-protection-guide/secure-personal-data_en)
- [GDPR - Encryption](https://gdpr-info.eu/issues/encryption/)

---

## 3. MiCA (Markets in Crypto-Assets)

### 3.1 Références

- **Texte :** Règlement (UE) 2023/1114 (MiCA)
- **Source :** [EUR-Lex - 02023R1114](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:02023R1114-20240109)
- **Autorités France :** AMF (Autorité des Marchés Financiers), ACPR (Autorité de Contrôle Prudentiel et de Résolution)
- **Entrée en vigueur :** Titres III et IV depuis le 30 juin 2024 ; applicabilité complète depuis le 30 décembre 2024

### 3.2 Périmètre MiCA

MiCA régit les **prestataires de services sur actifs crypto (PSCA)** et les émetteurs de crypto-actifs. Les services couverts incluent notamment :

- Garde et administration d'actifs crypto
- Réception et transmission d'ordres
- Conseil en investissement
- Gestion de portefeuille
- Exécution d'ordres pour le compte de tiers

### 3.3 Qualification du projet

| Question | Réponse projet | Impact |
|----------|---------------|--------|
| Garde d'actifs ? | Non — lecture seule via API | Probablement hors périmètre PSCA |
| Conseil / gestion de portefeuille ? | Non (agrégation et visualisation uniquement) | À confirmer |
| Exécution d'ordres ? | Non | Hors périmètre |

**Conclusion préliminaire :** Une application d'agrégation de portefeuille (lecture seule, pas de garde ni d'exécution d'ordres) peut ne pas relever du statut de PSCA. **Qualification juridique recommandée** avant commercialisation.

### 3.4 Actions mises en place

| Action | Description | Statut |
|--------|-------------|--------|
| Qualification juridique | Faire qualifier le service par un avocat ou l'AMF (service d'information) | À réaliser |
| Veille réglementaire | Suivre l'évolution de MiCA et des lignes directrices ESMA/AMF | À mettre en place |
| Documentation | Documenter clairement les fonctionnalités (agrégation uniquement, pas de conseil ni d'exécution) | À rédiger |

### 3.5 Références complémentaires

- [AMF - MiCA](https://www.amf-france.org/fr/sujets/mica)
- [ACPR - Émetteurs et prestataires crypto](https://acpr.banque-france.fr/fr/professionnels/lacpr-vous-accompagne/banque/creer-ma-societe/mes-procedures/emetteur-de-crypto-actifs-et-prestataires-de-services-sur-crypto-actifs)
- [IAPP - MiCA Data Governance](https://iapp.org/news/a/effective-data-governance-key-to-mica-compliant-crypto-privacy)

---

## 4. ANSSI (Agence Nationale de la Sécurité des Systèmes d'Information)

### 4.1 Références

- **Organisme :** ANSSI (cyber.gouv.fr)
- **Guides :** Guide de sélection d'algorithmes cryptographiques (2021), Guide des mécanismes cryptographiques (v2.04)
- **Source :** [ANSSI - Publications](https://cyber.gouv.fr/publications)

### 4.2 Contraintes et recommandations

| Domaine | Recommandation ANSSI | Application au projet |
|---------|----------------------|------------------------|
| Chiffrement symétrique | AES-GCM, AES-CTR ou AES-CBC ; clés 256 bits (128 bits minimum) | AES-256-GCM pour PII et credentials |
| Hachage | SHA2-256, SHA2-384 ou SHA2-512 | SHA-256 pour dérivation de clés |
| Échange de clés | ECDH (courbes ≥ 256 bits) ou RSA ≥ 3072 bits | Conforme si utilisation de librairies standard |
| Principe "une clé, un usage" | Une clé par usage/finalité | Clé par utilisateur pour chiffrement des données |
| Cycle de vie des clés | Génération, stockage, rotation, révocation | Gestion via OpenBao/Infisical |

### 4.3 Actions mises en place

| Action | Description | Statut |
|--------|-------------|--------|
| Algorithme | Utiliser AES-256-GCM pour le chiffrement des données sensibles | À implémenter |
| Dérivation de clés | Utiliser une KDF (ex. PBKDF2, Argon2) pour dériver les clés | À implémenter |
| Gestion des clés | OpenBao ou Infisical (self-hosted) pour stockage et injection des clés | Conçu |
| Bibliothèques | Utiliser des librairies éprouvées (OpenSSL, libsodium, etc.) — éviter les implémentations custom | À valider |
| Rotation des clés | Définir une politique de rotation (ex. annuelle ou à la révocation) | À définir |

### 4.4 Références complémentaires

- [ANSSI - Guide mécanismes crypto](https://www.ssi.gouv.fr/entreprise/reglementation/confiance-numerique/le-referentiel-general-de-securite-rgs/)
- [ANSSI - Hébergement cloud](https://cyber.gouv.fr/publications/recommandations-pour-lhebergement-des-si-sensibles-dans-le-cloud)

---

## 5. DORA (Digital Operational Resilience Act)

### 5.1 Références

- **Texte :** Règlement (UE) 2022/2554 (DORA)
- **Source :** [EUR-Lex - 32022R2554](https://eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32022R2554)
- **Champ :** Entités financières (banques, assureurs, marchés, etc.) et fournisseurs de services ICT critiques

### 5.2 Périmètre

DORA impose des exigences en matière de :
- Gestion des risques ICT
- Gestion des incidents
- Tests de résilience
- Chiffrement et contrôles cryptographiques (Art. 6-7)

### 5.3 Qualification du projet

Une application B2C d'agrégation de portefeuille, sans statut d'entité financière régulée, est **probablement hors périmètre** de DORA. À confirmer en cas d'évolution du modèle (partenariats, statut régulé).

### 5.4 Actions mises en place

| Action | Description | Statut |
|--------|-------------|--------|
| Qualification | Vérifier l'applicabilité de DORA si le modèle évolue | À évaluer |
| Bonnes pratiques | S'inspirer des principes DORA (résilience, gestion des incidents) à titre de bonne pratique | Optionnel |

---

## 6. Modèle de chiffrement et d'accès (synthèse)

### 6.1 Architecture retenue

```
[Inscription utilisateur]
        │
        ▼
[Génération clé utilisateur] ──► [Stockage OpenBao/Infisical]
        │                              │
        │                              │ Path/Policy lié à user_id
        │                              │ Admin : pas d'accès
        ▼                              ▼
[Chiffrement données PII/credentials]   [Récupération clé à la demande]
        │                              │ (session authentifiée uniquement)
        ▼                              ▼
[Stockage BDD (données chiffrées)] ◄── [Déchiffrement pour affichage]
```

### 6.2 Principes

| Principe | Implémentation |
|----------|-----------------|
| Clé par utilisateur | Une clé dédiée générée à l'inscription |
| Admin sans accès | Aucun rôle admin ne peut récupérer les clés utilisateurs |
| Chiffrement obligatoire | PII et credentials toujours chiffrés au repos |
| Gestion des clés | OpenBao ou Infisical, self-hosted sur Kubernetes |

### 6.3 Alignement réglementaire

| Réglementation | Alignement |
|----------------|------------|
| RGPD Art. 32 | Chiffrement + minimisation des accès |
| ANSSI | AES-256, une clé un usage, cycle de vie des clés |
| MiCA (si applicable) | Bonne gouvernance des données clients |

---

## 7. Plan d'actions prioritaire

| Priorité | Action | Responsable | Échéance |
|----------|--------|-------------|----------|
| P1 | Implémenter chiffrement AES-256-GCM pour PII et credentials | Dev | Sprint 1 |
| P1 | Intégrer OpenBao ou Infisical pour gestion des clés | Dev | Sprint 1 |
| P1 | Réaliser l'AIPD (Analyse d'Impact RGPD) | Juridique / DPO | Avant production |
| P2 | Qualification juridique MiCA (AMF / avocat) | Juridique | Avant commercialisation |
| P2 | Rédiger le registre des traitements RGPD | DPO | Avant production |
| P2 | Politique de confidentialité et mentions légales | Juridique | Avant production |
| P3 | Définir politique de rotation des clés | Archi / Secu | Phase 2 |
| P3 | Procédure de notification des violations (Art. 33 RGPD) | Ops / Juridique | Avant production |

---

## 8. Révision du document

- **Prochaine révision :** À planifier (ex. trimestrielle ou à chaque évolution réglementaire majeure)
- **Validation juridique :** Ce document est un support technique. Une validation par un conseil juridique spécialisé est recommandée avant toute décision engageante.

---

*Document généré dans le cadre du Product Brief database-crypto-api — workflow BMAD.*
