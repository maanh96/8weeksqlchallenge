# Case Study #8 - Fresh Segments

## B. Interest Analysis

### 1. Which interests have been present in all month_year dates in our dataset?
``` sql
WITH cte AS(
	SELECT 
		interest_id,
		COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id)
SELECT COUNT(*) AS number_interests_in_all_months
FROM cte
WHERE total_months = (SELECT COUNT(DISTINCT month_year) FROM interest_metrics);
```
Result:
| number_interests_in_all_months |
| :----------------------------- |
| 480                            |

### 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
``` sql
WITH cte AS(
	SELECT 
		interest_id,
		COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id)
SELECT total_months, COUNT(*) AS number_interests_in_all_n_months,
	ROUND(
		SUM(COUNT(*)) OVER(ORDER BY total_months DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / 
        (SELECT COUNT(DISTINCT interest_id) FROM interest_metrics) 
        *100, 2) AS cumulative_percent
FROM cte
GROUP BY total_months;
```
Result:
| total_months | number_interests_in_all_n_months | cumulative_percent |
| :----------- | :------------------------------- | :----------------- |
| 14           | 480                              | 39.93              |
| 13           | 82                               | 46.76              |
| 12           | 65                               | 52.16              |
| 11           | 94                               | 59.98              |
| 10           | 86                               | 67.14              |
| 9            | 95                               | 75.04              |
| 8            | 67                               | 80.62              |
| 7            | 90                               | 88.10              |
| 6            | 33                               | 90.85              |
| 5            | 38                               | 94.01              |
| 4            | 32                               | 96.67              |
| 3            | 15                               | 97.92              |
| 2            | 12                               | 98.92              |
| 1            | 13                               | 100.00             |

Look at the result, we can see that interests that have been present in 6 months or more account for 90% of the total interests.

### 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
``` sql
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
```
Result:
| interests_removed | records_removed |
| :---------------- | :-------------- |
| 110               | 400             |

### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
``` sql

```
Result:

### 5. After removing these interests - how many unique interests are there for each month?
``` sql
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
```
Result:
| month_year | total_interests |
| :--------- | :-------------- |
| 2018-07-01 | 709             |
| 2018-08-01 | 752             |
| 2018-09-01 | 774             |
| 2018-10-01 | 853             |
| 2018-11-01 | 925             |
| 2018-12-01 | 986             |
| 2019-01-01 | 966             |
| 2019-02-01 | 1072            |
| 2019-03-01 | 1078            |
| 2019-04-01 | 1035            |
| 2019-05-01 | 827             |
| 2019-06-01 | 804             |
| 2019-07-01 | 836             |
| 2019-08-01 | 1062            |

<br>

***
Let's move to [C. Segment Analysis](./C.%20Segment%20Analysis.md).
