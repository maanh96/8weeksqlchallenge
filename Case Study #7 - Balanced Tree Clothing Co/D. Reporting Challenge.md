# Case Study #7 - Balanced Tree Clothing Co.

## D. Reporting 

<p>Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.</p>

<p>Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.</p>

<p>He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the same analysis for February without many changes (if at all).</p>

<p>Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)</p>

***
We executes similiar queries as previous part but we will add the condition `WHERE DATE_FORMAT(start_txn_time, '%Y%m') = '202101'` to get the data of needed month.

For Questions in Part A:
``` sql
SELECT
	SUM(qty) AS total_quantity,
    SUM(price * qty) AS total_revenue_before_discounts,
    SUM(price * qty * discount /100) AS total_discount
FROM sales
WHERE DATE_FORMAT(start_txn_time, '%Y%m') = '202101';
```
Result:
| total_quantity | total_revenue_before_discounts | total_discount |
| :------------- | :----------------------------- | :------------- |
| 14788          | 420672                         | 51589.1000     |

For Questions in Part B:
```sql
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
```
Result:
| total_transactions | avg_products | percentile_25 | percentile_50 | percentile_75 | avg_discount_per_txn | member_percent | non_member_percent | avg_member_revenue | avg_non_member_revenue |
| :----------------- | :----------- | :------------ | :------------ | :------------ | :------------------- | :------------- | :----------------- | :----------------- | :--------------------- |
| 828                | 5.9879       | 312.8400      | 434.0700      | 563.5800      | 62.31                | 59.42          | 40.58              | 451.93             | 436.71                 |

For questions in part C, since the answer of each questions would have different row numbers, rather than combining them altogether, I think we should execute them one by one.

<br>

***
Let's move to [E. Bonus Challenge](./E.%20Bonus%20Challenge.md).
