# Case Study #8 - Fresh Segments

## C. Segment Analysis

### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
``` sql
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
```
Result:
| interest_id | interest_name                     | month_year | composition |
| :---------- | :-------------------------------- | :--------- | :---------- |
| 21057       | Work Comes First Travelers        | 2018-12-01 | 21.2        |
| 6284        | Gym Equipment Owners              | 2018-07-01 | 18.82       |
| 39          | Furniture Shoppers                | 2018-07-01 | 17.44       |
| 77          | Luxury Retail Shoppers            | 2018-07-01 | 17.19       |
| 12133       | Luxury Boutique Hotel Researchers | 2018-10-01 | 15.15       |
| 5969        | Luxury Bedding Shoppers           | 2018-12-01 | 15.05       |
| 171         | Shoe Shoppers                     | 2018-07-01 | 14.91       |
| 4898        | Cosmetics and Beauty Shoppers     | 2018-07-01 | 14.23       |
| 6286        | Luxury Hotel Guests               | 2018-07-01 | 14.1        |
| 4           | Luxury Retail Researchers         | 2018-07-01 | 13.97       |
| 58          | Budget Wireless Shoppers          | 2018-07-01 | 2.18        |
| 36138       | Haunted House Researchers         | 2019-02-01 | 2.18        |
| 34085       | Oakland Raiders Fans              | 2019-08-01 | 2.14        |
| 22408       | Super Mario Bros Fans             | 2018-07-01 | 2.12        |
| 42011       | League of Legends Video Game Fans | 2019-01-01 | 2.09        |
| 37421       | Budget Mobile Phone Researchers   | 2019-08-01 | 2.09        |
| 19591       | Camaro Enthusiasts                | 2018-10-01 | 2.08        |
| 19635       | Xbox Enthusiasts                  | 2018-07-01 | 2.05        |
| 19599       | Dodge Vehicle Shoppers            | 2019-03-01 | 1.97        |
| 37412       | Medieval History Enthusiasts      | 2018-10-01 | 1.94        |
| 33958       | Astrology Enthusiasts             | 2018-08-01 | 1.88        |

### 2. Which 5 interests had the lowest average ranking value?
``` sql
SELECT interest_id, interest_name, AVG(ranking) AS avg_ranking
FROM interest_metrics_filtered f
INNER JOIN interest_map p
	ON f.interest_id = p.id
GROUP BY interest_id
ORDER BY avg_ranking
LIMIT 5;
```
Result:
| interest_id | interest_name                  | avg_ranking |
| :---------- | :----------------------------- | :---------- |
| 41548       | Winter Apparel Shoppers        | 1.0000      |
| 42203       | Fitness Activity Tracker Users | 4.1111      |
| 115         | Mens Shoe Shoppers             | 5.9286      |
| 171         | Shoe Shoppers                  | 9.3571      |
| 6206        | Preppy Clothing Shoppers       | 11.8571     |

### 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
``` sql
SELECT interest_id, interest_name, ROUND(STD(percentile_ranking), 2) AS std_percentile
FROM interest_metrics_filtered f
INNER JOIN interest_map p
	ON f.interest_id = p.id
GROUP BY interest_id
ORDER BY std_percentile DESC
LIMIT 5;
```
Result:
| interest_id | interest_name                          | std_percentile |
| :---------- | :------------------------------------- | :------------- |
| 23          | Techies                                | 27.55          |
| 38992       | Oregon Trip Planners                   | 26.87          |
| 20764       | Entertainment Industry Decision Makers | 26.45          |
| 43546       | Personalized Gift Shoppers             | 24.55          |
| 103         | Live Concert Fans                      | 23.45          |

### 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
``` sql
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
```
Result:
| interest_id | interest_name                          | std_percentile | min_percent | max_percent | min_month_year | max_month_year |
| :---------- | :------------------------------------- | :------------- | :---------- | :---------- | :------------- | :------------- |
| 23          | Techies                                | 27.55          | 7.92        | 86.69       | 2019-08-01     | 2018-07-01     |
| 38992       | Oregon Trip Planners                   | 26.87          | 2.2         | 82.44       | 2019-07-01     | 2018-11-01     |
| 20764       | Entertainment Industry Decision Makers | 26.45          | 11.23       | 86.15       | 2019-08-01     | 2018-07-01     |
| 43546       | Personalized Gift Shoppers             | 24.55          | 5.7         | 73.15       | 2019-06-01     | 2019-03-01     |
| 103         | Live Concert Fans                      | 23.45          | 18.75       | 95.61       | 2019-07-01     | 2018-07-01     |



### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?
``` sql

```
Result:


<br>

***
Let's move to [D. Index Analysis](./D.%20Index%20Analysis.md).
