-- Covid Deaths by Continent
select Continent, max(cast(total_deaths as int)) as TotalDeaths
	from CovidDeaths
where continent is not null
Group by continent
order by TotalDeaths desc

-- Covid Prevalence by Country
Select Location
		, total_cases
		, new_cases
		, total_deaths
		, population
		,(total_cases/population)*100 as CovidPrevalance
		, date
from CovidDeaths
where location like '%states'
order by date

-- Likelyhood for Death
Select Location
		, total_cases
		, new_cases
		, total_deaths
		, ((total_deaths/cast(total_cases as int))*100) as DeathPercentage
		, date
from CovidDeaths
where location like '%states'
order by date

-- Deaths by Continent
SELECT Location
		, MAX(CAST(Total_Deaths as int)) as TotalDeaths

FROM CovidDeaths
where Continent IS NULL
GROUP BY Location

order by TotalDeaths desc

-- Deaths by Country
SELECT Location
		, cast(MAX(Total_Deaths) as int) as TotalDeathCount

FROM CovidDeaths
where continent is not null
GROUP BY Location
order by TotalDeathCount desc

-- Deaths Vs Cases
Select Location
		, total_cases
		, new_cases
		, total_deaths
		, population
		, ((total_deaths/cast(total_cases as int))*100) as DeathPercentage
		, date
from CovidDeaths
where location like '%states'
order by date

-- Global Numbers
select date
		, sum(new_cases) as totalcases
		, sum (new_deaths) as totaldeaths
		, sum(new_deaths) / sum (new_cases) * 100 as deathpercentage

from CovidDeaths
where new_cases != 0
Group by date

-- Infection Rate by Country
select location	
		, max(total_cases) as HighestCaseCount
		, population
		, (max(total_cases)/population) * 100 as InfectionRate

from CovidDeaths

group by location, population
order by InfectionRate desc

-- Running Total of Vaccinated
Select CD.continent, CD.location, CD.date, CD.population, cast (CV.new_vaccinations as bigint) NewVaccinations
, sum(Convert (bigint,CV.new_vaccinations)) over (Partition by CD.location order by CD.location, CD.
date) as runningtotalofvaccinated
from CovidDeaths CD
join CovidVaccinations CV on
CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by 2,3

-- Verifying new vaccinations data
/*select continent, location, date, cast(new_vaccinations as int)
from CovidVaccinations
where continent is not null
order by 1,2,3
*/


-- CTE for Running Total of Vaccinated

With RunTot 
(Continent, location, date, population, NewVaccinations, runningtotalofvaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population
	, cast (CV.new_vaccinations as bigint) NewVaccinations
	, sum(Convert (bigint,CV.new_vaccinations)) over (Partition by CD.location order by CD.location, CD.
date) as runningtotalofvaccinated
	
from CovidDeaths CD
join CovidVaccinations CV on
CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
)
Select continent
		, location
		, population
		, NewVaccinations
		, runningtotalofvaccinated/population * 100 as VaccinatedPercentage
	  
from RunTot
order by 1,2,3

-- Temp Table Percentage of People Vaccinated

DROP TABLE IF EXISTS #PercentageOfPeopleVaccinated

CREATE TABLE #PercentageOfPeopleVaccinated
(
Continent nvarchar (255)
, Location nvarchar (255)
, Date DateTime
, Population numeric
, NewVaccinations numeric
, runningtotalofvaccinated numeric
)
INSERT INTO #PercentageOfPeopleVaccinated
Select CD.continent, CD.location, CD.date, CD.population
	, cast (CV.new_vaccinations as bigint) NewVaccinations
	, sum(Convert (bigint,CV.new_vaccinations)) over (Partition by CD.location order by CD.location, CD.
date) as runningtotalofvaccinated
	
from CovidDeaths CD
join CovidVaccinations CV on
CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null

Select * from
#PercentageOfPeopleVaccinated



-- Creating View to store data for visualizations

CREATE VIEW PercentageOfPeopleVaccinated AS

Select CD.continent, CD.location, CD.date, CD.population
	, cast (CV.new_vaccinations as bigint) NewVaccinations
	, sum(Convert (bigint,CV.new_vaccinations)) over (Partition by CD.location order by CD.location, CD.
date) as runningtotalofvaccinated
	
from CovidDeaths CD
join CovidVaccinations CV on
CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null