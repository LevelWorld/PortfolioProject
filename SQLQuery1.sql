SELECT location,date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs Total Deaths
-- Shows the likelyhood of mortality post covid contraction
-- by default this query looks the 'United States'
SELECT location,date, total_cases, total_deaths, (CAST (total_deaths AS int) / CAST (total_cases AS int) )*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
wHERE location like '%states'
ORDER BY 1,2


-- Looking at total cases vs Populations
-- Shows the percentage of the population who contracted covid
-- by default this query looks the 'United States'
SELECT location,date, total_cases, population, (CAST (total_deaths AS int) / CAST (population AS int) )*100 as PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
wHERE location like '%states'
ORDER BY 1,2

-- Looking at Countries with Highest Infection rate compared to populations
-- Shows the percentage of the population who contracted covid
-- by default this query looks the 'United States'
SELECT location, population, Max(cast (total_cases as int)) as HighestInfectionCount, Max(cast (total_cases as float))/ CAST (population AS int) as PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PopulationPercentageInfected desc



-- Let's break things down by Continent
SELECT continent, location, MAX( cast (total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null	
GROUP BY continent
ORDER BY TotalDeathCount desc
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global number  NEEDS WORK
SELECT date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int) )as total_deaths, (SUM (cast(new_deaths as int)) /NULLIF( SUM(new_cases*100), 0)) as DeathPercentage
FROM PortfolioProject..CovidDeaths
wHERE continent is not null
Group by date
ORDER BY 1,2

-- Looking at total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(cast(vax.new_vaccinations as bigint)) OVER (partition by dea.location ORDER by dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
order by 2,3

-- USE CTE
WITH PopvsVax (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated) as (
	SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(cast(vax.new_vaccinations as bigint)) OVER (partition by dea.location ORDER by dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null

)
SELECT *, (Rolling_People_Vaccinated/Population) *100 as Rolling_Percentage_POP_Vax
FROM PopvsVax

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(cast(vax.new_vaccinations as bigint)) OVER (partition by dea.location ORDER by dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null

SELECT *, (Rolling_People_Vaccinated/Population) *100 as Rolling_Percentage_POP_Vax
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visulizatioins

Create View PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(cast(vax.new_vaccinations as bigint)) OVER (partition by dea.location ORDER by dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null