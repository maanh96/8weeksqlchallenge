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
		SUM(COUNT(*)) OVER(ORDER BY total_months DESC ROWS UNBOUNDED PRECEDING) / 
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

Look at the result, we can see that interests which have been present in 6 months or more account for 90% of the total interests.

### 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
``` sql
WITH cte AS(
	SELECT 
		interest_id,
		COUNT(month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id),
cte1 AS(
	SELECT total_months, COUNT(*) AS interests, SUM(total_months) AS records, 
		ROUND(
			SUM(COUNT(*)) OVER(ORDER BY total_months DESC ROWS UNBOUNDED PRECEDING) / 
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
Interests appearing for less than 6 months might indicate seasonality, shifts in consumer attention, or recently creation. Nevertheless, we do not have much data to conclude about them and they are also unlikely to represent the characteristic of the segment. Thus, it make sense to focus on the more stable and persistence ones in order to find sharper segmentation of customers' preference.

Example of an interest that present in all months and interest that present in less then 6 months:
| month_year | interest_id | interest_name                   | interest_summary                                                | composition | index_value | ranking | percentile_ranking | total_months |
| :--------- | :---------- | :------------------------------ | :-------------------------------------------------------------- | :---------- | :---------- | :------ | :----------------- | :----------- |
| 2018-07-01 | 133         | High End Camera Shoppers - Dupe | Consumers shopping for high end cameras and camera accessories. | 10.91       | 3.44        | 46      | 93.69              | 2            |
| 2018-08-01 | 133         | High End Camera Shoppers - Dupe | Consumers shopping for high end cameras and camera accessories. | 4.3         | 1.45        | 234     | 69.49              | 2            |
| 2018-07-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 10.95       | 3.08        | 75      | 89.71              | 14           |
| 2018-08-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 4.98        | 1.26        | 396     | 48.37              | 14           |
| 2018-09-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 6.97        | 1.2         | 431     | 44.74              | 14           |
| 2018-10-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 7.2         | 1.36        | 455     | 46.91              | 14           |
| 2018-11-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 6.6         | 1.33        | 531     | 42.78              | 14           |
| 2018-12-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 6.7         | 1.43        | 472     | 52.56              | 14           |
| 2019-01-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 5.89        | 1.34        | 405     | 58.38              | 14           |
| 2019-02-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 6.62        | 1.28        | 542     | 51.65              | 14           |
| 2019-03-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 6.73        | 1.42        | 368     | 67.61              | 14           |
| 2019-04-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 5.73        | 1.36        | 401     | 63.51              | 14           |
| 2019-05-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 3.22        | 1.55        | 453     | 47.14              | 14           |
| 2019-06-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 1.97        | 1.63        | 568     | 31.07              | 14           |
| 2019-07-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 1.92        | 1.46        | 679     | 21.41              | 14           |
| 2019-08-01 | 19757       | Natural Pet Food Shoppers       | Consumers researching and shopping for natural pet food.        | 2.76        | 1.54        | 745     | 35.16              | 14           |


### 5. After removing these interests - how many unique interests are there for each month?
``` sql
DROP TABLE IF EXISTS interest_metrics_filtered;
CREATE TEMPORARY TABLE interest_metrics_filtered
WITH cte AS(
	SELECT interest_id,
		COUNT(month_year) AS total_months
	FROM interest_metrics
	GROUP BY interest_id)
SELECT m.*, total_months
FROM interest_metrics m
INNER JOIN cte c
	On m.interest_id = c.interest_id
WHERE total_months >= 6;

SELECT 
	month_year,
    COUNT(interest_id) AS unique_interests
FROM interest_metrics_filtered
GROUP BY month_year;
```
Result:
| month_year | unique_interests |
| :--------- | :--------------- |
| 2018-07-01 | 709              |
| 2018-08-01 | 752              |
| 2018-09-01 | 774              |
| 2018-10-01 | 853              |
| 2018-11-01 | 925              |
| 2018-12-01 | 986              |
| 2019-01-01 | 966              |
| 2019-02-01 | 1072             |
| 2019-03-01 | 1078             |
| 2019-04-01 | 1035             |
| 2019-05-01 | 827              |
| 2019-06-01 | 804              |
| 2019-07-01 | 836              |
| 2019-08-01 | 1062             |

<br>

***
Let's move to [C. Segment Analysis](./C.%20Segment%20Analysis.md).
