# Case Study #7 - Balanced Tree Clothing Co.
<img src='https://8weeksqlchallenge.com/images/case-study-designs/7.png' width='400'>

View full case study [here](https://8weeksqlchallenge.com/case-study-7/)

## Introduction
Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer! Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

## Datasets
Dataset for this case study include:
* `product_details` includes all information about the entire range that Balanced Clothing sells in their store
* `sales` contains product level information for all the transactions made for Balanced Tree including quantity, price, percentage discount, member status, a transaction ID and also the transaction timestamp
* 2 additional tables `product_hierarchy` and `product_prices` are used only for the bonus question in Part E.

View SQL schema file [here](./Schema.sql) 

## Case Study Questions

### A. High Level Sales Analysis - [Solution](./A.%20High%20Level%20Sales%20Analysis.md)

<ol>
  <li>What was the total quantity sold for all products?</li>
  <li>What is the total generated revenue for all products before discounts?</li>
  <li>What was the total discount amount for all products?</li>
</ol>

### B. Transaction Analysis - [Solution](./B.%20Transaction%20Analysis.md)

<ol>
  <li>How many unique transactions were there?</li>
  <li>What is the average unique products purchased in each transaction?</li>
  <li>What are the 25th, 50th and 75th percentile values for the revenue per transaction?</li>
  <li>What is the average discount value per transaction?</li>
  <li>What is the percentage split of all transactions for members vs non-members?</li>
  <li>What is the average revenue for member transactions and non-member transactions?</li>
</ol>

### C. Product Analysis - [Solution](./C.%20Product%20Analysis.md)

<ol>
  <li>What are the top 3 products by total revenue before discount?</li>
  <li>What is the total quantity, revenue and discount for each segment?</li>
  <li>What is the top selling product for each segment?</li>
  <li>What is the total quantity, revenue and discount for each category?</li>
  <li>What is the top selling product for each category?</li>
  <li>What is the percentage split of revenue by product for each segment?</li>
  <li>What is the percentage split of revenue by segment for each category?</li>
  <li>What is the percentage split of total revenue by category?</li>
  <li>What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)</li>
  <li>What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?</li>
</ol>

### D. Reporting Challenge - [Solution](./D.%20Reporting%20Challenge.md)

<p>Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.</p>

<p>Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.</p>

<p>He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).</p>

<p>Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)</p>

### E. Bonus Challenge - [Solution](./E.%20Bonus%20Challenge.md)

<p>Use a single SQL query to transform the <code class="language-plaintext highlighter-rouge">product_hierarchy</code> and <code class="language-plaintext highlighter-rouge">product_prices</code> datasets to the <code class="language-plaintext highlighter-rouge">product_details</code> table.</p>

<br>

View full SQL query file [here](./Query.sql).
