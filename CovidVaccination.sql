SELECT * FROM PortfolioProject..CovidDeaths

--Select data we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

--Looking at Total Cases vs Total Deaths
--Showing likelihood of dying if you contract covid in Slovakia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='Slovakia' 


--Looking at Total Cases VS Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='Slovakia'

--Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS TotalCases, population, (MAX(total_cases)/population)*100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location='Slovakia'
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

--Showing the countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS Total_DeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_DeathsCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) AS Total_DeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_DeathsCount DESC

SELECT continent, MAX(cast(total_deaths as int)) AS Total_DeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE continent is not null
GROUP BY continent
ORDER BY Total_DeathsCount DESC

---Showing the continents with the highest deathcount

SELECT location , MAX(cast(total_deaths as int)) AS Total_DeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY Total_DeathsCount DESC

--nieco som skusal-------------------------------------------
SELECT MAX(TD)
FROM(
SELECT location, continent, MAX(cast(total_deaths as int)) AS TD
FROM PortfolioProject..CovidDeaths
WHERE continent='Europe'
GROUP BY location, continent )

SELECT continent, SUM(cast(new_deaths as int)) AS TD
FROM PortfolioProject..CovidDeaths
WHERE continent='Europe'
GROUP BY continent

----------------------------------------------------------------------------

---Breaking global 
SELECT date, sum(new_cases) AS NewCases, sum(cast(new_deaths as int)) AS NewDeaths, 
	(SUM(cast(new_deaths as int))/Sum(New_cases)) * 100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date ASC

--Looking at total population vs vaccination
SELECT cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations, 
	   SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location ORDER BY cd.location, cd.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON	cd.location=cv.location 
		and cd.date=cv.date
WHERE cd.continent is not null
ORDER BY 2,3


--USE CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingCountVaccinated)
as 
(
SELECT cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations, 
	   SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location ORDER BY cd.location, cd.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON	cd.location=cv.location 
		and cd.date=cv.date
WHERE cd.continent is not null
)
SELECT *, (RollingCountVaccinated/population)*100 AS VaccinationRate
FROM PopVsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations, 
	   SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location ORDER BY cd.location, cd.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON	cd.location=cv.location 
		and cd.date=cv.date
WHERE cd.continent is not null

SELECT *, (RollingCountVaccinated/population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated
----WHERE location='Slovakia'

---Creating view to store the data for later visualization
 
 Create View PercentagePopulationVaccinated as
 SELECT cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations, 
	   SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location ORDER BY cd.location, cd.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON	cd.location=cv.location 
		and cd.date=cv.date
WHERE cd.continent is not null