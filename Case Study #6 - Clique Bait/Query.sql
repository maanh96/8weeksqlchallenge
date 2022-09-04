/* --------------------
   Case Study Questions
   --------------------*/

-- A. Digital Analysis --
-- 1. How many users are there?
SELECT COUNT(DISTINCT user_id) AS total_users
FROM users;

-- 2 .How many cookies does each user have on average?
WITH cte AS(
	SELECT user_id, COUNT(cookie_id) AS total_cookie
	FROM users
	GROUP BY user_id)
SELECT ROUND(AVG(total_cookie), 2) AS avg_cookie
FROM cte;

-- 3. What is the unique number of visits by all users per month?
SELECT
	MONTH(event_time) AS month,
    COUNT(DISTINCT visit_id) AS total_visit
FROM events
GROUP BY month;

-- 4. What is the number of events for each event type?
SELECT
	e.event_type,
    event_name,
    COUNT(*) AS total_events
FROM events e
INNER JOIN event_identifier i
	ON e.event_type = i.event_type
GROUP BY e.event_type;

-- 5. What is the percentage of visits which have a purchase event?
SELECT 
	ROUND(COUNT(DISTINCT visit_id)/ (SELECT COUNT(DISTINCT visit_id) FROM events) *100, 2) AS purchase_visit_percent
FROM events
WHERE event_type = 3;

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
	-- from events create checkout_cte to select distinct of visit_id that view the checkout page
    -- left join with events with event_type = 3 (purchase)
    -- count where the event_type is null (no purchase) and divide to total visit_id in checkout_cte to get the percentage
WITH checkout_cte AS(
	SELECT DISTINCT visit_id
	FROM events
	WHERE event_type = 1 AND page_id = 12)
SELECT ROUND(COUNT(c.visit_id)/(SELECT COUNT(visit_id) FROM checkout_cte) * 100, 2) AS checkout_not_purchase_percent
FROM checkout_cte c
LEFT JOIN events e
	ON c.visit_id = e.visit_id AND event_type = 3
WHERE event_type IS NULL;

-- 7. What are the top 3 pages by number of views?
SELECT
	page_name,
    COUNT(visit_id) total_visit
FROM events e
INNER JOIN page_hierarchy p
	ON e.page_id = p.page_id
WHERE event_type = 1
GROUP BY e.page_id
ORDER BY total_visit DESC
LIMIT 3;

-- 8. What is the number of views and cart adds for each product category?
SELECT
	product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 END) AS total_views,
    SUM(CASE WHEN event_type = 2 THEN 1 END) AS total_cart_adds
FROM events e
INNER JOIN page_hierarchy p
	ON e.page_id = p.page_id
WHERE product_category IS NOT NULL
GROUP BY product_category;

-- 9. What are the top 3 products by purchases?
	-- from events create purchase_cte to select visit_id that purchase
    -- left join with events with event_type = 2 (add to cart)
    -- inner join with page_hierarchy to get page_name (product)
    -- count visit_id group by product_id and sort in descending order
    -- limit 3 to get top 3
WITH purchase_cte AS(
	SELECT visit_id
	FROM events
	WHERE event_type = 3)
SELECT page_name AS product, COUNT(p.visit_id) AS total_purchase
FROM purchase_cte p
LEFT JOIN events e
	ON p.visit_id = e.visit_id AND event_type = 2
INNER JOIN page_hierarchy h
	ON e.page_id = h.page_id
GROUP BY product_id
ORDER BY total_purchase DESC
LIMIT 3;

-- B. Product Funnel Analysis --
-- Using a single SQL query - create a new output table which has the following details:
	-- How many times was each product viewed?
	-- How many times was each product added to cart?
	-- How many times was each product added to a cart but not purchased (abandoned)?
	-- How many times was each product purchased?

	-- from events create view_add_cte that:
		-- inner join page_hierarchy to get page_name (product name)
        -- use CASE() to mark when product is viewed or added to cart
        -- filter product_id not null to get product only
    -- from events create purchase_cte to select visit_id that purchase
    -- left join view_add_cte with purchase_cte when cart_added IS NOT NULL
    -- sum the viewd, cart_added, purchased group by product_id to get total number
    -- sum the case when cart_added = 1 and purchased IS NULL to get total_abandoned
DROP TABLE IF EXISTS products;
CREATE TABLE products
WITH view_add_cte AS(
	SELECT
		product_id,
        page_name AS product_name,
		visit_id,
		CASE WHEN event_type = 1 THEN 1 END AS viewed,
		CASE WHEN event_type = 2 THEN 1 END AS cart_added
	FROM events e
	INNER JOIN page_hierarchy p
		ON e.page_id = p.page_id
	WHERE product_id IS NOT NULL),
purchase_cte AS(
	SELECT visit_id, 1 AS purchased
	FROM events
	WHERE event_type = 3)
SELECT 
	product_id,
    product_name,
    SUM(viewed) AS total_viewed,
    SUM(cart_added) AS total_cart_added,
    SUM(purchased) AS total_purchased,
    SUM(CASE WHEN cart_added = 1 AND purchased IS NULL THEN 1 END) AS total_abandoned
FROM view_add_cte v
LEFT JOIN purchase_cte p
	ON v.visit_id = p.visit_id AND cart_added IS NOT NULL
GROUP BY product_id
ORDER BY product_id;
SELECT * FROM products;
    
-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
DROP TABLE IF EXISTS product_categories;
CREATE TABLE product_categories
SELECT 
	product_category,
    SUM(total_viewed) AS total_viewed,
    SUM(total_cart_added) AS total_cart_added,
    SUM(total_purchased) AS total_purchased,
    SUM(total_abandoned) AS total_abandoned
FROM page_hierarchy h
INNER JOIN products p
	ON h.product_id = p.product_id
GROUP BY product_category;
SELECT * FROM product_categories;

-- 1. Which product had the most views, cart adds and purchases?
(SELECT product_name, 'most views' AS type
FROM products
ORDER BY total_viewed DESC
LIMIT 1)
UNION
(SELECT product_name, 'most cart adds' AS type
FROM products
ORDER BY total_cart_added DESC
LIMIT 1)
UNION
(SELECT product_name, 'most purchases' AS type
FROM products
ORDER BY total_purchased DESC
LIMIT 1); 

-- 2. Which product was most likely to be abandoned?
SELECT product_name, ROUND(total_abandoned/total_cart_added*100, 2) AS abandoned_rate
FROM products
ORDER BY abandoned_rate DESC
LIMIT 1;

-- 3. Which product had the highest view to purchase percentage?
SELECT product_name, ROUND(total_purchased/total_viewed *100, 2) AS view_to_purchase_percent
FROM products
ORDER BY view_to_purchase_percent DESC
LIMIT 1;

-- 4. What is the average conversion rate from view to cart add?
SELECT ROUND(AVG(total_cart_added/total_viewed *100), 2) AS view_to_cart_add_percent
FROM products;

-- 5. What is the average conversion rate from cart add to purchase?
SELECT ROUND(AVG(total_purchased/total_cart_added *100), 2) AS cart_add_to_purchase_percent
FROM products;

-- C. Campaigns Analysis --
-- Generate a table that has 1 single row for every unique visit_id record and has the following columns:
	-- user_id
	-- visit_id
	-- visit_start_time: the earliest event_time for each visit
	-- page_views: count of page views for each visit
	-- cart_adds: count of product cart add events for each visit
	-- purchase: 1/0 flag if a purchase event exists for each visit
	-- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
	-- impression: count of ad impressions for each visit
	-- click: count of ad clicks for each visit
	-- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
DROP TABLE IF EXISTS visits;
CREATE TABLE visits
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


