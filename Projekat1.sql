SELECT *
FROM COVIDDEATHS
order by 3,4;

--SELECT *
--FROM COVIDVACCINATIONS
--order by 3,4

--select data 
SELECT location, date_date, total_cases, new_cases, total_deaths, population
from COVIDDEATHS
order by 1,2;


--looking at total cases vs total deaths
--shows likeleyhood of dying if you catch covid in your country
SELECT location, date_date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDDEATHS
where location like '%Bosnia%'
order by 1,2;




--looking at total cases vs  population
--shows what percentage of population got covid
SELECT location, date_date, total_cases, population, (total_cases/population)*100 as TotalCasesPercentage
from COVIDDEATHS
where location like '%Bosnia%'
order by 1,2;



--looking at counties with highest infection rate compared to population
SELECT location, population, max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopulationInfectedPercentage
from COVIDDEATHS
--where location like '%Bosnia%'
group by location, population
order by PopulationInfectedPercentage desc;





--showing countries with highest deathcount per population
SELECT location, max(total_deaths) as TotalDeathsCount
from COVIDDEATHS
where continent is not null
group by location
order by TotalDeathsCount desc;

--BY CONTINENTS
SELECT location, max(total_deaths) as TotalDeathsCount
from COVIDDEATHS
where continent is null
group by location
order by TotalDeathsCount desc;


--showing the contitnets with highest deatCount
SELECT continent, max(total_deaths) as TotalDeathsCount
from COVIDDEATHS
where continent is not null
group by continent
order by TotalDeathsCount desc;

--GLOBAL PER DATE 
SELECT date_date,sum(new_cases), sum(new_deaths), 
sum(new_deaths)/sum(new_cases)*100 as deathsPercentage-- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDDEATHS
where continent is not null
group by date_date
order by 1,2;

--GLOBAL  
SELECT sum(new_cases), sum(new_deaths), 
sum(new_deaths)/sum(new_cases)*100 as deathsPercentage-- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDDEATHS
where continent is not null
order by 1,2;



--COVID VACCINATION
SELECT dea.continent, dea.location, dea.date_date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by  dea.location order by dea.location, 
dea.date_date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM COVIDDEATHS dea
JOIN COVIDVACCINATIONS vac
 ON DEa.location = vac.location
 and dea.date_date = vac.date_date
where dea.continent is not null
order by 2,3;



--CTE
with PopvsVac (Continent, location, date_date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date_date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by  dea.location order by dea.location, 
dea.date_date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM COVIDDEATHS dea
JOIN COVIDVACCINATIONS vac
 ON DEa.location = vac.location
 and dea.date_date = vac.date_date
where dea.continent is not null
--order by 2,3
)

select  p.*, ((RollingPeopleVaccinated/population)*100) from PopvsVac p;


--TEMP table--

--BEGIN
--      EXECUTE IMMEDIATE 'DROP TABLE sales';
--  EXCEPTION
--      WHEN OTHERS THEN NULL;
--  END;


--DROP table PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
    Continent VARCHAR2(26),
    location VARCHAR2(200),
    date_date DATE,
    population NUMBER(38),
    new_vaccination NUMBER(38),
    RollingPeopleVaccinated NUMBER(38)
);

insert into PercentPopulationVaccinated
    SELECT dea.continent, 
        dea.location, 
        dea.date_date, 
        dea.population,
        vac.new_vaccinations,
        sum(vac.new_vaccinations) OVER (Partition by  dea.location 
        order by dea.location, 
        dea.date_date) as RollingPeopleVaccinated
    FROM COVIDDEATHS dea
    JOIN COVIDVACCINATIONS vac
    ON (dea.location = vac.location
        and dea.date_date = vac.date_date);
        
select  p.*, ((RollingPeopleVaccinated/population)*100)
from PercentPopulationVaccinated p;

--________________________________________________________
--creating view to store data for later visualisations--
create View PercentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date_date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by  dea.location order by dea.location, 
dea.date_date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM COVIDDEATHS dea
JOIN COVIDVACCINATIONS vac
 ON DEa.location = vac.location
 and dea.date_date = vac.date_date
where dea.continent is not null
order by 2,3;

 
select * 
from PercentagePopulationVaccinated;

--DOMACI--
--ZEMLJE: Slovenia, Croatia, Serbia, BiH, Kosovo, Macedonia, Albania, Montenegro--
--1. Koje od navedenih imaju najveci procenat zarazenih u odnosu na broj stanovnika?-- 
--2. Koje imaju najveci postotak vakcinisanih u odnosu na broj stanovnika?--

--laksi nacin--
SELECT dea.location,  
        dea.population, 
        max(dea.total_cases), 
        max(vac.people_fully_vaccinated),
        round((max(dea.total_cases)/dea.population)*100,2) as Infected_Percentage,
        round((max(vac.people_fully_vaccinated)/dea.population)*100,2) as Vaccinated_Percentage
FROM COVIDDEATHS dea
JOIN  COVIDVACCINATIONS vac
ON DEa.location = vac.location 
where dea.location in ('Slovenia', 'Croatia', 'Serbia', 'Bosnia and Herzegovina', 'Kosovo', 'North Macedonia', 'Albania', 'Montenegro')
GROUP BY dea.location, dea.population
ORDER BY 5,6;



--bespotrebno tezi nacin
drop table domaci;

CREATE TABLE Domaci 
(
    location VARCHAR2(200) ,
    population NUMBER(38),
    total_cases NUMBER(38),
    people_fully_vaccinated NUMBER(38)--,
    --infected_percent NUMBER(38),
    --vaccinated_percent NUMBER(38)
);

insert into Domaci
    SELECT 
        dea.location,  
        dea.population,
        (dea.total_cases),
        (vac.people_fully_vaccinated) 
        
    FROM COVIDDEATHS dea
    inner JOIN COVIDVACCINATIONS vac
    ON (dea.location = vac.location)
    
    where dea.location like '%Montenegro%'
    or
    dea.location like '%Bosnia%'
    or
    dea.location like '%Slovenia%'
    or
    dea.location like '%Croatia%'
    or
    dea.location like '%Serbia%'
    or
    dea.location like '%Kosovo%'
    or
    dea.location like '%Macedonia%'
    or
    dea.location like '%Albania%'
;
    
--odgovor na 1.   
select  location,  
        population,
        max(total_cases),
        max(people_fully_vaccinated),
        round((max(total_cases)/population)*100,2) as Infected_Percentage,
        round((max(people_fully_vaccinated)/population)*100,2) as Vaccinated_Percentage
from domaci
group by location, population
order by 5 desc;

--odgovor na 2.   
select  location,  
        population,
        max(total_cases),
        max(people_fully_vaccinated),
        round((max(total_cases)/population)*100,2) as Infected_Percentage,
        round((max(people_fully_vaccinated)/population)*100,2) as Vaccinated_Percentage
from domaci
group by location, population
order by 6 desc;







