--Query to take a quick glance at my CovidDeaths table with the countries arranged in alphabetical order and
--starting with the earliest date 

Select *
from PortfolioProject1..CovidDeaths
order by 3,4

--Query to take a quick glance at my CovidVaccinations table with the countries arranged in alphabetical order and
--starting with the earliest date 

Select *
from PortfolioProject1..CovidVaccinations
order by 3,4

--Query to select my Data of interest on the CovidDeaths table

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by 1,2

--Query to look at the Total cases vs Total deaths on the CovidDeaths table with Italy as my country of interest

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject1..CovidDeaths
where location like '%italy%'
order by 1,2

--Looking at Total Cases Vs Population in Italy and calculating the percentage of population with Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject1..CovidDeaths
where location like '%italy%'
order by 1,2

--Query to look for Country with the Highest Infection Rate compared to its population

Select Location, population, MAX(total_cases) as HighestInfectionCountry, MAX((total_cases/population))*100 as
 PercentagePopulationInfected 
from PortfolioProject1..CovidDeaths
group by location, population
order by 4 Desc

--Query to look for countries with the Highest Death Count

Select Location, MAX(CONVERT(int, total_deaths)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount Desc

--Query to look for continents with the Highest Death Count

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc


--Query to take a look at the Global cases by date

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is not null
Group by date
Order by 1,2


--Query to at the Global cases (the total covid cases, total deaths and the world's percentage death)

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is not null
Order by 1,2

--Total Population VS Vaccinations. Here, I made use of table join to joining the 2 tables (the CovidDeath and CovidVaacinations) 
--on Location and Date. Result shows persons who have received atleast a covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --RollingPeopleVccinated/population) * 100
from PortfolioProject1..CovidVaccinations vac
join PortfolioProject1..CovidDeaths dea
    ON vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
order by 2,3

--CTE was used to perform Calculation (Percentage of the population Vaccinated) on Partition By in the previous query 

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --RollingPeopleVccinated/population) * 100
from PortfolioProject1..CovidVaccinations vac
join PortfolioProject1..CovidDeaths dea
    ON vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageRollingPeopleVaccinated
from PopvsVac


--TEMP Table (to perform calculation on the previous 'Total population vs Vaccination' query)

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --RollingPeopleVccinated/population) * 100
from PortfolioProject1..CovidVaccinations vac
join PortfolioProject1..CovidDeaths dea
    ON vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
from #PercentagePopulationVaccinated


--Creating view to store data for visualization

Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --RollingPeopleVccinated/population) * 100
from PortfolioProject1..CovidVaccinations vac
join PortfolioProject1..CovidDeaths dea
    ON vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2,3


