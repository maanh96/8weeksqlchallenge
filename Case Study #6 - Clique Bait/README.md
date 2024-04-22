# Case Study #6 - Clique Bait

<img src='https://8weeksqlchallenge.com/images/case-study-designs/6.png' width='400'>

View full case study [here](https://8weeksqlchallenge.com/case-study-6/)

## Introduction
Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry! In this case study - we are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Datasets

<img src='https://user-images.githubusercontent.com/58045173/188321344-2069c761-bfc5-4691-b208-235c845b24bd.png' width='600'>

Dataset for this case study include:

* `users`: Customers who visit the Clique Bait website are tagged via their `cookie_id`
* `events`: Customer visits are logged in this events table at a `cookie_id` level and the `event_type` and `page_id` values can be used to join onto relevant satellite tables to obtain further information about each event
* `event_identifier`: shows the types of events which are captured by Clique Bait’s digital data systems
* `campaign_identifier`: shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020
* `page_hierarchy`: lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

View SQL schema file [here](./Schema.sql) 

## Case Study Questions

### A. Digital Analysis - [Solution](./A.%20Digital%20Analysis.md)

<p>Using the available datasets - answer the following questions using a single query for each one:</p>

<ol>
  <li>How many users are there?</li>
  <li>How many cookies does each user have on average?</li>
  <li>What is the unique number of visits by all users per month?</li>
  <li>What is the number of events for each event type?</li>
  <li>What is the percentage of visits which have a purchase event?</li>
  <li>What is the percentage of visits which view the checkout page but do not have a purchase event?</li>
  <li>What are the top 3 pages by number of views?</li>
  <li>What is the number of views and cart adds for each product category?</li>
  <li>What are the top 3 products by purchases?</li>
</ol>

### B. Product Funnel Analysis - [Solution](./B.%20Product%20Funnel%20Analysis.md)

<p>Using a single SQL query - create a new output table which has the following details:</p>

<ul>
  <li>How many times was each product viewed?</li>
  <li>How many times was each product added to cart?</li>
  <li>How many times was each product added to a cart but not purchased (abandoned)?</li>
  <li>How many times was each product purchased?</li>
</ul>

<p>Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.</p>

<p>Use your 2 new output tables - answer the following questions:</p>

<ol>
  <li>Which product had the most views, cart adds and purchases?</li>
  <li>Which product was most likely to be abandoned?</li>
  <li>Which product had the highest view to purchase percentage?</li>
  <li>What is the average conversion rate from view to cart add?</li>
  <li>What is the average conversion rate from cart add to purchase?</li>
</ol>

### C. Campaigns Analysis - [Solution](C.%20Campaigns%20Analysis.md)

<p>Generate a table that has 1 single row for every unique <code class="language-plaintext highlighter-rouge">visit_id</code> record and has the following columns:</p>

<ul>
  <li><code class="language-plaintext highlighter-rouge">user_id</code></li>
  <li><code class="language-plaintext highlighter-rouge">visit_id</code></li>
  <li><code class="language-plaintext highlighter-rouge">visit_start_time</code>: the earliest <code class="language-plaintext highlighter-rouge">event_time</code> for each visit</li>
  <li><code class="language-plaintext highlighter-rouge">page_views</code>: count of page views for each visit</li>
  <li><code class="language-plaintext highlighter-rouge">cart_adds</code>: count of product cart add events for each visit</li>
  <li><code class="language-plaintext highlighter-rouge">purchase</code>: 1/0 flag if a purchase event exists for each visit</li>
  <li><code class="language-plaintext highlighter-rouge">campaign_name</code>: map the visit to a campaign if the <code class="language-plaintext highlighter-rouge">visit_start_time</code> falls between the <code class="language-plaintext highlighter-rouge">start_date</code> and <code class="language-plaintext highlighter-rouge">end_date</code></li>
  <li><code class="language-plaintext highlighter-rouge">impression</code>: count of ad impressions for each visit</li>
  <li><code class="language-plaintext highlighter-rouge">click</code>: count of ad clicks for each visit</li>
  <li><strong>(Optional column)</strong> <code class="language-plaintext highlighter-rouge">cart_products</code>: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the <code class="language-plaintext highlighter-rouge">sequence_number</code>)</li>
</ul>

<p>Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.</p>

<p>Some ideas you might want to investigate further include:</p>

<ul>
  <li>Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event</li>
  <li>Does clicking on an impression lead to higher purchase rates?</li>
  <li>What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?</li>
  <li>What metrics can you use to quantify the success or failure of each campaign compared to eachother?</li>
</ul>


<br>

View full SQL query file [here](./Query.sql).
