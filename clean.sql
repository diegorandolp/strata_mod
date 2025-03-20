\c data_analysis;

CREATE SCHEMA cleaning;

SET search_path TO cleaning;

DROP TABLE IF EXISTS layoffs;

CREATE TABLE layoffs(
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off TEXT,
    percentage_laid_off NUMERIC,
    date_layoff DATE,
    stage TEXT,
    country TEXT,
    funds_raised_millions NUMERIC
);

-- cp /home/.../layoffs.csv /tmp/
-- In terminal:
-- psql -U postgres -d data_analysis
-- set search_path to cleaning;
-- \copy layoffs FROM '/tmp/layoffs.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL 'NULL');

SELECT *
FROM layoffs
LIMIT 5;

-- 1. Duplicate
-- 2. Standardize the data
-- 3. Null or blank values
-- 4. Remove columns/rows

CREATE TABLE layoffs_staging AS
SELECT *
FROM layoffs;


-- 1. Duplicate: Partition by all columns

CREATE TABLE layoffs_no_duplicates AS
SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
               stage, country, funds_raised_millions
           ) AS row_num
FROM layoffs_staging;

DELETE FROM layoffs_no_duplicates
WHERE row_num > 1;

SELECT COUNT(*)
FROM layoffs_no_duplicates;

-- 2. Standardize data
-- Check every column with DISTINCT
-- 2.1 Delete blank spaces
SELECT DISTINCT t1.company
FROM layoffs_no_duplicates AS t1
ORDER BY t1.company DESC;

UPDATE layoffs_no_duplicates
SET company = TRIM(company);

-- 2.2 Standardize the name referring the same thing

SELECT DISTINCT t1.industry
FROM layoffs_no_duplicates AS t1
ORDER BY t1.industry;

-- Determine the names with the least frequency 'Crypto...'
SELECT t1.industry, COUNT(*)
FROM layoffs_no_duplicates AS t1
WHERE t1.industry LIKE 'Crypto%'
GROUP BY t1.industry;

UPDATE layoffs_no_duplicates
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

--
SELECT DISTINCT t1.country, TRIM(TRAILING '.' FROM t1.country)
FROM layoffs_no_duplicates AS t1
ORDER BY t1.country;

UPDATE layoffs_no_duplicates
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%.';

SELECT * from layoffs_no_duplicates LIMIT 5;

-- 3. Null or blank values
-- Try to complete the missing values with the information from the same company

-- Check the representation of the missing values
SELECT DISTINCT t1.industry
FROM layoffs_no_duplicates as t1
ORDER BY t1.industry;

-- Check the companies with missing values
SELECT *
FROM layoffs_no_duplicates AS t1
WHERE t1.industry IS NULL OR t1.industry = '';

-- Standardize the missing values
UPDATE layoffs_no_duplicates
SET industry = NULL
WHERE industry = '';

-- Check the companies that have missing anc complete values of industry
SELECT t1.industry, t2.industry
FROM layoffs_no_duplicates AS t1
JOIN layoffs_no_duplicates AS t2
ON t1.company = t2.company
WHERE t2.industry IS NULL
AND t1.industry IS NOT NULL;

-- Complete the missing values converting the previous query into an UPDATE
UPDATE layoffs_no_duplicates AS t2
SET industry = t1.industry
FROM layoffs_no_duplicates AS t1
WHERE t1.company = t2.company -- Join condition
AND t2.industry IS NULL -- WHERE condition
AND t1.industry IS NOT NULL;

-- 4. Delete columns/rows
DELETE
FROM layoffs_no_duplicates
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_no_duplicates
DROP COLUMN row_num;

SELECT *
FROM layoffs_no_duplicates
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 5;

-- Fix: total_laid_off to NUMERIC
ALTER TABLE layoffs_no_duplicates
ALTER COLUMN total_laid_off
SET DATA TYPE NUMERIC USING total_laid_off::NUMERIC;

SELECT *
FROM (
SELECT EXTRACT(YEAR FROM t1.date_layoff) AS year, t1.company,
    SUM(total_laid_off) AS total_per_year,
    COUNT(*) AS number_of_layoffs,
    ROW_NUMBER() OVER(PARTITION BY EXTRACT(YEAR FROM t1.date_layoff) ORDER BY SUM(total_laid_off) DESC) AS row_num
FROM layoffs_no_duplicates AS t1
WHERE t1.total_laid_off IS NOT NULL
GROUP BY EXTRACT(YEAR FROM t1.date_layoff), t1.company
ORDER BY year, total_per_year DESC) AS t1
WHERE t1.row_num <= 5;

