-- ==========================================
-- PROJET : Aminou GYM Management System
-- DESCRIPTION : Schéma de la base de données PostgreSQL (Supabase)
-- ==========================================

-- Table des membres
CREATE TABLE public."Membre" (
  "ID_Membre" serial NOT NULL,
  "Nom" text NOT NULL,
  "Prenom" text NOT NULL,
  "Sexe" character(1) NULL,
  "Telephone" text NOT NULL,
  "Date_Naissance" date NULL,
  "Photo_Path" text NULL,
  "Date_Inscription" timestamp WITHOUT TIME ZONE NULL DEFAULT CURRENT_DATE,
  CONSTRAINT Membre_pkey PRIMARY KEY ("ID_Membre"),
  CONSTRAINT Membre_Telephone_key UNIQUE ("Telephone"),
  CONSTRAINT Membre_Sexe_check CHECK (("Sexe" = ANY (ARRAY['H'::bpchar, 'F'::bpchar])))
) TABLESPACE pg_default;

-- Table des tarifs
CREATE TABLE public."Tarif" (
  "ID_Tarif" serial NOT NULL,
  "Sexe" character(1) NULL,
  "Type_Abonnement" text NOT NULL,
  "Avec_Coach" boolean NULL DEFAULT FALSE,
  "Duree_Mois" integer NOT NULL,
  "Prix_Abonnement" integer NOT NULL,
  CONSTRAINT Tarif_pkey PRIMARY KEY ("ID_Tarif"),
  CONSTRAINT Tarif_Sexe_check CHECK (("Sexe" = ANY (ARRAY['H'::bpchar, 'F'::bpchar])))
) TABLESPACE pg_default;

-- Table des inscriptions
CREATE TABLE public."Inscription" (
  "ID_Inscription" serial NOT NULL,
  "ID_Membre" integer NULL,
  "ID_Tarif" integer NULL,
  "Date_Debut" timestamp WITH TIME ZONE NULL,
  "Date_Fin" date NOT NULL,
  "Frais_Paye" boolean NULL DEFAULT FALSE,
  CONSTRAINT Inscription_pkey PRIMARY KEY ("ID_Inscription"),
  CONSTRAINT Inscription_ID_Membre_fkey FOREIGN KEY ("ID_Membre") REFERENCES "Membre" ("ID_Membre") ON DELETE CASCADE,
  CONSTRAINT Inscription_ID_Tarif_fkey FOREIGN KEY ("ID_Tarif") REFERENCES "Tarif" ("ID_Tarif")
) TABLESPACE pg_default;

-- Table des produits boutique
CREATE TABLE public."Produit" (
  "ID_Produit" serial NOT NULL,
  "Nom_Produit" text NOT NULL,
  "PrixVente" integer NOT NULL,
  "Stock_Actuel" integer NULL DEFAULT 0,
  CONSTRAINT Produit_pkey PRIMARY KEY ("ID_Produit")
) TABLESPACE pg_default;

-- Table des ventes boutique
CREATE TABLE public."VenteBoutique" (
  "ID_Vente" serial NOT NULL,
  "ID_Produit" integer NULL,
  "Quantite" integer NULL DEFAULT 1,
  "Date_Vente" timestamp WITHOUT TIME ZONE NULL DEFAULT CURRENT_TIMESTAMP,
  "Total_Vente" integer NOT NULL,
  CONSTRAINT VenteBoutique_pkey PRIMARY KEY ("ID_Vente"),
  CONSTRAINT VenteBoutique_ID_Produit_fkey FOREIGN KEY ("ID_Produit") REFERENCES "Produit" ("ID_Produit")
) TABLESPACE pg_default;

-- Table des dépenses
CREATE TABLE public."Depense" (
  "ID_Depense" serial NOT NULL,
  "Libelle_Depense" text NOT NULL,
  "Montant_Depense" integer NOT NULL,
  "Date_Depense" timestamp WITH TIME ZONE NULL,
  CONSTRAINT Depense_pkey PRIMARY KEY ("ID_Depense")
) TABLESPACE pg_default;
