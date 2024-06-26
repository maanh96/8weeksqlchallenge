# Case Study #5 - Data Mart

## B. Data Exploration

### 1. What day of the week is used for each <code class="language-plaintext highlighter-rouge">week_date</code> value?
``` sql
SELECT DISTINCT DAYNAME(week_date) AS week_day
FROM clean_weekly_sales;
```
Result:
| week_day |
| :------- |
| Monday   |

### 2. What range of week numbers are missing from the dataset?
``` sql
WITH RECURSIVE week_numbers_cte(week_number) AS(
	SELECT 1
    UNION
    SELECT week_number + 1
	FROM week_numbers_cte
    WHERE week_number + 1 <= 52)
SELECT GROUP_CONCAT(week_number SEPARATOR ' ,') AS week_number_missing
FROM week_numbers_cte
WHERE week_number NOT IN (SELECT week_number FROM clean_weekly_sales);
```
Result:
| week_number_missing                                                                                   |
| :---------------------------------------------------------------------------------------------------- |
| 1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10 ,11 ,36 ,37 ,38 ,39 ,40 ,41 ,42 ,43 ,44 ,45 ,46 ,47 ,48 ,49 ,50 ,51 ,52 |

### 3. How many total transactions were there for each year in the dataset?
``` sql
SELECT 
	calendar_year,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year
```
Result:
| calendar_year | total_transactions |
| :------------ | :----------------- |
| 2018          | 346406460          |
| 2019          | 365639285          |
| 2020          | 375813651          |

### 4. What is the total sales for each region for each month?
``` sql
SELECT
	region,
    month_number,
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
```
Result:
| region        | month_number | total_sales |
| :------------ | :----------- | :---------- |
| AFRICA        | 3            | 567767480   |
| AFRICA        | 4            | 1911783504  |
| AFRICA        | 5            | 1647244738  |
| AFRICA        | 6            | 1767559760  |
| AFRICA        | 7            | 1960219710  |
| AFRICA        | 8            | 1809596890  |
| AFRICA        | 9            | 276320987   |
| ASIA          | 3            | 529770793   |
| ASIA          | 4            | 1804628707  |
| ASIA          | 5            | 1526285399  |
| ASIA          | 6            | 1619482889  |
| ASIA          | 7            | 1768844756  |
| ASIA          | 8            | 1663320609  |
| ASIA          | 9            | 252836807   |
| CANADA        | 3            | 144634329   |
| CANADA        | 4            | 484552594   |
| CANADA        | 5            | 412378365   |
| CANADA        | 6            | 443846698   |
| CANADA        | 7            | 477134947   |
| CANADA        | 8            | 447073019   |
| CANADA        | 9            | 69067959    |
| EUROPE        | 3            | 35337093    |
| EUROPE        | 4            | 127334255   |
| EUROPE        | 5            | 109338389   |
| EUROPE        | 6            | 122813826   |
| EUROPE        | 7            | 136757466   |
| EUROPE        | 8            | 122102995   |
| EUROPE        | 9            | 18877433    |
| OCEANIA       | 3            | 783282888   |
| OCEANIA       | 4            | 2599767620  |
| OCEANIA       | 5            | 2215657304  |
| OCEANIA       | 6            | 2371884744  |
| OCEANIA       | 7            | 2563459400  |
| OCEANIA       | 8            | 2432313652  |
| OCEANIA       | 9            | 372465518   |
| SOUTH AMERICA | 3            | 71023109    |
| SOUTH AMERICA | 4            | 238451531   |
| SOUTH AMERICA | 5            | 201391809   |
| SOUTH AMERICA | 6            | 218247455   |
| SOUTH AMERICA | 7            | 235582776   |
| SOUTH AMERICA | 8            | 221166052   |
| SOUTH AMERICA | 9            | 34175583    |
| USA           | 3            | 225353043   |
| USA           | 4            | 759786323   |
| USA           | 5            | 655967121   |
| USA           | 6            | 703878990   |
| USA           | 7            | 760331754   |
| USA           | 8            | 712002790   |
| USA           | 9            | 110532368   |

### 5. What is the total count of transactions for each platform
``` sql
SELECT
	platform,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;
```
Result:
| platform | total_transactions |
| :------- | :----------------- |
| Retail   | 1081934227         |
| Shopify  | 5925169            |

### 6. What is the percentage of sales for Retail vs Shopify for each month?
``` sql
SELECT
	month_number,
    ROUND(SUM(CASE WHEN platform = 'Retail' THEN sales END)/SUM(sales) * 100, 2) AS retail_percent,
    ROUND(SUM(CASE WHEN platform = 'Shopify' THEN sales END)/SUM(sales) * 100, 2) AS shopify_percent
FROM clean_weekly_sales
GROUP BY month_number
ORDER BY month_number;
```
Result:
| month_number | retail_percent | shopify_percent |
| :----------- | :------------- | :-------------- |
| 3            | 97.54          | 2.46            |
| 4            | 97.59          | 2.41            |
| 5            | 97.30          | 2.70            |
| 6            | 97.27          | 2.73            |
| 7            | 97.29          | 2.71            |
| 8            | 97.08          | 2.92            |
| 9            | 97.38          | 2.62            |

### 7. What is the percentage of sales by demographic for each year in the dataset?
``` sql
SELECT
	calendar_year,
    ROUND(SUM(CASE WHEN demographic = 'Couples' THEN sales END)/SUM(sales) * 100, 2) AS couples_percent,
    ROUND(SUM(CASE WHEN demographic = 'Families' THEN sales END)/SUM(sales) * 100, 2) AS families_percent,
    ROUND(SUM(CASE WHEN demographic = 'unknown' THEN sales END)/SUM(sales) * 100, 2) AS unknown_percent
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
```
Result:
| calendar_year | couples_percent | families_percent | unknown_percent |
| :------------ | :-------------- | :--------------- | :-------------- |
| 2018          | 26.38           | 31.99            | 41.63           |
| 2019          | 27.28           | 32.47            | 40.25           |
| 2020          | 28.72           | 32.73            | 38.55           |

### 8. Which <code class="language-plaintext highlighter-rouge">age_band</code> and <code class="language-plaintext highlighter-rouge">demographic</code> values contribute the most to Retail sales?
``` sql
SELECT
	age_band,
    demographic,
    SUM(sales) AS total_sales,
    ROUND(SUM(sales)/ SUM(SUM(sales)) OVER() * 100, 2) AS sales_percent
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC
LIMIT 2;
```
Result:
| age_band | demographic | total_sales | sales_percent |
| :------- | :---------- | :---------- | :------------ |
| unknown  | unknown     | 16067285533 | 40.52         |
| Retirees | Families    | 6634686916  | 16.73         |

Besides unknown segment, Retirees `age_band` and Families `demographic` contributes the most to Retail sales.

### 9. Can we use the <code class="language-plaintext highlighter-rouge">avg_transaction</code> column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

We cannot use the `avg_transaction` to find the average transaction size for each year since the the count of unique purchases made each week are different from each other. Instead, we need to calculate the sum of `sales` then divide them by the sum of `transactions`. 

``` sql
SELECT
	calendar_year,
    platform,
    ROUND(SUM(sales)/SUM(transactions), 2) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year;
```
Result:
| calendar_year | platform | avg_transaction_group |
| :------------ | :------- | :-------------------- |
| 2018          | Retail   | 36.56                 |
| 2018          | Shopify  | 192.48                |
| 2019          | Retail   | 36.83                 |
| 2019          | Shopify  | 183.36                |
| 2020          | Retail   | 36.56                 |
| 2020          | Shopify  | 179.03                |

<br>

***
Let's move to [C. Before & After Analysis](./C.%20Before%20&%20After%20Analysis.md).
