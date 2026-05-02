# 🏋️‍♂️ Aminou GYM Management System

## 📊 Data Architecture & Internal Tooling
Ce projet consiste en la conception et le déploiement d'une solution de gestion complète pour une salle de sport, remplaçant un système manuel par une architecture de données centralisée et une interface métier automatisée.

## 🛠 Tech Stack
*   **Database**: PostgreSQL (hébergé sur **Supabase**) pour la gestion relationnelle des membres et des flux financiers.
*   **Interface**: **Appsmith** pour le développement de l'outil interne (Back-office).
*   **Logic**: SQL avancé pour les automatisations de prix et les calculs de dates d'expiration.
*   **Analytics**: Préparation des données pour **Data Analysis** (Power BI / Excel).

## 🏗 Database Schema
Le système repose sur 6 tables relationnelles optimisées pour l'intégrité des données :

*   **`Membre`** : Stockage des informations personnelles et profils des sportifs.
*   **`Tarif`** : Catalogue dynamique des offres (Sexe, durée, coaching).
*   **`Inscription`** : Table de liaison gérant le cycle de vie des abonnements (Dates de début/fin, statut de paiement).
*   **`Produit` & `VenteBoutique`** : Gestion des stocks et point de vente (POS) pour la boutique interne.
*   **`Depense`** : Journalisation des flux sortants pour le calcul de la rentabilité.

## 🖥 Application Modules (Appsmith)

### 1. Dashboard de Pilotage
*   **Suivi de Caisse** : Calcul en temps réel de la balance financière (Recettes - Dépenses).
*   **Alertes Expirations** : Détection automatique des abonnements arrivant à échéance sous 72h.
*   <img width="1918" height="873" alt="image de la page dashboard" src="https://github.com/user-attachments/assets/8b82c193-d7a1-44e8-9bed-a646d14d93b9" />
<img width="1902" height="872" alt="image de la page dashboard graphique" src="https://github.com/user-attachments/assets/20edd9a4-51c5-4146-b1df-b843ce65c6cf" />


### 2. Gestion des Flux Membres
*   **Inscription Intelligente** : Formulaire avec injection dynamique des prix selon le sexe et calcul automatique de la date d'expiration via SQL.
*   <img width="1907" height="886" alt="image gestion membre inscrit" src="https://github.com/user-attachments/assets/1e223592-f5e3-4a74-8139-d31c57166717" />
<img width="1916" height="922" alt="image de la page gestion membres1" src="https://github.com/user-attachments/assets/82b1a0aa-9977-4cb4-8cb9-03235309d0cb" />



### 3. Point de Vente & Stock
*   **POS Interface** : Enregistrement rapide des ventes avec décrémentation automatique du `Stock_Actuel` dans la table `Produit`.
*   <img width="1918" height="870" alt="image de la page boutique" src="https://github.com/user-attachments/assets/9d12207e-0bab-40d1-95f1-dd244c8587ac" />


### 4. Paramétrage & Finance
*   **Maintenance des Tarifs** : Interface de mise à jour sécurisée pour ajuster les prix selon l'inflation ou les nouvelles offres.
*   <img width="1913" height="890" alt="image de la page parametres" src="https://github.com/user-attachments/assets/ee0680ac-d113-4a31-b3d5-47e0a30b4807" />


## 🛠 Défis Techniques & Solutions

### 🔹 Gestion de l'intégrité référentielle en temps réel
*   **Problématique** : Éviter les erreurs de saisie lors des inscriptions (ex: inscrire un membre à un tarif qui ne correspond pas à son sexe).
*   **Solution** : Mise en place de filtres SQL dynamiques dans Appsmith pour que le menu déroulant des tarifs ne propose que les options valides (`Tarif.Sexe = Membre.Sexe`), garantissant ainsi la cohérence des données en amont.

### 🔹 Automatisation du cycle de vie des abonnements
*   **Problématique** : Calculer manuellement la date d'expiration pour chaque membre est source d'erreurs humaines et de pertes financières.
*   **Solution** : Développement d'une logique SQL utilisant les types `INTERVAL` de PostgreSQL pour calculer automatiquement la `Date_Fin` dès la sélection d'un `ID_Tarif`, éliminant toute intervention manuelle.

### 🔹 Optimisation des mises à jour (The Binding Ghost)
*   **Problématique** : Instabilité lors des mises à jour de lignes dans l'interface, causant des erreurs de type "undefined" sur l'entité de ligne.
*   **Solution** : Migration vers l'utilisation de `triggeredRow` dans les requêtes de mise à jour pour cibler l'ID unique de manière atomique, assurant la stabilité de l'application même lors de modifications rapides.

### 🔹 Synchronisation UI/Base de Données (Le "Parallel Run")
*   **Problématique** : Garantir la fiabilité de l'application avant l'abandon total du système manuel.
*   **Solution** : Mise en place d'une phase de test d'un mois avec double saisie pour comparer les résultats financiers (Recettes/Dépenses) générés par Appsmith avec les registres physiques, validant ainsi la précision des calculs SQL.

## 📈 Impact Data
En tant que **Data Analyst**, ce système permet désormais de générer des rapports précis sur :
*   Le taux de rétention des membres.
*   Le produit le plus vendu en boutique.
*   L'analyse de la rentabilité mensuelle via le journal des dépenses.

