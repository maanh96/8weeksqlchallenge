# Case Study #7 - Balanced Tree Clothing Co.

## B. Transaction Analysis

### 1. How many unique transactions were there?
``` sql
SELECT COUNT(DISTINCT txn_id) AS total_transactions
FROM sales;
```
Result:
| total_transactions |
| :----------------- |
| 2500               |

### 2. What is the average unique products purchased in each transaction?
``` sql
WITH cte AS(
	SELECT COUNT(prod_id) AS total_products
	FROM sales
	GROUP BY txn_id)
SELECT AVG(total_products) AS avg_products
FROM cte;
```
Result:
| avg_products |
| :----------- |
| 6.0380       |

### 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
``` sql
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
```
Result:
| percentile_25 | percentile_50 | percentile_75 |
| :------------ | :------------ | :------------ |
| 326.1800      | 441.0000      | 572.7500      |

### 4. What is the average discount value per transaction?
``` sql
WITH cte AS(
	SELECT SUM(qty * price * discount /100) AS total_discount
	FROM sales
	GROUP BY txn_id)
SELECT ROUND(AVG(total_discount), 2) AS avg_discount_per_txn
FROM cte;
```
Result:
| avg_discount_per_txn |
| :------------------- |
| 62.49                |

### 5. What is the percentage split of all transactions for members vs non-members?
``` sql
SELECT 
	member,
	COUNT(DISTINCT txn_id) AS total_transactions,
	ROUND(COUNT(DISTINCT txn_id)/ (SELECT COUNT(DISTINCT txn_id) FROM sales) *100, 2) AS transaction_percent
FROM sales
GROUP BY member;
```
Result:
| member | total_transactions | transaction_percent |
| :----- | :----------------- | :------------------ |
| 0      | 995                | 39.80               |
| 1      | 1505               | 60.20               |

### 6. What is the average revenue for member transactions and non-member transactions?
``` sql
WITH cte AS(
	SELECT
		txn_id,
		member,
		SUM(price * qty * (1-discount/100)) AS revenue
	FROM sales
	GROUP BY txn_id)
SELECT member, AVG(revenue) AS avg_revenue
FROM cte
GROUP BY member
```
Result:
| member | avg_revenue  |
| :----- | :----------- |
| 1      | 454.13696346 |
| 0      | 452.00776884 |

<br>

***
Let's move to [C. Product Analysis](./C.%20Product%20Analysis.md).
