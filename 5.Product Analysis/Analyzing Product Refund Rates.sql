USE mavenfuzzyfactory;

/*
October 15, 2014
From: Cindy Sharp (CEO)
Subject: Quality Issues & Refunds
Good morning,
Our Mr. Fuzzy supplier had some quality issues which weren’t corrected until September 2013. Then they had a major problem where the bears’ arms were falling off in Aug/Sep 2014. As a result, we replaced them with a new supplier on September 16, 2014.
Can you please pull monthly product refund rates, by product, and confirm our quality issues are now fixed?
-Cindy
*/

-- ASSIGNMENT: Analyzing Product Refund Rates
-- SOLUTION: Analyzing Product Refund Rates
SELECT
YEAR(order_items.created_at) AS yr,
MONTH(order_items.created_at) AS mo,
COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END)
	/COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_refund_rt,
COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,
COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END)
	/COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_refund_rt,
COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders,
COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END)
	/COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_refund_rt,
COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,
COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END)
	/COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_refund_rt
FROM order_items
	LEFT JOIN order_item_refunds
		ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE order_items.created_at < '2014-10-15'
GROUP BY 1,2
;
-- FINDING: Looks like the refund rates for Mr. Fuzzy did go down after the initial improvements in September 2013, but refund rates were terrible in August and September, as expected (13-14%).

/*
October 15, 2014
From: Cindy Sharp (CEO)
Subject: RE: Quality Issues & Refunds
Thanks, this is helpful to see.
Looks like the refund rates for Mr. Fuzzy did go down after the initial improvements in September 2013, but refund rates were terrible in August and September, as expected (13-14%).
Seems like the new supplier is doing much better so far, and the other products look okay too.
-Cindy
*/