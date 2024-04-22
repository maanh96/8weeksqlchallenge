# 8 Week SQL Challenge

This is my solution for the 8 case studies in [#8WeekSQLChallenge](https://8weeksqlchallenge.com).

Each case study folder contains:
* A readme file explains the case study's introduction, data, and questions
* Schema SQL file to create the schema, tables, and loading data
* One or multiple markdown files contain solutions and query result
* Query SQL file contains all SQL queries from the answer file.

Note: Solutions are coded in **MySQL 8.0**.

## List of case studies

[<img src='https://8weeksqlchallenge.com/images/case-study-designs/1.png' width='23%'>](./Case%20Study%20%231%20-%20Danny's%20Diner)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/2.png' width='23%'>](./Case%20Study%20%232%20-%20Pizza%20Runner)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/3.png' width='23%'>](./Case%20Study%20%233%20-%20Foodie-Fi)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/4.png' width='23%'>](./Case%20Study%20%234%20-%20Data%20Bank)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/5.png'  width='23%'>](./Case%20Study%20%235%20-%20Data%20Mart)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/6.png' width='23%'>](./Case%20Study%20%236%20-%20Clique%20Bait)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/7.png' width='23%'>](./Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co)[<img src='https://8weeksqlchallenge.com/images/case-study-designs/8.png' width='23%'>](./Case%20Study%20%238%20-%20Fresh%20Segments)
    

### 🍜 [Case Study #1 - Danny's Diner](./Case%20Study%20#1%20-%20Danny's%20Diner/) 
Using the sales and customers dataset of a restaurant to learn about their customers' visiting patterns, how much money they’ve spent and which menu items are their favorite.  

Notable functions used include:
* `RANK()` window function to get all items bought on the first day and items that are most popular for each customer
* `CASE()` function to calculate customer points regarding the items bought
* Other functions: `INNER JOIN`, `LEFT JOIN`, `SUM()`, `COUNT()`
<br>

### 🍕 [Case Study #2 - Pizza Runner](./Case%20Study%20#2%20-%20Pizza%20Runner/)
Analyze pizza restaurant's orders to optimize their delivery and operations. 

Notable functions used include:
* Data cleaning: use `CASE()` to convert inconsistent null values to `NULL`, use `REGEXP_SUBSTR()` to exact the numeric part and `CAST()` to convert values to the correct data type
* Use `SUM()` and `CASE()` to calculate the number of items that match certain conditions
* Date function: `DAYNAME()` to get the weekday name for a date, `TIMESTAMPDIFF()` to calculate preparation time in minute
* Split values in one row to multiple rows (to perform JOIN): use `JSON_ARRAY` and `REPLACE()` to convert a list of values to JSON array then use `JSON_TABLE` to transform it to tabular data
* Use `CONCAT` to get concatenated string from multiple columns and `GROUP_CONCAT()` to return concatenated string from multiple rows (group)
* Other functions used: `INNER JOIN`, `LEFT JOIN`, `AVG()`, `MIN()`, `MAX()`, `HOUR()`, `WEEK()`
<br>

### 🥑 [Case Study #3 - Foodie-Fi](./Case%20Study%20%233%20-%20Foodie-Fi/)
Working on a dataset of a streaming service company to gain insight into their customers' payment and subscription journey. 

Notable functions used include:
* `LAG()` and `LEAD()` window functions to retrieve  the value of the previous/next row
* Date function: use `ADDDATE()` and `SUBDATE()` with `INTERVAL` time unit to calculate dates, `DATEDIFF` to determine the number of days between two date values
* Use `SUM(...) OVER()` window function to fetch the global sum when calculating the percentage for each row
* Use `WITH RECURSIVE` CTE subquery to generate rows based on the initial row set
* Other functions used: `INNER JOIN`, `CASE`, `MONTHNAME()`, `ROW_NUMBER()`
<br>

### 💰 [Case Study #4 - Data Bank](./Case%20Study%20%234%20-%20Data%20Bank)
Exploring data of a new age bank where customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts, we will track how much data storage is needed and forecast its developments based on multiple hypothetical options.

Notable functions used include:
* Use `ROW_NUMBER()` to create a join column of two tables when the common fields are repeated
* Use `PERCENT_RANK()`, `FIRST_VALUE()` and `CASE` to find the n-th percentile of values 
* Use recursive CTE to add rows of months that don't have any transactions and use `SUM() OVER()` to calculate the closing balance of each
* Use `SUM()` window function with frame clause `ROWS UNBOUNDED PRECEDING` to calculate the running balance for each transaction record, use `LAST_VALUE()`, `AVG()`, `MAX()` window functions with frame clause `ROW/RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` to calculate closing balance, average running balance and max running balance of each month
* Use `COALESCE()` to return the first non-null value in the list. Use `GREATEST()` instead of `CASE` to return the value if it is positive and 0 if it is negative
* Use `UNION` to combine the result set of two SELECT statements
* Other functions used: `INNER JOIN`, `LAG()`, `LEAD()`, `CASE`, `LAST_VALUE()`, `SUBDATE()`, `ADDDATE()`
<br>

### 🛒 [Case Study #5 - Data Mart](./Case%20Study%20%235%20-%20Data%20Mart)
Perform before & after analysis to quantify the impact of changing to sustainable packaging methods on the sales performance of a supermarket. 

Notable functions used include:
* Data cleaning: `STR_TO_DATE` to convert string to date value, `WEEK()`, `MONTH()`, `YEAR()` to get desired date part
* Use `SUM()` and `CASE` to calculate the percentage of sales for each category
* Other functions used: `WITH RECURSIVE`, `GROUP_CONCAT()`
<br>

### 🪝 [Case Study #6 - Clique Bait](./Case%20Study%20%236%20-%20Clique%20Bait)
The case study's dataset recorded users' interactions with a seafood store website. Using SQL query we will analyze and calculate multiple indicators such as the number of products viewed, added to cart, purchased, abandoned, and the conversion rate between these actions. 

Notable functions used include:
* Calculate the percentage of a category using subquery
* Use `CASE()` to mark when a product is viewed or added to cart then use `SUM()` to calculate the total number of products
* Other functions used: `INNER JOIN`, `LEFT JOIN`, `UNION`,  `COUNT()`, `AVG()`
<br>

### 🏔️ [Case Study #7 - Balanced Tree Clothing Co](./Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co)
Working on the dataset of a clothing store's products and transactions to calculate the percentile value of revenue, percentage split of revenue and transactions by different indexes, total transaction penetration for each product and find out which products are often bought together. 

Notable functions used include:
* `PERCENT_RANK()`, `FIRST_VALUE()` and `CASE` to find n-th percentile values for the revenue per transaction
* Calculate the percentage by subquery and `SUM(...) OVER()` window function
* Use `RANK()` to find top-selling products for each segment
* `INNER JOIN` a table to itself to find the most common combination of any 3 products
* Other functions used: `AVG()`, `COUNT()`
<br>

### 🍊 [Case Study #8 - Fresh Segments](./Case%20Study%20%238%20-%20Fresh%20Segments)
In this case study, we act as a digital marketing agency that helps other businesses analyze trends in online ad click behavior for their unique customer base. Using aggregated interest metrics of a major client, we will analyze the top and bottom interests based on their composition and ranking and yield high-level insights about the customer list and their interests. 

Notable functions used include:
* `STR_TO_DATE` to update a column from string to date format
* Using frame clause `ROWS UNBOUNDED PRECEDING` in window functions to calculate the cumulative percentage of records and `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` to calculate the 3-month rolling average
* Other functions used: `UPDATE`, `DELETE`, `INNER JOIN`, `RANK OVER()`, `ROW_NUMBER() OVER()`