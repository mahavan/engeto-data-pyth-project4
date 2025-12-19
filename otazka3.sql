/*
 * Která kategorie potravin zdražuje nejpomaleji 
 * (je u ní nejnižší percentuální meziroční nárůst)? 
 */
WITH price_cte AS (
	SELECT 
		tmm.price,
		tmm.category_code, 
		tmm.category_name , 
		tmm.year
	FROM t_michael_mahovsky_project_sql_primary_final AS tmm 
	GROUP BY tmm.price, tmm.category_code, tmm.category_name, year  
	ORDER BY year 
),
prices_cte AS (
	SELECT
		-- cena pro předchozí rok
		lag(price) OVER (PARTITION BY price_cte.category_code  ORDER BY year) 
			AS price_prev_year,
		*
	FROM price_cte 
)
SELECT 
	-- meziroční rozdíl ceny v procentech
	round((price / price_prev_year), 3) * 100 - 100 AS price_diff_percent,
	*
FROM prices_cte
ORDER BY price_diff_percent;
/*
 * závěr: Nejpomaleji zdražila jablka, 
 * mezi lety 2006 a 2007 došlo u nich k poklesu ceny o 30,3 %.
 */