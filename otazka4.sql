/*
 * Otázka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin 
 * výrazně vyšší než růst mezd (větší než 10 %)?
 */
WITH wage_price_cte AS (
	SELECT 
		AVG(tmm.wage) AS wage,
		tmm.price, 
		tmm.category_code,
		tmm.category_name, 
		tmm.year
	FROM t_michael_mahovsky_project_sql_primary_final AS tmm 
	WHERE tmm.industry_branch_code IS NULL
	GROUP BY tmm.price, tmm.category_code, tmm.category_name, year  
	ORDER BY year 
),
previous_cte AS (
	SELECT
		-- mzda pro předchozí rok
		lag(wage) OVER (PARTITION BY wage_price_cte.category_code ORDER BY year) 
			AS wage_prev_year,
		-- cena pro předchozí rok
		lag(price) OVER (PARTITION BY wage_price_cte.category_code ORDER BY year) 
			AS price_prev_year,
		*
	FROM wage_price_cte  
),
wage_price_diff_cte AS (
	SELECT 
		-- meziroční rozdíl ceny a mzdy v procentech
		(round((price / price_prev_year), 3) * 100 - 100) 
			- (round((wage / wage_prev_year), 3) * 100 - 100) 
			AS wage_price_diff_percent,	
		*
	FROM previous_cte
),
price_perc_year_cte AS (
	SELECT
		*
	FROM wage_price_diff_cte
	-- odfiltrování NULL hodnot pro rok 2005 v roce 2006 a
	-- rozdílu <= 10 % 
	WHERE wage_price_diff_percent IS NOT NULL 
		AND wage_price_diff_percent > 10
	ORDER BY YEAR
)
SELECT  
	-- výpis jednotlivých let
	DISTINCT year
FROM price_perc_year_cte;

/* 
 * závěr: Meziroční nárůst cen potravin byl výrazně vyšší
 * než růst mezd (větší než 10 %) v těchto letech:
 * 2007, 2008, 2010-2013, 2015, 2017 a 2018
 */