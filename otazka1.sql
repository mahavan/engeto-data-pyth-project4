-- Otázka č. 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- dotaz pro první a poslední rok (2006 vs. 2018):
WITH payroll_cte AS (
	SELECT 
		AVG(tmm.wage) AS wage,
		tmm.industry_branch_code, 
		tmm.industry_name, 
		tmm.year
	FROM t_michael_mahovsky_project_sql_primary_final AS tmm 
	WHERE tmm.year IN (2006, 2018)
	GROUP BY tmm.industry_branch_code, tmm.industry_name, year  
	ORDER BY year 	
),
payrolls_cte AS (
	SELECT
		-- mzda pro předcházející období, pro rok 2006
		lag(wage) OVER (PARTITION BY payroll_cte.industry_branch_code ORDER BY year) AS wage_previous,
		*
	FROM payroll_cte 
)
SELECT 
	-- rozdíl mzdy 2018 - 2006
	wage - wage_previous AS wage_diff,
	*
FROM payrolls_cte;
-- závěr: růst ve všech odvětvích (sloupec wage_diff je všude kladný)


-- dotaz pro jednotlivé roky:
WITH payroll_cte AS (
	SELECT 
		AVG(tmm.wage) AS wage,
		tmm.industry_branch_code, 
		tmm.industry_name, 
		tmm.year
	FROM t_michael_mahovsky_project_sql_primary_final AS tmm 
	GROUP BY tmm.industry_branch_code, tmm.industry_name, year  
	ORDER BY year 
),
payrolls_cte AS (
	SELECT
		-- mzda pro předchozí rok
		lag(wage) OVER (PARTITION BY payroll_cte.industry_branch_code ORDER BY year) AS wage_prev_year,
		*
	FROM payroll_cte 
)
SELECT 
	-- rozdíl mzdy daného roku a předchozího roku
	wage - wage_prev_year AS wage_diff,
	*
FROM payrolls_cte;
-- závěr: U některých odvětví v některých letech došlo k poklesu průměrné hrubé mzdy (viz záporná hodnota ve sloupci wage_diff), celkově ale mezi lety 2006 až 2018 došlo k růstu mezd ve všech odvětvích.


