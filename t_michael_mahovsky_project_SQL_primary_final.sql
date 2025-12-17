/*  
SQL pro vytvoření tabulky t_michael_mahovsky_project_SQL_primary_final
Obsahuje průměrné mzdy a ceny vybraných potravin V ČR za společné roky.
*/
WITH table_payroll_cte AS (
	SELECT
		round(AVG(cp.value)::NUMERIC,0) AS wage,
		cp.industry_branch_code,
		cpib.name AS industry_name,
		cp.payroll_year
	FROM czechia_payroll AS cp 
	-- LEFT JOIN, protože je potřeba zachovat řádky s industry_branch_code = NULL
	LEFT JOIN czechia_payroll_industry_branch AS cpib 
		ON cp.industry_branch_code = cpib.code
	-- 5958 = prům. hrubá mzda na zaměst., 100 = na fyzickou osobu
	WHERE cp.value_type_code = 5958 AND cp.calculation_code = 100
	GROUP BY industry_name, cp.industry_branch_code, cp.payroll_year  
	ORDER BY cp.payroll_year 
),
table_price_cte AS (
	SELECT
		round(AVG(cp.value)::NUMERIC, 2) AS price,
		cp.category_code,
		cpc.name AS category_name,
		date_part('YEAR', date_from) AS price_year
	FROM czechia_price AS cp  
	JOIN czechia_price_category AS cpc
		ON cp.category_code = cpc.code 
	-- pro celou ČR je region_code = NULL
	WHERE cp.region_code IS NULL
	GROUP BY cp.category_code, category_name , price_year  
	ORDER BY price_year
)
SELECT
	tprc.wage,
	tprc.industry_branch_code,
	tprc.industry_name,
	tprc.payroll_year AS year,
	tpc.price,
	tpc.category_code,
	tpc.category_name
INTO t_michael_mahovsky_project_SQL_primary_final
FROM table_payroll_cte AS tprc
-- spojení tabulek pro společné roky
JOIN table_price_cte AS tpc
	ON tprc.payroll_year = tpc.price_year;

