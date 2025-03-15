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


\copy layoffs FROM '/home/diegorandolp/Code/NoUTEC/Data/strata_mod/layoffs.csv' DELIMITER ',' CSV HEADER

SELECT *
FROM layoffs
LIMIT 5;


