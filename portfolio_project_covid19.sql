-- Selecting data being used
SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject_Covid19.dbo.coviddeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows probability of dying from covid based on country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
from PortfolioProject_Covid19.dbo.coviddeaths
where location like '%states%'
order by 1,2 DESC

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as contraction_percentage
from PortfolioProject_Covid19.dbo.coviddeaths
where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population)*100 as contraction_percentage
from PortfolioProject_Covid19.dbo.coviddeaths
group by location, population
order by contraction_percentage desc

-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count, (MAX(cast(total_deaths as int))/population)*100 as death_rate
from PortfolioProject_Covid19.dbo.coviddeaths
where continent is not null
group by location, population
order by death_rate

-- Lets break things down by continent

-- Showing continents with the highest death count per population 
SELECT continent, MAX(cast(total_deaths as int)) AS highest_death_count
from PortfolioProject_Covid19.dbo.coviddeaths
where continent is not null
group by continent
order by highest_death_count desc

-- Data unclean so location will show total numbers while continents will not..
SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count
from PortfolioProject_Covid19.dbo.coviddeaths
where continent is null
group by location
order by highest_death_count desc

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_rate
from PortfolioProject_Covid19.dbo.coviddeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
, (
From PortfolioProject_Covid19.dbo.coviddeaths dea
Join PortfolioProject_Covid19.dbo.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
From PortfolioProject_Covid19.dbo.coviddeaths dea
Join PortfolioProject_Covid19.dbo.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Vax_Rate_Rolling
FROM PopvsVac

-- Using Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
From PortfolioProject_Covid19.dbo.coviddeaths dea
Join PortfolioProject_Covid19.dbo.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Vax_Rate_Rolling
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
USE PortfolioProject_Covid19
GO
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
From PortfolioProject_Covid19.dbo.coviddeaths dea
Join PortfolioProject_Covid19.dbo.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated