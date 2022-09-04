# Case Study #6 - Clique Bait

## A. Digital Analysis

### 1, How many users are there?
``` sql
SELECT COUNT(DISTINCT user_id) AS total_users
FROM users;
```
Result:
| total_users |
| :---------- |
| 500         |

### 2. How many cookies does each user have on average?
``` sql
WITH cte AS(
	SELECT user_id, COUNT(cookie_id) AS total_cookie
	FROM users
	GROUP BY user_id)
SELECT ROUND(AVG(total_cookie), 2) AS avg_cookie
FROM cte;
```
Result:
| avg_cookie |
| :--------- |
| 3.56       |

### 3. What is the unique number of visits by all users per month?
``` sql
SELECT
	MONTH(event_time) AS month,
    COUNT(DISTINCT visit_id) AS total_visit
FROM events
GROUP BY month;
```
Result:
| month | total_visit |
| :---- | :---------- |
| 1     | 876         |
| 2     | 1488        |
| 3     | 916         |
| 4     | 248         |
| 5     | 36          |

### 4. What is the number of events for each event type?
``` sql
SELECT
	e.event_type,
    event_name,
    COUNT(*) AS total_events
FROM events e
INNER JOIN event_identifier i
	ON e.event_type = i.event_type
GROUP BY e.event_type;
```
Result:
| event_type | event_name    | total_events |
| :--------- | :------------ | :----------- |
| 1          | Page View     | 20928        |
| 2          | Add to Cart   | 8451         |
| 3          | Purchase      | 1777         |
| 4          | Ad Impression | 876          |
| 5          | Ad Click      | 702          |

### 5. What is the percentage of visits which have a purchase event?
``` sql
SELECT 
	ROUND(COUNT(DISTINCT visit_id)/ (SELECT COUNT(DISTINCT visit_id) FROM events) *100, 2) AS purchase_visit_percent
FROM events
WHERE event_type = 3;
```
Result:
| purchase_visit_percent |
| :--------------------- |
| 49.86                  |

### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
``` sql
-- from events create checkout_cte to select distinct of visit_id that view the checkout page
-- left join with events with event_type = 3 (purchase)
-- count where the event_type is null (no purchase) and divide to total visit_id in checkout_cte to get the percentage

WITH checkout_cte AS(
	SELECT DISTINCT visit_id
	FROM events
	WHERE event_type = 1 AND page_id = 12)
SELECT ROUND(COUNT(c.visit_id)/(SELECT COUNT(visit_id) FROM checkout_cte) * 100, 2) AS checkout_not_purchase_percent
FROM checkout_cte c
LEFT JOIN events e
	ON c.visit_id = e.visit_id AND event_type = 3
WHERE event_type IS NULL;
```
Result:
| checkout_not_purchase_percent |
| :---------------------------- |
| 15.50                         |

### 7. What are the top 3 pages by number of views?
``` sql
SELECT
	page_name,
    COUNT(visit_id) total_visit
FROM events e
INNER JOIN page_hierarchy p
	ON e.page_id = p.page_id
WHERE event_type = 1
GROUP BY e.page_id
ORDER BY total_visit DESC
LIMIT 3;
```
Result:
| page_name    | total_visit |
| :----------- | :---------- |
| All Products | 3174        |
| Checkout     | 2103        |
| Home Page    | 1782        |

### 8. What is the number of views and cart adds for each product category?
``` sql
SELECT
	product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 END) AS total_views,
    SUM(CASE WHEN event_type = 2 THEN 1 END) AS total_cart_adds
FROM events e
INNER JOIN page_hierarchy p
	ON e.page_id = p.page_id
WHERE product_category IS NOT NULL
GROUP BY product_category;
```
Result:
| product_category | total_views | total_cart_adds |
| :--------------- | :---------- | :-------------- |
| Luxury           | 3032        | 1870            |
| Shellfish        | 6204        | 3792            |
| Fish             | 4633        | 2789            |

### 9. What are the top 3 products by purchases?
``` sql
-- from events create purchase_cte to select visit_id that purchase
-- left join with events with event_type = 2 (add to cart)
-- inner join with page_hierarchy to get page_name (product)
-- count visit_id group by product_id and sort in descending order
-- limit 3 to get top 3

WITH purchase_cte AS(
	SELECT visit_id
	FROM events
	WHERE event_type = 3)
SELECT page_name AS product, COUNT(p.visit_id) AS total_purchase
FROM purchase_cte p
LEFT JOIN events e
	ON p.visit_id = e.visit_id AND event_type = 2
INNER JOIN page_hierarchy h
	ON e.page_id = h.page_id
GROUP BY product_id
ORDER BY total_purchase DESC
LIMIT 3;
```
Result:
| product | total_purchase |
| :------ | :------------- |
| Lobster | 754            |
| Oyster  | 726            |
| Crab    | 719            |

<br>

***
Let's move to [B. Product Funnel Analysis](./B.%20Product%20Funnel%20Analysis.md).
