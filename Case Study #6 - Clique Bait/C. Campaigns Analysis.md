# Case Study #6 - Clique Bait

## C. Campaigns Analysis

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

<p>Use the subsequent dataset to generate at least 5 insights for the Clique Bait team.</p>

<p>Some ideas you might want to investigate further include:</p>

<ul>
  <li>Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event</li>
  <li>Does clicking on an impression lead to higher purchase rates?</li>
  <li>What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?</li>
  <li>What metrics can you use to quantify the success or failure of each campaign compared to each other?</li>
</ul>

***

```sql
DROP TABLE IF EXISTS visits;
CREATE TEMPORARY TABLE visits
SELECT
	user_id,
    visit_id,
    MIN(event_time) AS visit_start_time,
    SUM(CASE WHEN event_type = 1 THEN 1 END) AS page_views,
    SUM(CASE WHEN event_type = 2 THEN 1 END) AS cart_adds,
    SUM(CASE WHEN event_type = 3 THEN 1 END) AS purchase,
    campaign_name,
    SUM(CASE WHEN event_type = 4 THEN 1 END) AS impression,
    SUM(CASE WHEN event_type = 5 THEN 1 END) AS click,
    GROUP_CONCAT(page_name ORDER BY sequence_number SEPARATOR ', ') AS cart_products
FROM events e
INNER JOIN users u
	ON e.cookie_id = u.cookie_id
LEFT JOIN campaign_identifier c
	ON event_time BETWEEN c.start_date AND c.end_date
LEFT JOIN page_hierarchy p
	ON e.page_id = p.page_id AND event_type = 2 AND product_id IS NOT NULL
GROUP BY user_id, visit_id;
SELECT * FROM visits;
```
Result:
| user_id | visit_id | visit_start_time    | page_views | cart_adds | purchase | campaign_name                     | impression | click | cart_products                                                                         |
| :------ | :------- | :------------------ | :--------- | :-------- | :------- | :-------------------------------- | :--------- | :---- | :------------------------------------------------------------------------------------ |
| 1       | 02a5d5   | 2020-02-26 16:57:26 | 4          |           |          | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |
| 1       | 0826dc   | 2020-02-26 05:58:38 | 1          |           |          | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |
| 1       | 0fc437   | 2020-02-04 17:49:50 | 10         | 6         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster                            |
| 1       | 30b94d   | 2020-03-15 13:12:54 | 9          | 7         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab                        |
| 1       | 41355d   | 2020-03-25 00:11:18 | 6          | 1         |          | Half Off - Treat Your Shellf(ish) |            |       | Lobster                                                                               |
| 1       | ccf365   | 2020-02-04 19:16:09 | 7          | 3         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Lobster, Crab, Oyster                                                                 |
| 1       | eaffde   | 2020-03-25 20:06:32 | 10         | 8         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster           |
| 1       | f7c798   | 2020-03-15 02:23:26 | 9          | 3         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Russian Caviar, Crab, Oyster                                                          |
| 2       | 0635fb   | 2020-02-16 06:42:43 | 9          | 4         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Salmon, Kingfish, Abalone, Crab                                                       |
| 2       | 1f1198   | 2020-02-01 21:51:55 | 1          |           |          | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |
| 2       | 3b5871   | 2020-01-18 10:16:32 | 9          | 6         | 1        | 25% Off - Living The Lux Life     | 1          | 1     | Salmon, Kingfish, Russian Caviar, Black Truffle, Lobster, Oyster                      |
| 2       | 49d73d   | 2020-02-16 06:21:27 | 11         | 9         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Kingfish, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster |
| 2       | 910d9a   | 2020-02-01 10:40:47 | 8          | 1         |          | Half Off - Treat Your Shellf(ish) |            |       | Abalone                                                                               |
| 2       | c5c0ee   | 2020-01-18 10:35:23 | 1          |           |          | 25% Off - Living The Lux Life     |            |       |                                                                                       |
| 2       | d58cbd   | 2020-01-18 23:40:55 | 8          | 4         |          | 25% Off - Living The Lux Life     |            |       | Kingfish, Tuna, Abalone, Crab                                                         |
| ...     | ...      | ...                 | ...        | ....      | ...      | ...                               | ...        | ...   | ...                                                                                   | ... |

### Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
```sql
WITH cte AS (
	SELECT 
		user_id,
		campaign_name,
		CASE
			WHEN SUM(impression) > 0 THEN 'impress' ELSE 'no impress'
		END AS impress_status,
        COUNT(*) AS total_visit, 
		SUM(page_views)/COUNT(*) AS page_views_per_visit, 
		SUM(cart_adds)/COUNT(*) AS cart_adds_per_visit, 
		SUM(purchase)/COUNT(*) * 100 AS purchase_rate
	FROM visits
    WHERE campaign_name IS NOT NULL
	GROUP BY user_id, campaign_name)
SELECT
	campaign_name, 
    impress_status, 
    ROUND(AVG(total_visit), 2) AS avg_visit, 
    ROUND(AVG(page_views_per_visit), 2) AS avg_page_views_per_visit, 
    ROUND(AVG(cart_adds_per_visit), 2) AS avg_cart_adds_per_visit, 
    ROUND(AVG(purchase_rate), 2) AS avg_purchase_rate
FROM cte
GROUP BY campaign_name, impress_status
ORDER BY campaign_name;
```
Result:
| campaign_name                     | impress_status | avg_visit | avg_page_views_per_visit | avg_cart_adds_per_visit | avg_purchase_rate |
| :-------------------------------- | :------------- | :-------- | :----------------------- | :---------------------- | :---------------- |
| 25% Off - Living The Lux Life     | impress        | 2.73      | 7.47                     | 3.38                    | 62.09             |
| 25% Off - Living The Lux Life     | no impress     | 2.26      | 4.07                     | 1.15                    | 30.80             |
| BOGOF - Fishing For Compliments   | impress        | 2.78      | 7.29                     | 3.40                    | 63.42             |
| BOGOF - Fishing For Compliments   | no impress     | 2.18      | 4.13                     | 1.10                    | 30.68             |
| Half Off - Treat Your Shellf(ish) | impress        | 5.71      | 6.28                     | 2.64                    | 54.47             |
| Half Off - Treat Your Shellf(ish) | no impress     | 3.90      | 3.96                     | 1.18                    | 28.52             |

In general, users who have received impressions during campaign visit more often, view more page, add to cart more product and had almost double purchase rates.

### Does clicking on an impression lead to higher purchase rates?
```sql
SELECT
	ROUND(SUM(CASE WHEN purchase = 1 AND click = 1 THEN 1 END)/SUM(CASE WHEN click = 1 THEN 1 END) * 100, 2) AS purchase_rates_with_click,
    ROUND(SUM(CASE WHEN purchase = 1 AND click = 0 THEN 1 END)/SUM(CASE WHEN click = 0 THEN 1 END) * 100, 2) AS purchase_rates_no_click
FROM visits;
```
Result:
| purchase_rates_with_click | purchase_rates_no_click |
| :------------------------ | :---------------------- |
| 88.89                     | 40.29                   |

The query result shows that users who clicked on an impression had a significantly higher purchase rate (88.89%) compared to those who did not click on an impression (40.29%).

### What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
```sql
WITH cte AS (
	SELECT 
		user_id,
		campaign_name,
		CASE
			WHEN SUM(click) > 0 THEN 'click'
            WHEN SUM(impression) > 0 THEN 'impress no click'
            ELSE 'no impress'
		END AS campaign_status,
		SUM(purchase)/COUNT(*) * 100 AS purchase_rate
	FROM visits
    WHERE campaign_name IS NOT NULL
	GROUP BY user_id, campaign_name)
SELECT
	campaign_name, 
    campaign_status, 
    ROUND(AVG(purchase_rate), 2) AS avg_purchase_rate
FROM cte
GROUP BY campaign_name, campaign_status
ORDER BY campaign_name;
```
Result:
| campaign_name                     | campaign_status | avg_purchase_rate |
| :-------------------------------- | :-------------- | :---------------- |
| 25% Off - Living The Lux Life     | click           | 62.32             |
| 25% Off - Living The Lux Life     | impress no click         | 61.25             |
| 25% Off - Living The Lux Life     | no impress      | 30.80             |
| BOGOF - Fishing For Compliments   | click           | 64.00             |
| BOGOF - Fishing For Compliments   | impress no click         | 60.19             |
| BOGOF - Fishing For Compliments   | no impress      | 30.68             |
| Half Off - Treat Your Shellf(ish) | click           | 55.16             |
| Half Off - Treat Your Shellf(ish) | impress no click         | 49.78             |
| Half Off - Treat Your Shellf(ish) | no impress      | 28.52             |

People who click on a campaign impression have almost double higher purchase rate compare with users who do not receive an impression and just lightly higher purchase rate compare with users who have an impression but do not click.

***
~ This is the end of Case Study 6 ~

Back to [Main menu](https://github.com/maanh96/8weeksqlchallenge).