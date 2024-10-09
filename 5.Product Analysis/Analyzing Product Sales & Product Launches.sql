USE mavenfuzzyfactory;

/*
January 04, 2013
From: Cindy Sharp (CEO)
Subject: Sales Trends
Good morning,
We’re about to launch a new product, and I’d like to do a deep dive on our current flagship product.
Can you please pull monthly trends to date for number of sales, total revenue, and total margin generated for the business?
-Cindy
*/

-- ASSIGNMENT: Product-Level Sales Analysis
-- SOLUTION: Product-Level Sales Analysis
SELECT 
    YEAR(created_at) AS yr, 
    MONTH(created_at) AS mo, 
    COUNT(DISTINCT order_id) AS number_of_sales, 
    SUM(price_usd) AS total_revenue, 
    SUM(price_usd - cogs_usd) AS total_margin 
 
FROM orders 
WHERE created_at < '2013-01-04' -- date of the request 
GROUP BY 
    YEAR(created_at), 
    MONTH(created_at)
;
-- FINDING: The number of sales going up from 60 all the way up to 618 in November of 2012. And you see similar trends with increasing revenue and increasing total margin.

/*
January 04, 2013
From: Cindy Sharp (CEO)
Subject: RE: Sales Trends
Excellent, thank you!
This will serve as great baseline data so that we can see how our revenue and margin evolve as we roll out the new product.
It’s also nice to see our growth pattern in general. 
Thanks again,
-Cindy
*/

/*
April 05, 2013
From: Cindy Sharp (CEO)
Subject: Impact of New Product Launch
Good morning,
We launched our second product back on January 6th. Can you pull together some trended analysis? 
I’d like to see monthly order volume, overall conversion rates, revenue per session, and a breakdown of sales by product, all for the time period since April 1, 2012.
Thanks,
-Cindy
*/

-- ASSIGNMENT: Analyzing Product Launches
-- SOLUTION: Analyzing Product Launches
SELECT
    YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) AS product_two_order
FROM website_sessions
    LEFT JOIN orders
        USING (website_session_id)
WHERE website_sessions.created_at < '2013-04-01' -- the date of the request
        AND website_sessions.created_at > '2012-04-01' -- specified in the request
GROUP BY 1, 2
;
-- FINDING: We see product two getting a lot of sales in February of 2013, but then kind of reduced here in March. We're seeing our revenue per cession. It was 1.32 back in April, 2012 and it came up to 3.69 in Feb, 2013. And our conversion rates similarly have improved in general.

/*
April 05, 2013
From: Cindy Sharp (CEO)
Subject: RE:Impact of New Product Launch
Thanks!
This confirms that our conversion rate and revenue per session are improving over time, which is great.
I’m having a hard time understanding if the growth since January is due to our new product launch or just a continuation of our overall business improvements.
I’ll connect with Tom about digging into this some more. 
-Cindy
*/