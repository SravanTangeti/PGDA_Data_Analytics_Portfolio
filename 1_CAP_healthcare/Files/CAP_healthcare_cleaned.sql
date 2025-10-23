-- -----------------------------------------------
-- 🏥 Healthcare Project: Patient Readmission Analysis (MySQL)
-- -----------------------------------------------

-- 1. Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS healthcare;
USE healthcare;

-- 2. Create the main dataset table for diabetic patient data
CREATE TABLE diabetic_data (
  encounter_id BIGINT PRIMARY KEY,
  patient_nbr BIGINT,
  race VARCHAR(50),
  gender VARCHAR(15),
  age VARCHAR(20),
  weight VARCHAR(10),
  admission_type_id INT,
  discharge_disposition_id INT,
  admission_source_id INT,
  time_in_hospital INT,
  payer_code VARCHAR(20),
  medical_specialty VARCHAR(100),
  num_lab_procedures INT,
  num_procedures INT,
  num_medications INT,
  number_outpatient INT,
  number_emergency INT,
  number_inpatient INT,
  diag_1 VARCHAR(10),
  diag_2 VARCHAR(10),
  diag_3 VARCHAR(10),
  number_diagnoses INT,
  max_glu_serum VARCHAR(20),
  A1Cresult VARCHAR(20),
  metformin VARCHAR(20),
  repaglinide VARCHAR(20),
  nateglinide VARCHAR(20),
  chlorpropamide VARCHAR(20),
  glimepiride VARCHAR(20),
  acetohexamide VARCHAR(20),
  glipizide VARCHAR(20),
  glyburide VARCHAR(20),
  tolbutamide VARCHAR(20),
  pioglitazone VARCHAR(20),
  rosiglitazone VARCHAR(20),
  acarbose VARCHAR(20),
  miglitol VARCHAR(20),
  troglitazone VARCHAR(20),
  tolazamide VARCHAR(20),
  examide VARCHAR(20),
  citoglipton VARCHAR(20),
  insulin VARCHAR(20),
  glyburide_metformin VARCHAR(20),
  glipizide_metformin VARCHAR(20),
  glimepiride_pioglitazone VARCHAR(20),
  metformin_rosiglitazone VARCHAR(20),
  metformin_pioglitazone VARCHAR(20),
  `change` VARCHAR(10),
  diabetesMed VARCHAR(10),
  readmitted VARCHAR(20)
);

-- -----------------------------------------------
-- 3. Data Cleaning: Replace unknown race values ("?") with "Unknown"
-- -----------------------------------------------
UPDATE diabetic_data
SET race = 'Unknown'
WHERE race = '?';

-- View the updated race distribution
SELECT race, COUNT(*) AS count
FROM diabetic_data 
GROUP BY race;


-- -----------------------------------------------
-- 4. Dataset Overview & Descriptive Analysis
-- -----------------------------------------------

-- Total number of patient encounters in the dataset
SELECT COUNT(*) AS total_encounters
FROM diabetic_data;

-- Age group distribution of patients
SELECT age, COUNT(*) AS patient_count
FROM diabetic_data
GROUP BY age
ORDER BY age;


-- -----------------------------------------------
-- 5. Readmission Analysis
-- -----------------------------------------------

-- Total number of readmitted patients (<30 and >30 days)
SELECT COUNT(*) AS readmitted_patients
FROM diabetic_data
WHERE readmitted IN ('<30', '>30');

-- Percentage of patients who were readmitted
SELECT 
  ROUND(
    (SELECT COUNT(*) FROM diabetic_data WHERE readmitted IN ('<30', '>30')) * 100.0 /
    (SELECT COUNT(*) FROM diabetic_data),
    2
  ) AS readmission_percentage;

-- Readmission rate grouped by payer (insurance) type
SELECT 
  payer_code,
  COUNT(*) AS total_cases,
  SUM(CASE WHEN readmitted IN ('<30', '>30') THEN 1 ELSE 0 END) AS readmitted_cases,
  ROUND(
    SUM(CASE WHEN readmitted IN ('<30', '>30') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
    2
  ) AS readmission_rate_pct
FROM diabetic_data
GROUP BY payer_code
ORDER BY readmission_rate_pct DESC;


-- -----------------------------------------------
-- 6. Clinical Resource Usage Insights
-- -----------------------------------------------

-- Average number of days spent in hospital by admission type
SELECT admission_type_id, AVG(time_in_hospital) AS avg_stay_days
FROM diabetic_data
GROUP BY admission_type_id
ORDER BY admission_type_id;

-- Average number of medications per age group
SELECT age, AVG(num_medications) AS average_medications
FROM diabetic_data
GROUP BY age
ORDER BY age;

-- Most common number of procedures performed
SELECT num_procedures, COUNT(*) AS count
FROM diabetic_data
GROUP BY num_procedures
ORDER BY count DESC
LIMIT 5;


-- -----------------------------------------------
-- 7. Diagnosis Profiling
-- -----------------------------------------------

-- Top 10 most frequently recorded primary diagnoses
SELECT diag_1, COUNT(*) AS frequency
FROM diabetic_data
GROUP BY diag_1
ORDER BY frequency DESC
LIMIT 10;

-- -----------------------------------------------
-- ✅ End of script
-- -----------------------------------------------
