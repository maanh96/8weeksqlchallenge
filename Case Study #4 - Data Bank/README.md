# Case Study #4 - Data Bank
<img src='https://8weeksqlchallenge.com/images/case-study-designs/4.png' width='400'>

View the full case study [here](https://8weeksqlchallenge.com/case-study-4/).

## Introduction
Danny decides to launch a new initiative - Data Bank, which is a combination of the new age banks, cryptocurrency and the secure distributed data storage platform. Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. Data Bank team need our help to track how much data storage their customers will need, calculate metrics, growth and analyse their data in a smart way to better forecast and plan for their future developments.

## Datasets
<img src='https://8weeksqlchallenge.com/images/case-study-4-erd.png'>

The dataset for this case study includes:
* `regions`: contains the `region_id` and their respective `region_name` values
* `customer_nodes`: customers are randomly distributed across the nodes according to their region - this also specifies exactly which node contains both their cash and data. This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data
* `customer_transactions`: stores all customer deposits, withdrawals and purchases made using their Data Bank debit card

View SQL schema file [here](./Schema.sql).

## Case Study Questions

### A. Customer Nodes Exploration - [Solution](./A.%20Customer%20Nodes%20Exploration.md)
<ol>
  <li>How many unique nodes are there on the Data Bank system?</li>
  <li>What is the number of nodes per region?</li>
  <li>How many customers are allocated to each region?</li>
  <li>How many days on average are customers reallocated to a different node?</li>
  <li>What is the median, 80th and 95th percentile for this same reallocation days metric for each region?</li>
</ol>

### B. Customer Transactions - [Solution](./B.%20Customer%20Transactions.md)
<ol>
  <li>What is the unique count and total amount for each transaction type?</li>
  <li>What is the average total historical deposit counts and amounts for all customers?</li>
  <li>For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?</li>
  <li>What is the closing balance for each customer at the end of the month?</li>
  <li>What is the percentage of customers who increase their closing balance by more than 5%?</li>
</ol>

### C. Data Allocation Challenge - [Solution](./C.%20Data%20Allocation%20Challenge.md)
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:
<ul>
  <li>Option 1: data is allocated based off the amount of money at the end of the previous month</li>
  <li>Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days</li>
  <li>Option 3: data is updated real-time</li>
</ul>

For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:
<ul>
  <li>running customer balance column that includes the impact each transaction</li>
  <li>customer balance at the end of each month</li>
  <li>minimum, average and maximum values of the running balance for each customer</li>
</ul>

Using all of the data available - how much data would have been required for each option on a monthly basis?

### D. Extra Challenge - [Solution](./D.%20Extra%20Challenge.md)

Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Special notes:

<ul>
  <li>Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!</li>
</ul>

<br>

View the full SQL query file [here](./Query.sql).