Select * 
From Portfolio..CovidDeaths$
Where continent is not null
order by 3,4

--Select * 
--From Portfolio..CovidVaccinations$
--order by 3,4

--Selecting Data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Per_Case
From Portfolio..CovidDeaths$
Where location like 'United Kingdom'
order by 1,2

--Looking at what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as Cases_Per_Person
From Portfolio..CovidDeaths$
Where location like 'United Kingdom'
order by 1,2

--Looking at countries with highest infection rate
Select Location, MAX(total_cases) as Highest_Infection_Count, population, MAX((total_cases/population))*100 as Percent_Infected_Population
From Portfolio..CovidDeaths$
Group by location, population
order by Percent_Infected_Population desc

--Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as bigint)) as Highest_Death_Count
From Portfolio..CovidDeaths$
Where continent is not null
Group by location, population
order by Highest_Death_Count desc

--Break down by continent
Select continent, MAX(cast(total_deaths as bigint)) as Highest_Death_Count
From Portfolio..CovidDeaths$
Where continent is not null
Group by continent
order by Highest_Death_Count desc

--GLOBAL NUMBERS#
Select SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercent
From Portfolio..CovidDeaths$
Where continent is not null
--Group by date
order by 1,2

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopsvsVac (Continent, location, date, population, new_vaccinations, CumulativeVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (CumulativeVaccinations/population)*100
From PopsvsVac

--TEMP TABLE
 
 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 CumulativeVaccinations numeric
 )
 
 
 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
Select *, (CumulativeVaccinations/population)*100
From #PercentPopulationVaccinated

--Creating view for visualisation
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CumulativeVaccinations
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated
