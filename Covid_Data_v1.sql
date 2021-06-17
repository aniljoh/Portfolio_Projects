
--select * 
--from PortfolioProject1..deaths
--order by 3,4
--select * 
--from PortfolioProject1.dbo.vaccine
--order by 3,4


--Likelihood of dying if you contract covid in INDIA

select location,date,total_cases,total_deaths ,(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject1.dbo.deaths
where location='India'
order by 1,2

--Total cases vs population

select location,date,total_cases,population,((total_cases/population)*100 )as casepercentage
from PortfolioProject1.dbo.deaths
--where location='India'
order by 1,2

select location,population,max(total_cases) as higestinfection,max((total_cases/population))*100 as casepercentage
from PortfolioProject1.dbo.deaths
group by location,population
order by 3 desc


-- higest death counts countrywise
select location,population,max(cast(total_deaths as int)) as TotalDeaths,max((total_deaths/population))*100 as deathpercentage
from PortfolioProject1.dbo.deaths
where continent is NOT null
group by location,population
order by 3 desc

-- higest death counts continent
select location,max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject1.dbo.deaths
where continent is  null
group by location
order by TotalDeaths desc

--GLOBAL NUMBERS

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,round((sum(cast(new_deaths as int))/sum(new_cases)*100),2)as  deathpercentage
from PortfolioProject1.dbo.deaths
where continent is not null
group by date
order by date

select deaths.continent,deaths.location,deaths.date,population,new_vaccinations,
sum(convert (int,new_vaccinations)) over (PARTITION by deaths.location order by deaths.date) as Rollingpeoplevaccinated
from PortfolioProject1..deaths
join PortfolioProject1..vaccine
   on deaths.location=vaccine.location
   and deaths.date=vaccine.date
where deaths.continent is NOT NULL
order by 2,3

--use CTE

with popVSvac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select deaths.continent,deaths.location,deaths.date,population,new_vaccinations,
sum(convert (int,new_vaccinations)) over (PARTITION by deaths.location order by deaths.date) as Rollingpeoplevaccinated
from PortfolioProject1..deaths
join PortfolioProject1..vaccine
   on deaths.location=vaccine.location
   and deaths.date=vaccine.date
where deaths.continent is NOT NULL
--order by 2,3
)
select * ,(Rollingpeoplevaccinated/population)*100
from popVSvac


--temp table
DROP table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select deaths.continent,deaths.location,deaths.date,population,new_vaccinations,
sum(convert (int,new_vaccinations)) over (PARTITION by deaths.location order by deaths.date) as Rollingpeoplevaccinated
from PortfolioProject1..deaths
join PortfolioProject1..vaccine
   on deaths.location=vaccine.location
   and deaths.date=vaccine.date
where deaths.continent is NOT NULL
--order by 2,

select * ,(Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--Creating view for data visualization
create view percentvaccinated as
select deaths.continent,deaths.location,deaths.date,population,new_vaccinations,
sum(convert (int,new_vaccinations)) over (PARTITION by deaths.location order by deaths.date) as Rollingpeoplevaccinated
from PortfolioProject1..deaths
join PortfolioProject1..vaccine
   on deaths.location=vaccine.location
   and deaths.date=vaccine.date
where deaths.continent is NOT NULL
--order by 2,3

Create View globalnumbers as
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,round((sum(cast(new_deaths as int))/sum(new_cases)*100),2)as  deathpercentage
from PortfolioProject1.dbo.deaths
where continent is not null
group by date
--order by date