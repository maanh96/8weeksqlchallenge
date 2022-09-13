# Case Study #3 - Foodie-Fi

## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?
``` sql
SELECT 
    COUNT(DISTINCT customer_id) AS total_customer
FROM
    subscriptions;
```
Result:
| total_customer |
| -------------- |
| 1000           |

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
```sql
SELECT 
    MONTHNAME(start_date) AS month, COUNT(*) AS total_trial
FROM
    subscriptions
WHERE
    plan_id = 0
GROUP BY month
ORDER BY MONTH(start_date);
```
Result:
| month     | total_trial |
| --------- | ----------- |
| January   | 88          |
| February  | 68          |
| March     | 94          |
| April     | 81          |
| May       | 88          |
| June      | 79          |
| July      | 89          |
| August    | 88          |
| September | 87          |
| October   | 79          |
| November  | 75          |
| December  | 84          |

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
```sql
SELECT 
    plan_name, COUNT(*) AS total_plan
FROM
    subscriptions s
        INNER JOIN
    plans p ON s.plan_id = p.plan_id
WHERE
    YEAR(start_date) > 2020
GROUP BY s.plan_id;
```
Result:
| plan_name     | total_plan |
| ------------- | ---------- |
| basic monthly | 8          |
| pro monthly   | 60         |
| pro annual    | 63         |
| churn         | 71         |

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql
SELECT 
    COUNT(DISTINCT customer_id) AS churned_customer,
    ROUND(COUNT(DISTINCT customer_id) / 
			(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS churned_customer_percentage
FROM
    subscriptions
WHERE
    plan_id = 4;
```
Result:
| churned_customer | churned_customer_percentage |
| ---------------- | --------------------------- |
| 307              | 30.7                        |

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```sql
WITH cte AS(
	SELECT *,
		LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_plan_id
	FROM subscriptions)
SELECT
	COUNT(*) AS churned_after_trial_count,
	ROUND(COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 0) AS churned_after_trial_percentage
FROM cte
WHERE plan_id = 4 AND previous_plan_id = 0;
```
Result:
| churned_after_trial_count | churned_after_trial_percentage |
| ------------------------- | ------------------------------ |
| 92                        | 9                              |

### 6. What is the number and percentage of customer plans after their initial free trial?
``` sql
WITH cte AS(
	SELECT 
		customer_id, 
        plan_name,
		LAG(s.plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_plan_id
    FROM subscriptions s
	INNER JOIN plans p 
		ON s.plan_id = p.plan_id)
SELECT
	plan_name,
	COUNT(*) AS after_trial_count,
	ROUND(COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 2) AS after_trial_percentage
FROM cte
WHERE previous_plan_id = 0
GROUP BY plan_name;
```
Result:
| plan_name     | after_trial_count | after_trial_percentage |
| ------------- | ----------------- | ---------------------- |
| basic monthly | 546               | 54.60                  |
| pro annual    | 37                | 3.70                   |
| pro monthly   | 325               | 32.50                  |
| churn         | 92                | 9.20                   |

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```sql
-- we will use the temporary table we create at part A
SELECT
	plan_name,
    COUNT(*) AS total_customer,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 2) AS percentage
FROM subscriptions_temp
WHERE start_date <= '2020-12-31'
	AND (end_date >= '2020-12-31' OR end_date IS NULL)
GROUP BY plan_id;
```
Result:
| plan_name     | total_customer | percentage |
| ------------- | -------------- | ---------- |
| basic monthly | 224            | 29.09      |
| pro annual    | 195            | 25.32      |
| pro monthly   | 326            | 42.34      |
| trial         | 19             | 2.47       |
| churn         | 6              | 0.78       |

### 8. How many customers have upgraded to an annual plan in 2020?
```sql
SELECT COUNT(DISTINCT customer_id) AS total_customer
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = '2020';
```
Result:
| total_customer |
| -------------- |
| 195            |

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi
```sql
WITH trial AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 0),
annual AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 3)
SELECT ROUND(AVG(DATEDIFF(a.start_date, t.start_date)), 2) AS avg_trial_to_annual
FROM trial t
INNER JOIN annual a
	ON t.customer_id = a.customer_id;
```
Result:
| avg_trial_to_annual |
| ------------------- |
| 104.62              |

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
```sql
-- same with previous question but wee add additional cte to calculate period categories
WITH trial AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 0),
annual AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 3),
cte AS(
	SELECT 
		DATEDIFF(a.start_date, t.start_date) AS date_diff,
		FLOOR(DATEDIFF(a.start_date, t.start_date)/30) AS cat
	FROM trial t
	INNER JOIN annual a
		ON t.customer_id = a.customer_id)
SELECT 
	CASE
		WHEN cat = 0 THEN '0-30 days'
        ELSE CONCAT(cat*30 + 1, '-', (cat+1) * 30, ' days')
	END AS period,
	COUNT(*) AS total_customer,
    ROUND(AVG(date_diff), 2) AS avg_trial_to_annual
FROM cte
GROUP BY cat
ORDER BY cat;
```
Result:
| period       | total_customer | avg_trial_to_annual |
| ------------ | -------------- | ------------------- |
| 0-30 days    | 48             | 9.54                |
| 31-60 days   | 25             | 41.84               |
| 61-90 days   | 33             | 70.88               |
| 91-120 days  | 35             | 99.83               |
| 121-150 days | 43             | 133.05              |
| 151-180 days | 35             | 161.54              |
| 181-210 days | 27             | 190.33              |
| 211-240 days | 4              | 224.25              |
| 241-270 days | 5              | 257.20              |
| 271-300 days | 1              | 285.00              |
| 301-330 days | 1              | 327.00              |
| 331-360 days | 1              | 346.00              |

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```sql
WITH cte AS(
	SELECT *,
		LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan_id
	FROM subscriptions)
SELECT COUNT(*) AS pro_to_basic
FROM cte
WHERE YEAR(start_date) = '2020' AND plan_id = 2 AND next_plan_id = 1;
```
Result:
| pro_to_basic |
| ------------ |
| 0            |

<br>

***
Let's move to [C. Challenge Payment Question](./C.%20Challenge%20Payment%20Question.md).
