select * from PortfolioProject..['Covid Deaths (1)$'] where continent is not null order by 3,4 
select * from PortfolioProject..['Covid Vaccinations$'] order by 3,4

select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..['Covid Deaths (1)$'] order by 1,2
--Looking Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID

select location, date, total_cases, total_deaths, (total_deaths/total_cases) as DeathPercentage from PortfolioProject..['Covid Deaths (1)$'] where location like '%states%' and continent is not null order by 1,2



--Looking at Total Cases vs Population
--Shows what percentage of population has Covid 

Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage from PortfolioProject..['Covid Deaths (1)$'] where location like '%states%' and continent is not null order by 1,2

--Showing Highest Infection Percentage rate and Population Innfection Percentage by Locatio 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected from PortfolioProject..['Covid Deaths (1)$'] 
--where location like '%states%'
Where continent is not null
Group by location, population 
order by PercentPopulationInfected desc

--Showing Continent  with the Highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..['Covid Deaths (1)$'] 
--where location like '%states%' 
where continent is not null
Group by continent 
order by TotalDeathCount desc

-- Breaking it down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..['Covid Deaths (1)$'] 
--where location like '%states%' 
where continent is not null
Group by continent   
order by TotalDeathCount desc


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..['Covid Deaths (1)$'] 
--where location like '%states%' 
where continent is not null
Group by continent 
order by TotalDeathCount desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..['Covid Deaths (1)$'] 
where continent is not null 
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)
from PortfolioProject..['Covid Deaths (1)$'] dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null 
order by 2,3


--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths (1)$'] dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..['Covid Deaths (1)$'] dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View tp store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
from PortfolioProject..['Covid Deaths (1)$'] dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated