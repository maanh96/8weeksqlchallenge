# Case Study #2 - Pizza Runner

## B. Runner and Customer Experience
### 1. How many runners signed up for each 1 week period? (i.e. week starts <code>2021-01-01</code>)
```sql
SELECT 
    WEEK(registration_date) AS registration_week,
    COUNT(*) AS total_runner
FROM
    runners
GROUP BY registration_week;
```
Result:
| registration_week | total_runner |
| ----------------- | ------------ |
| 0                 | 1            |
| 1                 | 2            |
| 2                 | 1            |

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
SELECT 
    runner_id,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                order_time,
                pickup_time)),
            2) AS average_time
FROM
    runner_orders_temp r
INNER JOIN customer_orders_temp c 
    ON r.order_id = c.order_id
WHERE
    cancellation IS NULL
GROUP BY runner_id;
```
Result:
| runner_id | average_time |
| --------- | ------------ |
| 1         | 15.33        |
| 2         | 23.40        |
| 3         | 10.00        |

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
WITH cte AS(
	SELECT
		COUNT(pizza_id) AS pizza_delivered,
		TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS prep_time
	FROM runner_orders_temp r
	INNER JOIN customer_orders_temp c
		ON r.order_id = c.order_id
	WHERE cancellation IS NULL
	GROUP BY r.order_id)
SELECT pizza_delivered, ROUND(AVG(prep_time), 2) AS avg_prep_time, 
	ROUND(AVG(prep_time)/pizza_delivered, 2) AS avg_prep_time_per_pizza
FROM cte
GROUP BY pizza_delivered;
```
Result:
| pizza_delivered | avg_prep_time | avg_prep_time_per_pizza |
| --------------- | ------------- | ----------------------- |
| 1               | 12.00         | 12.00                   |
| 2               | 18.00         | 9.00                    |
| 3               | 29.00         | 9.67                    |

More pizzas will take more time to prepare, but the average time per pizza will decrease, which means increased efficiency.

### 4. What was the average distance travelled for each customer?
```sql
SELECT 
    customer_id, ROUND(AVG(distance), 2) AS avg_distance
FROM
    runner_orders_temp r
        INNER JOIN
    customer_orders_temp c ON r.order_id = c.order_id
WHERE
    cancellation IS NULL
GROUP BY customer_id;
```
Result:
| customer_id | avg_distance |
| ----------- | ------------ |
| 101         | 20           |
| 102         | 16.73        |
| 103         | 23.4         |
| 104         | 10           |
| 105         | 25           |

### 5. What was the difference between the longest and shortest delivery times for all orders?
```sql
SELECT 
    MAX(duration) - MIN(duration) AS max_dif_time
FROM
    runner_orders_temp;
```
Result:
| max_dif_time |
| ------------ |
| 30           |

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql
SELECT 
    runner_id,
    order_id,
    distance,
    ROUND(duration / 60, 2) AS duration_hr,
    ROUND(distance / duration * 60, 2) AS avg_speed
FROM
    runner_orders_temp
WHERE
    cancellation IS NULL
ORDER BY runner_id , order_id;
```
Result:
| runner_id | order_id | distance | duration_hr | avg_speed |
| --------- | -------- | -------- | ----------- | --------- |
| 1         | 1        | 20       | 0.53        | 37.5      |
| 1         | 2        | 20       | 0.45        | 44.44     |
| 1         | 3        | 13.4     | 0.33        | 40.2      |
| 1         | 10       | 10       | 0.17        | 60        |
| 2         | 4        | 23.4     | 0.67        | 35.1      |
| 2         | 7        | 25       | 0.42        | 60        |
| 2         | 8        | 23.4     | 0.25        | 93.6      |
| 3         | 5        | 10       | 0.25        | 40        |

The runners' average speed seem to increase as they get used to the job.

### 7. What is the successful delivery percentage for each runner?
```sql
SELECT 
    runner_id,
    ROUND(SUM(CASE
                WHEN cancellation IS NULL THEN 1
                ELSE 0
            END) / COUNT(*) * 100,
            0) AS successful_rate
FROM
    runner_orders_temp
GROUP BY runner_id;
```
Result:
| runner_id | successful_rate |
| --------- | --------------- |
| 1         | 100             |
| 2         | 75              |
| 3         | 50              |

<br>

***
Let's move to [C. Ingredient Optimisation](./C.%20Ingredient%20Optimisation.md).