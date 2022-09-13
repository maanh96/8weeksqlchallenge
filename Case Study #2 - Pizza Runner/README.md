# Case Study #2 - Pizza Runner
<img src='https://8weeksqlchallenge.com/images/case-study-designs/2.png' width='400'>

View full case study [here](https://8weeksqlchallenge.com/case-study-2/)

## Introduction
Danny wanted to expand his new Pizza Empire by launching Pizza Runner program. He started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. He need our further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimize Pizza Runner’s operations.

## Datasets

![Pizza Runner](https://user-images.githubusercontent.com/58045173/188302025-0298e873-9c67-4cd3-94d5-f7c7200f619d.png)

Dataset for this case study include:
* `runners`: shows the `registration_date` for each new runner
* `customer_orders`: captures customer pizza orders with 1 row for **each individual pizza** that is part of the order, `exclusions` are the `ingredient_id` values which should be removed from the pizza and `extras` are the `ingredient_id` values which need to be added to the pizza
* `runner_orders`: records infos of each order's delivery, `pickup_time` is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas, `distance` and `duration` fields are related to how far and long the runner had to travel to deliver the order to the respective customer
* `pizza_names`: contains `pizza_id` and corresponding `pizza_name`
* `pizza_recipes`: `pizza_id` has a standard set of `toppings` which are used as part of the pizza recipe
* `pizza_toppings`: contains all of the `topping_name` values with their corresponding `topping_id` value

View SQL schema file [here](./Schema.sql) 

## Case Study Questions
Before writing SQL queries we will need to clean the data in the `customer_orders` and `runner_orders` tables: [Data cleaning](./0.%20Data%20cleaning.md).

### A. Pizza Metrics - [Solution](./A.%20Pizza%20Metrics.md)
<ol>
  <li>How many pizzas were ordered?</li>
  <li>How many unique customer orders were made?</li>
  <li>How many successful orders were delivered by each runner?</li>
  <li>How many of each type of pizza was delivered?</li>
  <li>How many Vegetarian and Meatlovers were ordered by each customer?</li>
  <li>What was the maximum number of pizzas delivered in a single order?</li>
  <li>For each customer, how many delivered pizzas had at least 1 change and how many had no changes?</li>
  <li>How many pizzas were delivered that had both exclusions and extras?</li>
  <li>What was the total volume of pizzas ordered for each hour of the day?</li>
  <li>What was the volume of orders for each day of the week?</li>
</ol>

### B. Runner and Customer Experience - [Solution](./B.%20Runner%20and%20Customer%20Experience.md)
<ol>
  <li>How many runners signed up for each 1 week period? (i.e. week starts <code>2021-01-01</code>)</li>
  <li>What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?</li>
  <li>Is there any relationship between the number of pizzas and how long the order takes to prepare?</li>
  <li>What was the average distance travelled for each customer?</li>
  <li>What was the difference between the longest and shortest delivery times for all orders?</li>
  <li>What was the average speed for each runner for each delivery and do you notice any trend for these values?</li>
  <li>What is the successful delivery percentage for each runner?</li>
</ol>

### C. Ingredient Optimisation - [Solution](./C.%20Ingredient%20Optimisation.md)
<ol>
  <li>What are the standard ingredients for each pizza?</li>
  <li>What was the most commonly added extra?</li>
  <li>What was the most common exclusion?</li>
  <li>Generate an order item for each record in the <code>customers_orders</code> table in the format of one of the following:
    <ul>
      <li><code>Meat Lovers</code></li>
      <li><code>Meat Lovers - Exclude Beef</code></li>
      <li><code>Meat Lovers - Extra Bacon</code></li>
      <li><code>Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers</code></li>
    </ul>
  </li>
  <li>Generate an alphabetically ordered comma separated ingredient list for each pizza order from the <code>customer_orders</code> table and add a <code>2x</code> in front of any relevant ingredients
    <ul>
      <li>For example: <code>"Meat Lovers: 2xBacon, Beef, ... , Salami"</code></li>
    </ul>
  </li>
  <li>What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?</li>
</ol>

### D. Pricing and Ratings - [Solution](./D.%20Pricing%20and%20Ratings%20%26%20E.%20Bonus%20Questions.md)
<ol>
  <li>If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?</li>
  <li>What if there was an additional $1 charge for any pizza extras?
    <ul>
      <li>Add cheese is $1 extra</li>
    </ul>
  </li>
  <li>The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.</li>
  <li>Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
    <ul>
      <li><code>customer_id</code></li>
      <li><code>order_id</code></li>
      <li><code>runner_id</code></li>
      <li><code>rating</code></li>
      <li><code>order_time</code></li>
      <li><code>pickup_time</code></li>
      <li>Time between order and pickup</li>
      <li>Delivery duration</li>
      <li>Average speed</li> 
      <li>Total number of pizzas</li>
    </ul>
  </li>
  <li>If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?</li>
</ol>


### E. Bonus Questions - [Solution](./D.%20Pricing%20and%20Ratings%20%26%20E.%20Bonus%20Questions.md#e-bonus-questions)
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an <code>INSERT</code> statement to demonstrate what would happen if a new <code>Supreme</code> pizza with all the toppings was added to the Pizza Runner menu?

<br>

View full SQL query file [here](./Query.sql).
