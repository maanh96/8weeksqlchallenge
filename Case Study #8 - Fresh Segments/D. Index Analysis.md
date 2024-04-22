# Case Study #8 - Fresh Segments

## D. Index Analysis

The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

### 1. What is the top 10 interests by the average composition for each month?
``` sql
WITH cte AS(
	SELECT *, ROUND(composition/index_value, 2) AS avg_composition,
		ROW_NUMBER() OVER(PARTITION BY month_year ORDER BY composition/index_value DESC) AS month_ranking
	FROM interest_metrics)
SELECT month_year, month_ranking, interest_id, interest_name, avg_composition
FROM cte
INNER JOIN interest_map m
	ON cte.interest_id = m.id
WHERE month_ranking <= 10;
```
Result:
| month_year | month_ranking | interest_id | interest_name                 | avg_composition |
| :--------- | :------------ | :---------- | :---------------------------- | :-------------- |
| 2018-07-01 | 1             | 6324        | Las Vegas Trip Planners       | 7.36            |
| 2018-07-01 | 2             | 6284        | Gym Equipment Owners          | 6.94            |
| 2018-07-01 | 3             | 4898        | Cosmetics and Beauty Shoppers | 6.78            |
| 2018-07-01 | 4             | 77          | Luxury Retail Shoppers        | 6.61            |
| 2018-07-01 | 5             | 39          | Furniture Shoppers            | 6.51            |
| 2018-07-01 | 6             | 18619       | Asian Food Enthusiasts        | 6.1             |
| 2018-07-01 | 7             | 6208        | Recently Retired Individuals  | 5.72            |
| 2018-07-01 | 8             | 21060       | Family Adventures Travelers   | 4.85            |
| 2018-07-01 | 9             | 21057       | Work Comes First Travelers    | 4.8             |
| 2018-07-01 | 10            | 82          | HDTV Researchers              | 4.71            |
| 2018-08-01 | 1             | 6324        | Las Vegas Trip Planners       | 7.21            |
| 2018-08-01 | 2             | 6284        | Gym Equipment Owners          | 6.62            |
| 2018-08-01 | 3             | 77          | Luxury Retail Shoppers        | 6.53            |
| 2018-08-01 | 4             | 39          | Furniture Shoppers            | 6.3             |
| 2018-08-01 | 5             | 4898        | Cosmetics and Beauty Shoppers | 6.28            |
| ...        |

### 2. For all of these top 10 interests - which interest appears the most often?
``` sql
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
```
Result:
| interest_id | interest_name            | total_appear |
| :---------- | :----------------------- | :----------- |
| 5969        | Luxury Bedding Shoppers  | 10           |
| 6065        | Solar Energy Researchers | 10           |
| 7541        | Alabama Trip Planners    | 10           |


### 3. What is the average of the average composition for the top 10 interests for each month?
``` sql
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
```
Result:
| month_year | month_avg_avg_composition |
| :--------- | :------------------------ |
| 2018-07-01 | 6.04                      |
| 2018-08-01 | 5.94                      |
| 2018-09-01 | 6.89                      |
| 2018-10-01 | 7.07                      |
| 2018-11-01 | 6.62                      |
| 2018-12-01 | 6.65                      |
| 2019-01-01 | 6.4                       |
| 2019-02-01 | 6.58                      |
| 2019-03-01 | 6.17                      |
| 2019-04-01 | 5.75                      |
| 2019-05-01 | 3.54                      |
| 2019-06-01 | 2.43                      |
| 2019-07-01 | 2.76                      |
| 2019-08-01 | 2.63                      |

### 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
``` sql
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
```
Result:
| month_year | interest_name                 | max_index_composition | 3_month_moving_avg | 1_month_ago                       | 2_month_ago                       |
| :--------- | :---------------------------- | :-------------------- | :----------------- | :-------------------------------- | :-------------------------------- |
| 2018-09-01 | Work Comes First Travelers    | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.36     |
| 2018-10-01 | Work Comes First Travelers    | 9.14                  | 8.2                | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 7.21     |
| 2018-11-01 | Work Comes First Travelers    | 8.28                  | 8.56               | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 8.26  |
| 2018-12-01 | Work Comes First Travelers    | 8.31                  | 8.58               | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 9.14  |
| 2019-01-01 | Work Comes First Travelers    | 7.66                  | 8.08               | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.28  |
| 2019-02-01 | Work Comes First Travelers    | 7.66                  | 7.88               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 8.31  |
| 2019-03-01 | Alabama Trip Planners         | 6.54                  | 7.29               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66  |
| 2019-04-01 | Solar Energy Researchers      | 6.28                  | 6.83               | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 7.66  |
| 2019-05-01 | Readers of Honduran Content   | 4.41                  | 5.74               | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.54       |
| 2019-06-01 | Las Vegas Trip Planners       | 2.77                  | 4.49               | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 6.28    |
| 2019-07-01 | Las Vegas Trip Planners       | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 4.41 |
| 2019-08-01 | Cosmetics and Beauty Shoppers | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.77     |

### 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?
As we've known, the average `composition` metric show the **percentage** of all Fresh Segments clients’ customer list interacted with a particular interest in a month. Hence a possible reason why the max average composition might change from month to month could be due to the expansion of the customer base, especially when the new customers have more diverse interests compare with the old base.

That is to say, the fluctuation in the max average composition alone is not necessary signal something is not quite right with the overall business model for Fresh Segments. However, Fresh Segment should pay attention closely on the `composition` of each clients' customer list since the drop of this metric might indicate the effectiveness of the online ads is decreasing over time. 

<br>

***
~ This is the end of 8 Week SQL Challenge ~

Back to [Main menu](https://github.com/maanh96/8weeksqlchallenge).