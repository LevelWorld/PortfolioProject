

-- Data Cleaning in MYSQL
-- What I will do in this project
-- 1. Remove Duplications
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove any Columns

select * 
from layoffs;



-- Create a stage table
Create table layoffs_staging
Like layoffs;

select * 
from layoffs_staging;

insert layoffs_staging
select * 
from layoffs;

-- removing duplicates
-- will need a 'row_num'  columns

-- just to test my idea
select *, 
row_number() over( partition by
company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
From layoffs_staging;

with duplicate_cte as
(
select *, 
row_number() over( partition by
company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_num
From layoffs_staging
)
select *
From duplicate_cte
where row_num > 1;

-- to see if we were able to find duplicates
select *
From layoffs_staging
Where company = 'Casper';

-- For deleting duplicates
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
From layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over( partition by
company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_num
From layoffs_staging;

select *
From layoffs_staging2
where row_num > 1;

Delete
From layoffs_staging2
where row_num > 1;

-- Standarding Data
-- white space
Select company, TRIM(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select *
From layoffs_staging2;

-- similar industries
select distinct industry
From layoffs_staging2
order by 1;

select *
From layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- 'United States.' --> 'United States'
Select distinct country, trim(TRAILING '.' FROM country)
from layoffs_staging2
where country like 'United States%'
order by 1;

update layoffs_staging2
set country = trim(Trailing '.' from country)
where country like 'United States%';

-- changeing column type from text to date
Select * -- `date`,
-- str_to_date(`date`, '%m/%d/%Y') 
From layoffs_staging2;

update layoffs_staging2 
set `date` = str_to_date(`date`, '%m/%d/%Y') ;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` Date;

-- working with null and blank values
Select * 
From layoffs_staging2
where total_laid_off is null and
percentage_laid_off is null;

Select *
From layoffs_staging2
where industry is null or
industry = '';

Select * 
From layoffs_staging2
where company = 'Airbnb';

Select * 
From layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

-- deleteing rows I can't use due to missing data
delete
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- drop row_num column
alter table layoffs_staging2
drop column row_num;

Select * 
From layoffs_staging2;
