# Case Study #3 - Foodie-Fi

## A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

***

<br>

First, let's create a temporary table to calculate `end_date` of each plan.
``` sql
-- for this and  other questions, we will create a temporary table subscriptions_temp to calculate the end_date of each plan
-- from subscription table we create a cte table that:
    -- inner join plans to get plan_name
    -- create date_diff column to calculate the duration between current plan and previous plan
    -- create previous_plan column by using LAG() window function
-- create end_date column based on previous_plan and date_diff
DROP TABLE IF EXISTS subscriptions_temp;
CREATE TEMPORARY TABLE subscriptions_temp
WITH cte AS(
	SELECT
		customer_id,
        s.plan_id,
		plan_name,
        price,
		start_date,
		DATEDIFF(start_date, LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date)) AS date_diff,
		CASE
			WHEN plan_name = 'churn' THEN LAG(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date)
			ELSE NULL
		END AS plan_before_churn
	FROM subscriptions s
	INNER JOIN plans p
		ON s.plan_id = p.plan_id)
SELECT customer_id, plan_id, plan_name, price, start_date,
	CASE
		WHEN plan_before_churn = 'trial' THEN ADDDATE(LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL 7 DAY)
        WHEN plan_before_churn LIKE '%monthly' THEN 
			ADDDATE(LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL CEILING(date_diff/31) MONTH)
		WHEN plan_before_churn = 'pro annual' THEN 
			ADDDATE(LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL CEILING(date_diff/365) YEAR)
		ELSE SUBDATE(LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL 1 DAY)
    END AS end_date
FROM cte;
SELECT * FROM subscription_temp;
```

Now, let's filter customer_id to get information of 8 sample customers.
``` sql
-- filter needed customer_id
SELECT customer_id, plan_name, start_date, end_date
FROM subscriptions_temp
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19); 
```
Result:
| customer_id | plan_name     | start_date | end_date   |
| ----------- | ------------- | ---------- | ---------- |
| 1           | trial         | 2020-08-01 | 2020-08-07 |
| 1           | basic monthly | 2020-08-08 |            |
| 2           | trial         | 2020-09-20 | 2020-09-26 |
| 2           | pro annual    | 2020-09-27 |            |
| 11          | trial         | 2020-11-19 | 2020-11-25 |
| 11          | churn         | 2020-11-26 | 2020-11-26 |
| 13          | trial         | 2020-12-15 | 2020-12-21 |
| 13          | basic monthly | 2020-12-22 | 2021-03-28 |
| 13          | pro monthly   | 2021-03-29 |            |
| 15          | trial         | 2020-03-17 | 2020-03-23 |
| 15          | pro monthly   | 2020-03-24 | 2020-04-28 |
| 15          | churn         | 2020-04-29 | 2020-05-24 |
| 16          | trial         | 2020-05-31 | 2020-06-06 |
| 16          | basic monthly | 2020-06-07 | 2020-10-20 |
| 16          | pro annual    | 2020-10-21 |            |
| 18          | trial         | 2020-07-06 | 2020-07-12 |
| 18          | pro monthly   | 2020-07-13 |            |
| 19          | trial         | 2020-06-22 | 2020-06-28 |
| 19          | pro monthly   | 2020-06-29 | 2020-08-28 |
| 19          | pro annual    | 2020-08-29 |            |

Brief description:
* **Customer 1:** started free trial on 1 August 2020, after 7 day free trial downgraded to basic monthly plan and used this plan until now;
* **Customer 2:** started free trial on 20 August 2020, after 7 day free trial upgraded to pro annual plan and used this plan until now;
* **Customer 11:** started free trial on 19 November 2020, after 7 day free trial canceled the subscription;
* **Customer 13:** started free trial on 15 December 2020, after 7 day free trial downgraded to basic monthly plan until 29 March 2021 when he/she upgraded to pro monthly plan and used it until now;
* **Customer 15:** started free trial on 17 March 2020, after 7 day free trial automatically continue with the pro monthly plan until cancelled on 29 April 2020. The subscription continued until 24 May 2020;
* **Customer 16:** started free trial on 31 May 2020, after 7 day free trial downgraded to basic monthly plan until 31 October 2020 when he/she upgraded to pro annual plan and used it until now;
* **Customer 18:** started free trial on 06 July 2020, after 7 day free trial automatically continue with the pro monthly plan until now;
* **Customer 13:** started free trial on 22 June 2020, after 7 day free trial automatically continue with the pro monthly plan until 29 August 2020 when he/she upgraded to pro annual plan and used it until now.

<br>

***
Let's move to [B. Data Analysis Questions](./B.%20Data%20Analysis%20Questions.md).