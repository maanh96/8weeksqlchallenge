# Case Study #4 - Data Bank

## D. Extra Challenge

<p>Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.</p>

<p>If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?</p>

<p>Special notes:</p>

<ul>
  <li>Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!</li>
</ul>

***

<br>

Data Bank team want to calculated data growth using simple interest at 6% annually and interest is calculated on daily basis so we need to find:

* Running balance of each transaction
* Data interest for each balance in period from the day of this transaction to the next (when the balance is changed)
* Since data calculated on monthly basis, we need to include rows for the first day of each month (even the month when no transaction occured) and calculated the data interest accordingly.

So first we use recursive CTE to generate rows of first day of each month and then union with the `value_cte` calculated from `customer_transactions` table.

```sql
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

-- to be continued -- 
```
Result of `union_cte`:
| customer_id | month | day        | transaction_value |
| :---------- | :---- | :--------- | :---------------- |
| 1           | 1     | 2020-01-01 |                   |
| 1           | 1     | 2020-01-02 | 312               |
| 1           | 2     | 2020-02-01 |                   |
| 1           | 3     | 2020-03-01 |                   |
| 1           | 3     | 2020-03-05 | -612              |
| 1           | 3     | 2020-03-17 | 324               |
| 1           | 3     | 2020-03-19 | -664              |
| 1           | 4     | 2020-04-01 |                   |
| 2           | 1     | 2020-01-01 |                   |
| 2           | 1     | 2020-01-03 | 549               |
| 2           | 2     | 2020-02-01 |                   |
| 2           | 3     | 2020-03-01 |                   |
| 2           | 3     | 2020-03-24 | 61                |
| 2           | 4     | 2020-04-01 |                   |
| 3           | 1     | 2020-01-01 |                   |
| 3           | 1     | 2020-01-27 | 144               |
| 3           | 2     | 2020-02-01 |                   |
| 3           | 2     | 2020-02-22 | -965              |
| 3           | 3     | 2020-03-01 |                   |
| 3           | 3     | 2020-03-05 | -213              |
| ...         | ...   | ...        | ...               |

Next, we create a `running_cte` table to find running balance and date difference between each time point for interest calculation.
```sql
-- continue from previous syntax --

running_cte AS(
	SELECT customer_id, month, day, transaction_value, 
		SUM(transaction_value) OVER(PARTITION BY customer_id ORDER BY day ROWS UNBOUNDED PRECEDING) AS running_balance,
		DATEDIFF(COALESCE(LEAD(day) OVER(PARTITION BY customer_id ORDER BY day), '2020-05-01'), day) AS date_diff
	FROM union_cte),

-- to be continued --
```
Result of `running_cte`:
| customer_id | month | day        | transaction_value | running_balance | date_diff |
| :---------- | :---- | :--------- | :---------------- | :-------------- | :-------- |
| 1           | 1     | 2020-01-01 |                   |                 | 1         |
| 1           | 1     | 2020-01-02 | 312               | 312             | 30        |
| 1           | 2     | 2020-02-01 |                   | 312             | 29        |
| 1           | 3     | 2020-03-01 |                   | 312             | 4         |
| 1           | 3     | 2020-03-05 | -612              | -300            | 12        |
| 1           | 3     | 2020-03-17 | 324               | 24              | 2         |
| 1           | 3     | 2020-03-19 | -664              | -640            | 13        |
| 1           | 4     | 2020-04-01 |                   | -640            | 30        |
| 2           | 1     | 2020-01-01 |                   |                 | 2         |
| 2           | 1     | 2020-01-03 | 549               | 549             | 29        |
| 2           | 2     | 2020-02-01 |                   | 549             | 29        |
| 2           | 3     | 2020-03-01 |                   | 549             | 23        |
| 2           | 3     | 2020-03-24 | 61                | 610             | 8         |
| 2           | 4     | 2020-04-01 |                   | 610             | 30        |
| 3           | 1     | 2020-01-01 |                   |                 | 26        |
| 3           | 1     | 2020-01-27 | 144               | 144             | 5         |
| 3           | 2     | 2020-02-01 |                   | 144             | 21        |
| 3           | 2     | 2020-02-22 | -965              | -821            | 8         |
| 3           | 3     | 2020-03-01 |                   | -821            | 4         |
| 3           | 3     | 2020-03-05 | -213              | -1034           | 14        |
| ...         | ...   | ...        | ...               | ...             | ...       |

Following, we calculate data interest for each period then sum using window function to get accumulated data interest amount. We then add `acc_data_interest` with current running balance to get the total data allocated each time.

```sql
-- continue from previous syntax --

interest_cte AS(
	SELECT *,
		GREATEST(running_balance*date_diff*0.06/365, 0) AS data_interest
	FROM running_cte),

data_cte AS(
	SELECT *,
			SUM(data_interest) OVER(PARTITION BY customer_id ORDER BY day ROWS UNBOUNDED PRECEDING) AS acc_data_interest,
			GREATEST(running_balance, 0) + SUM(data_interest) OVER(PARTITION BY customer_id ORDER BY day ROWS UNBOUNDED PRECEDING) AS current_data_allocated
	FROM interest_cte),

-- to be continued --
```
Result of `data_cte`:
| customer_id | month | day        | transaction_value | running_balance | date_diff | data_interest       | acc_data_interest   | current_data_allocated |
| :---------- | :---- | :--------- | :---------------- | :-------------- | :-------- | :------------------ | :------------------ | :--------------------- |
| 1           | 1     | 2020-01-01 |                   |                 | 1         |                     |                     |                        |
| 1           | 1     | 2020-01-02 | 312               | 312             | 30        | 1.5386301369863014  | 1.5386301369863014  | 313.5386301369863      |
| 1           | 2     | 2020-02-01 |                   | 312             | 29        | 1.4873424657534247  | 3.025972602739726   | 315.0259726027397      |
| 1           | 3     | 2020-03-01 |                   | 312             | 4         | 0.20515068493150684 | 3.231123287671233   | 315.2311232876712      |
| 1           | 3     | 2020-03-05 | -612              | -300            | 12        | 0                   | 3.231123287671233   | 3.231123287671233      |
| 1           | 3     | 2020-03-17 | 324               | 24              | 2         | 0.00789041095890411 | 3.2390136986301368  | 27.23901369863014      |
| 1           | 3     | 2020-03-19 | -664              | -640            | 13        | 0                   | 3.2390136986301368  | 3.2390136986301368     |
| 1           | 4     | 2020-04-01 |                   | -640            | 30        | 0                   | 3.2390136986301368  | 3.2390136986301368     |
| 2           | 1     | 2020-01-01 |                   |                 | 2         |                     |                     |                        |
| 2           | 1     | 2020-01-03 | 549               | 549             | 29        | 2.6171506849315067  | 2.6171506849315067  | 551.6171506849315      |
| 2           | 2     | 2020-02-01 |                   | 549             | 29        | 2.6171506849315067  | 5.234301369863013   | 554.234301369863       |
| 2           | 3     | 2020-03-01 |                   | 549             | 23        | 2.0756712328767124  | 7.309972602739726   | 556.3099726027398      |
| 2           | 3     | 2020-03-24 | 61                | 610             | 8         | 0.8021917808219179  | 8.112164383561645   | 618.1121643835617      |
| 2           | 4     | 2020-04-01 |                   | 610             | 30        | 3.0082191780821916  | 11.120383561643836  | 621.1203835616438      |
| 3           | 1     | 2020-01-01 |                   |                 | 26        |                     |                     |                        |
| 3           | 1     | 2020-01-27 | 144               | 144             | 5         | 0.11835616438356163 | 0.11835616438356163 | 144.11835616438356     |
| 3           | 2     | 2020-02-01 |                   | 144             | 21        | 0.4970958904109589  | 0.6154520547945206  | 144.61545205479453     |
| 3           | 2     | 2020-02-22 | -965              | -821            | 8         | 0                   | 0.6154520547945206  | 0.6154520547945206     |
| 3           | 3     | 2020-03-01 |                   | -821            | 4         | 0                   | 0.6154520547945206  | 0.6154520547945206     |
| 3           | 3     | 2020-03-05 | -213              | -1034           | 14        | 0                   | 0.6154520547945206  | 0.6154520547945206     |
| ...         | ...   | ....       | ...               | ...             | ...       | ...                 | ...                 | ...                    |

Finally we query the max data allocated of each month of each customer and then sum group by month to get the data required on monthly basis for option 4.

```sql
-- continue from previous syntax --

month_data_cte AS(
	SELECT customer_id, month, MAX(current_data_allocated) AS max_data_allocated
	FROM data_cte
	GROUP BY customer_id, month)
SELECT month, ROUND(SUM(max_data_allocated)) AS option_4
FROM month_data_cte
GROUP BY month;
```
Result:
| month | option_4 |
| :---- | :------- |
| 1     | 369626   |
| 2     | 415274   |
| 3     | 409053   |
| 4     | 321200   |

<br>

***
~ This is the end of Case Study 4 ~

Back to [Main menu](https://github.com/maanh96/8weeksqlchallenge).
