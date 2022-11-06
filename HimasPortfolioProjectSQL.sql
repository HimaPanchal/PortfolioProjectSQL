--- Following along with Alex The Analyst's Youtube Project for Data Analysis



select * 
from PortfolioProject.dbo.Covid_deaths$
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

	select location, date, total_cases,new_cases, total_deaths, population
	from PortfolioProject..Covid_deaths$
	order by 1, 2

--- Looking at Total Cases vs Total Deaths in Canada
--- Likelihood of dying if you get COVID Infected

select location, date, total_cases,new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_deaths$
where location like '%canada%'
order by 1, 2


--- Looking at Total Cases Vs Population in Canada
--- Shows what percentage got COVID
select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..Covid_deaths$
where location like '%canada%'
order by 1, 2


--- Looking at Countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..Covid_deaths$
--where location like '%canada%'
group by Location, Population
order by PercentPopulationInfected desc

--- Showing Countries with Highest Death Count per Population

Select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_deaths$
where continent is null
Group by continent 
order by TotalDeathCount desc

-- Global Numbers
Select Sum(new_cases) as total_cases, 
Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(New_deaths as int))/Sum(New_cases)*100 as DeathPercentage
from PortfolioProject..Covid_deaths$
where continent is not null 
order by 1,2

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProject..Covid_deaths$ dea
--Join PortfolioProject..CovidVaccinations$ vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

	Select deaths.continent, deaths.location, deaths.date, deaths.population,Vaccinations.new_vaccinations ,
	Sum(convert (int,Vaccinations.new_vaccinations)) OVER (Partition by deaths.Location order by deaths.location, deaths.Date) as RollingPeopleVaccinated

	from PortfolioProject..Covid_deaths$ deaths
	Join PortfolioProject..CovidVaccinations$ Vaccinations
	 On deaths.location = Vaccinations.location
	 and deaths.date= Vaccinations.date
	 where deaths.continent is not null
	 order by 2,3

	 --Using CTE 
With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(	Select deaths.continent, deaths.location, deaths.date, deaths.population,Vaccinations.new_vaccinations ,
	Sum(convert (bigint,Vaccinations.new_vaccinations)) OVER (Partition by deaths.Location order by deaths.location, deaths.Date) as RollingPeopleVaccinated

	from PortfolioProject..Covid_deaths$ deaths
	Join PortfolioProject..CovidVaccinations$ Vaccinations
	 On deaths.location = Vaccinations.location
	 and deaths.date= Vaccinations.date
	 where deaths.continent is not null
	

)

Select  (RollingPeopleVaccinated/population)*100 from PopvsVac

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_deaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated1 as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..Covid_deaths$ deaths
Join PortfolioProject..CovidVaccinations$ vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 









