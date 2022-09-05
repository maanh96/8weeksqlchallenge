/* --------------------
   Case Study Questions
   --------------------*/

-- A. High Level Sales Analysis --
-- 1. What was the total quantity sold for all products?
SELECT SUM(qty) AS total_quantity
FROM sales;

-- 2. What is the total generated revenue for all products before discounts?
SELECT SUM(price * qty) AS total_revenue_before_discounts
FROM sales;

-- 3. What was the total discount amount for all products?
SELECT SUM(price * qty * discount /100) AS total_discount
FROM sales;

-- B. Transaction Analysis --
-- 1. How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS total_transactions
FROM sales;

-- 2. What is the average unique products purchased in each transaction?
WITH cte AS(
	SELECT COUNT(prod_id) AS total_products
	FROM sales
	GROUP BY txn_id)
SELECT AVG(total_products) AS avg_products
FROM cte;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
	-- use PERCENT_RANK() to find the percentile of revenue (after discount)
    -- use FIRST_VALUE() AND CASE to find out revenue that have percentile is smaller and nearest to 0.25, 0.5 and 0.75
WITH cte AS(
	SELECT
		txn_id,
		SUM(qty * price * (1-discount/100)) AS revenue,
        PERCENT_RANK() OVER(ORDER BY SUM(qty * price * (1-discount/100))) AS percentile
	FROM sales
	GROUP BY txn_id)
SELECT DISTINCT
	FIRST_VALUE(revenue) OVER(ORDER BY CASE WHEN percentile <= 0.25 THEN percentile END DESC) AS percentile_25,
    FIRST_VALUE(revenue) OVER(ORDER BY CASE WHEN percentile <= 0.5 THEN percentile END DESC) AS percentile_50,
    FIRST_VALUE(revenue) OVER(ORDER BY CASE WHEN percentile <= 0.75 THEN percentile END DESC) AS percentile_75
FROM cte;

-- 4. What is the average discount value per transaction?
WITH cte AS(
	SELECT SUM(qty * price * discount /100) AS total_discount
	FROM sales
	GROUP BY txn_id)
SELECT ROUND(AVG(total_discount), 2) AS avg_discount_per_txn
FROM cte;

-- 5. What is the percentage split of all transactions for members vs non-members?
SELECT 
	member,
	COUNT(DISTINCT txn_id) AS total_transactions,
	ROUND(COUNT(DISTINCT txn_id)/ (SELECT COUNT(DISTINCT txn_id) FROM sales) *100, 2) AS transaction_percent
FROM sales
GROUP BY member;

-- 6. What is the average revenue for member transactions and non-member transactions?
WITH cte AS(
	SELECT
		txn_id,
		member,
		SUM(price * qty * (1-discount/100)) AS revenue
	FROM sales
	GROUP BY txn_id)
SELECT member, AVG(revenue) AS avg_revenue
FROM cte
GROUP BY member;

-- C. Product Analysis --
-- 1. What are the top 3 products by total revenue before discount?
SELECT
	product_name,
    SUM(qty * s.price) AS revenue_before_discount
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY s.prod_id
ORDER BY revenue_before_discount DESC
LIMIT 3;

-- 2. What is the total quantity, revenue and discount for each segment?
SELECT
	segment_name,
    SUM(qty) AS total_quantity,
    ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS total_revenue,
    ROUND(SUM(qty * s.price * discount/100), 2) AS total_discount
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.segment_id;

-- 3. What is the top selling product for each segment?
WITH cte AS(
	SELECT
		segment_name,
		product_name,
		SUM(qty) AS total_quantity,
		RANK() OVER(PARTITION BY segment_id ORDER BY SUM(qty) DESC) AS ranking
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY s.prod_id)
SELECT segment_name, product_name, total_quantity
FROM cte
WHERE ranking = 1;

-- 4. What is the total quantity, revenue and discount for each category?
SELECT
	category_name,
    SUM(qty) AS total_quantity,
    ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS total_revenue,
    ROUND(SUM(qty * s.price * discount/100), 2) AS total_discount
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.category_id;

-- 5. What is the top selling product for each category?
WITH cte AS(
	SELECT
		category_name,
		product_name,
		SUM(qty) AS total_quantity,
		RANK() OVER(PARTITION BY category_id ORDER BY SUM(qty) DESC) AS ranking
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY s.prod_id)
SELECT category_name, product_name, total_quantity
FROM cte
WHERE ranking = 1;

-- 6. What is the percentage split of revenue by product for each segment?
WITH cte AS(
	SELECT
		segment_name,
		product_name,
		ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS revenue
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY p.product_id)
SELECT *, ROUND(revenue/ SUM(revenue) OVER(PARTITION BY segment_name)*100, 2) AS revenue_percent
FROM cte;

-- 7. What is the percentage split of revenue by segment for each category?
WITH cte AS(
	SELECT
		category_name,
		segment_name,
		ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS revenue
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY p.segment_id)
SELECT *, ROUND(revenue/ SUM(revenue) OVER(PARTITION BY category_name)*100, 2) AS revenue_percent
FROM cte;

-- 8. What is the percentage split of total revenue by category?
SELECT 
	category_name,
	ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS revenue,
	ROUND(SUM(qty * s.price * (1-discount/100))/ (SUM(SUM(qty * s.price * (1-discount/100))) OVER()) *100, 2) AS transaction_percent    
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY category_name;

-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
SELECT
	product_name,
    ROUND(COUNT(prod_id)/ (SELECT COUNT(DISTINCT txn_id) FROM sales) *100, 2) AS penetration_rate
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY prod_id;

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
	-- from sales join product_details to create a cte table to select txn_id, prod_id and product_name
    -- we get the combination of 3 product by inner join (by txn.id) cte with itself 2 times
    -- to get only the distinct combination we add join condition so that c1.prod_id < c2.prod_id < c3.prod_id
    -- count the combination and sort in descending order, limit 1 to get the most common
WITH cte AS(
	SELECT txn_id, prod_id, product_name
    FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id)
SELECT c1.product_name, c2.product_name, c3.product_name, COUNT(*) AS total_transaction
FROM cte c1
INNER JOIN cte c2
	ON c1.txn_id = c2.txn_id AND c1.prod_id < c2.prod_id
INNER JOIN cte c3
	ON c1.txn_id = c3.txn_id AND c2.prod_id < c3.prod_id
GROUP BY c1.prod_id, c2.prod_id, c3.prod_id
ORDER BY total_transaction DESC
LIMIT 1;

-- D. Reporting Challenge --
-- Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.
-- Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.
-- He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).
-- Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

-- Part A
SELECT
	SUM(qty) AS total_quantity,
    SUM(price * qty) AS total_revenue_before_discounts,
    SUM(price * qty * discount /100) AS total_discount
FROM sales
WHERE DATE_FORMAT(start_txn_time, '%Y%m') = '202101';

-- Part B
WITH cte AS(
	SELECT txn_id,
		COUNT(prod_id) AS total_products,
        SUM(qty * price * (1-discount/100)) AS revenue,
        PERCENT_RANK() OVER(ORDER BY SUM(qty * price * (1-discount/100))) AS percentile,
        SUM(qty * price * discount /100) AS total_discount,
        CASE WHEN member = true THEN txn_id END AS member_transaction,
        CASE WHEN member = false THEN txn_id END AS non_member_transaction,
        CASE WHEN member = true THEN SUM(qty * price * (1-discount/100)) END AS member_revenue,
        CASE WHEN member = false THEN SUM(qty * price * (1-discount/100)) END AS non_member_revenue
	FROM sales
    WHERE DATE_FORMAT(start_txn_time, '%Y%m') = '202101'
	GROUP BY txn_id),
cte2 AS(
	SELECT *,
		FIRST_VALUE(revenue) OVER(ORDER BY CASE WHEN percentile <= 0.25 THEN percentile END DESC) AS percentile_25,
		FIRST_VALUE(revenue) OVER(ORDER BY CASE WHEN percentile <= 0.5 THEN percentile END DESC) AS percentile_50,
		FIRST_VALUE(revenue) OVER(ORDER BY CASE WHEN percentile <= 0.75 THEN percentile END DESC) AS percentile_75
	FROM cte)
SELECT 
	COUNT(DISTINCT txn_id) AS total_transactions,
    AVG(total_products) AS avg_products,
    percentile_25, percentile_50, percentile_75,
    ROUND(AVG(total_discount), 2) AS avg_discount_per_txn,
    ROUND(COUNT(DISTINCT member_transaction) / COUNT(DISTINCT txn_id) * 100, 2) AS member_percent,
    ROUND(COUNT(DISTINCT non_member_transaction) / COUNT(DISTINCT txn_id) * 100, 2) AS non_member_percent,
    ROUND(AVG(member_revenue), 2) AS avg_member_revenue,
    ROUND(AVG(non_member_revenue), 2) AS avg_non_member_revenue
FROM cte2;

-- E. Bonus Challenge --
-- Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
DROP TABLE IF EXISTS product_details_temp;
CREATE TEMPORARY TABLE product_details_temp
SELECT 
	product_id, 
    price,
    CONCAT(h1.level_text, ' ', h2.level_text, ' - ', h3.level_text) AS product_name,
    h3.id AS category_id,
    h2.id AS segment_id,
    p.id AS style_id, 
    h3.level_text AS category_name,
    h2.level_text AS segment_name,
    h1.level_text AS style_name
FROM product_prices p
INNER JOIN product_hierarchy h1
	ON p.id = h1.id
INNER JOIN product_hierarchy h2
	ON h1.parent_id = h2.id
INNER JOIN product_hierarchy h3
	ON h2.parent_id = h3.id
ORDER BY category_id, segment_id, style_id;
SELECT * FROM product_details_temp;
