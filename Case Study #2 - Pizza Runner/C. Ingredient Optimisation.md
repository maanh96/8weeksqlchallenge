# Case Study #2 - Pizza Runner

## C. Ingredient Optimisation 
### 1. What are the standard ingredients for each pizza?
```sql
-- in order to join with other table we will create a pizza_receipes_temp table to convert toppings to long format
DROP TABLE IF EXISTS pizza_recipes_temp;

CREATE TEMPORARY TABLE pizza_recipes_temp
SELECT p.pizza_id, j.toppings 
FROM pizza_recipes p 
INNER JOIN JSON_TABLE(
	REPLACE(json_array(p.toppings), ', ', '","'),
	'$[*]' COLUMNS (toppings VARCHAR(50) PATH '$')
) AS j;

SELECT * FROM pizza_recipes_temp;
```
Result:
| pizza_id | toppings |
| -------- | -------- |
| 1        | 1        |
| 1        | 2        |
| 1        | 3        |
| 1        | 4        |
| ...      | ...      |

```sql
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
```
Result:
| pizza_name | toppings                                                              |
| ---------- | --------------------------------------------------------------------- |
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |

### 2. What was the most commonly added extra?
```sql
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

SELECT * FROM extras_temp;
```
Result:
| record_id | extras |
| --------- | ------ |
| 1         |        |
| 2         |        |
| 3         |        |
| 4         |        |
| 5         |        |
| 6         |        |
| 7         |        |
| 8         | 1      |
| 9         |        |
| 10        | 1      |
| 11        |        |
| 12        | 1      |
| 12        | 5      |
| 13        |        |
| 14        | 1      |
| 14        | 4      |


```sql
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
```
Result:
| topping_name | add_count |
| ------------ | --------- |
| Bacon        | 4         |

### 3. What was the most common exclusion?
```sql
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
```
Result:
| topping_name | remove_count |
| ------------ | ------------ |
| Cheese       | 4            |

### 4. Generate an order item for each record in the <code>customers_orders</code> table in the format of one of the following:
* <code>Meat Lovers</code>
* <code>Meat Lovers - Exclude Beef</code>
* <code>Meat Lovers - Extra Bacon</code>
* <code>Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers</code>
```sql
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
```
Result:
| order_id | customer_id | order_details                                                   |
| -------- | ----------- | --------------------------------------------------------------- |
| 1        | 101         | Meatlovers                                                      |
| 2        | 101         | Meatlovers                                                      |
| 3        | 102         | Meatlovers                                                      |
| 3        | 102         | Vegetarian                                                      |
| 4        | 103         | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | Vegetarian - Exclude Cheese                                     |
| 5        | 104         | Meatlovers - Extra Bacon                                        |
| 6        | 101         | Vegetarian                                                      |
| 7        | 105         | Vegetarian - Extra Bacon                                        |
| 8        | 102         | Meatlovers                                                      |
| 9        | 103         | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10       | 104         | Meatlovers                                                      |
| 10       | 104         | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the <code>customer_orders</code> table and add a <code>2x</code> in front of any relevant ingredients
* For example: <code>"Meat Lovers: 2xBacon, Beef, ... , Salami"</code>

```sql
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
```
Result:
| order_id | customer_id | ingredient_list                                                                     |
| -------- | ----------- | ----------------------------------------------------------------------------------- |
| 1        | 101         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2        | 101         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | 102         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | 102         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 4        | 103         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | 103         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | 103         | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                      |
| 5        | 104         | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6        | 101         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 7        | 105         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 8        | 102         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 9        | 103         | Meatlovers: 2xBacon, BBQ Sauce, Beef, 2xChicken, Mushrooms, Pepperoni, Salami       |
| 10       | 104         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 10       | 104         | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                     |
      
### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
```sql
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
```
Result:
| topping_name | total_quantity |
| ------------ | -------------- |
| Bacon        | 11             |
| Mushrooms    | 11             |
| Cheese       | 10             |
| Beef         | 9              |
| Chicken      | 9              |
| Pepperoni    | 9              |
| Salami       | 9              |
| BBQ Sauce    | 8              |
| Onions       | 3              |
| Peppers      | 3              |
| Tomatoes     | 3              |
| Tomato Sauce | 3              |

<br>

***
Let's move to [D. Pricing and Ratings](https://github.com/maanh96/8weeksqlchallenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/D.%20Pricing%20and%20Ratings%20%26%20E.%20Bonus%20Questions.md).
