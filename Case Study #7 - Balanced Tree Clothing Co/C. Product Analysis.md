# Case Study #7 - Balanced Tree Clothing Co.

## C. Product 

### 1. What are the top 3 products by total revenue before discount?
``` sql
SELECT
	product_name,
    SUM(qty * s.price) AS revenue_before_discount
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY s.prod_id
ORDER BY revenue_before_discount DESC
LIMIT 3;
```
Result:
| product_name                 | revenue_before_discount |
| :--------------------------- | :---------------------- |
| Blue Polo Shirt - Mens       | 217683                  |
| Grey Fashion Jacket - Womens | 209304                  |
| White Tee Shirt - Mens       | 152000                  |

### 2. What is the total quantity, revenue and discount for each segment?
``` sql
SELECT
	segment_name,
    SUM(qty) AS total_quantity,
    ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS total_revenue,
    ROUND(SUM(qty * s.price * discount/100), 2) AS total_discount
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.segment_id;
```
Result:
| segment_name | total_quantity | total_revenue | total_discount |
| :----------- | :------------- | :------------ | :------------- |
| Jeans        | 11349          | 183006.03     | 25343.97       |
| Shirt        | 11265          | 356548.73     | 49594.27       |
| Socks        | 11217          | 270963.56     | 37013.44       |
| Jacket       | 11385          | 322705.54     | 44277.46       |

### 3. What is the top selling product for each segment?
``` sql
WITH cte AS(
	SELECT
		segment_name,
		product_name,
		SUM(qty) AS total_quantity,
		RANK() OVER(PARTITION BY segment_id ORDER BY SUM(qty) DESC) AS ranking
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY s.prod_id)
SELECT segment_name, product_name, total_quantity
FROM cte
WHERE ranking = 1;    
```
Result:
| segment_name | product_name                  | total_quantity |
| :----------- | :---------------------------- | :------------- |
| Jeans        | Navy Oversized Jeans - Womens | 3856           |
| Jacket       | Grey Fashion Jacket - Womens  | 3876           |
| Shirt        | Blue Polo Shirt - Mens        | 3819           |
| Socks        | Navy Solid Socks - Mens       | 3792           |

### 4. What is the total quantity, revenue and discount for each category?
``` sql
SELECT
	category_name,
    SUM(qty) AS total_quantity,
    ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS total_revenue,
    ROUND(SUM(qty * s.price * discount/100), 2) AS total_discount
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.category_id;
```
Result:
| category_name | total_quantity | total_revenue | total_discount |
| :------------ | :------------- | :------------ | :------------- |
| Womens        | 22734          | 505711.57     | 69621.43       |
| Mens          | 22482          | 627512.29     | 86607.71       |

### 5. What is the top selling product for each category?
``` sql
WITH cte AS(
	SELECT
		category_name,
		product_name,
		SUM(qty) AS total_quantity,
		RANK() OVER(PARTITION BY category_id ORDER BY SUM(qty) DESC) AS ranking
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY s.prod_id)
SELECT category_name, product_name, total_quantity
FROM cte
WHERE ranking = 1;
```
Result:
| category_name | product_name                 | total_quantity |
| :------------ | :--------------------------- | :------------- |
| Womens        | Grey Fashion Jacket - Womens | 3876           |
| Mens          | Blue Polo Shirt - Mens       | 3819           |

### 6. What is the percentage split of revenue by product for each segment?
``` sql
WITH cte AS(
	SELECT
		segment_name,
		product_name,
		ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS revenue
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY p.product_id)
SELECT *, ROUND(revenue/ SUM(revenue) OVER(PARTITION BY segment_name)*100, 2) AS revenue_percent
FROM cte;
```
Result:
| segment_name | product_name                     | revenue   | revenue_percent |
| :----------- | :------------------------------- | :-------- | :-------------- |
| Jacket       | Indigo Rain Jacket - Womens      | 62740.47  | 19.44           |
| Jacket       | Khaki Suit Jacket - Womens       | 76052.95  | 23.57           |
| Jacket       | Grey Fashion Jacket - Womens     | 183912.12 | 56.99           |
| Jeans        | Navy Oversized Jeans - Womens    | 43992.39  | 24.04           |
| Jeans        | Cream Relaxed Jeans - Womens     | 32606.60  | 17.82           |
| Jeans        | Black Straight Jeans - Womens    | 106407.04 | 58.14           |
| Shirt        | White Tee Shirt - Mens           | 133622.40 | 37.48           |
| Shirt        | Blue Polo Shirt - Mens           | 190863.93 | 53.53           |
| Shirt        | Teal Button Up Shirt - Mens      | 32062.40  | 8.99            |
| Socks        | White Striped Socks - Mens       | 54724.19  | 20.20           |
| Socks        | Pink Fluro Polkadot Socks - Mens | 96377.73  | 35.57           |
| Socks        | Navy Solid Socks - Mens          | 119861.64 | 44.24           |

### 7. What is the percentage split of revenue by segment for each category?
``` sql
WITH cte AS(
	SELECT
		category_name,
		segment_name,
		ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS revenue
	FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY p.segment_id)
SELECT *, ROUND(revenue/ SUM(revenue) OVER(PARTITION BY category_name)*100, 2) AS revenue_percent
FROM cte;
```
Result:
| category_name | segment_name | revenue   | revenue_percent |
| :------------ | :----------- | :-------- | :-------------- |
| Mens          | Shirt        | 356548.73 | 56.82           |
| Mens          | Socks        | 270963.56 | 43.18           |
| Womens        | Jeans        | 183006.03 | 36.19           |
| Womens        | Jacket       | 322705.54 | 63.81           |

### 8. What is the percentage split of total revenue by category?
``` sql
SELECT 
	category_name,
	ROUND(SUM(qty * s.price * (1-discount/100)), 2) AS revenue,
	ROUND(SUM(qty * s.price * (1-discount/100))/ (SUM(SUM(qty * s.price * (1-discount/100))) OVER()) *100, 2) AS transaction_percent    
FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id
GROUP BY category_name;
```
Result:
| category_name | revenue   | transaction_percent |
| :------------ | :-------- | :------------------ |
| Womens        | 505711.57 | 44.63               |
| Mens          | 627512.29 | 55.37               |

### 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
``` sql
SELECT
	product_name,
    ROUND(COUNT(prod_id)/ (SELECT COUNT(DISTINCT txn_id) FROM sales) *100, 2) AS penetration_rate
FROM sales s
INNER JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY prod_id;
```
Result:
| product_name                     | penetration_rate |
| :------------------------------- | :--------------- |
| Navy Oversized Jeans - Womens    | 50.96            |
| Black Straight Jeans - Womens    | 49.84            |
| Cream Relaxed Jeans - Womens     | 49.72            |
| Khaki Suit Jacket - Womens       | 49.88            |
| Indigo Rain Jacket - Womens      | 50.00            |
| Grey Fashion Jacket - Womens     | 51.00            |
| White Tee Shirt - Mens           | 50.72            |
| Teal Button Up Shirt - Mens      | 49.68            |
| Blue Polo Shirt - Mens           | 50.72            |
| Navy Solid Socks - Mens          | 51.24            |
| White Striped Socks - Mens       | 49.72            |
| Pink Fluro Polkadot Socks - Mens | 50.32            |

### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
``` sql
-- from sales join product_details to create a cte table to select txn_id, prod_id and product_name
-- we get the combination of 3 product by inner join (by txn.id) cte table with itself 2 times
-- to get only the distinct combination we add join condition so that c1.prod_id < c2.prod_id < c3.prod_id
-- count the combination and sort in descending order, limit 1 to get the most common
WITH cte AS(
	SELECT txn_id, prod_id, product_name
    FROM sales s
	INNER JOIN product_details p
		ON s.prod_id = p.product_id)
SELECT c1.product_name, c2.product_name, c3.product_name, COUNT(*) AS total_transaction
FROM cte c1
INNER JOIN cte c2
	ON c1.txn_id = c2.txn_id AND c1.prod_id < c2.prod_id
INNER JOIN cte c3
	ON c1.txn_id = c3.txn_id AND c2.prod_id < c3.prod_id
GROUP BY c1.prod_id, c2.prod_id, c3.prod_id
ORDER BY total_transaction DESC
LIMIT 1;
```
Result:
| product_name           | product_name                 | product_name                | total_transaction |
| :--------------------- | :--------------------------- | :-------------------------- | :---------------- |
| White Tee Shirt - Mens | Grey Fashion Jacket - Womens | Teal Button Up Shirt - Mens | 352               |

<br>

***
Let's move to [D. Reporting Challenge](./D.%20Reporting%20Challenge.md).
