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
-- 4. Remove columns

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

