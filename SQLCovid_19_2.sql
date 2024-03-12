ewSelect *
From PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
Order by 3,4

Select *
From PortfolioProject.dbo.CovidVaccinations
Order by 3,4

--Select data that we are going to bre using
--Select location, date, total_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--Where Continent IS NOT NULL
--Order by 1, 2

--Finding percetages of total cases vs total deaths
-- (convert(decimal(15,3), total_deaths) / convert(decimal(15,3), total_cases))

Select location, date, total_cases, total_deaths, (convert(decimal(15,3), total_deaths) / convert(decimal(15,3),total_cases))*100 as PercentageDeaths
From PortfolioProject..CovidDeaths
Where location like 'Guinea%'
Order by 1,2

--Looking at Total_cases vs population in Guinea 
-- Which shows what percentage of population contracted Covid19

Select location, date, population, total_cases, (convert(decimal(15,3), total_cases) / convert(decimal(15,3),population))*100 as PercentageOfInfectedPopulation
From PortfolioProject..CovidDeaths
Where location like 'Guinea'
Order by 1,2

--looking at the highest infection by country compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((convert(decimal(15,3), total_cases))
/ convert(decimal(15,3),population))*100 as PercentageOfInfectedPopulation
From PortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Group by location, population
Order by PercentageOfInfectedPopulation DESC

--Highest deaths count by country

Select  Max(CAST(Total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by location
Order by TotaldeathCount DESC

--Breaking down things by continent

Select continent, Max(convert(decimal(15,3),Total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by continent
Order by TotaldeathCount DESC;

--Global Deaths 

Select date, SUM((new_cases )) as total_cases, SUM(CAST(new_deaths as int))as total_deaths,
SUM(CAST(new_deaths AS INT)) / SUM((new_cases)) *100 as DeathsPercentage
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by date
Order by 2,3

--Total vaccinations vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert( int, new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

--Create Temp Table
Drop Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert( int, vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--create view
Create View PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert( int, new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated






