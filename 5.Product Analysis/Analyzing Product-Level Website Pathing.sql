USE mavenfuzzyfactory;

/*
April 06, 2014
From: Morgan Rockwell (Website Manager)
Subject: Help w/ User Pathing
Hi there! 
Now that we have a new product, I’m thinking about our user path and conversion funnel. Let’s look at sessions which hit the /products page and see where they went next. 
Could you please pull clickthrough rates from /products since the new product launch on January 6th 2013, by product, and compare to the 3 months leading up to launch as a baseline? 
Thanks, Morgan
*/

-- ASSIGNMENT: Product-Level Website Pathing
-- SOLUTION: Product-Level Website Pathing
-- Step 1: find the relevant /products pageviews with website_session_id 
-- Step 2: find the next pageview id that occurs AFTER the product pageview 
-- Step 3: find the pageview_url associated with any applicable next pageview id 
-- Step 4: summarize the data and analyze the pre vs post periods

-- Step 1: find the relevant /products pageviews with website_session_id 
CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
		WHEN created_at <'2013-01-06' THEN 'A.Pre_Product_2'
        WHEN created_at >= '2013-01-06' THEN 'B.Post_Product_2'
        ELSE 'check logic'
        END AS time_period
FROM website_pageviews
WHERE pageview_url = '/products'
	AND created_at BETWEEN '2012-10-06' AND '2013-04-06';

-- Step 2: find the next pageview id that occurs AFTER the product pageview 
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT
	products_pageviews.time_period,
	products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1, 2;

-- Step 3: find the pageview_url associated with any applicable next pageview id 
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT
	sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
	website_pageviews.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = sessions_w_next_pageview_id.min_next_pageview_id;

-- Step 4: summarize the data and analyze the pre vs post periods
SELECT
	time_period,
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_pg,
	COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) /COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY time_period
;
-- FINDING: Looks like the percent of /products pageviews that clicked to Mr. Fuzzy has gone down since the launch of the Love Bear, but the overall clickthrough rate has gone up

/*
April 06, 2014
From: Cindy Sharp (CEO)
Subject: RE: Help w/ User Pathing
Great analysis! 
Looks like the percent of /products pageviews that clicked to Mr. Fuzzy has gone down since the launch of the Love Bear, but the overall clickthrough rate has gone up, so it seems to be generating additional product interest overall. 
As a follow up, we should probably look at the conversion funnels for each product individually.
Thanks!
-Morgan
*/

/*
April 10, 2014
From: Morgan Rockwell (Website Manager)
Hi there! 
I’d like to look at our two products since January 6th and analyze the conversion funnels from each product page to conversion.
It would be great if you could produce a comparison between the two conversion funnels, for all website traffic.
Thanks! 
-Morgann
*/

-- ASSIGNMENT: Building Product-Level Conversion Funnels
-- SOLUTION: Building Product-Level Conversion Funnels
-- STEP 1: select all pageviews for relevent sessions
-- STEP 2: figure out which pageview urls to look for
-- STEP 3: pull all pageviews and identify the funnel steps
-- STEP 4: create the session-level conversion funnel view
-- STEP 5: aggregate the data to assess funnel performance
CREATE TEMPORARY TABLE sessions_seeing_product_pages
SELECT
	website_session_id,
    website_pageview_id,
    pageview_url AS product_page_seen
FROM website_pageviews
WHERE website_pageviews.created_at BETWEEN '2013-01-06' AND '2013-04-10'
	AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');
    
-- find the right pageview_urls to build the funnels
SELECT DISTINCT
	website_pageviews.pageview_url
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id;        


-- firstly look at the inner query to look over the pageview-level reuslts
-- then, turn it into a subquery and make it the summary with flags
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyouforyourorder_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at;

CREATE TEMPORARY TABLE session_product_level_made_it_flags
SELECT
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy' 
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'check the logic'
	END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyouforyourorder_page) AS thankyouforyourorder_made_it
FROM(
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyouforyourorder_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY 1, 2;

-- final output part 1
SELECT 
	product_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE 0 END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE 0 END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE 0 END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyouforyourorder_made_it = 1 THEN website_session_id ELSE 0 END) AS to_thankyou
FROM session_product_level_made_it_flags
GROUP BY 1;

-- then this as final output part 2 - click rates
SELECT
	product_seen,
     COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT website_session_id) AS product_page_click_rt,
	 COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE 0 END) AS cart_click_rt,
     COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE 0 END) AS shipping_click_rt,
	 COUNT(DISTINCT CASE WHEN thankyouforyourorder_made_it = 1 THEN website_session_id ELSE 0 END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE 0 END) AS billing_click_rt
FROM session_product_level_made_it_flags
GROUP BY product_seen
;
-- FINDING: 43% of people seeing Mr. Fuzzy click through to the cart and 54 almost 55% click through From Love Bear to the cart. So that's interesting. But then once they get to the cart, these look pretty similar to me.

/*
April 10, 2014
From: Morgan Rockwell (Website Manager)
Subject: RE: Product Conversion Funnels
This is great to see! 
We had found that adding a second product increased overall CTR from the /products page, and this analysis shows that the Love Bear has a better click rate to the /cart page and comparable rates throughout the rest of the funnel.
Seems like the second product was a great addition for our 
business. I wonder if we should add a third…
Thanks! 
-Morgan
*/
