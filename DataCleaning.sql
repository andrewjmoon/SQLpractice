-- Data Cleaning

select * from layoffs 
limit 5;

-- now when we are data cleaning we usually follow a few steps
-- 1. Check for duplicates and remove any.
-- 2. Standardize data and fix errors.
-- 3. Look at null values and see what .
-- 4. Remove any columns and rows that are not necessary - few ways.
-- 5. Create a duplicate staging file to clean the data there but keep the raw data file untouched as well.

create table layoffs_staging
like layoffs;

select * from layoffs_staging 
limit 5;

insert layoffs_staging
select * from layoffs;
-- 1. Remove Duplicates
# First let's check for duplicates

select *,
row_number() over(partition by company, industry, total_laid_off,
percentage_laid_off, `date`) as row_num
from layoffs_staging;

# Create a CTE
with duplicate_cte AS
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country,
funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

select * from layoffs_staging
where company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

# Inserting into layoffs_staging2 table
insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country,
funds_raised_millions) as row_num
from layoffs_staging;

select * from layoffs_staging2
where row_num > 1;

delete from layoffs_staging2
where row_num > 1;

-- Standarizing data
select distinct(trim(company))
from layoffs_staging2;

update layoffs_staging2
set company = TRIM(company);

select company from layoffs_staging2;

select distinct industry from layoffs_staging2
order by 1;
select * from layoffs_staging2 
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country, TRIM(trailing '.' from country) 
from layoffs_staging2
order by 1;

# update to remove the period behind United States
update layoffs_staging2
set country = TRIM(trailing '.' from country) 
where country like 'United States%';

# change date from text format to date format.
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select date
from layoffs_staging2;

#Change table to date format:
alter table layoffs_staging2
modify column `date` DATE;

select * from layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is null;

-- It looks like airbnb is a travel industry, but this one just isn't populated.
-- Write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- Makes it easy so if there were thousands we wouldn't have to manually check them all
-- We should set the blanks to nulls since those are typically easier to work with
# Set industry to null where the spaces are blank.
update layoffs_staging2
set industry = null
where industry = '';
-- now if we check those are all null
select * from layoffs_staging2
where industry is null or industry = '';

select * from layoffs_staging2
where company = 'Airbnb';

select * from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

# update query to fill in the industry row for Carvana, etc.
-- this is how we populate the nulls.
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

select * from layoffs_staging2
where company like 'Bally%';

delete from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;
