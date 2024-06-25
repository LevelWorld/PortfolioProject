-- Exploratory Data Analysis

Select * 
From layoffs_staging2;

Select MAX(total_laid_off), Max(percentage_laid_off)
From layoffs_staging2;

-- what companies had 100% layoff
Select *
From layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

Select company, sum(total_laid_off)
From layoffs_staging2
group by company
order by 2 desc;

select min(`date`), Max(`date`)
from layoffs_staging2;

Select industry, sum(total_laid_off)
From layoffs_staging2
group by industry
order by 2 desc;

Select YEAR(`date`), SUM(total_laid_off)
From layoffs_staging2
group by YEAR(`date`)
order by 1 desc;

Select stage, SUM(total_laid_off)
From layoffs_staging2
group by stage
order by 2 desc;

select substring(`date`, 1,7) as `MONTH`, SUM(total_laid_off)
from layoffs_staging2
WHERE substring(`date`, 1,7) IS NOT NULL
group by `MONTH`
ORDER BY 1 ASC;

-- ROLLING TOTAL
WITH ROLLING_TOTAL AS (
select substring(`date`, 1,7) as `MONTH`, SUM(total_laid_off) AS total_off
from layoffs_staging2
WHERE substring(`date`, 1,7) IS NOT NULL
group by `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off)  over(order by `MONTH`) AS rolling_total
from ROLLING_TOTAL;

-- company layoff by the year
Select company, YEAR(`date`), sum(total_laid_off)
From layoffs_staging2
group by company, YEAR(`date`)
order by 3 desc;


-- ranking the top 5 company by layoffs per year
with company_year (company, years,total_laid_off) as (
Select company, YEAR(`date`), sum(total_laid_off)
From layoffs_staging2
group by company, YEAR(`date`)
) , company_year_rank as
(select *, 
dense_rank() over ( partition by years order by total_laid_off desc) as Ranking
from company_year
where years is not null
)
select *
From Company_year_rank
where Ranking <= 5 ;
