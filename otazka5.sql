/*
 * Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 * Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách
 * ve stejném nebo následujícím roce výraznějším růstem?
 */

-- Dotazem zjistíme meziroční změnu HDP v procentech
WITH gdp_cte AS (
	SELECT 
		gdp,
		tmm2.abbreviation,
		tmm2."year" 
	FROM t_michael_mahovsky_project_sql_secondary_final AS tmm2
	WHERE tmm2.abbreviation = 'CZ'
),
gdp_diff_cte AS (
	SELECT 
		*,
		-- HDP předcházejícího roku
		lag(gdp) OVER (PARTITION BY gdp_cte.abbreviation ORDER BY year) 
			AS previous_gdp
	FROM gdp_cte
)
SELECT 
	*,
	-- meziroční rozdíl HDP v procentech
	round((gdp / previous_gdp * 100 - 100)::numeric, 2) 
		AS gdp_diff_percent 
FROM gdp_diff_cte 
ORDER BY gdp_diff_percent DESC; 

-- výsledek: Za výraznější změnu HDP považuji meziroční změnu > 5 %,
-- nastala v letech 2007, 2015 a 2017 (gdp_diff_percent > 5)

WITH table_czechia_cte AS (
	SELECT 
		wage,
		tmm.year,
		tmm.price,
		tmm.category_code,
		tmm.category_name 
	FROM t_michael_mahovsky_project_sql_primary_final AS tmm
	-- filtr pro celou republiku - industry_branch_code = NULL
	WHERE tmm.industry_branch_code IS NULL
),
previous_cte AS (
	SELECT 
		-- prům. mzda předchozí rok
		lag(wage) OVER (PARTITION BY table_czechia_cte.category_code ORDER BY year) 
			AS previous_wage,
		-- cena předchozí rok
		lag(price) OVER (PARTITION BY table_czechia_cte.category_code ORDER BY year) 
			AS previous_price,
		table_czechia_cte.price AS current_price,
		-- cena následující rok
		lead(price) OVER (PARTITION BY table_czechia_cte.category_code ORDER BY YEAR) 
			AS next_price,
		*
	FROM table_czechia_cte
)
SELECT
	-- meziroční rozdíly v procentech
	round((wage / previous_wage * 100 - 100), 2) AS wage_diff_percent,
	round((price / previous_price * 100 - 100), 2) AS prev_price_diff_percent,
	round((next_price / price * 100 - 100), 2) AS next_price_diff_percent,
	*
FROM previous_cte
ORDER BY year;

/*
 * Závěr: Z hodnot sloupce wage_diff_percent (mzdový rozdíl daného a předešlého roku v %) je zřejmé, 
 * že růst HDP má pozitivní vliv na růst průměrné mzdy. Nejvíce se růst HDP projevuje v následujícím 
 * kalendářním roce. Ve sledovaném období (2007-2008 a 2015-2018) vždy došlo k většímu zvýšení průměrné mzdy.
 *  
 * U cen potravin tato přímá závislost neexistuje. U cen sledujeme sloupce prev_price_diff_percent vyjadřující
 * meziroční procentuální rozdíl ceny k předešlému roku, u next_price_diff_percent k následujícímu roku. 
 * Ve stejném sledovaném období došlo z 26 druhů potravin u 5 až 10 potravin k meziročnímu poklesu ceny.  
 * Není zde tedy přímý vztah mezi vyšším růstem HDP a cenou potravin.
 */