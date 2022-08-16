# Case Study #1 - Danny's Diner

## Case Study Questions

### 1. What is the total amount each customer spent at the restaurant?

```sql
-- from sales table inner join with menu on product_id to get items' price
-- sum price group by customer_id

SELECT 
	customer_id,
    SUM(price) AS total_amount
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id 
GROUP BY customer_id;
```
Result:
| customer_id | total_amount |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

### 2. How many days has each customer visited the restaurant?
```sql
-- from sales table count distinct order_date group by customer_id

SELECT 
	customer_id,
    COUNT(DISTINCT order_date) AS total_day
FROM sales
GROUP BY customer_id;
```
Result: 
| customer_id | total_day |
| ----------- | --------- |
| A           | 4         |
| B           | 6         |
| C           | 2         |

### 3. What was the first item from the menu purchased by each customer?
```sql
-- assume "first item" is the item(s) bought in the first day of each customer
-- from sales table create a cte table that:
	-- rank order_date of each customer
	-- inner join with menu to get items' name
-- filter item(s) where ranking = 1
-- group by all columns to get distinct result only

WITH cte AS (
	SELECT
		customer_id,
		product_name,
		RANK() OVER (
			PARTITION BY customer_id
            ORDER BY order_date) AS ranking
	FROM sales s
    INNER JOIN menu m
		ON s.product_id = m.product_id)
SELECT customer_id, product_name
FROM cte
WHERE ranking = 1
GROUP BY customer_id, product_name;
```
Result: 
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
-- from sales table count product_id to get total_purchase of each item
-- inner join with menu to get items' name
-- order by total_purchase in decending ordder and limit 1

SELECT
	product_name,
    COUNT(s.product_id) AS total_purchase
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
GROUP BY m.product_id
ORDER BY total_purchase DESC
LIMIT 1;
```
Result: 
| product_name | total_purchase |
| ------------ | -------------- |
| ramen        | 8              |

### 5. Which item was the most popular for each customer?
```sql
-- from sales create cte table that:
	-- rank purchase number of items of each customer in decending order
	-- inner join with menu to get items' name
-- filter ranking = 1

WITH cte AS(
	SELECT 
		customer_id, 
        product_name,
		COUNT(s.product_id) AS total_purchase,
		RANK() OVER(
			PARTITION BY customer_id
			ORDER BY COUNT(s.product_id) DESC) AS ranking
	FROM sales s
	INNER JOIN menu m
		ON s.product_id = m.product_id
	GROUP BY customer_id, s.product_id)
SELECT customer_id, product_name, total_purchase
FROM cte
WHERE ranking = 1;
```
Result:
| customer_id | product_name | total_purchase |
| ----------- | ------------ | -------------- |
| A           | ramen        | 3              |
| B           | curry        | 2              |
| B           | sushi        | 2              |
| B           | ramen        | 2              |
| C           | ramen        | 3              |

### 6. Which item was purchased first by the customer after they became a member?
```sql
-- from sales create a cte table that:
	-- rank the order date of items of each customer
	-- inner join with members table and filter entries where order_date >= join_date
	-- inner join with menu to get items' name
-- filter ranking = 1

WITH cte AS(
	SELECT 
		s.customer_id,
        product_name,
        order_date,
		RANK() OVER(
			PARTITION BY s.customer_id 
            ORDER BY order_date) AS ranking
	FROM sales s
	INNER JOIN members m
		ON s.customer_id = m.customer_id  AND s.order_date >= m.join_date
	INNER JOIN menu mn
		ON s.product_id = mn.product_id)
SELECT customer_id, order_date, product_name
FROM cte
WHERE ranking = 1;
```
Result: 
| customer_id | order_date | product_name |
| ----------- | ---------- | ------------ |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |

### 7. Which item was purchased just before the customer became a member?
```sql
-- from sales create a cte table that:
	-- rank the order date of items of each customer in decending order
	-- inner join with members table and filter entries where order_date < join_date
	-- inner join with menu to get items' name
-- filter ranking = 1

WITH cte AS(
	SELECT 
		s.customer_id,
        product_name,
        order_date,
		RANK() OVER(
			PARTITION BY s.customer_id 
            ORDER BY order_date DESC) AS ranking
	FROM sales s
	INNER JOIN members m
		ON s.customer_id = m.customer_id  AND s.order_date < m.join_date
	INNER JOIN menu mn
		ON s.product_id = mn.product_id)
SELECT customer_id, order_date, product_name
FROM cte
WHERE ranking = 1;
```
Result:
| customer_id | order_date | product_name |
| ----------- | ---------- | ------------ |
| A           | 2021-01-01 | sushi        |
| A           | 2021-01-01 | curry        |
| B           | 2021-01-04 | sushi        |

### 8. What is the total items and amount spent for each member before they became a member?
```sql
-- from sales table inner join with members table and filter entries where order_date < join_date
-- inner join with menu to get items' price
-- count product_id and sum price group by customer_id

SELECT 
	s.customer_id,
	COUNT(DISTINCT s.product_id) AS total_items,
	SUM(price) AS total_amount
FROM sales s
INNER JOIN members m
	ON s.customer_id = m.customer_id  AND s.order_date < m.join_date
INNER JOIN menu mn
	ON s.product_id = mn.product_id
GROUP BY s.customer_id;
```
Result: 
| customer_id | total_items | total_amount |
| ----------- | ----------- | ------------ |
| A           | 2           | 25           |
| B           | 2           | 40           |

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
-- from sales create a cte table that:
	-- inner join with menu to get items' name and price
	-- calculate point column = price*10 except for sushi = price*20
-- sum point group by customer_id

WITH cte AS(
	SELECT
		customer_id,
		CASE
			WHEN product_name = 'sushi' THEN price * 20
			ELSE price * 10
		END AS point
	FROM sales s
	INNER JOIN menu m
		ON s.product_id = m.product_id)
SELECT customer_id, SUM(point) AS total_point
FROM cte
GROUP BY customer_id;
```
Result: 
| customer_id | total_point |
| ----------- | ----------- |
| A           | 860         |
| B           | 940         |
| C           | 360         |

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
-- from sales create a cte table that:
	-- inner join with members table and filter entries where order_date <= '2021-01-31'
	-- inner join with menu to get items' name and price
	-- calculate point column = price*10 except for sushi = price*20 or when join_date <= order_date <= join_date + 6
-- sum point group by customer_id

WITH cte AS(
	SELECT
		s.customer_id,
		CASE
			WHEN product_name = 'sushi' 
				OR order_date BETWEEN join_date AND join_date + 6
                THEN price * 20
			ELSE price * 10
		END AS point
	FROM sales s
    INNER JOIN members m
		ON s.customer_id = m.customer_id AND order_date <= '2021-01-31'
	INNER JOIN menu mn
		ON s.product_id = mn.product_id)
SELECT customer_id, SUM(point) AS total_point
FROM cte
GROUP BY customer_id;
```
Result: 
| customer_id | total_point |
| ----------- | ----------- |
| A           | 1370        |
| B           | 820         |

## Bonus Questions
### Join All The Things: 
Creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL
``` sql
-- from sales table left join with members and inner join with menu
-- create member column with 'Y' value if order_date >= join_date, else 'N'
-- order by customer_id, order_date, product_name

SELECT
	s.customer_id,
    order_date,
    product_name,
    price,
    CASE
		WHEN order_date >= join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM sales s
LEFT JOIN members m
	ON s.customer_id = m.customer_id
INNER JOIN menu mn
	ON s.product_id = mn.product_id
ORDER BY s.customer_id, order_date, product_name;
```
Result:
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
```sql
-- create a cte table same as the query above
-- create ranking column partition by customer_id, member, order by order_date

WITH cte AS(
	SELECT
		s.customer_id,
		order_date,
		product_name,
		price,
		CASE
			WHEN order_date >= join_date THEN 'Y'
			ELSE 'N'
		END AS member
	FROM sales s
	LEFT JOIN members m
		ON s.customer_id = m.customer_id
	INNER JOIN menu mn
		ON s.product_id = mn.product_id)
SELECT *,
	CASE
		WHEN member = 'Y' THEN
			RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
        ELSE NULL
    END AS ranking
FROM cte
ORDER BY s.customer_id, order_date, product_name;
```
Result:
| customer_id | order_date | product_name | price | member | ranking |
| ----------- | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01 | curry        | 15    | N      |         |
| A           | 2021-01-01 | sushi        | 10    | N      |         |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      |         |
| B           | 2021-01-02 | curry        | 15    | N      |         |
| B           | 2021-01-04 | sushi        | 10    | N      |         |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-07 | ramen        | 12    | N      |         |