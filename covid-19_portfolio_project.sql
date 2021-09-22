SELECT * 
FROM PortfolioProject..CovidDeaths$
ORDER BY 3, 4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Looking at total cases vs total deaths

-- Likelihood of dying from COVID-19 in Nigeria
 

-- Total cases vs Population
-- Shows percentage of people that are infected
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_infected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Nigeria'

-- Countries with the highest infection rates per population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 AS percent_infected_population
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY percent_infected_population DESC

-- Countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) as total_death_count
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Continents with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) as total_death_count
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS 
		total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percent_death--, (total_deaths/total_cases)*100 AS percent_death
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Global death rate from COVID
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS 
		total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percent_death--, (total_deaths/total_cases)*100 AS percent_death
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Percentage of Cumulative vaccinations by date and location with CTE
WITH people_vaccinated (continent, location, date, population, 
	new_vaccinations, cumulative_new_vaccinated)
AS
	(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS cumulative_new_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (cumulative_new_vaccinated/population)*100 AS percent_cumulative_vaccinated
FROM people_vaccinated


-- Percentage of Cumulative vaccinations by date and location with Temp Tables
DROP TABLE IF EXISTS #percent_people_vaccinated
CREATE TABLE #percent_people_vaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_new_vaccinated numeric
)

INSERT INTO #percent_people_vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS cumulative_new_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * , (cumulative_new_vaccinated/population)*100 AS percent_cumulative_vaccinated
FROM #percent_people_vaccinated

-- Create view to store data for later visualisations
CREATE VIEW percent_people_vaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS cumulative_new_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM #percent_people_vaccinated