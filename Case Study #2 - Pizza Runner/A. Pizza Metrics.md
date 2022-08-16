# Case Study #2 - Pizza Runner

## A. Pizza Metrics

### 1. How many pizzas were ordered?
``` sql
SELECT 
    COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp;
```
Result:
| pizza_ordered |
| ------------- |
| 14            |

### 2. How many unique customer orders were made?
``` sql
SELECT 
    COUNT(DISTINCT order_id) AS unique_order
FROM
    customer_orders_temp;
```
Result:
| unique_order |
| ------------ |
| 10           |

### 3. How many successful orders were delivered by each runner?
``` sql
SELECT 
    runner_id, COUNT(*) AS order_delivered
FROM
    runner_orders_temp
WHERE
    cancellation IS NULL
GROUP BY runner_id;
```
Result:
| runner_id | order_delivered |
| --------- | --------------- |
| 1         | 4               |
| 2         | 3               |
| 3         | 1               |

### 4. How many of each type of pizza was delivered?
``` sql
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
```
Result:
| pizza_name | pizza_delivered |
| ---------- | --------------- |
| Meatlovers | 9               |
| Vegetarian | 3               |

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
``` sql
SELECT 
    customer_id, pizza_name, COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp c
        INNER JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY customer_id , pizza_name
ORDER BY customer_id;
```
Result:
| customer_id | pizza_name | pizza_ordered |
| ----------- | ---------- | ------------- |
| 101         | Meatlovers | 2             |
| 101         | Vegetarian | 1             |
| 102         | Meatlovers | 2             |
| 102         | Vegetarian | 1             |
| 103         | Meatlovers | 3             |
| 103         | Vegetarian | 1             |
| 104         | Meatlovers | 3             |
| 105         | Vegetarian | 1             |

### 6. What was the maximum number of pizzas delivered in a single order?
``` sql
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
```
Result:
| order_id | max_pizza_delivered |
| -------- | ------------------- |
| 4        | 3                   |

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
``` sql
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
```
Result:
| customer_id | pizza_delivered_w_change | pizza_delivered_no_change |
| ----------- | ------------------------ | ------------------------- |
| 101         | 0                        | 2                         |
| 102         | 0                        | 3                         |
| 103         | 3                        | 0                         |
| 104         | 2                        | 1                         |
| 105         | 1                        | 0                         |

### 8. How many pizzas were delivered that had both exclusions and extras?
``` sql
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
```
Result:
| pizza_delivered_w_exclustions_extras |
| ------------------------------------ |
| 1                                    |

### 9. What was the total volume of pizzas ordered for each hour of the day?
``` sql
SELECT 
    HOUR(order_time) AS hour, COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp
GROUP BY hour
ORDER BY hour;
```
Result:
| hour | pizza_ordered |
| ---- | ------------- |
| 11   | 1             |
| 13   | 3             |
| 18   | 3             |
| 19   | 1             |
| 21   | 3             |
| 23   | 3             |

### 10. What was the volume of orders for each day of the week?
``` sql
SELECT 
    DAYNAME(order_time) AS day_of_week,
    COUNT(*) AS pizza_ordered
FROM
    customer_orders_temp
GROUP BY day_of_week
ORDER BY day_of_week;
```
Result:
| day_of_week | pizza_ordered |
| ----------- | ------------- |
| Friday      | 1             |
| Saturday    | 5             |
| Thursday    | 3             |
| Wednesday   | 5             |

<br>

***
Let's move to [B. Runner and Customer Experience](./B.%20Runner%20and%20Customer%20Experience.md).