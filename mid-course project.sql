-- mid-course project

-- question1
SELECT 
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM mavenfuzzyfactory.website_sessions
	LEFT JOIN orders
		USING(website_session_id)
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 
	month;
    
-- question 2
SELECT 
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders
FROM mavenfuzzyfactory.website_sessions
	LEFT JOIN orders
		USING(website_session_id)
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 
	1;

-- question 3
SELECT 
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders
FROM mavenfuzzyfactory.website_sessions
	LEFT JOIN orders
		USING(website_session_id)
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 
	1;
    
-- question 4
SELECT DISTINCT utm_source, utm_campaign, http_referer FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';
-- utm_source:gsearch NULL bsearch

SELECT 
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
 
FROM mavenfuzzyfactory.website_sessions
	LEFT JOIN orders
		USING(website_session_id)
WHERE
	website_sessions.created_at < '2012-11-27'
GROUP BY 
	1;

-- question 5
SELECT 
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM mavenfuzzyfactory.website_sessions
	LEFT JOIN orders
		USING(website_session_id)
WHERE 
	website_sessions.created_at < '2012-11-27'
GROUP BY 
	month;
    
-- question 6
SELECT
	MIN(created_at),
	MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';
-- first_test_pv 23504

CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM  website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28'
        AND website_pageviews.website_pageview_id > 23504
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;

CREATE TEMPORARY TABLE nonband_test_sessions_w_landing_page
SELECT
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

/*前面的两个步骤可以合并成一个步骤,使用subquery
SELECT
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM (
    SELECT 
        website_pageviews.website_session_id,
        MIN(website_pageviews.website_pageview_id) AS min_pageview_id
    FROM website_pageviews
    INNER JOIN website_sessions
        ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28'
        AND website_pageviews.website_pageview_id > 23504
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
    GROUP BY
        website_pageviews.website_session_id
) AS first_test_pageviews
LEFT JOIN website_pageviews
    ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');
*/
CREATE TEMPORARY TABLE nonband_test_sessions_w_orders
SELECT 
	nonband_test_sessions_w_landing_page.website_session_id,
	nonband_test_sessions_w_landing_page.landing_page,
    orders.order_id AS order_id
FROM nonband_test_sessions_w_landing_page
	LEFT JOIN orders
		USING (website_session_id);

-- SELECT * FROM nonband_test_sessions_w_orders;
    
SELECT
	landing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
	COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonband_test_sessions_w_orders
GROUP BY 1;
-- 在视频里，lander-1的转换率比home高0.0087

-- find the most recent pageview for gsearch nonbrand where the traffic was sent to /home
SELECT
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
	LEFT JOIN website_pageviews
		USING (website_session_id)
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-27';
-- max website_session_id = 17145

SELECT
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND website_sessions.created_at < '2012-11-27'
    AND website_session_id > 17145; -- 17145之后的都是/lander-1
-- sessions_since_test 22972 

-- 22972 *  0.0087(incremental conversation rate ) =202 incremental orders since 7/29
  -- roughly 4 months, so roughly 50 extra orders per month. Not bad!

-- question 7
CREATE TEMPORARY TABLE session_level_made_it_flag
SELECT 
	website_session_id,
    MAX(home_page) AS saw_home_page,
    MAX(custom_lander) AS saw_custom_lander,
    MAX(product_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyouforyourorder_page) AS thankyouforyourorder_made_it
    
FROM(
SELECT 
	website_pageviews.website_session_id,
	website_pageviews.pageview_url,
    CASE WHEN website_pageviews.pageview_url = '/home' THEN 1 ELSE NULL END AS home_page,
    CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE NULL END AS custom_lander,
    CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE NULL END AS product_page,
    CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END AS mrfuzzy_page,
    CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE NULL END AS cart_page,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE NULL END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE NULL END AS billing_page,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS thankyouforyourorder_page
    
FROM website_sessions
	LEFT JOIN website_pageviews
		USING(website_session_id)
WHERE website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
    
ORDER BY
	website_pageviews.website_session_id
) AS pageview_level
GROUP BY
	website_session_id
;  
-- 分别看/home和/lander-1 到oder转化漏斗我不会，其实一个CASE语句即可：
SELECT 
	CASE
		WHEN saw_home_page = 1 THEN 'saw_home_page'
		WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'check logic'
	END AS segment,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE 0 END) AS to_product,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE 0 END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE 0 END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE 0 END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE 0 END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyouforyourorder_made_it = 1 THEN website_session_id ELSE 0 END) AS to_thankyou
FROM session_level_made_it_flag
GROUP BY segment
;

-- question 8

-- find the first time group B was seen
SELECT 
	MIN(created_at) AS first_created_at,
	MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'
	AND website_pageviews.created_at < '2012-11-10';
--  first_created_at     first_pv_id
--  2012-09-10 00:13:05    53550

SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders
		USING(website_session_id)
WHERE website_pageviews.created_at < '2012-10-10'
	AND website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.pageview_url IN ( '/billing', '/billing-2')
;
	
SELECT 
	 billing_version_seen,
     COUNT(DISTINCT website_session_id) AS sessions,
     SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM(
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders
		USING(website_session_id)
WHERE website_pageviews.created_at < '2012-11-10'
	AND website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.pageview_url IN ( '/billing', '/billing-2')
) AS billing_sessions_w_orders
GROUP BY
billing_version_seen;
-- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- lift: $8.51 per billing page view 

SELECT
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
-- billing_sessions_past_month ；1193
-- 1,193 billing sessions past moth
-- lift: $8.51 per billing page view 
-- value of billing test: $10152 over the past month

