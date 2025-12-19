-- Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba 
-- za první a poslední srovnatelné období v dostupných datech cen a mezd?
WITH count_cte AS (
	SELECT 
		wage,
		tmm.price,
		tmm.category_code, 
		tmm.category_name, 
		year
	FROM t_michael_mahovsky_project_sql_primary_final AS tmm 
	WHERE year IN (2006, 2018)
		AND tmm.category_code IN (111301, 114201) -- chleba a mléko
		-- pro celorepublikovou průměrnou mzdu
		AND tmm.industry_branch_code IS NULL 
	GROUP BY tmm.price,tmm.category_code, tmm.category_name, year, tmm.industry_branch_code, wage  
	ORDER BY year
)
SELECT
	-- zaokrouhlení dolů na celé kusy
	floor(wage / price) AS count,
	*
FROM count_cte 
-- závěr: V roce 2006 je možné si za průměrnou hrubou mzdu koupit 1 309 litrů mléka a 1 172 kg chleba.
-- V roce 2018 1 563 litrů mléka a 1 278 kg chleba.   
	
