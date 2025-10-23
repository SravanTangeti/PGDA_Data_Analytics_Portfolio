/*============================================================
  1️⃣ SCHEMA & TABLE SETUP
============================================================*/

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS retail_data;
USE retail_data;

-- Create staging table (all text) for raw CSV import
-- Purpose: Avoid import errors due to mixed formats/nulls
CREATE TABLE marketing_campaign_stage (
  ID VARCHAR(10),
  Year_Birth VARCHAR(5),
  Education VARCHAR(50),
  Marital_Status VARCHAR(50),
  Income VARCHAR(20),
  Kidhome VARCHAR(2),
  Teenhome VARCHAR(2),
  Dt_Customer VARCHAR(20),
  Recency VARCHAR(5),
  MntWines VARCHAR(10),
  MntFruits VARCHAR(10),
  MntMeatProducts VARCHAR(10),
  MntFishProducts VARCHAR(10),
  MntSweetProducts VARCHAR(10),
  MntGoldProds VARCHAR(10),
  NumDealsPurchases VARCHAR(5),
  NumWebPurchases VARCHAR(5),
  NumCatalogPurchases VARCHAR(5),
  NumStorePurchases VARCHAR(5),
  NumWebVisitsMonth VARCHAR(5),
  AcceptedCmp1 VARCHAR(2),
  AcceptedCmp2 VARCHAR(2),
  AcceptedCmp3 VARCHAR(2),
  AcceptedCmp4 VARCHAR(2),
  AcceptedCmp5 VARCHAR(2),
  Complain VARCHAR(2),
  Z_CostContact VARCHAR(5),
  Z_Revenue VARCHAR(5),
  Response VARCHAR(2),
  Age VARCHAR(3)
);

-- Create final table with proper data types
CREATE TABLE marketing_campaign (
  ID INT PRIMARY KEY,
  Year_Birth INT,
  Education VARCHAR(50),
  Marital_Status VARCHAR(50),
  Income DECIMAL(15,2),
  Kidhome INT,
  Teenhome INT,
  Dt_Customer DATE,
  Recency INT,
  MntWines DECIMAL(10,2),
  MntFruits DECIMAL(10,2),
  MntMeatProducts DECIMAL(10,2),
  MntFishProducts DECIMAL(10,2),
  MntSweetProducts DECIMAL(10,2),
  MntGoldProds DECIMAL(10,2),
  NumDealsPurchases INT,
  NumWebPurchases INT,
  NumCatalogPurchases INT,
  NumStorePurchases INT,
  NumWebVisitsMonth INT,
  AcceptedCmp1 TINYINT,
  AcceptedCmp2 TINYINT,
  AcceptedCmp3 TINYINT,
  AcceptedCmp4 TINYINT,
  AcceptedCmp5 TINYINT,
  Complain TINYINT,
  Z_CostContact INT,
  Z_Revenue INT,
  Response TINYINT,
  Age INT,
  Age_Group VARCHAR(20)
);

/*============================================================
  2️⃣ DATA TRANSFER FROM STAGING TO FINAL TABLE
============================================================*/

-- Clean + transform data from staging table into final table
INSERT INTO marketing_campaign
(
  ID, Year_Birth, Education, Marital_Status, Income, Kidhome, Teenhome,
  Dt_Customer, Recency, MntWines, MntFruits, MntMeatProducts, MntFishProducts,
  MntSweetProducts, MntGoldProds, NumDealsPurchases, NumWebPurchases,
  NumCatalogPurchases, NumStorePurchases, NumWebVisitsMonth,
  AcceptedCmp1, AcceptedCmp2, AcceptedCmp3, AcceptedCmp4, AcceptedCmp5, 
  Complain, Z_CostContact, Z_Revenue, Response, Age, Age_Group
)
SELECT
  CAST(ID AS UNSIGNED),
  CAST(Year_Birth AS UNSIGNED),
  Education,
  Marital_Status,
  NULLIF(Income, '') + 0,
  NULLIF(Kidhome, '') + 0,
  NULLIF(Teenhome, '') + 0,
  CASE
    WHEN Dt_Customer LIKE '%-%' THEN STR_TO_DATE(Dt_Customer, '%d-%m-%Y')
    WHEN Dt_Customer LIKE '%/%' THEN STR_TO_DATE(Dt_Customer, '%m/%d/%Y')
    ELSE NULL
  END,
  NULLIF(Recency, '') + 0,
  NULLIF(MntWines, '') + 0,
  NULLIF(MntFruits, '') + 0,
  NULLIF(MntMeatProducts, '') + 0,
  NULLIF(MntFishProducts, '') + 0,
  NULLIF(MntSweetProducts, '') + 0,
  NULLIF(MntGoldProds, '') + 0,
  NULLIF(NumDealsPurchases, '') + 0,
  NULLIF(NumWebPurchases, '') + 0,
  NULLIF(NumCatalogPurchases, '') + 0,
  NULLIF(NumStorePurchases, '') + 0,
  NULLIF(NumWebVisitsMonth, '') + 0,
  NULLIF(AcceptedCmp1, '') + 0,
  NULLIF(AcceptedCmp2, '') + 0,
  NULLIF(AcceptedCmp3, '') + 0,
  NULLIF(AcceptedCmp4, '') + 0,
  NULLIF(AcceptedCmp5, '') + 0,
  NULLIF(Complain, '') + 0,
  NULLIF(Z_CostContact, '') + 0,
  NULLIF(Z_Revenue, '') + 0,
  NULLIF(Response, '') + 0,
  NULLIF(Age, '') + 0,
  CASE 
    WHEN NULLIF(Age, '') + 0 BETWEEN 18 AND 30 THEN '18-30'
    WHEN NULLIF(Age, '') + 0 BETWEEN 31 AND 45 THEN '31-45'
    WHEN NULLIF(Age, '') + 0 BETWEEN 46 AND 60 THEN '46-60'
    WHEN NULLIF(Age, '') + 0 > 60 THEN '60+'
    ELSE 'Unknown'
  END
FROM marketing_campaign_stage;

/*============================================================
  3️⃣ DATA VALIDATION / SANITY CHECKS
============================================================*/

-- Row count check
SELECT COUNT(*) AS total_customers FROM marketing_campaign;

-- Peek at sample records
SELECT * FROM marketing_campaign LIMIT 10;

-- Date range & missing date count
SELECT 
    MIN(Dt_Customer) AS earliest_customer_date,
    MAX(Dt_Customer) AS latest_customer_date,
    SUM(CASE WHEN Dt_Customer IS NULL THEN 1 ELSE 0 END) AS missing_dates
FROM marketing_campaign;

-- Missing income count
SELECT SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS missing_incomes
FROM marketing_campaign;

/*============================================================
  4️⃣ ANALYSIS QUERIES
============================================================*/

-- Total spending by product category
SELECT 'MntWines' AS category, SUM(MntWines) AS total_spent FROM marketing_campaign
UNION ALL
SELECT 'MntFruits', SUM(MntFruits) FROM marketing_campaign
UNION ALL
SELECT 'MntMeatProducts', SUM(MntMeatProducts) FROM marketing_campaign
UNION ALL
SELECT 'MntFishProducts', SUM(MntFishProducts) FROM marketing_campaign
UNION ALL
SELECT 'MntSweetProducts', SUM(MntSweetProducts) FROM marketing_campaign
UNION ALL
SELECT 'MntGoldProds', SUM(MntGoldProds) FROM marketing_campaign
ORDER BY total_spent DESC;

SELECT Response, COUNT(*) AS total_customers
FROM marketing_campaign
GROUP BY Response;

-- Response rate breakdown
SELECT 
    Response, 
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM marketing_campaign), 2) AS pct_of_total
FROM marketing_campaign
GROUP BY Response;

-- Education vs Marital Status customer distribution
SELECT 
    Education, 
    Marital_Status, 
    COUNT(*) AS customer_count
FROM marketing_campaign
GROUP BY Education, Marital_Status
ORDER BY Education, Marital_Status;

-- Average income for responders
SELECT 
    AVG(Income) AS avg_income_responders
FROM marketing_campaign	
WHERE Response = 1
  AND Income IS NOT NULL;

-- Campaign acceptance totals
SELECT
  SUM(AcceptedCmp1) AS Accepted_Cmp1,
  SUM(AcceptedCmp2) AS Accepted_Cmp2,
  SUM(AcceptedCmp3) AS Accepted_Cmp3,
  SUM(AcceptedCmp4) AS Accepted_Cmp4,
  SUM(AcceptedCmp5) AS Accepted_Cmp5
FROM marketing_campaign;

SELECT Response, COUNT(*) AS total_customers,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM marketing_campaign), 2) AS pct_of_total
FROM marketing_campaign
GROUP BY Response;

-- Average kids & teens per household
SELECT 
    ROUND(AVG(Kidhome), 2) AS avg_kids, 
    ROUND(AVG(Teenhome), 2) AS avg_teens
FROM marketing_campaign;

-- Average monthly web visits by age group
SELECT 
    Age_Group, 
    ROUND(AVG(NumWebVisitsMonth), 2) AS avg_web_visits
FROM marketing_campaign
GROUP BY Age_Group
ORDER BY Age_Group;
