-- TESTING TO SEE IF THE DATA WAS IMPORTED CORRECTY BY SEEING ALL ROWS AND COLUMNS
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM CovidVaccinations
WHERE continent IS NULL
ORDER BY 3,4;

-- SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying in Australia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like 'Australia'
ORDER BY 1,2;

--Looking at Total Cases vs Population
-- Shows what percentage of population has Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM CovidDeaths
WHERE location like 'Australia'
ORDER BY 1,2;

-- Look at Countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highest_Number_of_Infection, MAX((total_cases/population))*100 AS PercentInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentInfected desc;

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Break down by Continent

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Global Numbers
-- total of New Cases and Deaths by Date

SELECT date,SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths as int)) AS TOTAL_DEATHS, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


--TOTAL CASES AND DEATHS GLOBALLY

SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths as int)) AS TOTAL_DEATHS, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- JOINT COVID DEATHS AND VACCINATION TABLES ON LOCATION AND DATE

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3

--ROLLING TOTAL OF NEW VACCINATIONS GLOBALLY

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(BIGINT,V.new_vaccinations)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS RollingVaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE TO SHOW PERCENTAGE OF POPULATION VACCINATED BY DIVDING ROLLING NUMBER OF PEOPLE VACCINATED BY THE POPULATION NUMBER

WITH PopvsVac (CONTINENT, LOCATION, DATE, POPULATION, new_vaccinations, RollingVaccinated)
AS ( 
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(BIGINT,V.new_vaccinations)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS RollingVaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *, (RollingVaccinated/POPULATION)*100 AS PERCENT_VACCINATED
FROM PopvsVac;

-- USE TEMP TABLE FOR THE ABOVE QUERY

DROP TABLE IF EXISTS PERCENTVACCINATED
CREATE TABLE PERCENTVACCINATED
(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATIONS NUMERIC,
RollingVaccinated NUMERIC)

INSERT INTO PERCENTVACCINATED 

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(BIGINT,V.new_vaccinations)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS RollingVaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *, (RollingVaccinated/POPULATION)*100 AS PERCENT_VACCINATED
FROM PERCENTVACCINATED

--CREATING VIEW TO STORE DATA FOR LATER VISUAISATIONS

CREATE VIEW PERCENTAGE_VACCINATED AS

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(BIGINT,V.new_vaccinations)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS RollingVaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *
FROM PERCENTAGE_VACCINATED;