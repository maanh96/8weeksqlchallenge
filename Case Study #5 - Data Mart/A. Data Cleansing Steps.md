# Case Study #5 - Data Mart

## A. Data Cleansing Steps
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

***
<br>

``` sql
DROP TABLE IF EXISTS clean_weekly_sales;

CREATE TABLE clean_weekly_sales
SELECT
	STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
    WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
    MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
    YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
    region, 
    platform, 
    CASE
		WHEN segment = 'null' THEN 'unknown'
        ELSE segment
    END AS segment,
    CASE
		WHEN segment LIKE '%1' THEN 'Young Adults'
        WHEN segment LIKE '%2' THEN 'Middle Aged'
        WHEN segment LIKE '%3' OR segment LIKE '%4' THEN 'Retirees'
        ELSE 'unknown'
    END AS age_band,
    CASE
		WHEN segment LIKE 'C%' THEN 'Couples'
        WHEN segment LIKE 'F%' THEN 'Families'
		ELSE 'unknown'
    END AS demographic,
    customer_type,
    transactions,
    sales,
    ROUND(sales/transactions, 2) AS avg_transaction
FROM weekly_sales;

SELECT * FROM clean_weekly_sales;
```
Result:
| week_date  | week_number | month_number | calendar_year | region        | platform | segment | age_band     | demographic | customer_type | transactions | sales    | avg_transaction |
| :--------- | :---------- | :----------- | :------------ | :------------ | :------- | :------ | :----------- | :---------- | :------------ | :----------- | :------- | :-------------- |
| 2020-08-31 | 35          | 8            | 2020          | ASIA          | Retail   | C3      | Retirees     | Couples     | New           | 120631       | 3656163  | 30.31           |
| 2020-08-31 | 35          | 8            | 2020          | ASIA          | Retail   | F1      | Young Adults | Families    | New           | 31574        | 996575   | 31.56           |
| 2020-08-31 | 35          | 8            | 2020          | USA           | Retail   | unknown | unknown      | unknown     | Guest         | 529151       | 16509610 | 31.20           |
| 2020-08-31 | 35          | 8            | 2020          | EUROPE        | Retail   | C1      | Young Adults | Couples     | New           | 4517         | 141942   | 31.42           |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Retail   | C2      | Middle Aged  | Couples     | New           | 58046        | 1758388  | 30.29           |
| 2020-08-31 | 35          | 8            | 2020          | CANADA        | Shopify  | F2      | Middle Aged  | Families    | Existing      | 1336         | 243878   | 182.54          |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Shopify  | F3      | Retirees     | Families    | Existing      | 2514         | 519502   | 206.64          |
| 2020-08-31 | 35          | 8            | 2020          | ASIA          | Shopify  | F1      | Young Adults | Families    | Existing      | 2158         | 371417   | 172.11          |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Shopify  | F2      | Middle Aged  | Families    | New           | 318          | 49557    | 155.84          |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Retail   | C3      | Retirees     | Couples     | New           | 111032       | 3888162  | 35.02           |
| 2020-08-31 | 35          | 8            | 2020          | USA           | Shopify  | F1      | Young Adults | Families    | Existing      | 1398         | 260773   | 186.53          |
| 2020-08-31 | 35          | 8            | 2020          | OCEANIA       | Shopify  | C2      | Middle Aged  | Couples     | Existing      | 4661         | 882690   | 189.38          |
| 2020-08-31 | 35          | 8            | 2020          | SOUTH AMERICA | Retail   | C2      | Middle Aged  | Couples     | Existing      | 1029         | 38762    | 37.67           |
| 2020-08-31 | 35          | 8            | 2020          | SOUTH AMERICA | Shopify  | C4      | Retirees     | Couples     | New           | 6            | 917      | 152.83          |
| 2020-08-31 | 35          | 8            | 2020          | EUROPE        | Shopify  | F3      | Retirees     | Families    | Existing      | 115          | 35215    | 306.22          |
| 2020-08-31 | 35          | 8            | 2020          | OCEANIA       | Retail   | F3      | Retirees     | Families    | Existing      | 551905       | 30371770 | 55.03           |
| 2020-08-31 | 35          | 8            | 2020          | ASIA          | Shopify  | C3      | Retirees     | Couples     | Existing      | 1969         | 374327   | 190.11          |
| 2020-08-31 | 35          | 8            | 2020          | AFRICA        | Retail   | F1      | Young Adults | Families    | Existing      | 97604        | 5185233  | 53.13           |
| 2020-08-31 | 35          | 8            | 2020          | OCEANIA       | Retail   | C2      | Middle Aged  | Couples     | New           | 111219       | 2980673  | 26.80           |
| 2020-08-31 | 35          | 8            | 2020          | USA           | Retail   | F1      | Young Adults | Families    | New           | 11820        | 463738   | 39.23           |


<br>

***
Let's move to [B. Data Exploration](./B.%20Data%20Exploration.md).
