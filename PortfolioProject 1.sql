select *
from PortfolioProject..coviddeath
where continent is not null
order by 3,4


--select *
--from PortfolioProject..covidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..coviddeath
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeath
where location like '%nigeria%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid 

select location, date,  Population, total_cases, (total_cases/Population)*100 as PercentofPopulationInfected
from PortfolioProject..coviddeath
--where location like '%nigeria%'
order by 1,2



--Looking at countries with highest infection rate compared to population

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as PercentofPopulationInfected
from PortfolioProject..coviddeath
--where location like '%nigeria%'
group by location, population
order by PercentofPopulationInfected desc


--Showing countries with highest death count by population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeath
where continent is not null
group by location
order by TotalDeathCount desc


--Let's Break things down by Continent
--Showing the Continents with the highest death counts


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeath
where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..coviddeath
where continent is not null
group by date
order by 1,2


--Looking at Total population vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later Visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null



create view ContinentsWithHighestDeathCount as
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeath
where continent is not null
group by continent
--order by TotalDeathCount desc




