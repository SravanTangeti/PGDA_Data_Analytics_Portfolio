-- SQL Tasks for Credit Card Transaction Data Analysis
-- Use with your full cc_data.csv and location_data.csv imported as cc_data and location_data tables

-- 1. Create schema and set as default
CREATE SCHEMA finance;
USE finance;

-- 2. Import data (assumed done via GUI or LOAD DATA INFILE)
-- Table structures must be created to match your CSV columns
-- Example table structures:
-- CREATE TABLE cc_data (...);
-- CREATE TABLE location_data (...);

-- DATA EXPLORATION

-- Total number of transactions
SELECT COUNT(*) AS total_transactions FROM cc_data;
# SELECT COUNT(*) FROM location_data;

-- Top 10 most frequent merchants
SELECT merchant, COUNT(*) AS txn_count
FROM cc_data
GROUP BY merchant
ORDER BY txn_count DESC
LIMIT 10;

-- Average transaction amt for each category
SELECT category, AVG(amt) AS avg_transaction_amt
FROM cc_data
GROUP BY category;

-- Number and percentage of fraudulent transactions
SELECT
  COUNT(*) AS total_txns,
  SUM(is_fraud) AS total_frauds,
  ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_pct
FROM cc_data;

--- Join tables to get geo-coordinates for each transaction
SELECT
  cc.trans_num,
  cc.cc_num,
  cc.city,
  cc.state,
  loc.lat,
  loc.long AS long_
FROM cc_data cc
LEFT JOIN location_data loc
  ON cc.cc_num = loc.cc_num
WHERE loc.lat IS NOT NULL AND loc.long IS NOT NULL;


-- City with the highest population
SELECT city, state, city_pop
FROM cc_data
ORDER BY city_pop DESC
LIMIT 1;

-- City with the highest transaction count (proxy for population)
SELECT city, state, COUNT(*) AS txn_count
FROM cc_data
GROUP BY city, state
ORDER BY txn_count DESC
LIMIT 1;

-- Find earliest and latest transaction dates
SELECT
  MIN(trans_date_trans_time) AS earliest_txn,
  MAX(trans_date_trans_time) AS latest_txn
FROM cc_data;

-- DATA AGGREGATION

-- Total amt spent across all transactions
SELECT SUM(amt) AS total_spent FROM cc_data;

-- Count per transaction category
SELECT category, COUNT(*) AS txn_count
FROM cc_data
GROUP BY category;

-- Average amt by gender
SELECT gender, AVG(amt) AS avg_amt
FROM cc_data
GROUP BY gender;

-- Day of week with highest average transaction amount
SELECT
  DAYNAME(STR_TO_DATE(trans_date_trans_time, '%d-%m-%Y %H:%i')) AS day_of_week,
  AVG(amt) AS avg_amt
FROM cc_data
GROUP BY day_of_week
ORDER BY avg_amt DESC
LIMIT 1;
