--SELECT *
--FROM CovidProject.dbo.CovidDeaths
--order by 3,4

--SELECT *
--FROM CovidProject.dbo.CovidVacinations
--order by 3,4


--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidProject.dbo.CovidDeaths
WHERE location ='United States'
ORDER BY 1,2

--Looking at totaly cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_percentage
FROM CovidProject.dbo.CovidDeaths
WHERE location ='United States'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
FROM CovidProject.dbo.CovidDeaths
--WHERE location='United States'
GROUP BY location, population
ORDER BY percent_population_infected desc

--Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT))AS total_death_count
FROM CovidProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY total_death_count desc

--Deaths by continent

SELECT location, MAX(CAST(total_deaths AS INT))AS total_death_count
FROM CovidProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count desc

--global numbers

Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE continent is not null 
--Group By date
ORDER BY  1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS rolling_amount_vaccinated
FROM CovidProject.dbo.CovidDeaths dea
JOIN CovidProject.dbo.CovidVaccinations vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Creating a CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_amount_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS rolling_amount_vaccinated
FROM CovidProject.dbo.CovidDeaths dea
JOIN CovidProject.dbo.CovidVaccinations vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_amount_vaccinated/population)*100 AS percentage_of_population_vaccinated
FROM pop_vs_vac

--Creating a TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_amount_vaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS rolling_amount_vaccinated
FROM CovidProject.dbo.CovidDeaths dea
JOIN CovidProject.dbo.CovidVaccinations vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_amount_vaccinated/population)*100 AS percentage_of_population_vaccinated
FROM #PercentPopulationVaccinated


--Creating Views for vizualizations

USE CovidProject
GO
CREATE VIEW PercentPopulationVaccinated AS --Percent of population vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS rolling_amount_vaccinated
FROM CovidProject.dbo.CovidDeaths dea
JOIN CovidProject.dbo.CovidVaccinations vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


USE CovidProject
GO
CREATE VIEW PercentPopulationInfected AS --Percent of population infected
SELECT location, population, MAX(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
FROM CovidProject.dbo.CovidDeaths
GROUP BY location, population
--ORDER BY percent_population_infected desc

USE CovidProject
GO
CREATE VIEW DeathsByContinent AS --# of deaths by continent
SELECT location, MAX(CAST(total_deaths AS INT))AS total_death_count
FROM CovidProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
--ORDER BY total_death_count desc

USE CovidProject
GO
CREATE VIEW SurvivalRate AS
SELECT Location, date, total_cases,total_deaths, 100-(total_deaths/total_cases)*100 AS survival_rate
FROM CovidProject.dbo.CovidDeaths
--WHERE location ='United States'
WHERE CovidProject.dbo.CovidDeaths.continent IS NOT NULL
--ORDER BY 1,2