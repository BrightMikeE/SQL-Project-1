
select *
from [Portfolio Project 1 ]. .[Covid Deaths]
where continent is not null
order by 3,4

select *
from [Covid Vaccination]
order by 3,4

--select Data that we are going to be using

select location, DATE, total_cases, new_cases, total_deaths, population_density
from [Portfolio Project 1 ]. .[Covid Deaths]
order by 1,2

--looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country
select location, DATE, total_cases, total_deaths, (convert(float,total_deaths)/Nullif(convert(float,total_cases),0))*100 as  DeathPercentage
from [Portfolio Project 1 ]. .[Covid Deaths]
where location like '%kingdom%'
order by 1,2

--looking at the total cases Vs the population density
--shows what percentage of population got covid

select location, DATE, total_cases, population_density, (total_cases/population_density)*100 as PercentagePopulationInfected
from [Portfolio Project 1 ]. .[Covid Deaths]
where location like '%kingdom%'
order by 1,2

-- Looking at countries with highest infection rate compared to population density

select location, population_density, max(total_cases) as HighestInfectioncount, max((total_cases/population_density))*100 as PercentagePopulationnfected
from [Portfolio Project 1 ]. .[Covid Deaths]
--where location like '%kingdom%'
group by  location, population_density
order by PercentagePopulationnfected desc


--Showing Countries with the Highest Death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project 1 ]. .[Covid Deaths]
--where location like '%kingdom%'
where continent is not null
group by  location 
order by TotalDeathCount desc

--Lets break things down by continent


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project 1 ]. .[Covid Deaths]
--where location like '%kingdom%'
where continent is not null
group by  location
order by TotalDeathCount desc


--showing the continents with the highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project 1 ]. .[Covid Deaths]
--where location like '%kingdom%'
where continent is not null
group by  continent
order by TotalDeathCount desc


--Global Numbers

select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from [Portfolio Project 1 ]. .[Covid Deaths]
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccinations

select Dea.continent, Dea.location, dea.date, dea.population_density, Vac.new_vaccinations,
SUM(convert(int,Vac.new_vaccinations)) over(partition by Dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from [Portfolio Project 1 ]. .[Covid Deaths] Dea
join [Portfolio Project 1 ]. .[Covid Vaccination] Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date 
where dea.continent is not null
order by 2,3 

-- use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location, dea.date, dea.population_density, Vac.new_vaccinations,
SUM(convert(int,Vac.new_vaccinations)) over(partition by Dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from [Portfolio Project 1 ]. .[Covid Deaths] Dea
join [Portfolio Project 1 ]. .[Covid Vaccination] Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--use CTE 2
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location, dea.date, dea.population_density, Vac.new_vaccinations,
SUM(convert(int,Vac.new_vaccinations)) over(partition by Dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from [Portfolio Project 1 ]. .[Covid Deaths] Dea
join [Portfolio Project 1 ]. .[Covid Vaccination] Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated Numeric
)

insert into #PercentPopulationVaccinated
select Dea.continent, Dea.location, dea.date, dea.population_density, Vac.new_vaccinations,
SUM(convert(bigint,Vac.new_vaccinations)) over(partition by Dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from [Portfolio Project 1 ]. .[Covid Deaths] Dea
join [Portfolio Project 1 ]. .[Covid Vaccination] Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date 
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visualisation

create view PercentPopulationVaccinated as
select Dea.continent, Dea.location, dea.date, dea.population_density, Vac.new_vaccinations,
SUM(convert(bigint,Vac.new_vaccinations)) over(partition by Dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
from [Portfolio Project 1 ]. .[Covid Deaths] Dea
join [Portfolio Project 1 ]. .[Covid Vaccination] Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date 
where dea.continent is not null
--order by 2,3

--select *
--from PercentPopulationVaccinated