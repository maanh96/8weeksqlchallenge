# 8 Week SQL Challenge

This is my solutions for the 8 case studies in [#8WeekSQLChallenge](https://8weeksqlchallenge.com).

Each case study folder contains:
* A readme file explains the case study's introduction, data and questions
* Schema SQL file to create the schema, tables and loading data
* One or multiple markdown files contains solutions and queries result
* Query SQL file contains all SQL queries from answer file.

Note: Solutions are coded in **MySQL 8.0**.

## List of case studies


[<img src='https://8weeksqlchallenge.com/images/case-study-designs/1.png' width='23%'>](./Case%20Study%20%231%20-%20Danny's%20Diner)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/2.png' width='23%'>](./Case%20Study%20%232%20-%20Pizza%20Runner)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/3.png' width='23%'>](./Case%20Study%20%233%20-%20Foodie-Fi)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/4.png' width='23%'>](./Case%20Study%20%234%20-%20Data%20Bank)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/5.png'  width='23%'>](./Case%20Study%20%235%20-%20Data%20Mart)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/6.png' width='23%'>](./Case%20Study%20%236%20-%20Clique%20Bait)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/7.png' width='23%'>](./Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/8.png' width='23%'>](./Case%20Study%20%238%20-%20Fresh%20Segments)
    

### 🍜 [Case Study #1 - Danny's Diner](./Case%20Study%20%231%20-%20Danny's%20Diner) 

* Use `RANK()` window function to get all items bought in first day and items that are most popular for each customer
* Use `CASE()` function to calculate customer point regarding the items bought
* Other functions used: `INNER JOIN`, `LEFT JOIN`, `SUM()`, `COUNT()`... 


### 🍕 [Case Study #2 - Pizza Runner](./Case%20Study%20%232%20-%20Pizza%20Runner)

* Data cleaning: use `CASE()` to convert inconsistent null values to `NULL`, use `REGEXP_SUBSTR()` to exact the numeric part and `CAST()` to convert values to right data type
* Use `SUM()` and `CASE()` to calculate number of items that match certain conditions
* Date function: `DAYNAME()` to get weekday name for a date, `TIMESTAMPDIFF()` to calculate preparation time in minute unit
* Split values in one row to multiple rows (to perform JOIN): use `JSON_ARRAY` and `REPLACE()` to convert list of values to JSON array then use `JSON_TABLE` to exact to tabular data
* Use `CONCAT` to get concatenated string from multiple columns and `GROUP_CONCAT()` to return concatenated string from multiple rows (group)
* Other functions used: `INNER JOIN`, `LEFT JOIN`, `AVG()`, `MIN()`, `MAX()`, `HOUR()`, `WEEK()`...


### 🥑 [Case Study #3 - Foodie-Fi](./Case%20Study%20%233%20-%20Foodie-Fi)
Notable functions used:

* Use `LAG()` and `LEAD()` window function to return the value of previous/next row
* Date function: use `ADDDATE()` and `SUBDATE()` with `INTERVAL` time unit to calculate date, `DATEDIFF` to find number of days between two date values
* Calculate percentage: If the table is not temporary, use subquery to return the value of total when calculating percentage (not effect by `WHERE` or `GROUP BY`). In case of temporary table, in some cases, one solution is using `SUM() OVER()` window function to get the total value but note that the window function is executed after `WHERE` and `GROUP BY` clause, hence this solution may not suitable for all cases
* Use `WITH RECURSIVE` CTE subquery to generate additional rows based on initial row set
* Other functions used: `INNER JOIN`, `CASE`, `MONTHNAME()`, `ROW_NUMBER()`...

### 💰 [Case Study #4 - Data Bank](./Case%20Study%20%234%20-%20Data%20Bank)

* Use `ROW_NUMBER()` to create join column of two tables when the common fields are repeated
* Use `PERCENT_RANK()`, `FIRST_VALUE()` and `CASE` to find n-th percentile of values 
* Use recursive CTE to add rows of of month that don't have any transaction then use `SUM() OVER()` to calculate closing balance of each
* Use `SUM()` window function with frame clause `ROWS UNBOUNDED PRECEDING` to calculate running balance for each transaction (row), use `LAST_VALUE()`, `AVG()`, `MAX()` window functions with frame clause `ROW/RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` to calculate closing balance, average running balance and max running balance of each month
* Use `COALESCE()` to return first non-null value in list, use `GREATEST()` instead of CASE to return value if it is positive and 0 if value is negative
* Use `UNION` to combine the result-set of two SELECT statements
* Other functions used: `INNER JOIN`, `LAG()`, `LEAD()`, `CASE`, `LAST_VALUE()`, `SUBDATE()`, `ADDDATE()`...

### 🛒 [Case Study #5 - Data Mart](./Case%20Study%20%235%20-%20Data%20Mart)
* Other functions used: 

### 🪝 [Case Study #6 - Clique Bait](./Case%20Study%20%236%20-%20Clique%20Bait)
* Other functions used: 

### 🏔️ [Case Study #7 - Balanced Tree Clothing Co](./Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co)
* Other functions used: 

### 🍊 [Case Study #8 - Fresh Segments](./Case%20Study%20%238%20-%20Fresh%20Segments)
* Other functions used: 