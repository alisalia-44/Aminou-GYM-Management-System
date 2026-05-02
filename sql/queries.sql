-- =================================================================
-- PROJECT: Aminou GYM Management System
-- DESCRIPTION: Business Logic & Data Analysis Queries (Appsmith + PostgreSQL)
-- AUTHOR: Ali Salia
-- =================================================================

-- -----------------------------------------------------------------
-- 1. MEMBER MANAGEMENT & REGISTRATION
-- -----------------------------------------------------------------

-- ATOMIC REGISTRATION: Creates a member and their first subscription in one transaction
-- Uses CTE (Common Table Expressions) to pass the new ID to the second insert
WITH nouveau_membre AS (
    INSERT INTO public."Membre" (
        "Nom", "Prenom", "Sexe", "Telephone", "Date_Naissance", "Photo_Path", "Date_Inscription"
    ) 
    VALUES (
        '{{input_nom.text}}', 
        '{{input_prenom.text}}', 
        '{{Select_sexe.selectedOptionValue}}',
        '{{input_tel.text}}',
        NULLIF('{{date_naissance.formattedDate}}', '')::date, 
        '{{input_photo.files[0]?.data || "default_avatar.png"}}', 
        CURRENT_TIMESTAMP
    )
    RETURNING "ID_Membre", "Sexe"
)
INSERT INTO public."Inscription" ("ID_Membre", "ID_Tarif", "Date_Debut", "Date_Fin", "Frais_Paye") 
SELECT 
    n."ID_Membre", 
    (SELECT "ID_Tarif" FROM public."Tarif" 
     WHERE "Sexe" = n."Sexe"
     AND "Type_Abonnement" = '{{sel_type.selectedOptionValue}}' 
     AND "Duree_Mois" = {{Number(sel_duree.selectedOptionValue || 1)}} 
     AND "Avec_Coach" = {{sw_coach.isSwitchedOn}}::boolean 
     LIMIT 1), 
    CURRENT_TIMESTAMP, 
    '{{date_fin.formattedDate}}'::timestamp, 
    true 
FROM nouveau_membre n;

-- FETCH MEMBERS WITH LATEST EXPIRATION DATE
-- Logic: Handles multiple subscriptions by selecting only the MAX(Date_Fin)
SELECT 
    m."ID_Membre", m."Nom", m."Prenom", m."Sexe", m."Telephone", m."Date_Inscription",
    i."Date_Fin"
FROM public."Membre" m
LEFT JOIN public."Inscription" i ON m."ID_Membre" = i."ID_Membre"
WHERE i."Date_Fin" = (
    SELECT MAX("Date_Fin") FROM public."Inscription" WHERE "ID_Membre" = m."ID_Membre"
) OR i."Date_Fin" IS NULL 
ORDER BY m."Date_Inscription" DESC;

-- -----------------------------------------------------------------
-- 2. SALES & INVENTORY (POS SYSTEM)
-- -----------------------------------------------------------------

-- RECORD SALE WITH CLEANED INPUT
INSERT INTO public."VenteBoutique" ("ID_Produit", "Quantite", "Date_Vente", "Total_Vente")
VALUES (
    {{select_produit.selectedOptionValue}},
    {{Number(input_quantite.text) || 0}},
    CURRENT_TIMESTAMP,
    {{ Number(inp_total.text.toString().replace(/[^0-9.]/g, '')) || 0 }}
);

-- DYNAMIC STOCK UPDATE
UPDATE public."Produit"
SET "Stock_Actuel" = "Stock_Actuel" - {{input_quantite.text}}
WHERE "ID_Produit" = {{select_produit.selectedOptionValue}};

-- -----------------------------------------------------------------
-- 3. FINANCIAL ANALYSIS & DASHBOARD
-- -----------------------------------------------------------------

-- GLOBAL ACTIVITY FEED (Unified Feed)
-- Merges Subscriptions, Sales, and Expenses into a single chronological stream
(
  SELECT TO_CHAR(i."Date_Debut", 'DD/MM HH24:MI:SS') as "Heure",
         'Abo: ' || m."Nom" || ' ' || m."Prenom" as "Action",
         t."Prix_Abonnement" as "Montant", i."Date_Debut"::timestamp as "Tri"
  FROM public."Inscription" i
  JOIN public."Membre" m ON i."ID_Membre" = m."ID_Membre"
  JOIN public."Tarif" t ON i."ID_Tarif" = t."ID_Tarif"
  UNION ALL 
  SELECT TO_CHAR(v."Date_Vente", 'DD/MM HH24:MI:SS') as "Heure",
         'Vente: ' || p."Nom_Produit" as "Action",
         v."Total_Vente" as "Montant", v."Date_Vente"::timestamp as "Tri"
  FROM public."VenteBoutique" v
  JOIN public."Produit" p ON v."ID_Produit" = p."ID_Produit"
  UNION ALL
  SELECT TO_CHAR(d."Date_Depense", 'DD/MM HH24:MI:SS') as "Heure",
         'Frais: ' || d."Libelle_Depense" as "Action",
         d."Montant_Depense" * -1 as "Montant", d."Date_Depense"::timestamp as "Tri"
  FROM public."Depense" d
)
ORDER BY "Tri" DESC LIMIT 5;

-- DAILY CASH FLOW SUMMARY
SELECT 
    (SELECT COALESCE(SUM(t."Prix_Abonnement"), 0) FROM public."Inscription" i
     JOIN public."Tarif" t ON i."ID_Tarif" = t."ID_Tarif"
     WHERE i."Date_Debut"::date = CURRENT_DATE) as "Total_Inscriptions",
    (SELECT COALESCE(SUM("Total_Vente"), 0) FROM public."VenteBoutique" 
     WHERE "Date_Vente"::date = CURRENT_DATE) as "Total_Ventes",
    (SELECT COALESCE(SUM("Montant_Depense"), 0) FROM public."Depense" 
     WHERE "Date_Depense"::date = CURRENT_DATE) as "Total_Depenses";

-- -----------------------------------------------------------------
-- 4. RETENTION & ALERTS
-- -----------------------------------------------------------------

-- 72H EXPIRATION MONITOR
-- Identifies members whose subscription ends within 3 days for proactive renewal
SELECT "Nom", "Prenom", "Telephone", "Date_Fin"
FROM public."Membre" M
JOIN public."Inscription" I ON M."ID_Membre" = I."ID_Membre"
WHERE I."Date_Fin" BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '3 days')
AND I."ID_Inscription" = (
    SELECT MAX("ID_Inscription") FROM public."Inscription" WHERE "ID_Membre" = M."ID_Membre"
);
