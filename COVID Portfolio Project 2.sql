SELECT *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
Order by 1,2

--Looking at Total cases vs Total deaths
--shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
Order by 1,2

--Looking at countries with Highest Infection Rate compared to population

SELECT location, population,MAX (total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population

SELECT location, MAX (cast(total_deaths as int))as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
Order by TotalDeathCount desc


--Let's break things down by continent

SELECT continent, MAX (cast(total_deaths as int))as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--showing the continents with the highest death count per population

SELECT continent, MAX (cast(total_deaths as int))as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

SELECT   sum(new_cases) as totalcases, sum(Cast(new_deaths  as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--Group By date
Order by 1,2

Select *
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and  dea.date = vac.date

--Looking at Total Population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--CREATE CTE
With Popvsvac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From Popvsvac


--TEMP TABLE

Drop Table  if exists #PercentPopulationVaccinated
Create Table #PercentPopulatedVaccinated
(
continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulatedVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulatedVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null
