/* --------------------
   Case Study Questions
   --------------------*/
   
-- Data Cleaning --

-- customer_orders: clean up null values in exclusions and extras columns
DROP TABLE IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp
SELECT
	order_id,
    customer_id,
    pizza_id,
    order_time,
    CASE
		WHEN exclusions IN ('', 'null') THEN NULL
        ELSE exclusions
	END AS exclusions,
    CASE
		WHEN extras IN ('', 'null') THEN NULL
        ELSE extras
	END AS extras
FROM customer_orders;
SELECT * FROM customer_orders_temp;

-- runner_orders: clean up null values and correct data type in pickup_time, distance, duration and cancellation columns 
DROP TABLE IF EXISTS runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp
SELECT 
	order_id,
	runner_id,
    CASE
		WHEN pickup_time = 'null' THEN NULL
        ELSE CAST(pickup_time AS DATETIME)
	END AS pickup_time,
	CASE
		WHEN distance = 'null' THEN NULL
        ELSE CAST(REGEXP_SUBSTR(distance, "[0-9]+\.?[0-9]+") AS FLOAT)
    END AS distance,
    CASE
		WHEN duration = 'null' THEN NULL
        ELSE CAST(REGEXP_SUBSTR(duration, "[0-9]+") AS UNSIGNED)
    END AS duration,
    CASE
		WHEN cancellation IN ('', 'null') THEN NULL
        ELSE cancellation
	END AS cancellation
FROM runner_orders;
SELECT * FROM runner_orders_temp;

-- A. Pizza Metrics --
-- 1. How many pizzas were ordered?
SELECT 
    COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp;

-- 2. How many unique customer orders were made?
SELECT 
    COUNT(DISTINCT order_id) AS unique_order
FROM
    customer_orders_temp;

-- 3. How many successful orders were delivered by each runner?
SELECT 
    runner_id, COUNT(*) AS order_delivered
FROM
    runner_orders_temp
WHERE
    cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT 
    pizza_name, COUNT(*) AS pizza_delivered
FROM
    customer_orders_temp c
        INNER JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
        INNER JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    cancellation IS NULL
GROUP BY c.pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    customer_id, pizza_name, COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp c
        INNER JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY customer_id , pizza_name
ORDER BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT 
    c.order_id, COUNT(*) AS max_pizza_delivered
FROM
    customer_orders_temp c
        INNER JOIN
    runner_orders r ON c.order_id = r.order_id
WHERE
    cancellation IS NULL
GROUP BY c.order_id
ORDER BY max_pizza_delivered DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    customer_id,
    SUM(CASE
        WHEN exclusions IS NULL AND extras IS NULL THEN 0
        ELSE 1
    END) AS pizza_delivered_w_change,
    SUM(CASE
        WHEN exclusions IS NULL AND extras IS NULL THEN 1
        ELSE 0
    END) AS pizza_delivered_no_change
FROM
    customer_orders_temp c
        INNER JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    cancellation IS NULL
GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
    SUM(CASE
        WHEN
            exclusions IS NOT NULL
                AND extras IS NOT NULL
        THEN
            1
        ELSE 0
    END) AS pizza_delivered_w_exclustions_extras
FROM
    customer_orders_temp c
        INNER JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    cancellation IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    HOUR(order_time) AS hour, COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp
GROUP BY hour
ORDER BY hour;

-- 10. What was the volume of orders for each day of the week?
SELECT 
    DAYNAME(order_time) AS day_of_week,
    COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp
GROUP BY day_of_week
ORDER BY day_of_week;

-- B. Runner and Customer Experience --

SELECT 
    WEEK(registration_date) AS registration_week,
    COUNT(*) AS total_runner
FROM
    runners
GROUP BY registration_week;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
    runner_id,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                order_time,
                pickup_time)),
            2) AS average_time
FROM
    runner_orders_temp r
        INNER JOIN
    customer_orders_temp c ON r.order_id = c.order_id
WHERE
    cancellation IS NULL
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS(
	SELECT
		COUNT(pizza_id) AS pizza_delivered,
		TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS prep_time
	FROM runner_orders_temp r
	INNER JOIN customer_orders_temp c
		ON r.order_id = c.order_id
	WHERE cancellation IS NULL
	GROUP BY r.order_id)
SELECT pizza_delivered, ROUND(AVG(prep_time), 2) AS avg_prep_time
FROM cte
GROUP BY pizza_delivered;

-- 4. What was the average distance travelled for each customer
SELECT 
    customer_id, ROUND(AVG(distance), 2) AS avg_distance
FROM
    runner_orders_temp r
        INNER JOIN
    customer_orders_temp c ON r.order_id = c.order_id
WHERE
    cancellation IS NULL
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
    MAX(duration) - MIN(duration) AS max_dif_time
FROM
    runner_orders_temp;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
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

-- 7. What is the successful delivery percentage for each runner?
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

-- C. Ingredient Optimisation --

-- 1. What are the standard ingredients for each pizza?\
	-- in order to join with other table we will create a pizza_receipes_temp table to convert toppings to long format
DROP TABLE IF EXISTS pizza_recipes_temp;
CREATE TEMPORARY TABLE pizza_recipes_temp
SELECT p.pizza_id, j.toppings 
FROM pizza_recipes p 
INNER JOIN JSON_TABLE(
	REPLACE(json_array(p.toppings), ', ', '","'),
	'$[*]' COLUMNS (toppings VARCHAR(50) PATH '$')
) AS j;
	-- from pizza_recipes_temp inner join with pizza_names and pizza_toppings to get name of pizza and toppings
SELECT 
    pizza_name,
    GROUP_CONCAT(topping_name
        SEPARATOR ', ') AS toppings
FROM
    pizza_recipes_temp r
        INNER JOIN
    pizza_names n ON r.pizza_id = n.pizza_id
        INNER JOIN
    pizza_toppings t ON r.toppings = t.topping_id
GROUP BY pizza_name;
    
-- 2. What was the most commonly added extra?
	-- create record_id column for customer_orders_temp to distinguish each record
ALTER TABLE customer_orders_temp
ADD COLUMN record_id INTEGER PRIMARY KEY AUTO_INCREMENT;
    -- in order to join with other table we will create an extras_temp table
DROP TABLE IF EXISTS extras_temp;
CREATE TEMPORARY TABLE extras_temp
SELECT c.record_id, j.extras 
FROM customer_orders_temp c
INNER JOIN JSON_TABLE(
	REPLACE(json_array(c.extras), ', ', '","'),
	'$[*]' COLUMNS (extras VARCHAR(50) PATH '$')
) AS j;
	-- from extras_temp join with pizza_toppings to get toppings' name
SELECT 
    topping_name, COUNT(*) AS add_count
FROM
    extras_temp e
        INNER JOIN
    pizza_toppings t ON e.extras = t.topping_id
GROUP BY e.extras
ORDER BY add_count DESC
LIMIT 1;

-- 3. What was the most common exclusion?
-- in order to join with other table we will create an exclusions_temp table
DROP TABLE IF EXISTS exclusions_temp;
CREATE TEMPORARY TABLE exclusions_temp
SELECT c.record_id, j.exclusions
FROM customer_orders_temp c
INNER JOIN JSON_TABLE(
	REPLACE(json_array(c.exclusions), ', ', '","'),
	'$[*]' COLUMNS (exclusions VARCHAR(50) PATH '$')
) AS j;
	-- from exclusions_temp join with pizza_toppings to get toppings' name
SELECT 
    topping_name, COUNT(*) AS remove_count
FROM
    exclusions_temp e
        INNER JOIN
    pizza_toppings t ON e.exclusions = t.topping_id
GROUP BY e.exclusions
ORDER BY remove_count DESC
LIMIT 1;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following: Meat Lovers; Meat Lovers - Exclude Beef; Meat Lovers - Extra Bacon; Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
	-- from customer_orders_temp create a cte table that:
		-- inner join pizza_names to get pizza_name
        -- left join extras_temp and pizza_toppings (t1) to get extras name
        -- left join exclusions_temp and pizza_topping (t2) to get exclusions name
        -- group_concat on extras and exclusions name
	-- use case to create order_details
WITH cte AS(
	SELECT
		order_id,
		customer_id,
		pizza_name,
		GROUP_CONCAT(DISTINCT t1.topping_name SEPARATOR ', ') AS extras,
		GROUP_CONCAT(DISTINCT t2.topping_name SEPARATOR ', ') AS exclusions
	FROM customer_orders_temp c
	INNER JOIN pizza_names p
		ON c.pizza_id = p.pizza_id
	LEFT JOIN extras_temp ex
		ON c.record_id = ex.record_id
	LEFT JOIN exclusions_temp ec
		ON c.record_id = ec.record_id
	LEFT JOIN pizza_toppings t1
		ON ex.extras = t1.topping_id
	LEFT JOIN pizza_toppings t2
		ON ec.exclusions = t2.topping_id
	GROUP BY c.record_id)
SELECT order_id, customer_id,
	CASE
		WHEN extras IS NOT NULL AND exclusions IS NOT NULL THEN CONCAT(pizza_name, ' - Exclude ', exclusions, ' - Extra ', extras)
        WHEN exclusions IS NOT NULL THEN CONCAT(pizza_name, ' - Exclude ', exclusions)
        WHEN extras IS NOT NULL THEN CONCAT(pizza_name, ' - Extra ', extras)
        ELSE pizza_name 
    END AS order_details
FROM cte;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
	-- from customer_orders_temp create a cte table that:
		-- inner join pizza_names to get pizza name
        -- inner join pizza_recipes_temp to get list of ingredient
        -- inner join pizza_toppings to get toppings name
        -- use case for each toppings in case of none, exclusion (not appear), extra (2x)
        -- order by toppings name
	-- use case to create order_details
WITH cte AS(
	SELECT
		c.record_id,
		order_id,
		customer_id,
		pizza_name,
		CASE
			WHEN toppings IN (SELECT extras FROM extras_temp ex WHERE ex.record_id = c.record_id ) THEN CONCAT('2x', topping_name)
			WHEN toppings IN (SELECT exclusions FROM exclusions_temp ec WHERE ec.record_id = c.record_id ) THEN NULL
			ELSE topping_name
		END AS toppings
	FROM customer_orders_temp c
	INNER JOIN pizza_names p
		ON c.pizza_id = p.pizza_id
	INNER JOIN pizza_recipes_temp r
		ON c.pizza_id = r.pizza_id
	INNER JOIN pizza_toppings t
		ON r.toppings = t.topping_id
	ORDER BY topping_name)
SELECT order_id, customer_id,
	CONCAT(pizza_name, ': ', GROUP_CONCAT(toppings SEPARATOR ', ')) AS ingredient_list
FROM cte
GROUP BY record_id;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- from customer_orders_temp create a cte table that:
        -- inner join pizza_recipes_temp to get list of ingredient
        -- inner join pizza_toppings to get toppings name
        -- use case create topping_used column for each toppings in case of none (1), exclusion (0), extra (2)
        -- inner join runner_orders_temp to filter when delivery is cancelled
	-- sum topping_used to get total quantity
    -- order by total quantity in decending order
WITH cte AS(
	SELECT
		c.record_id,
		topping_name,
		CASE
			WHEN toppings IN (SELECT extras FROM extras_temp ex WHERE ex.record_id = c.record_id ) THEN 2
			WHEN toppings IN (SELECT exclusions FROM exclusions_temp ec WHERE ec.record_id = c.record_id ) THEN 0
			ELSE 1
		END AS topping_used
	FROM customer_orders_temp c
	INNER JOIN pizza_recipes_temp r
		ON c.pizza_id = r.pizza_id
	INNER JOIN pizza_toppings t
		ON r.toppings = t.topping_id
	INNER JOIN runner_orders_temp ru
		ON c.order_id = ru.order_id
	WHERE cancellation IS NULL)
SELECT topping_name, SUM(topping_used) AS total_quantity
FROM cte
GROUP BY topping_name
ORDER BY total_quantity DESC;

-- D. Pricing and Ratings --

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

-- 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
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

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
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

SELECT 
    *
FROM
    runner_ratings;

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries? customer_id; order_id; runner_id; rating; order_time; pickup_time; Time between order and pickup; Delivery duration; Average speed; Total number of pizzas
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

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
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

-- E. Bonus Questions --
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
	-- insert into pizza_names
INSERT INTO pizza_names VALUES(3, 'Supreme');
	-- insert into pizza_recipes
INSERT INTO pizza_recipes
VALUES (3, (SELECT GROUP_CONCAT(topping_id SEPARATOR ', ') FROM pizza_toppings));

SELECT 
    *
FROM
    pizza_recipes;