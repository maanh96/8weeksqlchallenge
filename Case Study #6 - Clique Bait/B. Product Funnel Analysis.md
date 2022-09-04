# Case Study #6 - Clique Bait

## B. Product Funnel Analysis

### Using a single SQL query - create a new output table which has the following details:
* How many times was each product viewed?
* How many times was each product added to cart?
* How many times was each product added to a cart but not purchased (abandoned)?
* How many times was each product purchased?
``` sql
-- from events create view_add_cte that:
    -- inner join page_hierarchy to get page_name (product name)
    -- use CASE() to mark when product is viewed or added to cart
    -- filter product_id not null to get product only
-- from events create purchase_cte to select visit_id that purchase
-- left join view_add_cte with purchase_cte when cart_added IS NOT NULL
-- sum the viewd, cart_added, purchased group by product_id to get total number
-- sum the case when cart_added = 1 and purchased IS NULL to get total_abandoned

DROP TABLE IF EXISTS products;
CREATE TABLE products
WITH view_add_cte AS(
	SELECT
		product_id,
        page_name AS product_name,
		visit_id,
		CASE WHEN event_type = 1 THEN 1 END AS viewed,
		CASE WHEN event_type = 2 THEN 1 END AS cart_added
	FROM events e
	INNER JOIN page_hierarchy p
		ON e.page_id = p.page_id
	WHERE product_id IS NOT NULL),

purchase_cte AS(
	SELECT visit_id, 1 AS purchased
	FROM events
	WHERE event_type = 3)

SELECT 
	product_id,
    product_name,
    SUM(viewed) AS total_viewed,
    SUM(cart_added) AS total_cart_added,
    SUM(purchased) AS total_purchased,
    SUM(CASE WHEN cart_added = 1 AND purchased IS NULL THEN 1 END) AS total_abandoned
FROM view_add_cte v
LEFT JOIN purchase_cte p
	ON v.visit_id = p.visit_id AND cart_added IS NOT NULL
GROUP BY product_id
ORDER BY product_id;

SELECT * FROM products;
```
Result:
| product_id | product_name   | total_viewed | total_cart_added | total_purchased | total_abandoned |
| :--------- | :------------- | :----------- | :--------------- | :-------------- | :-------------- |
| 1          | Salmon         | 1559         | 938              | 711             | 227             |
| 2          | Kingfish       | 1559         | 920              | 707             | 213             |
| 3          | Tuna           | 1515         | 931              | 697             | 234             |
| 4          | Russian Caviar | 1563         | 946              | 697             | 249             |
| 5          | Black Truffle  | 1469         | 924              | 707             | 217             |
| 6          | Abalone        | 1525         | 932              | 699             | 233             |
| 7          | Lobster        | 1547         | 968              | 754             | 214             |
| 8          | Crab           | 1564         | 949              | 719             | 230             |
| 9          | Oyster         | 1568         | 943              | 726             | 217             |

### Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
``` sql
DROP TABLE IF EXISTS product_categories;
CREATE TABLE product_categories
SELECT 
	product_category,
    SUM(total_viewed) AS total_viewed,
    SUM(total_cart_added) AS total_cart_added,
    SUM(total_purchased) AS total_purchased,
    SUM(total_abandoned) AS total_abandoned
FROM page_hierarchy h
INNER JOIN products p
	ON h.product_id = p.product_id
GROUP BY product_category;
SELECT * FROM product_categories;
```
Result:
| product_category | total_viewed | total_cart_added | total_purchased | total_abandoned |
| :--------------- | :----------- | :--------------- | :-------------- | :-------------- |
| Fish             | 4633         | 2789             | 2115            | 674             |
| Luxury           | 3032         | 1870             | 1404            | 466             |
| Shellfish        | 6204         | 3792             | 2898            | 894             |

### 1. Which product had the most views, cart adds and purchases?
``` sql
(SELECT product_name, 'most views' AS type
FROM products
ORDER BY total_viewed DESC
LIMIT 1)
UNION
(SELECT product_name, 'most cart adds' AS type
FROM products
ORDER BY total_cart_added DESC
LIMIT 1)
UNION
(SELECT product_name, 'most purchases' AS type
FROM products
ORDER BY total_purchased DESC
LIMIT 1);
```
Result:
| product_name | type           |
| :----------- | :------------- |
| Oyster       | most views     |
| Lobster      | most cart adds |
| Lobster      | most purchases |

### 2. Which product was most likely to be abandoned?
``` sql
SELECT product_name, ROUND(total_abandoned/total_cart_added*100, 2) AS abandoned_rate
FROM products
ORDER BY abandoned_rate DESC
LIMIT 1;
```
Result:
| product_name   | abandoned_rate |
| :------------- | :------------- |
| Russian Caviar | 26.32          |

### 3. Which product had the highest view to purchase percentage?
``` sql
SELECT product_name, ROUND(total_purchased/total_viewed *100, 2) AS view_to_purchase_percent
FROM products
ORDER BY view_to_purchase_percent DESC
LIMIT 1;
```
Result:
| product_name | view_to_purchase_percent |
| :----------- | :----------------------- |
| Lobster      | 48.74                    |

### 4. What is the average conversion rate from view to cart add?
``` sql
SELECT ROUND(AVG(total_cart_added/total_viewed *100), 2) AS view_to_cart_add_percent
FROM products;
```
Result:
| view_to_cart_add_percent |
| :----------------------- |
| 60.95                    |

### 5. What is the average conversion rate from cart add to purchase?
``` sql
SELECT ROUND(AVG(total_purchased/total_cart_added *100), 2) AS cart_add_to_purchase_percent
FROM products;
```
Result:
| cart_add_to_purchase_percent |
| :--------------------------- |
| 75.93                        |


<br>

***
Let's move to [C. Campaigns Analysis](C.%20Campaigns%20Analysis.md).
