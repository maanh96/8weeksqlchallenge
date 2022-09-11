# Case Study #8 - Fresh Segments
<img src='https://8weeksqlchallenge.com/images/case-study-designs/8.png' width='400'>

View full case study [here](https://8weeksqlchallenge.com/case-study-8/)

## Introduction
Danny created Fresh Segments, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

Danny has asked for our assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.

## Datasets
<img src=''>
Dataset for this case study include:


View SQL schema file [here](./Schema.sql) 

## Case Study Questions

### A. Data Exploration and Cleansing - [Solution](./A.%20Data%20Exploration%20and%20Cleansing.md)

<ol>
  <li>Update the <code class="language-plaintext highlighter-rouge">fresh_segments.interest_metrics</code> table by modifying the <code class="language-plaintext highlighter-rouge">month_year</code> column to be a date data type with the start of the month</li>
  <li>What is count of records in the <code class="language-plaintext highlighter-rouge">fresh_segments.interest_metrics</code> for each <code class="language-plaintext highlighter-rouge">month_year</code> value sorted in chronological order (earliest to latest) with the null values appearing first?</li>
  <li>What do you think we should do with these null values in the <code class="language-plaintext highlighter-rouge">fresh_segments.interest_metrics</code></li>
  <li>How many <code class="language-plaintext highlighter-rouge">interest_id</code> values exist in the <code class="language-plaintext highlighter-rouge">fresh_segments.interest_metrics</code> table but not in the <code class="language-plaintext highlighter-rouge">fresh_segments.interest_map</code> table? What about the other way around?</li>
  <li>Summarise the <code class="language-plaintext highlighter-rouge">id</code> values in the <code class="language-plaintext highlighter-rouge">fresh_segments.interest_map</code> by its total record count in this table</li>
  <li>What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where <code class="language-plaintext highlighter-rouge">interest_id = 21246</code> in your joined output and include all columns from <code class="language-plaintext highlighter-rouge">fresh_segments.interest_metrics</code> and all columns from <code class="language-plaintext highlighter-rouge">fresh_segments.interest_map</code> except from the <code class="language-plaintext highlighter-rouge">id</code> column.</li>
  <li>Are there any records in your joined table where the <code class="language-plaintext highlighter-rouge">month_year</code> value is before the <code class="language-plaintext highlighter-rouge">created_at</code> value from the <code class="language-plaintext highlighter-rouge">fresh_segments.interest_map</code> table? Do you think these values are valid and why?</li>
</ol>

### B. Interest Analysis - [Solution](./B.%20Interest%20Analysis.md)

<ol>
  <li>Which interests have been present in all <code class="language-plaintext highlighter-rouge">month_year</code> dates in our dataset?</li>
  <li>Using this same <code class="language-plaintext highlighter-rouge">total_months</code> measure - calculate the cumulative percentage of all records starting at 14 months - which <code class="language-plaintext highlighter-rouge">total_months</code> value passes the 90% cumulative percentage value?</li>
  <li>If we were to remove all <code class="language-plaintext highlighter-rouge">interest_id</code> values which are lower than the <code class="language-plaintext highlighter-rouge">total_months</code> value we found in the previous question - how many total data points would we be removing?</li>
  <li>Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed <code class="language-plaintext highlighter-rouge">interest</code> example for your arguments - think about what it means to have less months present from a segment perspective.</li>
  <li>After removing these interests - how many unique interests are there for each month?</li>
</ol>

### C. Segment Analysis - [Solution](./C.%20Segment%20Analysis.md)

<ol>
  <li>Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any <code class="language-plaintext highlighter-rouge">month_year</code>? Only use the maximum composition value for each interest but you must keep the corresponding <code class="language-plaintext highlighter-rouge">month_year</code></li>
  <li>Which 5 interests had the lowest average <code class="language-plaintext highlighter-rouge">ranking</code> value?</li>
  <li>Which 5 interests had the largest standard deviation in their <code class="language-plaintext highlighter-rouge">percentile_ranking</code> value?</li>
  <li>For the 5 interests found in the previous question - what was minimum and maximum <code class="language-plaintext highlighter-rouge">percentile_ranking</code> values for each interest and its corresponding <code class="language-plaintext highlighter-rouge">year_month</code> value? Can you describe what is happening for these 5 interests?</li>
  <li>How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?</li>
</ol>

### D. Index Analysis - [Solution](./D.%20Index%20Analysis.md)

<p>The <code class="language-plaintext highlighter-rouge">index_value</code> is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.</p>

<p>Average composition can be calculated by dividing the <code class="language-plaintext highlighter-rouge">composition</code> column by the <code class="language-plaintext highlighter-rouge">index_value</code> column rounded to 2 decimal places.</p>

<ol>
  <li>What is the top 10 interests by the average composition for each month?</li>
  <li>For all of these top 10 interests - which interest appears the most often?</li>
  <li>What is the average of the average composition for the top 10 interests for each month?</li>
  <li>What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.</li>
  <li>Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?</li>
</ol>

<br>

View full SQL query file [here](./Query.sql).