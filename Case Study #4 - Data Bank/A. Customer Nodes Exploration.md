# Case Study #4 - Data Bank

## A. Customer Nodes Exploration

### 1. How many unique nodes are there on the Data Bank system?
``` sql
SELECT COUNT(DISTINCT node_id) unique_nodes
FROM customer_nodes;
```
Result:
| unique_nodes |
| :----------- |
| 5            |

### 2. What is the number of nodes per region?
``` sql
SELECT
	region_name,
    COUNT(*) AS total_nodes
FROM customer_nodes c
INNER JOIN regions r
	ON c.region_id = r.region_id
GROUP BY c.region_id;
```
Result:
| region_name | total_nodes |
| :---------- | :---------- |
| Australia   | 770         |
| America     | 735         |
| Africa      | 714         |
| Asia        | 665         |
| Europe      | 616         |
    
### 3. How many customers are allocated to each region?
``` sql
SELECT
	region_name,
    COUNT(DISTINCT customer_id) AS total_customers
FROM customer_nodes c
INNER JOIN regions r
	ON c.region_id = r.region_id
GROUP BY c.region_id;
```
Result:
| region_name | total_customers |
| :---------- | :-------------- |
| Australia   | 110             |
| America     | 105             |
| Africa      | 102             |
| Asia        | 95              |
| Europe      | 88              |

### 4. How many days on average are customers reallocated to a different node?
``` sql
-- nodes are randomly distributed so there are cases when after reallocate (new row), customers still get the same node
-- we will create a temporary table to combine those to one row from first start_date to last end_date of the same node
-- filter out end_date = '9999-12-31' before calculating so that it does not effect our average result			

DROP TABLE IF EXISTS customer_nodes_temp;
CREATE TEMPORARY TABLE customer_nodes_temp
WITH cte AS(
	SELECT
		*,
		LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_node,
		LEAD(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_node
        FROM customer_nodes),
start AS(
	SELECT *, ROW_NUMBER() OVER() AS round
	FROM cte
	WHERE prev_node IS NULL OR node_id != prev_node),
end AS(
	SELECT *, ROW_NUMBER() OVER() AS round
    FROM cte
    WHERE next_node IS NULL OR node_id != next_node)
SELECT s.customer_id, region_name, s.node_id, s.start_date, e.end_date, DATEDIFF(e.end_date, s.start_date) AS total_reallocate_days
FROM start s
INNER JOIN end e
	ON s.round = e.round
INNER JOIN regions r
	ON s.region_id = r.region_id
WHERE e.end_date != '9999-12-31'
ORDER BY s.customer_id, s.start_date;

-- caculate average reallocate day using created temp table
SELECT ROUND(AVG(total_reallocate_days), 2) AS avg_allocate_day
FROM customer_nodes_temp;
```
Result:
| avg_allocate_day |
| :--------------- |
| 17.87            |

### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
``` sql
-- use PERCENT_RANK() to find the percentile of each reallocation days for each region
-- use FIRST_VALUE() AND CASE to find out the day that have percentile is smaller and nearest to 0.5, 0.8 and 0.95
 WITH cte AS(
	SELECT DISTINCT
		region_name,
        total_reallocate_days,
		PERCENT_RANK() OVER(PARTITION BY region_name ORDER BY total_reallocate_days) AS percentile
	FROM customer_nodes_temp)
SELECT DISTINCT
	region_name,
	FIRST_VALUE(total_reallocate_days) OVER(PARTITION BY region_name ORDER BY CASE WHEN percentile <= 0.50 THEN percentile END DESC) AS median,
	FIRST_VALUE(total_reallocate_days) OVER(PARTITION BY region_name ORDER BY CASE WHEN percentile <= 0.80 THEN percentile END DESC) AS percentile_80,
	FIRST_VALUE(total_reallocate_days) OVER(PARTITION BY region_name ORDER BY CASE WHEN percentile <= 0.95 THEN percentile END DESC) AS percentile_95
FROM cte;
```
Result:
| region_name | median | percentile_80 | percentile_95 |
| :---------- | :----- | :------------ | :------------ |
| Africa      | 17     | 27            | 38            |
| America     | 17     | 26            | 36            |
| Asia        | 17     | 26            | 38            |
| Australia   | 17     | 27            | 41            |
| Europe      | 18     | 27            | 38            |

<br>

***
Let's move to [B. Customer Transactions](./B.%20Customer%20Transactions.md).
