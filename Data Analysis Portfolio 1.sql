SELect *
from PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 3,4


--SELect *
--from PortfolioProject..CovidVaccinations
--order by 3,4

SELect location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2



-- Total Cases vs Total Deaths

SELect location, date, total_cases, total_deaths, (total_deaths/total_cases)
from PortfolioProject..CovidDeaths
order by 1, 2

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- What percentage of population got Covid

Select location, date, population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS CovidPercentage
from PortfolioProject..covidDeaths
--where location like '%states%'
order by 1, 2

-- Countries with Highest Infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent <> ''
Group by location, population
order by TotalDeathCount DESC

-- Break things down by Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent = ''
Group by location
order by TotalDeathCount DESC


--Global numbers

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int))  as total_deaths
, SUM(cast(new_deaths as int)) / NULLIF(SUM(cast(new_cases as float)), 0) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent <> ''
--group by date
order by 1,2


--total population vs vaccinations


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, cast(dea.population as float), vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	where dea.continent <> ''
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/NULLIF (population, 0)) * 100
From PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, cast(dea.population as float), cast (vac.new_vaccinations as float)
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	where dea.continent <> ''
--order by 2, 3

Select *, (RollingPeopleVaccinated/NULLIF (population, 0)) * 100
From #PercentpopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	where dea.continent <> ''
--order by 2, 3