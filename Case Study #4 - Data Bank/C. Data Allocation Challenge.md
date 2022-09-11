# Case Study #4 - Data Bank

## C. Data Allocation Challenge

<p>To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:</p>

<ul>
  <li>Option 1: data is allocated based off the amount of money at the end of the previous month</li>
  <li>Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days</li>
  <li>Option 3: data is updated real-time</li>
</ul>

<p>For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:</p>

<ul>
  <li>running customer balance column that includes the impact each transaction</li>
  <li>customer balance at the end of each month</li>
  <li>minimum, average and maximum values of the running balance for each customer</li>
</ul>

<p>Using all of the data available - how much data would have been required for each option on a monthly basis?</p>

***

<br>
From the description of each option, we note that:

* For option 1 and 2, data is allocated based on previous month so here we assume the data for first month will be 0 while in reality, customer should be allocated a fixed amount of data for their first month
* Option 2 data allocated would be equal to the average running balance of previous month while for option 3, the data is updated real-time so we will calculate the data required by the maximum running balance of current month
* For all 3 options, when customer don't make any transaction in a month, their balance remain the same with previous month so we will calculated data for that month based on the closing balance of previous month
* Another note is that when the balance is negative, the data allocated will be 0.

Now, let's calculate the required information. First, we create `running_cte` table to calculate the impact each transaction.

```sql
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
```
Result:
| customer_id | month | txn_date   | transaction_value | running_balance |
| :---------- | :---- | :--------- | :---------------- | :-------------- |
| 1           | 1     | 2020-01-02 | 312               | 312             |
| 1           | 2     |            |                   | 312             |
| 1           | 3     | 2020-03-05 | -612              | -300            |
| 1           | 3     | 2020-03-17 | 324               | 24              |
| 1           | 3     | 2020-03-19 | -664              | -640            |
| 1           | 4     |            |                   | -640            |
| 2           | 1     | 2020-01-03 | 549               | 549             |
| 2           | 2     |            |                   | 549             |
| 2           | 3     | 2020-03-24 | 61                | 610             |
| 2           | 4     |            |                   | 610             |
| ...         | ...   | ...        | ...               | ....            |

<br>

Next we create `month_cte` to calculate closing balance, average running balance and maximum running balance of each month.

```sql
DROP TABLE IF EXISTS month_cte;

CREATE TEMPORARY TABLE month_cte
SELECT DISTINCT customer_id, month,
		LAST_VALUE(running_balance) OVER(PARTITION BY customer_id, month ORDER BY txn_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS closing_balance,
		ROUND(AVG(running_balance) OVER(PARTITION BY customer_id, month ORDER BY txn_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) AS avg_balance,
		MAX(running_balance) OVER(PARTITION BY customer_id, month ORDER BY txn_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_balance
FROM running_cte;

SELECT * FROM month_cte;
```
| customer_id | month | closing_balance | avg_balance | max_balance |
| :---------- | :---- | :-------------- | :---------- | :---------- |
| 1           | 1     | 312             | 312         | 312         |
| 1           | 2     | 312             | 312         | 312         |
| 1           | 3     | -640            | -305        | 24          |
| 1           | 4     | -640            | -640        | -640        |
| 2           | 1     | 549             | 549         | 549         |
| 2           | 2     | 549             | 549         | 549         |
| 2           | 3     | 610             | 610         | 610         |
| 2           | 4     | 610             | 610         | 610         |
| 3           | 1     | 144             | 144         | 144         |
| 3           | 2     | -821            | -821        | -821        |
| ...         | ...   | ...             | ...         | ...         |

Finally, we calculate the data required for each option.

```sql
WITH data_cte AS(
	SELECT *,
		GREATEST(LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY month), 0) AS option_1,
		GREATEST(LAG(avg_balance) OVER(PARTITION BY customer_id ORDER BY month), 0) AS option_2,
		GREATEST(max_balance, 0) AS option_3
	FROM month_cte)
SELECT month, SUM(option_1) AS option_1, SUM(option_2) AS option_2, SUM(option_3) AS option_3
FROM data_cte
GROUP BY month;
```
Result:
| month | option_1 | option_2 | option_3 |
| :---- | :------- | :------- | :------- |
| 1     |          |          | 369041   |
| 2     | 235595   | 224542   | 377065   |
| 3     | 261508   | 254231   | 370593   |
| 4     | 258207   | 254194   | 282682   |

***
Finally, let's move to [D. Extra Challenge](./D.%20Extra%20Challenge.md).
