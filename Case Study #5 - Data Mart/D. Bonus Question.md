# Case Study #5 - Data Mart

## D. Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

<ul>
  <li><code>region</code></li>
  <li><code>platform</code></li>
  <li><code>age_band</code></li>
  <li><code>demographic</code></li>
  <li><code>customer_type</code></li>
</ul>

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

***

### Region impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	region,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY region
ORDER BY percent_diff;
```
Result:
| region        | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :------------ | :------------ | :----------- | :---------- | :--------- | :----------- |
| ASIA          | 2020          | 1637244466   | 1583807621  | -53436845  | -3.26        |
| OCEANIA       | 2020          | 2354116790   | 2282795690  | -71321100  | -3.03        |
| SOUTH AMERICA | 2020          | 213036207    | 208452033   | -4584174   | -2.15        |
| CANADA        | 2020          | 426438454    | 418264441   | -8174013   | -1.92        |
| USA           | 2020          | 677013558    | 666198715   | -10814843  | -1.60        |
| AFRICA        | 2020          | 1709537105   | 1700390294  | -9146811   | -0.54        |
| EUROPE        | 2020          | 108886567    | 114038959   | 5152392    | 4.73         |

### Platform impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	platform,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY platform
ORDER BY percent_diff;
```
Result:
| platform | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :------- | :------------ | :----------- | :---------- | :--------- | :----------- |
| Retail   | 2020          | 6906861113   | 6738777279  | -168083834 | -2.43        |
| Shopify  | 2020          | 219412034    | 235170474   | 15758440   | 7.18         |

### Age_band impact in sales metrics performance in 2020 for the 12 week before and after period
```sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	age_band,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY age_band
ORDER BY percent_diff;
```
Result:
| age_band     | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :----------- | :------------ | :----------- | :---------- | :--------- | :----------- |
| unknown      | 2020          | 2764354464   | 2671961443  | -92393021  | -3.34        |
| Middle Aged  | 2020          | 1164847640   | 1141853348  | -22994292  | -1.97        |
| Retirees     | 2020          | 2395264515   | 2365714994  | -29549521  | -1.23        |
| Young Adults | 2020          | 801806528    | 794417968   | -7388560   | -0.92        |

### Demographic impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	demographic,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY demographic
ORDER BY percent_diff;
```
Result:
| demographic | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :---------- | :------------ | :----------- | :---------- | :--------- | :----------- |
| unknown     | 2020          | 2764354464   | 2671961443  | -92393021  | -3.34        |
| Families    | 2020          | 2328329040   | 2286009025  | -42320015  | -1.82        |
| Couples     | 2020          | 2033589643   | 2015977285  | -17612358  | -0.87        |

### Customer_type impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	customer_type,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY customer_type
ORDER BY percent_diff;
```
Result:
| customer_type | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :------------ | :------------ | :----------- | :---------- | :--------- | :----------- |
| Guest         | 2020          | 2573436301   | 2496233635  | -77202666  | -3.00        |
| Existing      | 2020          | 3690116427   | 3606243454  | -83872973  | -2.27        |
| New           | 2020          | 862720419    | 871470664   | 8750245    | 1.01         |

Looking at the data, we see the highest negative impact at regions like Asia (-3.26%) and Oceania (-2.43%), retail platform (-2.43%), guest and existing customer (-3.00% and -2.27%, respectively). On one hand, this may indicate that the sustainable packaging changes were not well received in that area of the business. But on other hand, it is worth noting that these results may be affected by other factors like the change in customer behavior or other external events. Danny's team thus need to do surveys and perform further analysis in these areas.

<br>

***
~ This is the end of Case Study 5 ~

Back to [Main menu](https://github.com/maanh96/8weeksqlchallenge).