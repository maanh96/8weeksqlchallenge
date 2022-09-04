# Case Study #5 - Data Mart

<img src='https://8weeksqlchallenge.com/images/case-study-designs/5.png' width='400'>

View full case study [here]()

## Introduction
In June 2020 - large scale supply changes were made at Data Mart, Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer. Danny needs our help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

## Datasets
<img src='https://8weeksqlchallenge.com/images/case-study-5-erd.png'>

For this case study there is only a single table - `weekly_sales`, which:

* has international operations using a multi-`region` strategy
* has both, a retail and online `platform` in the form of a Shopify store front to serve their customers
* Customer `segment` and `customer_type` data relates to personal age and demographics information that is shared with Data Mart
* `transactions` is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases
* Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a `week_date` value which represents the start of the sales week.

View SQL schema file [here](./Schema.sql) 

## Case Study Questions

### A. Data Cleansing Steps - [Solution](./A.%20Data%20Cleansing%20Steps.md)

<p>In a single query, perform the following operations and generate a new table in the <code class="language-plaintext highlighter-rouge">data_mart</code> schema named <code class="language-plaintext highlighter-rouge">clean_weekly_sales</code>:</p>

<ul>
  <li>
    <p>Convert the <code class="language-plaintext highlighter-rouge">week_date</code> to a <code class="language-plaintext highlighter-rouge">DATE</code> format</p>
  </li>
  <li>
    <p>Add a <code class="language-plaintext highlighter-rouge">week_number</code> as the second column for each <code class="language-plaintext highlighter-rouge">week_date</code> value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc</p>
  </li>
  <li>
    <p>Add a <code class="language-plaintext highlighter-rouge">month_number</code> with the calendar month for each <code class="language-plaintext highlighter-rouge">week_date</code> value as the 3rd column</p>
  </li>
  <li>
    <p>Add a <code class="language-plaintext highlighter-rouge">calendar_year</code> column as the 4th column containing either 2018, 2019 or 2020 values</p>
  </li>
  <li>
    <p>Add a new column called <code class="language-plaintext highlighter-rouge">age_band</code> after the original <code class="language-plaintext highlighter-rouge">segment</code> column using the following mapping on the number inside the <code class="language-plaintext highlighter-rouge">segment</code> value</p>
  </li>
</ul>

<table>
  <thead>
    <tr>
      <th>segment</th>
      <th>age_band</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>Young Adults</td>
    </tr>
    <tr>
      <td>2</td>
      <td>Middle Aged</td>
    </tr>
    <tr>
      <td>3 or 4</td>
      <td>Retirees</td>
    </tr>
  </tbody>
</table>

<ul>
  <li>Add a new <code class="language-plaintext highlighter-rouge">demographic</code> column using the following mapping for the first letter in the <code class="language-plaintext highlighter-rouge">segment</code> values:</li>
</ul>

<table>
  <tbody>
    <tr>
      <td>segment</td>
      <td>demographic</td>
    </tr>
    <tr>
      <td>C</td>
      <td>Couples</td>
    </tr>
    <tr>
      <td>F</td>
      <td>Families</td>
    </tr>
  </tbody>
</table>

<ul>
  <li>
    <p>Ensure all <code class="language-plaintext highlighter-rouge">null</code> string values with an <code class="language-plaintext highlighter-rouge">"unknown"</code> string value in the original <code class="language-plaintext highlighter-rouge">segment</code> column as well as the new <code class="language-plaintext highlighter-rouge">age_band</code> and <code class="language-plaintext highlighter-rouge">demographic</code> columns</p>
  </li>
  <li>
    <p>Generate a new <code class="language-plaintext highlighter-rouge">avg_transaction</code> column as the <code class="language-plaintext highlighter-rouge">sales</code> value divided by <code class="language-plaintext highlighter-rouge">transactions</code> rounded to 2 decimal places for each record</p>
  </li>
</ul>

### B. Data Exploration - [Solution](./B.%20Data%20Exploration.md)

<ol>
  <li>What day of the week is used for each <code class="language-plaintext highlighter-rouge">week_date</code> value?</li>
  <li>What range of week numbers are missing from the dataset?</li>
  <li>How many total transactions were there for each year in the dataset?</li>
  <li>What is the total sales for each region for each month?</li>
  <li>What is the total count of transactions for each platform</li>
  <li>What is the percentage of sales for Retail vs Shopify for each month?</li>
  <li>What is the percentage of sales by demographic for each year in the dataset?</li>
  <li>Which <code class="language-plaintext highlighter-rouge">age_band</code> and <code class="language-plaintext highlighter-rouge">demographic</code> values contribute the most to Retail sales?</li>
  <li>Can we use the <code class="language-plaintext highlighter-rouge">avg_transaction</code> column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?</li>
</ol>

### C. Before & After Analysis - [Solution](C.%20Before%20&%20After%20Analysis.md) 

<p>This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.</p>

<p>Taking the <code class="language-plaintext highlighter-rouge">week_date</code> value of <code class="language-plaintext highlighter-rouge">2020-06-15</code> as the baseline week where the Data Mart sustainable packaging changes came into effect.</p>

<p>We would include all <code class="language-plaintext highlighter-rouge">week_date</code> values for <code class="language-plaintext highlighter-rouge">2020-06-15</code> as the start of the period <strong>after</strong> the change and the previous <code class="language-plaintext highlighter-rouge">week_date</code> values would be <strong>before</strong></p>

<p>Using this analysis approach - answer the following questions:</p>

<ol>
  <li>What is the total sales for the 4 weeks before and after <code class="language-plaintext highlighter-rouge">2020-06-15</code>? What is the growth or reduction rate in actual values and percentage of sales?</li>
  <li>What about the entire 12 weeks before and after?</li>
  <li>How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?</li>
</ol>

### D. Bonus Question - [Solution](./D.%20Bonus%20Question.md)

<p>Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?</p>

<ul>
  <li><code class="language-plaintext highlighter-rouge">region</code></li>
  <li><code class="language-plaintext highlighter-rouge">platform</code></li>
  <li><code class="language-plaintext highlighter-rouge">age_band</code></li>
  <li><code class="language-plaintext highlighter-rouge">demographic</code></li>
  <li><code class="language-plaintext highlighter-rouge">customer_type</code></li>
</ul>

<p>Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?</p>


<br>

View full SQL query file [here](./Query.sql).
