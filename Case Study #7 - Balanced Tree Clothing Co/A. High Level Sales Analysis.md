# Case Study #7 - Balanced Tree Clothing Co.

## A. High Level Sales Analysis

### 1. What was the total quantity sold for all products?
``` sql
SELECT SUM(qty) AS total_quantity
FROM sales;
```
Result:
| total_quantity |
| :------------- |
| 45216          |

### 2. What is the total generated revenue for all products before discounts?
``` sql
SELECT SUM(price * qty) AS total_revenue_before_discounts
FROM sales;
```
Result:
| total_revenue_before_discounts |
| :----------------------------- |
| 1289453                        |

### 3. What was the total discount amount for all products?
``` sql
SELECT SUM(price * qty * discount /100) AS total_discount
FROM sales;
```
Result:
| total_discount |
| :------------- |
| 156229.1400    |

<br>

***
Let's move to [B. Transaction Analysis](./B.%20Transaction%20Analysis.md).
