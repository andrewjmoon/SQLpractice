-- Exploratory Data Analysis
select * from layoffs_staging2
limit 5;
-- 1 means 100%.
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- 2400 is equal to 2.4 billion
select * from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

select company, sum(total_laid_off) as sum_laid_off
from layoffs_staging2
group by company
order by sum_laid_off desc;

select min(`date`), max(`date`)
from layoffs_staging2;

select industry, sum(total_laid_off) as sum_laid_off
from layoffs_staging2
group by industry
order by sum_laid_off desc;


select country, sum(total_laid_off) as sum_laid_off
from layoffs_staging2
group by country
order by sum_laid_off desc;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by year(`date`) desc;

# order by 1,2,3,4 (stage is 1 and sum(total_laid_off) is 2)
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

select company, avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

# month(`date`) as month or substring(`date`, 6,2) as month
select month(`date`) as months, sum(total_laid_off) as sum_tlo
from layoffs_staging2
group by months
order by sum_tlo desc;

# month(`date`) as month or substring(`date`, 6,2) as month
select substring(`date`, 1,7) as months, sum(total_laid_off) as sum_tlo
from layoffs_staging2
group by months
order by months;

# CTE - How to create a rolling total amount of total laid off.
with rolling_total as 
(select substring(`date`, 1,7) as months, sum(total_laid_off) as sum_tlo
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by months
order by months
)
select months, sum_tlo, sum(sum_tlo) over(order by months) as rolling_totals
from rolling_total;

# Look at lay offs per company and year. 
SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)

# CTE for we looked at Companies with the most Layoffs. Now let's look at that per year.
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
),
 Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;
