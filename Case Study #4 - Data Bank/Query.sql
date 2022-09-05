/* --------------------
   Case Study Questions
   --------------------*/

-- A. Customer Nodes Exploration --
-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) unique_nodes
FROM customer_nodes;

-- 2. What is the number of nodes per region?
SELECT
	region_name,
    COUNT(*) AS total_nodes
FROM customer_nodes c
INNER JOIN regions r
	ON c.region_id = r.region_id
GROUP BY c.region_id;

-- 3. How many customers are allocated to each region?
SELECT
	region_name,
    COUNT(DISTINCT customer_id) AS total_customers
FROM customer_nodes c
INNER JOIN regions r
	ON c.region_id = r.region_id
GROUP BY c.region_id;

-- 4. How many days on average are customers reallocated to a different node?
	-- nodes are randomly distributed so there are cases when after reallocate (new row), customers still get the same node
    -- we will create a temporary table to combine those to one row from first start_date to last end_date of the same node
    -- filter out end_date = '9999-12-31' before calculating so that it does not effect our average result			
DROP TABLE IF EXISTS customer_nodes_temp;
CREATE TEMPORARY TABLE customer_nodes_temp
WITH cte AS(
	SELECT
		*,
		LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_node,
		LEAD(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_node
        FROM customer_nodes),
start AS(
	SELECT *, ROW_NUMBER() OVER() AS round
	FROM cte
	WHERE prev_node IS NULL OR node_id != prev_node),
end AS(
	SELECT *, ROW_NUMBER() OVER() AS round
    FROM cte
    WHERE next_node IS NULL OR node_id != next_node)
SELECT s.customer_id, region_name, s.node_id, s.start_date, e.end_date, DATEDIFF(e.end_date, s.start_date) AS total_reallocate_days
FROM start s
INNER JOIN end e
	ON s.round = e.round
INNER JOIN regions r
	ON s.region_id = r.region_id
WHERE e.end_date != '9999-12-31'
ORDER BY s.customer_id, s.start_date;

	-- caculate average reallocate day using created temp table
SELECT ROUND(AVG(total_reallocate_days), 2) AS avg_allocate_day
FROM customer_nodes_temp;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
	-- use PERCENT_RANK() to find the percentile of each reallocation days for each region
    -- use FIRST_VALUE() AND CASE to find out the day that have percentile is smaller and nearest to 0.5, 0.8 and 0.95
 WITH cte AS(
	SELECT DISTINCT
		region_name,
        total_reallocate_days,
		PERCENT_RANK() OVER(PARTITION BY region_name ORDER BY total_reallocate_days) AS percentile
	FROM customer_nodes_temp)
SELECT DISTINCT
	region_name,
	FIRST_VALUE(total_reallocate_days) OVER(PARTITION BY region_name ORDER BY CASE WHEN percentile <= 0.50 THEN percentile END DESC) AS median,
	FIRST_VALUE(total_reallocate_days) OVER(PARTITION BY region_name ORDER BY CASE WHEN percentile <= 0.80 THEN percentile END DESC) AS percentile_80,
	FIRST_VALUE(total_reallocate_days) OVER(PARTITION BY region_name ORDER BY CASE WHEN percentile <= 0.95 THEN percentile END DESC) AS percentile_95
FROM cte;

-- B. Customer Transactions --
-- 1. What is the unique count and total amount for each transaction type?
SELECT
	txn_type,
    COUNT(*) AS count,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?
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

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
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

-- 4. What is the closing balance for each customer at the end of the month?
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

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
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

-- C. Data Allocation Challenge
-- To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:
	-- Option 1: data is allocated based off the amount of money at the end of the previous month
	-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
	-- Option 3: data is updated real-time
-- For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:
	-- running customer balance column that includes the impact each transaction
	-- customer balance at the end of each month
	-- minimum, average and maximum values of the running balance for each customer
-- Using all of the data available - how much data would have been required for each option on a monthly basis?

	-- create running_cte to calculate the impact each transaction
DROP TABLE IF EXISTS running_cte;
CREATE TEMPORARY TABLE running_cte
WITH RECURSIVE month_cte(customer_id, month) AS(
	SELECT
		customer_id,
        MIN(MONTH(txn_date)) FROM customer_transactions GROUP BY customer_id
    UNION ALL
    SELECT 
		customer_id,
        month + 1 FROM month_cte
    WHERE month + 1 <= (SELECT MAX(MONTH(txn_date)) FROM customer_transactions)),
value_cte AS(
	SELECT *,
		CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END AS transaction_value
	FROM customer_transactions),
running_cte AS(
	SELECT customer_id, MONTH(txn_date) AS month, txn_date, transaction_value,
		SUM(transaction_value) OVER(PARTITION BY customer_id ORDER BY txn_date ROWS UNBOUNDED PRECEDING) AS running_balance
	FROM value_cte)
SELECT m.customer_id, m.month, txn_date, transaction_value, 
		COALESCE(running_balance, 
				LAG(running_balance) OVER(PARTITION BY customer_id ORDER BY month)) AS running_balance
	FROM month_cte m
	LEFT JOIN running_cte r
		ON m.customer_id = r.customer_id AND m.month = r.month;
SELECT * FROM running_cte;

	-- create month_cte to calculate closing balance, maximum and average running balance of each month
DROP TABLE IF EXISTS month_cte;
CREATE TEMPORARY TABLE month_cte
SELECT DISTINCT customer_id, month,
		LAST_VALUE(running_balance) OVER(PARTITION BY customer_id, month ORDER BY txn_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS closing_balance,
		ROUND(AVG(running_balance) OVER(PARTITION BY customer_id, month ORDER BY txn_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) AS avg_balance,
		MAX(running_balance) OVER(PARTITION BY customer_id, month ORDER BY txn_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_balance
FROM running_cte;
SELECT * FROM month_cte LIMIT 10;

	-- calculated data per option
WITH data_cte AS(
	SELECT *,
		GREATEST(LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY month), 0) AS option_1,
		GREATEST(LAG(avg_balance) OVER(PARTITION BY customer_id ORDER BY month), 0) AS option_2,
		GREATEST(max_balance, 0) AS option_3
	FROM month_cte)
SELECT month, SUM(option_1) AS option_1, SUM(option_2) AS option_2, SUM(option_3) AS option_3
FROM data_cte
GROUP BY month;

-- D. Extra Challenge
-- Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.
-- If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

WITH RECURSIVE month_cte(customer_id, month, day, transaction_value) AS(
	SELECT
		customer_id,
        MIN(MONTH(txn_date)),
		SUBDATE(ADDDATE(LAST_DAY(txn_date), INTERVAL 1 DAY), INTERVAL 1 MONTH),
        NULL
    FROM customer_transactions GROUP BY customer_id
    UNION ALL
    SELECT 
		customer_id,
        month + 1,
        ADDDATE(day, INTERVAL 1 MONTH),
        NULL
	FROM month_cte
    WHERE month + 1 <= (SELECT MAX(MONTH(txn_date)) FROM customer_transactions)),
value_cte AS(
	SELECT customer_id, MONTH(txn_date) AS month, txn_date,
		CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END AS transaction_value
	FROM customer_transactions),
union_cte AS(
	SELECT *
	FROM month_cte
	UNION
	SELECT *
	FROM value_cte
	ORDER BY customer_id, month, day),
running_cte AS(
	SELECT customer_id, month, day, transaction_value, 
		SUM(transaction_value) OVER(PARTITION BY customer_id ORDER BY day ROWS UNBOUNDED PRECEDING) AS running_balance,
		DATEDIFF(COALESCE(LEAD(day) OVER(PARTITION BY customer_id ORDER BY day), '2020-05-01'), day) AS date_diff
	FROM union_cte),
interest_cte AS(
	SELECT *,
		GREATEST(running_balance*date_diff*0.06/365, 0) AS data_interest
	FROM running_cte),
data_cte AS(
	SELECT *,
			SUM(data_interest) OVER(PARTITION BY customer_id ORDER BY day ROWS UNBOUNDED PRECEDING) AS acc_data_interest,
			GREATEST(running_balance, 0) + SUM(data_interest) OVER(PARTITION BY customer_id ORDER BY day ROWS UNBOUNDED PRECEDING) AS current_data_allocated
	FROM interest_cte),
month_data_cte AS(
	SELECT customer_id, month, MAX(current_data_allocated) AS max_data_allocated
	FROM data_cte
	GROUP BY customer_id, month)
SELECT month, ROUND(SUM(max_data_allocated)) AS option_4
FROM month_data_cte
GROUP BY month;
