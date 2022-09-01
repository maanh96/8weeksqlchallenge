# Case Study #4 - Data Bank

## B. Customer Transactions

### 1. What is the unique count and total amount for each transaction type?
``` sql
SELECT
	txn_type,
    COUNT(*) AS count,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;
```
Result:
| txn_type   | count | total_amount |
| :--------- | :---- | :----------- |
| deposit    | 2671  | 1359168      |
| withdrawal | 1580  | 793003       |
| purchase   | 1617  | 806537       |

### 2. What is the average total historical deposit counts and amounts for all customers?
``` sql
WITH cte AS(
	SELECT
		customer_id,
		COUNT(*) AS count,
		AVG(txn_amount) AS amount
	FROM customer_transactions
    WHERE txn_type = 'deposit'
	GROUP BY customer_id)
SELECT ROUND(AVG(count)) AS avg_deposit_count, ROUND(AVG(amount), 2) AS avg_deposit_amount
FROM cte;
```
Result:
| avg_deposit_count | avg_deposit_amount |
| :---------------- | :----------------- |
| 5                 | 508.61             |
### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
``` sql
WITH cte AS(
	SELECT
		customer_id,
		MONTH(txn_date) AS month,
		SUM(CASE WHEN txn_type = 'deposit' THEN 1 END) AS total_deposit,
		SUM(CASE WHEN txn_type IN ('purchase', 'withdrawal') THEN 1 END) AS purchase_withdrawal
	FROM customer_transactions
	GROUP BY customer_id, month)
SELECT month, COUNT(customer_id) AS customer_count
FROM cte
WHERE total_deposit > 1 AND purchase_withdrawal >= 1
GROUP BY month;
```
Result:
| month | customer_count |
| :---- | :------------- |
| 1     | 168            |
| 3     | 192            |
| 4     | 70             |
| 2     | 181            |

### 4. What is the closing balance for each customer at the end of the month?
``` sql
-- use recursive cte to add row of month that don't have any transaction
-- left join with amount_cte to caculate closing balance

DROP TABLE IF EXISTS monthly_balance;
CREATE TEMPORARY TABLE monthly_balance
WITH RECURSIVE month_cte(customer_id, month) AS(
	SELECT
		customer_id,
        MIN(MONTH(txn_date)) FROM customer_transactions GROUP BY customer_id
    UNION ALL
    SELECT 
		customer_id,
        month + 1 FROM month_cte
    WHERE month + 1 <= (SELECT MAX(MONTH(txn_date)) FROM customer_transactions)),

amount_cte AS(
	SELECT
		customer_id,
		MONTH(txn_date) AS month,
		SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) AS monthly_amount
	FROM customer_transactions
	GROUP BY customer_id, month)

SELECT m.customer_id, m.month, monthly_amount,
	SUM(monthly_amount) OVER(PARTITION BY customer_id ORDER BY month RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
FROM month_cte m
LEFT JOIN amount_cte a
	ON m.customer_id = a.customer_id AND m.month = a.month
ORDER BY m.customer_id, m.month;

SELECT * FROM monthly_balance;
```
Result:
| customer_id | month | monthly_amount | closing_balance |
| :---------- | :---- | :------------- | :-------------- |
| 1           | 1     | 312            | 312             |
| 1           | 2     |                | 312             |
| 1           | 3     | -952           | -640            |
| 1           | 4     |                | -640            |
| 2           | 1     | 549            | 549             |
| 2           | 2     |                | 549             |
| 2           | 3     | 61             | 610             |
| 2           | 4     |                | 610             |
| 3           | 1     | 144            | 144             |
| 3           | 2     | -965           | -821            |
| 3           | 3     | -401           | -1222           |
| 3           | 4     | 493            | -729            |
| ...         | ...   | ...            | ...             |

### 5. What is the percentage of customers who increase their closing balance by more than 5%?
``` sql
-- for the 5% increase index to be meaningful, we will count only the customer that they have at least one month where closing balance is increased by more than 5% and the previous balance is positive

WITH cte AS(
	SELECT *,
		CASE WHEN LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY month) > 0
			THEN monthly_amount / LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY month) * 100 
		END AS change_percent
	FROM monthly_balance)
SELECT ROUND(COUNT(DISTINCT customer_id)/ (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions)*100, 2) AS customer_increase_percent
FROM cte
WHERE change_percent >= 5;
```
Result:
| customer_increase_percent |
| :------------------------ |
| 37.00                     |

<br>

***
Let's move to [C. Data Allocation Challenge](./C.%20Data%20Allocation%20Challenge.md).
