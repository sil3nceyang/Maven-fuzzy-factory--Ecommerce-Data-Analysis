USE mavenfuzzyfactory;

/*
September 05, 2012
From: Morgan Rockwell (Website Manager)
Subject: Help Analyzing Conversion Funnels
Hi there! 
I’d like to understand where we lose our gsearch visitors between the new /lander-1 page and placing an order. Can you build us a full conversion funnel, analyzing how many customers make it to each step?
Start with /lander-1 and build the funnel all the way to our thank you page. Please use data since August 5th.
Thanks!
-Morgan
*/

-- ASSIGNMENT: ASSIGNMENT: Building Conversion Funnels
-- SOLUTION: ASSIGNMENT: Building Conversion Funnels
-- Solution is a multi-step query. 
-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each pageview as the specific funnel step
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.created_at AS pageview_created_at,
	website_pageviews.pageview_url,
    CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE NULL END AS product_page, -- product_page flag
    CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END AS mrfuzzy_page,
    CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE NULL END AS cart_page,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE NULL END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE NULL END AS billing_page,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS thankyouforyourorderpage
FROM website_pageviews
	LEFT JOIN website_sessions
		USING(website_session_id)        
WHERE website_pageviews.created_at > '2012-08-05' 
	AND  website_pageviews.created_at < '2012-09-05'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'    
ORDER BY
	website_pageviews.website_session_id,
	pageview_created_at;

CREATE TEMPORARY TABLE session_level_made_it_flags_demo
SELECT 
	website_session_id,
    MAX(product_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyouforyourorderpage) AS thankyouforyourorder_made_it
FROM(
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.created_at AS pageview_created_at,
	website_pageviews.pageview_url,
    CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE NULL END AS product_page,
    CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END AS mrfuzzy_page,
    CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE NULL END AS cart_page,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE NULL END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE NULL END AS billing_page,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS thankyouforyourorderpage    
FROM website_pageviews
	LEFT JOIN website_sessions
		USING(website_session_id)
WHERE website_pageviews.created_at BETWEEN '2012-08-05' AND '2012-09-05'
    AND website_pageviews.pageview_url IN ('/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
    AND website_sessions.utm_source = 'gsearch'    
ORDER BY
	website_pageviews.website_session_id,
	pageview_created_at
) AS pageview_level
GROUP BY
	website_session_id;

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE 0 END) AS to_product,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE 0 END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE 0 END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE 0 END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE 0 END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyouforyourorder_made_it = 1 THEN website_session_id ELSE 0 END) AS to_thankyou
FROM session_level_made_it_flags_demo;

SELECT 
	 COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
	 COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE 0 END) AS product_click_rt,
	 COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE 0 END) AS mrfuzzy_click_rt,
	 COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE 0 END) AS cart_click_rt,
	 COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE 0 END) AS shipping_click_rt,
	 COUNT(DISTINCT CASE WHEN thankyouforyourorder_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE 0 END) AS billing_click_rt
FROM session_level_made_it_flags_demo
;
-- FINDING: The lander, Mr. Fuzzy page, and the billing page have the lowest click rates.

/*
September 05, 2012
From: Morgan Rockwell (Website Manager)
Subject: RE: Help Analyzing Conversion Funnels
This analysis is really helpful! 
Looks like we should focus on the lander, Mr. Fuzzy page, and the billing page, which have the lowest click rates. 
I have some ideas for the billing page that I think will make customers more comfortable entering their credit card info. 
I’ll test a new page soon and will ask for help analyzing performance.
Thanks! 
-Morgan
*/


/*
November 10, 2012
From: Morgan Rockwell (Website Manager)
Subject:  Conversion Funnel Test Results
Hello! 
We tested an updated billing page based on your funnel analysis. Can you take a look and see whether /billing-2 is doing any better than the original /billing page? 
We’re wondering what % of sessions on those pages end up placing an order. FYI – we ran this test for all traffic, not just for our search visitors.
Thanks! 
-Morgan
*/

-- ASSIGNMENT: Analyzing Conversion Funnel Tests
-- SOLUTION: Analyzing Conversion Funnel Tests
-- First, find the starting point to frame of the analysis:
SELECT 
	MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2';
-- first_pv_id
-- 53550

SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		USING(website_session_id)
WHERE website_pageviews.created_at < '2012-11-10' -- time of assignment
	AND website_pageviews.website_pageview_id >= 53550 -- first pageview_id where test was live
    AND website_pageviews.pageview_url IN ( '/billing', '/billing-2');

-- same as above, just wrapping as a subquery and summarizing
-- final analysis output

SELECT 
	 billing_version_seen,
     COUNT(DISTINCT website_session_id) AS sessions,
     COUNT(DISTINCT order_id) AS orders,
     COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS billing_to_order_rt
FROM(
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		USING(website_session_id)
WHERE website_pageviews.created_at < '2012-11-10'
	AND website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.pageview_url IN ( '/billing', '/billing-2')
) AS billing_sessions_w_orders
GROUP BY
	billing_version_seen
;
-- FINDING: They have almost the same number of sessions because we're just randomizing that through the experiment. But it looks like billing two has a lot more orders and the conversion rate to order is substantially higher.She's moved the conversion rate from 45% to 62%, which is a pretty marked difference.

/*
November 10, 2012
From: Morgan Rockwell (Website Manager)
Subject: RE: Conversion Funnel Test Results
This is so good to see! 
Looks like the new version of the billing page is doing a much better job converting customers…yes!! 
I will get Engineering to roll this out to all of our customers right away. Your insights just made us some major revenue. 
Thanks so much!
-Morgan
*/
