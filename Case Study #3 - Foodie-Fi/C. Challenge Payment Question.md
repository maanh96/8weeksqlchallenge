# Case Study #3 - Foodie-Fi

## C. Challenge Payment Question
The Foodie-Fi team wants you to create a new <code class="language-plaintext highlighter-rouge">payments</code> table for the year 2020 that includes amounts paid by each customer in the <code class="language-plaintext highlighter-rouge">subscriptions</code> table with the following requirements:</p>

<ul>
  <li>monthly payments always occur on the same day of month as the original <code class="language-plaintext highlighter-rouge">start_date</code> of any monthly paid plan</li>
  <li>upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately</li>
  <li>upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period</li>
  <li>once a customer churns they will no longer make payments</li>
</ul>

<br>

First let's create a `subscriptions_temp_2020` temporary table to cut off entries in desired period.
```sql
-- first we create a temporary table to store only entries in 2020 and create last_date column to cut off in '2020-12-31' 
DROP TABLE IF EXISTS subscriptions_temp_2020;
CREATE TEMPORARY TABLE subscriptions_temp_2020
SELECT 
	customer_id,
    plan_id,
    plan_name,
    price,
    start_date,
    CASE
		WHEN end_date IS NULL OR end_date > '2020-12-31' THEN '2020-12-31'
        ELSE end_date
    END AS last_date
 FROM subscriptions_temp
 WHERE plan_id IN (1, 2, 3) AND start_date <= '2020-12-31';
 ```

In this case, we need to generate additional rows for `payment_date`, after research I found one solution is using [Recursive Common Table Expressions](https://dev.mysql.com/doc/refman/8.0/en/with.html#common-table-expressions-recursive). 

Another point to note is case that upgraded from basic to pro monthly/annual will start immediately and amount will reduced by the current paid amount in that month. For this requirement, we will use `CASE` to check if the current payment date is within a month from the previous payment date.
```sql
-- create 2020 payments table using recursive cte to generate all payment date based on plan type and last_date
-- calculate paid amount with note that case upgrade from basic to pro monthly/annual will start immediately and amount will reduced by the current paid amount in that month
DROP TABLE IF EXISTS payments;
CREATE TABLE payments
WITH RECURSIVE cte(customer_id, plan_id, plan_name, price, payment_date, last_date) AS(
	SELECT
		customer_id,
		plan_id,
		plan_name,
		price,
		start_date,
        last_date
	FROM subscriptions_temp_2020
    UNION ALL
    SELECT
		customer_id,
		plan_id,
		plan_name,
		price,
		CASE
			WHEN plan_id IN (1, 2) THEN ADDDATE(payment_date, INTERVAL 1 MONTH)
            ELSE ADDDATE(payment_date, INTERVAL 1 YEAR)
		END,
        last_date
	FROM cte WHERE 
		(CASE
			WHEN plan_id IN (1, 2) THEN ADDDATE(payment_date, INTERVAL 1 MONTH)
            ELSE ADDDATE(payment_date, INTERVAL 1 YEAR)
		END) < last_date
    )
SELECT customer_id, plan_id, plan_name, payment_date,
	CASE
		WHEN payment_date < ADDDATE(LAG(payment_date) OVER(PARTITION BY customer_id ORDER BY payment_date), INTERVAL 1 MONTH) THEN price - 9.90
        ELSE price
    END AS amount,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM cte;
```
Now, let check the result and compare with example outputs.
```sql
-- check customer_id in example outputs to compare result
SELECT * FROM payments
WHERE customer_id IN (1, 2, 13, 15, 16, 18, 19);
```
Result:
| customer_id | plan_id | plan_name     | payment_date | amount | payment_order |
| ----------- | ------- | ------------- | ------------ | ------ | ------------- |
| 1           | 1       | basic monthly | 2020-08-08   | 9.90   | 1             |
| 1           | 1       | basic monthly | 2020-09-08   | 9.90   | 2             |
| 1           | 1       | basic monthly | 2020-10-08   | 9.90   | 3             |
| 1           | 1       | basic monthly | 2020-11-08   | 9.90   | 4             |
| 1           | 1       | basic monthly | 2020-12-08   | 9.90   | 5             |
| 2           | 3       | pro annual    | 2020-09-27   | 199.00 | 1             |
| 13          | 1       | basic monthly | 2020-12-22   | 9.90   | 1             |
| 15          | 2       | pro monthly   | 2020-03-24   | 19.90  | 1             |
| 15          | 2       | pro monthly   | 2020-04-24   | 19.90  | 2             |
| 16          | 1       | basic monthly | 2020-06-07   | 9.90   | 1             |
| 16          | 1       | basic monthly | 2020-07-07   | 9.90   | 2             |
| 16          | 1       | basic monthly | 2020-08-07   | 9.90   | 3             |
| 16          | 1       | basic monthly | 2020-09-07   | 9.90   | 4             |
| 16          | 1       | basic monthly | 2020-10-07   | 9.90   | 5             |
| 16          | 3       | pro annual    | 2020-10-21   | 189.10 | 6             |
| 18          | 2       | pro monthly   | 2020-07-13   | 19.90  | 1             |
| 18          | 2       | pro monthly   | 2020-08-13   | 19.90  | 2             |
| 18          | 2       | pro monthly   | 2020-09-13   | 19.90  | 3             |
| 18          | 2       | pro monthly   | 2020-10-13   | 19.90  | 4             |
| 18          | 2       | pro monthly   | 2020-11-13   | 19.90  | 5             |
| 18          | 2       | pro monthly   | 2020-12-13   | 19.90  | 6             |
| 19          | 2       | pro monthly   | 2020-06-29   | 19.90  | 1             |
| 19          | 2       | pro monthly   | 2020-07-29   | 19.90  | 2             |
| 19          | 3       | pro annual    | 2020-08-29   | 199.00 | 3             |

Great, it's all correct!!!

<br>

***
Finally, let's move to [D. Outside The Box Questions](./D.%20Outside%20The%20Box%20Questions.md).
