# Case Study #3 - Foodie-Fi
<img src='https://8weeksqlchallenge.com/images/case-study-designs/3.png' width='400'>

View full case study [here](https://8weeksqlchallenge.com/case-study-3/)

## Introduction
Danny and his friends launched his new startup Foodie-Fi, a new streaming service that only had food related content, in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world. We will help him querying relevant data and create new tables to answer important business questions.

## Datasets
<img src='https://8weeksqlchallenge.com/images/case-study-3-erd.png'>

Dataset for this case study include:
* `plans`: Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial. When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price but their plan will continue until the end of the billing period.
<center>

| plan_id | plan_name     | price |
| ------- | ------------- | ----- |
| 0       | trial         | 0     |
| 1       | basic monthly | 9.90  |
| 2       | pro monthly   | 19.90 |
| 3       | pro annual    | 199   |
| 4       | churn         | null  |
</center>

* `subscriptions`: including `customer_id`, `plan_id` and `start_date`. If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the `start_date` in the subscriptions table will reflect the date that the actual plan changes. When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway. When customers churn - they will keep their access until the end of their current billing period but the `start_date` will be technically the day they decided to cancel their service. 

View SQL schema file [here](./Schema.sql) 

## Case Study Questions

### A. Customer Journey - [Solution](./A.%20Customer%20Journey.md)
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

### B. Data Analysis Questions - [Solution](./B.%20Data%20Analysis%20Questions.md)
<ol>
  <li>How many customers has Foodie-Fi ever had?</li>
  <li>What is the monthly distribution of <code class="language-plaintext highlighter-rouge">trial</code> plan <code class="language-plaintext highlighter-rouge">start_date</code> values for our dataset - use the start of the month as the group by value</li>
  <li>What plan <code class="language-plaintext highlighter-rouge">start_date</code> values occur after the year 2020 for our dataset? Show the breakdown by count of events for each <code class="language-plaintext highlighter-rouge">plan_name</code></li>
  <li>What is the customer count and percentage of customers who have churned rounded to 1 decimal place?</li>
  <li>How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?</li>
  <li>What is the number and percentage of customer plans after their initial free trial?</li>
  <li>What is the customer count and percentage breakdown of all 5 <code class="language-plaintext highlighter-rouge">plan_name</code> values at <code class="language-plaintext highlighter-rouge">2020-12-31</code>?</li>
  <li>How many customers have upgraded to an annual plan in 2020?</li>
  <li>How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?</li>
  <li>Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)</li>
  <li>How many customers downgraded from a pro monthly to a basic monthly plan in 2020?</li>
</ol>

### C. Challenge Payment Question - [Solution](./C.%20Challenge%20Payment%20Question.md)
The Foodie-Fi team wants you to create a new <code class="language-plaintext highlighter-rouge">payments</code> table for the year 2020 that includes amounts paid by each customer in the <code class="language-plaintext highlighter-rouge">subscriptions</code> table with the following requirements:</p>

<ul>
  <li>monthly payments always occur on the same day of month as the original <code class="language-plaintext highlighter-rouge">start_date</code> of any monthly paid plan</li>
  <li>upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately</li>
  <li>upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period</li>
  <li>once a customer churns they will no longer make payments</li>
</ul>

### D. Outside The Box Questions - [Solution](./D.%20Outside%20The%20Box%20Questions.md)
<ol>
  <li>How would you calculate the rate of growth for Foodie-Fi?</li>
  <li>What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?</li>
  <li>What are some key customer journeys or experiences that you would analyse further to improve customer retention?</li>
  <li>If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?</li>
  <li>What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?</li>
</ol>

<br>

View full SQL query file [here](./Query.sql).
