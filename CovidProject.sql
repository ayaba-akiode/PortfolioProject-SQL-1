SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;


SELECT *
FROM CovidVaccinations
ORDER BY 3,4;

--Return columns needed for the project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

--Return total cases versus total date by location
--What is the percentage of death to the total number of cases

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageOfDeath
FROM CovidDeaths
ORDER BY 1,2;

--What is the percentage of death to the total number of cases by specific location, e.g Nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageOfDeath
FROM CovidDeaths
WHERE location like '%igeria%'
ORDER BY 1,2;

--TOTAL CASES VS POPULATION
--What percentage of the population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageThatGotInfected
FROM CovidDeaths
ORDER BY 1,2;

--What country has the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageThatGotInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

--What countries have the highest death count, remove continents that have null value
SELECT location, MAX(cast(total_deaths as float)) AS HighestTotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestTotalDeathCount DESC;


--What countries have the highest death count by continent
SELECT continent, MAX(cast(total_deaths as float)) AS HighestTotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeathCount DESC;


--What countries have the highest death count by continent
SELECT continent, MAX(cast(total_deaths as float)) AS HighestTotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeathCount DESC;


--Show total case vs total death recorded per day globally
SELECT date, SUM(total_cases), SUM(cast(total_deaths as float))
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Show total case vs total death recorded per day by location
SELECT location, date, SUM(total_cases) AS TotalCase, SUM(cast(total_deaths as float)) AS TotalDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, date
ORDER BY 1,2;

--Show number of new case to number of new death recorded per day globally
SELECT date, SUM(new_cases) AS TotalNewCase, SUM(cast(new_deaths as float)) AS TotalNewDeath, 
SUM(cast(new_deaths as float))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Show percentage of death to new cases recorded per day globally
SELECT date, SUM(new_cases) AS TotalNewCase, SUM(cast(new_deaths as float)) AS TotalNewDeath, 
SUM(cast(new_deaths as float))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Show percentage of death to new cases recorded over the covid period globally
SELECT SUM(new_cases) AS TotalNewCase, SUM(cast(new_deaths as float)) AS TotalNewDeath, 
SUM(cast(new_deaths as float))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Return all data from the covid vaccination table
SELECT *
FROM CovidVaccinations;

--Join both tables together and join on location and date
SELECT *
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date;

--Show the total number of population in the world vs those who were vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
ORDER BY 1,2;

--Show the total number of population in the world vs those who were vaccinated, remove null continents
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--Show the total number of population in the world vs those who were vaccinated, where continent is North America
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent = 'North America'
ORDER BY 2,3;

--Show the new vaccinations count per day, show by location(partition) in an incremental pattern
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CurrentNewVaccination
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--Show the number of people vaccinated per day vs total population.
-- WE need a CTE or TEMP table to store the value of the CurrentNewVaccination
-- Using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, CurrentNewVaccination)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CurrentNewVaccination
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac

--Now Show the number of people vaccinated per day vs total population.
WITH PopvsVac (continent, location, date, population, new_vaccinations, CurrentNewVaccination)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CurrentNewVaccination
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (CurrentNewVaccination/population)* 100 AS PercentageCurrentNewVaccination
FROM PopvsVac;

--Perform the same Using temp table.Create the temp table and speciy data types
--create temp table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations float, 
CurrentNewVaccination float
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CurrentNewVaccination
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS CurrentNewVaccination
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

-- Return all data from the view created
SELECT *
FROM PercentPopulationVaccinated


-- Creating view for the percentage of death to the total number of cases

CREATE VIEW PercentageOfDeath AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageOfDeath
FROM CovidDeaths;

SELECT *
FROM PercentageOfDeath