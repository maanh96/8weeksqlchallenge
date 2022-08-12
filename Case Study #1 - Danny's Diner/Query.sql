/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
	-- from sales table inner join with menu on product_id to get items' price
	-- sum price group by customer_id
SELECT 
	customer_id,
    SUM(price) AS total_amount
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id 
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
	-- from sales table count distinct order_date group by customer_id
SELECT 
	customer_id,
    COUNT(DISTINCT order_date) AS total_day
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
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

-- 5. Which item was the most popular for each customer?
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

-- 6. Which item was purchased first by the customer after they became a member?
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

-- 7. Which item was purchased just before the customer became a member
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

-- 8. What is the total items and amount spent for each member before they became a member?
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

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
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

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
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


/* --------------------
   Bonus  Questions
   --------------------*/

-- Join All The Things: recreating basic data tables including: customer_id, order_date, product_name, price, member
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

-- Rank All The Things: ranking of customer products, for non-member purchases: null ranking values
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