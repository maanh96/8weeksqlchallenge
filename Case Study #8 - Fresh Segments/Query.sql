/* --------------------
   Case Study Questions
   --------------------*/

-- A. Data Exploration and Cleansing --
-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ALTER TABLE interest_metrics
MODIFY COLUMN month_year VARCHAR(10);

UPDATE interest_metrics
SET month_year = STR_TO_DATE(CONCAT('01-', month_year), "%d-%m-%Y")
WHERE month_year IS NOT NULL;

ALTER TABLE interest_metrics
MODIFY COLUMN month_year DATE;

SELECT * FROM interest_metrics;

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT month_year, COUNT(*) AS total_records
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year;

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics
SELECT 
	COUNT(*) AS total_null,
    COUNT(*) / (SELECT COUNT(*) FROM interest_metrics) AS null_percent
FROM interest_metrics
WHERE CONCAT(_month, _year, month_year, interest_id, composition, index_value) IS NULL;

SELECT *
FROM interest_metrics
WHERE CONCAT(_month, _year, month_year, interest_id, composition, index_value) IS NULL;

	-- delete null values
DELETE FROM interest_metrics WHERE month_year IS NULL;

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
SELECT COUNT(*) AS not_in_map
FROM interest_metrics e
LEFT JOIN interest_map m
	ON e.interest_id = m.id
WHERE m.id IS NULL;

SELECT COUNT(*) AS not_in_metrics
FROM interest_metrics e
RIGHT JOIN interest_map m
	ON e.interest_id = m.id
WHERE e.interest_id IS NULL;

-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT COUNT(*) AS total_records, COUNT(DISTINCT id) AS total_id
FROM interest_map;

-- 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
SELECT e.*, interest_name, interest_summary, created_at, last_modified
FROM interest_metrics e
INNER JOIN interest_map m
	ON e.interest_id = m.id
WHERE interest_id = 21246;

-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
SELECT month_year, created_at
FROM interest_metrics e
INNER JOIN interest_map m
	ON e.interest_id = m.id
WHERE month_year < created_at;

SELECT month_year, created_at
FROM interest_metrics e
INNER JOIN interest_map m
	ON e.interest_id = m.id
WHERE MONTH(month_year) < MONTH(created_at) AND YEAR(month_year) <= YEAR(created_at);


-- B. Interest Analysis -- 
-- 1. Which interests have been present in all month_year dates in our dataset?
WITH cte AS(
	SELECT 
		interest_id,
		COUNT(month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id)
SELECT COUNT(*) AS number_interests_in_all_months
FROM cte
WHERE total_months = (SELECT COUNT(DISTINCT month_year) FROM interest_metrics);

-- 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH cte AS(
	SELECT 
		interest_id,
		COUNT(month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id)
SELECT total_months, COUNT(*) AS number_interests_in_all_n_months,
	ROUND(
		SUM(COUNT(*)) OVER(ORDER BY total_months DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / 
        (SELECT COUNT(DISTINCT interest_id) FROM interest_metrics) 
        *100, 2) AS cumulative_percent
FROM cte
GROUP BY total_months;

-- 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
WITH cte AS(
	SELECT 
		interest_id,
		COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id),
cte1 AS(
	SELECT total_months, COUNT(*) AS interests, SUM(total_months) AS records, 
		ROUND(
			SUM(COUNT(*)) OVER(ORDER BY total_months DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / 
			(SELECT COUNT(DISTINCT interest_id) FROM interest_metrics) 
			*100, 2) AS cumulative_percent
	FROM cte
	GROUP BY total_months)
SELECT SUM(interests) AS interests_removed, SUM(records) AS records_removed
FROM cte1
WHERE cumulative_percent > 91;

-- 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
WITH cte AS(
	SELECT interest_id,
		COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id)
SELECT *
FROM interest_metrics m
INNER JOIN cte c
	On m.interest_id = c.interest_id
WHERE month_year = '2019-04-01'
;

-- 5. After removing these interests - how many unique interests are there for each month?
DROP TABLE IF EXISTS interest_metrics_filtered;
CREATE TEMPORARY TABLE interest_metrics_filtered
WITH cte AS(
	SELECT interest_id,
		COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id)
SELECT m.*, total_months
FROM interest_metrics m
INNER JOIN cte c
	On m.interest_id = c.interest_id
WHERE total_months >= 6;

SELECT 
	month_year,
    COUNT(interest_id) AS total_interests
FROM interest_metrics_filtered
GROUP BY month_year;

-- C. Segment Analysis -- 
-- 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
WITH cte AS(
	SELECT interest_id,
		MAX(composition) AS max_composition,
        RANK() OVER(ORDER BY MAX(composition) DESC) AS top,
        RANK() OVER(ORDER BY MAX(composition)) AS bottom
	FROM interest_metrics_filtered
	GROUP BY interest_id)
SELECT m.interest_id, interest_name, month_year, composition
FROM cte
INNER JOIN interest_metrics m
	ON cte.interest_id = m.interest_id AND cte.max_composition = m.composition
INNER JOIN interest_map p
	ON cte.interest_id = p.id
WHERE top <= 10 OR bottom <= 10
ORDER BY composition DESC;

-- 2. Which 5 interests had the lowest average ranking value?
SELECT interest_id, interest_name, AVG(ranking) AS avg_ranking
FROM interest_metrics_filtered f
INNER JOIN interest_map p
	ON f.interest_id = p.id
GROUP BY interest_id
ORDER BY avg_ranking
LIMIT 5;

-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
SELECT interest_id, interest_name, ROUND(STD(percentile_ranking), 2) AS std_percentile
FROM interest_metrics_filtered f
INNER JOIN interest_map p
	ON f.interest_id = p.id
GROUP BY interest_id
ORDER BY std_percentile DESC
LIMIT 5;

-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
WITH cte AS(
	SELECT interest_id, interest_name, ROUND(STD(percentile_ranking), 2) AS std_percentile
	FROM interest_metrics_filtered f
	INNER JOIN interest_map p
		ON f.interest_id = p.id
	GROUP BY interest_id
	ORDER BY std_percentile DESC
	LIMIT 5),
cte2 AS(
	SELECT cte.*, MIN(m.percentile_ranking) AS min_percent, MAX(m.percentile_ranking) AS max_percent
	FROM cte
	INNER JOIN interest_metrics m
		ON cte.interest_id = m.interest_id
	GROUP BY interest_id)
SELECT cte2.*, 
	MIN(CASE WHEN cte2.min_percent = m.percentile_ranking THEN m.month_year END) AS min_month_year,
    MIN(CASE WHEN cte2.max_percent = m.percentile_ranking THEN m.month_year END) AS max_month_year
FROM cte2
INNER JOIN interest_metrics m
	ON cte2.interest_id = m.interest_id AND (cte2.min_percent = m.percentile_ranking OR cte2.max_percent = m.percentile_ranking)
GROUP BY interest_id
ORDER BY std_percentile DESC;

-- 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

-- D. Index Analysis --
-- The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
-- Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.
-- 1. What is the top 10 interests by the average composition for each month?
WITH cte AS(
	SELECT *, ROUND(composition/index_value, 2) AS avg_composition,
		ROW_NUMBER() OVER(PARTITION BY month_year ORDER BY composition/index_value DESC) AS month_ranking
	FROM interest_metrics)
SELECT month_year, month_ranking, interest_id, interest_name, avg_composition
FROM cte
INNER JOIN interest_map m
	ON cte.interest_id = m.id
WHERE month_ranking <= 10;

-- 2. For all of these top 10 interests - which interest appears the most often?
WITH cte AS(
	SELECT *, ROUND(composition/index_value, 2) AS avg_composition,
		ROW_NUMBER() OVER(PARTITION BY month_year ORDER BY composition/index_value DESC) AS month_ranking
	FROM interest_metrics),
cte2 AS(
	SELECT month_year, month_ranking, interest_id, avg_composition
	FROM cte
	WHERE month_ranking <= 10),
cte3 AS(
	SELECT interest_id, COUNT(*) AS total_appear
	FROM cte2
	GROUP BY interest_id)
SELECT interest_id, interest_name, total_appear
FROM cte3
INNER JOIN interest_map m
	ON cte3.interest_id = m.id
WHERE total_appear = (SELECT MAX(total_appear) FROM cte3);

-- 3. What is the average of the average composition for the top 10 interests for each month?
WITH cte AS(
	SELECT *, ROUND(composition/index_value, 2) AS avg_composition,
		ROW_NUMBER() OVER(PARTITION BY month_year ORDER BY composition/index_value DESC) AS month_ranking
	FROM interest_metrics),
cte2 AS(
	SELECT month_year, month_ranking, interest_id, interest_name, avg_composition
	FROM cte
	INNER JOIN interest_map m
		ON cte.interest_id = m.id
	WHERE month_ranking <= 10)
SELECT month_year, ROUND(AVG(avg_composition), 2) AS month_avg_avg_composition
FROM cte2
GROUP BY month_year;

-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
WITH cte AS(
	SELECT *, ROUND(composition/index_value, 2) AS avg_composition,
		ROW_NUMBER() OVER(PARTITION BY month_year ORDER BY composition/index_value DESC) AS month_ranking
	FROM interest_metrics),
cte2 AS(
	SELECT month_year, month_ranking, interest_id, interest_name, avg_composition
	FROM cte
	INNER JOIN interest_map m
		ON cte.interest_id = m.id
	WHERE month_ranking =1),
cte3 AS(
	SELECT month_year, interest_name, avg_composition AS max_index_composition,
		ROUND(AVG(avg_composition) OVER(ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS 3_month_moving_avg,
		LAG(CONCAT(interest_name, ': ', avg_composition)) OVER(ORDER BY month_year) AS 1_month_ago,
		LAG(CONCAT(interest_name, ': ', avg_composition), 2) OVER(ORDER BY month_year) AS 2_month_ago
	FROM cte2)
SELECT *
FROM cte3
WHERE 2_month_ago IS NOT NULL;