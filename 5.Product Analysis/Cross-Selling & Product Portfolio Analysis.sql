USE mavenfuzzyfactory;

/*
November 22, 2013
From: Cindy Sharp (CEO)
Subject: Cross-Selling Performance
Good morning,
On September 25th we started giving customers the option to add a 2nd product while on the /cart page. Morgan says this has been positive, but I’d like your take on it.
Could you please compare the month before vs the month after the change? I’d like to see CTR from the /cart page, Avg Products per Order, AOV, and overall revenue per /cart page view.
Thanks, Cindy
*/

-- ASSIGNMENT: Cross-Sell Analysis
-- SOLUTION: Cross-Sell Analysis
-- find the /cart pageview
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT
	website_session_id AS cart_session_id,
    website_pageview_id AS cart_pageview_id,
    CASE
		WHEN created_at < '2013-09-25' THEN 'A.Pre_Cross_Sell'
        WHEN created_at >= '2013-09-25' THEN 'B.Post_Cross_Sell'
        ELSE 'check logic'
    END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart';
    
-- find the next pageview
CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
SELECT
	sessions_seeing_cart.time_period,
	sessions_seeing_cart.cart_session_id,
    MIN(website_pageviews.website_pageview_id) AS pv_id_after_cart
FROM sessions_seeing_cart
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id =sessions_seeing_cart.cart_session_id 
        AND website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
GROUP BY 1, 2
HAVING
	 MIN(website_pageviews.website_pageview_id) IS NOT NULL; -- 'HAVING' chooses those who have the next pageview

CREATE TEMPORARY TABLE pre_post_sessions_orders
SELECT
	time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
FROM sessions_seeing_cart
	INNER JOIN orders  -- 'INNER JOIN' cuts off all the seeions that dont have orders
		ON orders.website_session_id = sessions_seeing_cart.cart_session_id;

SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_orders.cart_session_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		USING (cart_session_id)
	LEFT JOIN pre_post_sessions_orders
		USING (cart_session_id)
ORDER BY sessions_seeing_cart.cart_session_id;

SELECT
	time_period,
    COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_page) AS clickthorughs,
    SUM(clicked_to_another_page)/COUNT(DISTINCT cart_session_id) AS cart_ctr,
    SUM(items_purchased)/SUM(placed_order) AS products_per_order,
    SUM(price_usd)/SUM(placed_order) AS aov, -- average order values
	SUM(price_usd)/COUNT(DISTINCT cart_session_id) AS rev_per_cart_session
FROM(
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_orders.cart_session_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		USING (cart_session_id)
	LEFT JOIN pre_post_sessions_orders
		USING (cart_session_id)
ORDER BY sessions_seeing_cart.cart_session_id
) AS full_data
GROUP BY time_period
;
-- FINDING: Products per order is gone up from one when there was no cross selling to about 1.045. And then we have our average order value, which seems like it's gone up from 51.41 to 54.25.

/*
November 22, 2013
From: Cindy Sharp (CEO)
Subject: RE: Cross-Selling Performance
Thanks!
It looks like the CTR from the /cart page didn’t go down (I was worried), and that our products per order, AOV, and revenue per /cart session are all up slightly since the cross-sell feature was added.
Doesn’t look like a game changer, but the trend looks positive. Great analysis! 
-Cindy
*/

/*
January 12, 2014
From: Cindy Sharp (CEO)
Subject: Recent Product Launch
Good morning,
On December 12th 2013, we launched a third product targeting the birthday gift market (Birthday Bear).
Could you please run a pre-post analysis comparing the month before vs. the month after, in terms of session-to-order conversion rate, AOV, products per order, and 
revenue per session?
Thank you!
-Cindy
*/

-- ASSIGNMENT: Product Portfolio Expansion
-- SOLUTION: Product Portfolio Expansion
SELECT
    CASE
		WHEN website_sessions.created_at < '2013-12-12' THEN 'A.Pre_Birthday_Bear'
	    WHEN website_sessions.created_at >= '2013-12-12' THEN 'B.Post_Birthday_Bear'
		ELSE 'check logic'
    END AS time_period,
    -- COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    -- COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    -- SUM(orders.price_usd) AS total_revenue,
    -- SUM(orders.items_purchased) AS total_products_sold,
	SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS averge_order_value,
	SUM(orders.items_purchased)/COUNT(DISTINCT orders.order_id) AS products_per_order,
	SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		USING (website_session_id)
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1
;
-- FINDING: Pre birthday bear, we see a conversion rate of 6% and post birthday Bear, we're seeing conversion rate all the way up to 7%, at least at face value. Then in terms of the average order value, we're seeing that go up as well from $54.22 to $56.93. The products per order definitely seems to have gone up from 1.04 to 1.12. So it's possible that the Birthday Bear is a really good cross seller to product one and product two. Or maybe it's the other way around. Maybe the Birthday Bear sells well as a primary product, and product one and product two cross-sell well into that product. So finally we have revenue per session. And that's gone up quite a bit too, from $3.30 roughly to roughly $4.

/*
January 12, 2014
From: Cindy Sharp (CEO)
Subject: RE: Recent Product Launch
Great – it looks like all of our critical metrics have improved since we launched the third product. This is fantastic! 
I’m going to meet with Tom about increasing our ad spend now that we’re driving more revenue per session, and we may also consider adding a fourth product.
Stay tuned,
-Cindy
*/
