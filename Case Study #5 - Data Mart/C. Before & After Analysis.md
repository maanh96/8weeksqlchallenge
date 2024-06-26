# Case Study #5 - Data Mart

## C. Before & After Analysis

<p>This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.</p>

<p>Taking the <code class="language-plaintext highlighter-rouge">week_date</code> value of <code class="language-plaintext highlighter-rouge">2020-06-15</code> as the baseline week where the Data Mart sustainable packaging changes came into effect.</p>

<p>We would include all <code class="language-plaintext highlighter-rouge">week_date</code> values for <code class="language-plaintext highlighter-rouge">2020-06-15</code> as the start of the period <strong>after</strong> the change and the previous <code class="language-plaintext highlighter-rouge">week_date</code> values would be <strong>before</strong></p>

<p>Using this analysis approach - answer the following questions:</p>

### 1. What is the total sales for the 4 weeks before and after <code class="language-plaintext highlighter-rouge">2020-06-15</code>? What is the growth or reduction rate in actual values and percentage of sales?
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 4 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 4 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte;
```
Result:
| before_sales | after_sales | value_diff | percent_diff |
| :----------- | :---------- | :--------- | :----------- |
| 2345878357   | 2318994169  | -26884188  | -1.15        |

### 2. What about the entire 12 weeks before and after?
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte;
```
Result:
| before_sales | after_sales | value_diff | percent_diff |
| :----------- | :---------- | :--------- | :----------- |
| 7126273147   | 6973947753  | -152325394 | -2.14        |

### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_number < WEEK('2020-06-15') AND week_number >= WEEK('2020-06-15') - 12 THEN 'before'
			WHEN week_number >= WEEK('2020-06-15') AND week_number < WEEK('2020-06-15') + 12 THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY calendar_year
ORDER BY calendar_year;
```
Result:
| calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :------------ | :----------- | :---------- | :--------- | :----------- |
| 2018          | 6396562317   | 6500818510  | 104256193  | 1.63         |
| 2019          | 6883386397   | 6862646103  | -20740294  | -0.30        |
| 2020          | 7126273147   | 6973947753  | -152325394 | -2.14        |

Based on the table, it appears that the downward trend in sales between the two periods already started in 2019. However, the decline is significantly worse in 2020, which might due to the shift to sustainable packaging.

<br>

***
Let's move to [D. Bonus Question](./D.%20Bonus%20Question.md).
