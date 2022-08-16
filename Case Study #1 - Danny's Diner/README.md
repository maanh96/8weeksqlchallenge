# Case Study #1 - Danny's Diner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" width="400">

View full case study [here](https://8weeksqlchallenge.com/case-study-1/)

## Introduction
Danny opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen. He is in need of our assistance to  answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.

## Datasets

![image](https://user-images.githubusercontent.com/58045173/184476035-06f9e40b-022f-4339-ba81-7f77e78c57c2.png)

Dataset for this case study include:
* `sales`: captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered
* `menu`: maps the `product_id` to the actual `product_name` and price of each menu item
* `members`: captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program

View SQL schema file [here](./Schema.sql) 

## Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

<ol>
  <li>What is the total amount each customer spent at the restaurant?</li>
  <li>How many days has each customer visited the restaurant?</li>
  <li>What was the first item from the menu purchased by each customer?</li>
  <li>What is the most purchased item on the menu and how many times was it purchased by all customers?</li>
  <li>Which item was the most popular for each customer?</li>
  <li>Which item was purchased first by the customer after they became a member?</li>
  <li>Which item was purchased just before the customer became a member?</li>
  <li>What is the total items and amount spent for each member before they became a member?</li>
  <li>If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?</li>
  <li>In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?</li>
</ol>

<br>

View my solution [here](./Answer.md) or SQL query file [here](./Query.sql).
