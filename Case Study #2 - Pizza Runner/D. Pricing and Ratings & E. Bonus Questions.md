# Case Study #2 - Pizza Runner

### D. Pricing and Ratings
### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
```sql
SELECT 
    SUM(CASE
        WHEN pizza_id = 1 THEN 12
        ELSE 10
    END) AS total_revenue
FROM
    customer_orders_temp c
        INNER JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    cancellation IS NULL;
```
Result:
| total_revenue |
| ------------- |
| 138           |

### 2. What if there was an additional $1 charge for any pizza extras?
* Add cheese is $1 extra
```sql
-- from customer_orders_temp create a cte table that:
  -- use case to find pizza_revenue based on pizza_id
  -- inner join extras_orders to get list of extras, use case to add $1 with each extra and sum (group by record_id) to get extra_revenue
  -- inner join runner_orders_temp to filter when delivery is successful
-- sum both column pizza_revenue and extra_revenue to get total_revenue

WITH cte AS(
	SELECT
		pizza_id,
        CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END AS pizza_revenue,
		SUM(CASE WHEN ex.extras IS NOT NULL THEN 1 ELSE 0 END) AS extra_revenue
	FROM customer_orders_temp c
	LEFT JOIN extras_temp ex
		ON c.record_id = ex.record_id
	INNER JOIN runner_orders_temp r
		ON c.order_id = r.order_id
	WHERE cancellation IS NULL
	GROUP BY c.record_id)
SELECT SUM(pizza_revenue) + SUM(extra_revenue) AS total_revenue
FROM cte;
```
Result:
| total_revenue |
| ------------- |
| 142           |
  
### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
```sql
DROP TABLE IF EXISTS runner_ratings;

CREATE TABLE runner_ratings (
    order_id INTEGER,
    rating INTEGER,
    comments VARCHAR(50),
    CHECK (rating IN (1 , 2, 3, 4, 5))
);

INSERT INTO runner_ratings
VALUES(1, 6, 'Test');

INSERT INTO runner_ratings
VALUES
	(1, 3, NULL ),
	(2, 4, NULL),
    (3, 4, NULL),
	(4, 1,'Too long' ),
	(5, 4, NULL),
	(7, 5, 'Okay'),
	(8, 5, 'Fast'),
	(10, 5, NULL);

SELECT * FROM runner_ratings;
```
Result:
| order_id | rating | comments |
| -------- | ------ | -------- |
| 1        | 3      |          |
| 2        | 4      |          |
| 3        | 4      |          |
| 4        | 1      | Too long |
| 5        | 4      |          |
| 7        | 5      | Okay     |
| 8        | 5      | Fast     |
| 10       | 5      |          |

### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
* <code>customer_id</code>
* <code>order_id</code>
* <code>runner_id</code>
* <code>rating</code>
* <code>order_time</code>
* <code>pickup_time</code>
* Time between order and pickup
* Delivery duration
* Average speed 
* Total number of pizzas

```sql
SELECT 
    customer_id,
    c.order_id,
    rating,
    order_time,
    pickup_time,
    TIMESTAMPDIFF(MINUTE,
        order_time,
        pickup_time) AS prep_time,
    duration AS delivery_duration,
    ROUND(distance / duration * 60, 2) AS avg_speed,
    COUNT(pizza_id) AS total_pizza
FROM
    customer_orders_temp c
        INNER JOIN
    runner_orders_temp r ON c.order_id = r.order_id
        INNER JOIN
    runner_ratings rt ON c.order_id = rt.order_id
GROUP BY c.order_id;
```
Result:
| customer_id | order_id | rating | order_time          | pickup_time         | prep_time | delivery_duration | avg_speed | total_pizza |
| ----------- | -------- | ------ | ------------------- | ------------------- | --------- | ----------------- | --------- | ----------- |
| 101         | 1        | 3      | 2020-01-01 18:05:02 | 2020-01-01 18:15:34 | 10        | 32                | 37.5      | 1           |
| 101         | 2        | 4      | 2020-01-01 19:00:52 | 2020-01-01 19:10:54 | 10        | 27                | 44.44     | 1           |
| 102         | 3        | 4      | 2020-01-02 23:51:23 | 2020-01-03 00:12:37 | 21        | 20                | 40.2      | 2           |
| 103         | 4        | 1      | 2020-01-04 13:23:46 | 2020-01-04 13:53:03 | 29        | 40                | 35.1      | 3           |
| 104         | 5        | 4      | 2020-01-08 21:00:29 | 2020-01-08 21:10:57 | 10        | 15                | 40        | 1           |
| 105         | 7        | 5      | 2020-01-08 21:20:29 | 2020-01-08 21:30:45 | 10        | 25                | 60        | 1           |
| 102         | 8        | 5      | 2020-01-09 23:54:33 | 2020-01-10 00:15:02 | 20        | 15                | 93.6      | 1           |
| 104         | 10       | 5      | 2020-01-11 18:34:49 | 2020-01-11 18:50:20 | 15        | 10                | 60        | 2           |
      
### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
```sql
WITH cte AS(
	SELECT 
		SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS pizza_revenue, 
        distance * 0.3 AS delivery_cost
	FROM customer_orders_temp c
	INNER JOIN runner_orders_temp r
		ON c.order_id = r.order_id
	WHERE cancellation IS NULL
	GROUP BY c.order_id)
SELECT ROUND(SUM(pizza_revenue) - SUM(delivery_cost), 2) AS total_revenue
FROM cte;
```
Result:
| total_revenue |
| ------------- |
| 94.44         |

## E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an <code>INSERT</code> statement to demonstrate what would happen if a new <code>Supreme</code> pizza with all the toppings was added to the Pizza Runner menu?
```sql
-- insert into pizza_names
INSERT INTO pizza_names VALUES(3, 'Supreme');

-- insert into pizza_recipes
INSERT INTO pizza_recipes
VALUES (3, (SELECT GROUP_CONCAT(topping_id SEPARATOR ', ') FROM pizza_toppings));

-- show new pizza tables
SELECT 
    r.pizza_id, pizza_name, toppings
FROM
    pizza_recipes r
        INNER JOIN
    pizza_names p ON r.pizza_id = p.pizza_id;
```
Result:
| pizza_id | pizza_name | toppings                              |
| -------- | ---------- | ------------------------------------- |
| 1        | Meatlovers | 1, 2, 3, 4, 5, 6, 8, 10               |
| 2        | Vegetarian | 4, 6, 7, 9, 11, 12                    |
| 3        | Supreme    | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 |

<br>

***
Back to [Main menu](https://github.com/maanh96/8weeksqlchallenge).