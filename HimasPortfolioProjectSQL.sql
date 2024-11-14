---  Project for sharpening Data Analysis concepts such as cleaning data ,ETL 



-- Retrieve all records from Covid_deaths table, ordered by third and fourth columns
SELECT * 
FROM PortfolioProject.dbo.Covid_deaths$
ORDER BY 3, 4;

-- Retrieve all records from CovidVaccinations table, ordered by third and fourth columns
-- SELECT * 
-- FROM PortfolioProject..CovidVaccinations$
-- ORDER BY 3, 4;

-- Select specific columns from Covid_deaths table, ordered by location and date
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_deaths$
ORDER BY location, date;

-- Total Cases vs Total Deaths in Canada: Likelihood of dying if infected with COVID
SELECT location, date, total_cases, new_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths$
WHERE location LIKE '%canada%'
ORDER BY location, date;

-- Total Cases vs Population in Canada: Shows what percentage got COVID
SELECT location, date, total_cases, population, 
       (total_cases / population) * 100 AS InfectionPercentage
FROM PortfolioProject..Covid_deaths$
WHERE location LIKE '%canada%'
ORDER BY location, date;

-- Countries with highest infection rate compared to population
SELECT location, population, 
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM PortfolioProject..Covid_deaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..Covid_deaths$
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC;

-- Global Numbers for new cases and new deaths, calculating death percentage
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS int)) AS total_deaths, 
       SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths$
WHERE continent IS NOT NULL;

-- Rolling total of vaccinated people by location and date
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, Vaccinations.new_vaccinations,
       SUM(CONVERT(INT, Vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covid_deaths$ deaths
JOIN PortfolioProject..CovidVaccinations$ Vaccinations
ON deaths.location = Vaccinations.location
AND deaths.date = Vaccinations.date
WHERE deaths.continent IS NOT NULL
ORDER BY deaths.location, deaths.date;

-- Using CTE to calculate rolling vaccination rate as percentage of population
WITH PopvsVac AS (
    SELECT deaths.continent, deaths.location, deaths.date, deaths.population, Vaccinations.new_vaccinations,
           SUM(CONVERT(BIGINT, Vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) AS RollingPeopleVaccinated
    FROM PortfolioProject..Covid_deaths$ deaths
    JOIN PortfolioProject..CovidVaccinations$ Vaccinations
    ON deaths.location = Vaccinations.location
    AND deaths.date = Vaccinations.date
    WHERE deaths.continent IS NOT NULL
)
SELECT (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM PopvsVac;

-- Temporary table to calculate rolling vaccination percentage per population
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert data into temporary table
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covid_deaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date;

-- Select data from temporary table, calculating vaccination rate as percentage of population
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated;

-- Create view for later visualizations
CREATE VIEW PercentPopulationVaccinated1 AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
       SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covid_deaths$ deaths
JOIN PortfolioProject..CovidVaccinations$ vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL;








