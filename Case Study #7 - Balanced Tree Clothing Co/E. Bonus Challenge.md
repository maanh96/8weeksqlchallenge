# Case Study #7 - Balanced Tree Clothing Co.

## E. Bonus Challenge

<p>Use a single SQL query to transform the <code class="language-plaintext highlighter-rouge">product_hierarchy</code> and <code class="language-plaintext highlighter-rouge">product_prices</code> datasets to the <code class="language-plaintext highlighter-rouge">product_details</code> table.</p>


```sql
DROP TABLE IF EXISTS product_details_temp;
CREATE TEMPORARY TABLE product_details_temp
SELECT 
	product_id, 
    price,
    CONCAT(h1.level_text, ' ', h2.level_text, ' - ', h3.level_text) AS product_name,
    h3.id AS category_id,
    h2.id AS segment_id,
    p.id AS style_id, 
    h3.level_text AS category_name,
    h2.level_text AS segment_name,
    h1.level_text AS style_name
FROM product_prices p
INNER JOIN product_hierarchy h1
	ON p.id = h1.id
INNER JOIN product_hierarchy h2
	ON h1.parent_id = h2.id
INNER JOIN product_hierarchy h3
	ON h2.parent_id = h3.id
ORDER BY category_id, segment_id, style_id;
SELECT * FROM product_details_temp;
```
Result:
| product_id | price | product_name                     | category_id | segment_id | style_id | category_name | segment_name | style_name          |
| :--------- | :---- | :------------------------------- | :---------- | :--------- | :------- | :------------ | :----------- | :------------------ |
| c4a632     | 13    | Navy Oversized Jeans - Womens    | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized      |
| e83aa3     | 32    | Black Straight Jeans - Womens    | 1           | 3          | 8        | Womens        | Jeans        | Black Straight      |
| e31d39     | 10    | Cream Relaxed Jeans - Womens     | 1           | 3          | 9        | Womens        | Jeans        | Cream Relaxed       |
| d5e9a6     | 23    | Khaki Suit Jacket - Womens       | 1           | 4          | 10       | Womens        | Jacket       | Khaki Suit          |
| 72f5d4     | 19    | Indigo Rain Jacket - Womens      | 1           | 4          | 11       | Womens        | Jacket       | Indigo Rain         |
| 9ec847     | 54    | Grey Fashion Jacket - Womens     | 1           | 4          | 12       | Womens        | Jacket       | Grey Fashion        |
| 5d267b     | 40    | White Tee Shirt - Mens           | 2           | 5          | 13       | Mens          | Shirt        | White Tee           |
| c8d436     | 10    | Teal Button Up Shirt - Mens      | 2           | 5          | 14       | Mens          | Shirt        | Teal Button Up      |
| 2a2353     | 57    | Blue Polo Shirt - Mens           | 2           | 5          | 15       | Mens          | Shirt        | Blue Polo           |
| f084eb     | 36    | Navy Solid Socks - Mens          | 2           | 6          | 16       | Mens          | Socks        | Navy Solid          |
| b9a74d     | 17    | White Striped Socks - Mens       | 2           | 6          | 17       | Mens          | Socks        | White Striped       |
| 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens | 2           | 6          | 18       | Mens          | Socks        | Pink Fluro Polkadot |

<br>

***
Back to [Main menu](https://github.com/maanh96/8weeksqlchallenge).
