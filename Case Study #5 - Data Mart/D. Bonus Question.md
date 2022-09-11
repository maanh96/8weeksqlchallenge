# Case Study #5 - Data Mart

## D. Bonus Question

<p>Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?</p>

<ul>
  <li><code>region</code></li>
  <li><code>platform</code></li>
  <li><code>age_band</code></li>
  <li><code>demographic</code></li>
  <li><code>customer_type</code></li>
</ul>

<p>Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?</p>

***

### Region impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_number < WEEK('2020-06-15') AND week_number >= WEEK('2020-06-15') - 12 THEN 'before'
			WHEN week_number >= WEEK('2020-06-15') AND week_number < WEEK('2020-06-15') + 12 THEN 'after'
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
GROUP BY region, calendar_year
ORDER BY region;
```
Result:
| region        | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :------------ | :------------ | :----------- | :---------- | :--------- | :----------- |
| AFRICA        | 2018          | 1563248942   | 1607727883  | 44478941   | 2.85         |
| AFRICA        | 2019          | 1670190863   | 1689397982  | 19207119   | 1.15         |
| AFRICA        | 2020          | 1709537105   | 1700390294  | -9146811   | -0.54        |
| ASIA          | 2018          | 1429074635   | 1440266977  | 11192342   | 0.78         |
| ASIA          | 2019          | 1546923588   | 1527852673  | -19070915  | -1.23        |
| ASIA          | 2020          | 1637244466   | 1583807621  | -53436845  | -3.26        |
| CANADA        | 2018          | 392274392    | 397676193   | 5401801    | 1.38         |
| CANADA        | 2019          | 425949859    | 418084572   | -7865287   | -1.85        |
| CANADA        | 2020          | 426438454    | 418264441   | -8174013   | -1.92        |
| EUROPE        | 2018          | 108637914    | 119222652   | 10584738   | 9.74         |
| EUROPE        | 2019          | 110616933    | 111158432   | 541499     | 0.49         |
| EUROPE        | 2020          | 108886567    | 114038959   | 5152392    | 4.73         |
| OCEANIA       | 2018          | 2083777433   | 2107162176  | 23384743   | 1.12         |
| OCEANIA       | 2019          | 2260692110   | 2250286927  | -10405183  | -0.46        |
| OCEANIA       | 2020          | 2354116790   | 2282795690  | -71321100  | -3.03        |
| SOUTH AMERICA | 2018          | 192629232    | 196640343   | 4011111    | 2.08         |
| SOUTH AMERICA | 2019          | 205391484    | 203889016   | -1502468   | -0.73        |
| SOUTH AMERICA | 2020          | 213036207    | 208452033   | -4584174   | -2.15        |
| USA           | 2018          | 626919769    | 632122286   | 5202517    | 0.83         |
| USA           | 2019          | 663621560    | 661976501   | -1645059   | -0.25        |
| USA           | 2020          | 677013558    | 666198715   | -10814843  | -1.60        |

### Platform impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_number < WEEK('2020-06-15') AND week_number >= WEEK('2020-06-15') - 12 THEN 'before'
			WHEN week_number >= WEEK('2020-06-15') AND week_number < WEEK('2020-06-15') + 12 THEN 'after'
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
GROUP BY platform, calendar_year
ORDER BY platform;
```
Result:
| platform | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :------- | :------------ | :----------- | :---------- | :--------- | :----------- |
| Retail   | 2018          | 6257743808   | 6353427510  | 95683702   | 1.53         |
| Retail   | 2019          | 6721435351   | 6676371376  | -45063975  | -0.67        |
| Retail   | 2020          | 6906861113   | 6738777279  | -168083834 | -2.43        |
| Shopify  | 2018          | 138818509    | 147391000   | 8572491    | 6.18         |
| Shopify  | 2019          | 161951046    | 186274727   | 24323681   | 15.02        |
| Shopify  | 2020          | 219412034    | 235170474   | 15758440   | 7.18         |

### Age_band impact in sales metrics performance in 2020 for the 12 week before and after period
```sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_number < WEEK('2020-06-15') AND week_number >= WEEK('2020-06-15') - 12 THEN 'before'
			WHEN week_number >= WEEK('2020-06-15') AND week_number < WEEK('2020-06-15') + 12 THEN 'after'
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
GROUP BY age_band, calendar_year
ORDER BY age_band;
```
Result:
| age_band     | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :----------- | :------------ | :----------- | :---------- | :--------- | :----------- |
| Middle Aged  | 2018          | 1011444017   | 1028384577  | 16940560   | 1.67         |
| Middle Aged  | 2019          | 1100600690   | 1099510697  | -1089993   | -0.10        |
| Middle Aged  | 2020          | 1164847640   | 1141853348  | -22994292  | -1.97        |
| Retirees     | 2018          | 2003410521   | 2041055465  | 37644944   | 1.88         |
| Retirees     | 2019          | 2248190286   | 2227936421  | -20253865  | -0.90        |
| Retirees     | 2020          | 2395264515   | 2365714994  | -29549521  | -1.23        |
| unknown      | 2018          | 2661648967   | 2707785139  | 46136172   | 1.73         |
| unknown      | 2019          | 2765625395   | 2767236826  | 1611431    | 0.06         |
| unknown      | 2020          | 2764354464   | 2671961443  | -92393021  | -3.34        |
| Young Adults | 2018          | 720058812    | 723593329   | 3534517    | 0.49         |
| Young Adults | 2019          | 768970026    | 767962159   | -1007867   | -0.13        |
| Young Adults | 2020          | 801806528    | 794417968   | -7388560   | -0.92        |

### Demographic impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_number < WEEK('2020-06-15') AND week_number >= WEEK('2020-06-15') - 12 THEN 'before'
			WHEN week_number >= WEEK('2020-06-15') AND week_number < WEEK('2020-06-15') + 12 THEN 'after'
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
GROUP BY demographic, calendar_year
ORDER BY demographic;
```
Result:
| demographic | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :---------- | :------------ | :----------- | :---------- | :--------- | :----------- |
| Couples     | 2018          | 1692610371   | 1709778317  | 17167946   | 1.01         |
| Couples     | 2019          | 1882666117   | 1866585818  | -16080299  | -0.85        |
| Couples     | 2020          | 2033589643   | 2015977285  | -17612358  | -0.87        |
| Families    | 2018          | 2042302979   | 2083255054  | 40952075   | 2.01         |
| Families    | 2019          | 2235094885   | 2228823459  | -6271426   | -0.28        |
| Families    | 2020          | 2328329040   | 2286009025  | -42320015  | -1.82        |
| unknown     | 2018          | 2661648967   | 2707785139  | 46136172   | 1.73         |
| unknown     | 2019          | 2765625395   | 2767236826  | 1611431    | 0.06         |
| unknown     | 2020          | 2764354464   | 2671961443  | -92393021  | -3.34        |

### Customer_type impact in sales metrics performance in 2020 for the 12 week before and after period
``` sql
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_number < WEEK('2020-06-15') AND week_number >= WEEK('2020-06-15') - 12 THEN 'before'
			WHEN week_number >= WEEK('2020-06-15') AND week_number < WEEK('2020-06-15') + 12 THEN 'after'
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
GROUP BY customer_type, calendar_year
ORDER BY customer_type;
```
Result:
| customer_type | calendar_year | before_sales | after_sales | value_diff | percent_diff |
| :------------ | :------------ | :----------- | :---------- | :--------- | :----------- |
| Existing      | 2018          | 3041461267   | 3101653990  | 60192723   | 1.98         |
| Existing      | 2019          | 3437299948   | 3409469795  | -27830153  | -0.81        |
| Existing      | 2020          | 3690116427   | 3606243454  | -83872973  | -2.27        |
| Guest         | 2018          | 2483293080   | 2532124572  | 48831492   | 1.97         |
| Guest         | 2019          | 2573624358   | 2566792537  | -6831821   | -0.27        |
| Guest         | 2020          | 2573436301   | 2496233635  | -77202666  | -3.00        |
| New           | 2018          | 871807970    | 867039948   | -4768022   | -0.55        |
| New           | 2019          | 872462091    | 886383771   | 13921680   | 1.60         |
| New           | 2020          | 862720419    | 871470664   | 8750245    | 1.01         |



<br>

***
~ This is the end of Case Study 5 ~

Back to [Main menu](https://github.com/maanh96/8weeksqlchallenge).