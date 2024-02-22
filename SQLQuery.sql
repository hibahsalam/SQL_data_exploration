/*

COVID 19 DATA EXPLORATION
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--TOTAL CASES vs TOTAL DEATHS
select 
	location, 
	date, 
	total_deaths, 
	total_cases, 
	(total_deaths/total_cases)*100 as death_percentage
from dbo.CovidDeaths as cd 
order by location, date desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--TOTAL CASES vs POPULATION
--Shows the percentage of population affected 
select 
	location, 
	date, 
	total_cases, 
	population, 
	(cast(total_cases as float)/cast(population as float))*100 as case_percentage 
from dbo.CovidDeaths as cd 
order by case_percentage desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--COUNTRIES INFECTION RATE PER POPULATION 
Select 
	location,
	population,
	SUM(new_cases) as max_infected, 
	SUM(cast(new_cases as int)/cast(population as float))*100 as InfectionRate
From CovidDeaths
where continent is not null 
group by location, population
order by InfectionRate desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--COUNTRIES DEATH COUNT
create view DeathCountLocation as
Select 
	location, 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as DeathCount, 
	SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
group by location;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CONTINENT DEATH COUNT
create view DeathCountContinent as
Select 
	continent, 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
group by continent;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--VACCINATION TABLE--

-- This shows the number of people who got atleast one vaccination

select distinct
	cd.location, 
	cd.population,
	year(cd.date) as year,
	sum(cast(cv.new_vaccinations as int)) over(partition by cd.location, year(cd.date)) as [vaccinated people]
from 
(select distinct * from CovidDeaths) cd join (select distinct * from CovidVaccinations) cv
on
cd.date = cv.date
and cd.location = cv.location
where cv.new_vaccinations is not null;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Using CTE to perform calculation on Partition By in previous query
With VaccinatedPeople (Continent, Location, population, Date, PeopleVaccinated)
as
(
select distinct
	cd.continent,
	cd.location, 
	cd.population,
	year(cd.date) as Year,
	sum(cast(cv.new_vaccinations as float)) over(partition by cd.location, year(cd.date)) as PeopleVaccinated
from 
(select distinct * from CovidDeaths) cd join (select distinct * from CovidVaccinations) cv
on
cd.date = cv.date
and cd.location = cv.location
where cv.new_vaccinations is not null
)
Select *, (PeopleVaccinated/Population)*100 as VaccinatedPercentage
From VaccinatedPeople;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #VaccinatedPeoplePercentage
create table #VaccinatedPeoplePercentage
(
	continent varchar(max),
	location varchar(max), 
	population numeric,
	date datetime,
	PeopleVaccinated numeric
)
insert into #VaccinatedPeoplePercentage
select distinct
	cd.continent,
	cd.location, 
	cd.population,
	year(cd.date) as Year,
	sum(cast(cv.new_vaccinations as float)) over(partition by cd.location, year(cd.date)) as PeopleVaccinated
from 
(select distinct * from CovidDeaths) cd join (select distinct * from CovidVaccinations) cv
on
cd.date = cv.date
and cd.location = cv.location
where cv.new_vaccinations is not null

Select *, (PeopleVaccinated/Population)*100 as VaccinatedPercentage
From #VaccinatedPeoplePercentage;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

---VIEWS---

create view IdCreation as
select ROW_NUMBER() over(partition by location order by date) as ID,* from CovidVaccinations;

select * from IdCreation;






