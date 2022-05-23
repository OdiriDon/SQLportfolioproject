SELECT * 
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT * 
--FROM CovidPortfolioProject..CovidVaccination
--ORDER BY 3, 4

--Select data that we would be using for the this project

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidVaccination
ORDER BY 1, 2

--Looking at the total cases vs total deaths in Nigeria and the United States
--Shows the likelihood of dying if you contract covid

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE Location LIKE '%Nigeria%'
ORDER BY 1, 2

--Looking a the total cases vs the population in United States and Nigeria
--Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases / population) * 100 AS ContactedPopulation
FROM CovidPortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1, 2

SELECT Location, date, population, total_cases, (total_cases / population) * 100 AS ContactedPopulation
FROM CovidPortfolioProject..CovidDeaths
WHERE Location LIKE '%Nigeria%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PopulationOfInfected
FROM CovidPortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PopulationOfInfected DESC

--This is showing the countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
WHERE location IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


--Going by continents
--This is showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Breaking global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100  AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--Looking at total populations vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

---- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 