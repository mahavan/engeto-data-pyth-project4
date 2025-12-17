/*  
SQL pro vytvoření tabulky t_michael_mahovsky_project_SQL_secondary_final
Obsahuje HDP, počet obyv. a GINI index pro evropské země za vybrané roky (2006 až 2018).
*/
WITH table_countries_cte AS (
	SELECT 
		c.abbreviation, 
		c.country 
	FROM countries AS c 
	-- je potřeba vyfiltrovat jen evropské země
	WHERE c.continent = 'Europe'
),
table_economies_cte AS (
	SELECT 
		country,
		year,
		gdp,
		population,
		gini
	FROM economies AS e
	WHERE year BETWEEN 2006 AND 2018
)
SELECT
	tcc.abbreviation,
	tcc.country,
	tec.year,
	tec.gdp,
	tec.population,
	tec.gini
INTO t_michael_mahovsky_project_SQL_secondary_final
FROM table_countries_cte AS tcc
-- spojení obou tabulek na základě společného sloupce - (evropské) země
JOIN table_economies_cte AS tec
	ON tcc.country = tec.country;

