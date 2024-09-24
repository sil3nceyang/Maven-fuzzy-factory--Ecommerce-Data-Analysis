USE mavenfuzzyfactory;

/*
April 12, 2012
From: Cindy Sharp (CEO)
Subject: Site traffic breakdown
Good morning,
We've been live for almost a month now and we're starting to generate sales. Can you help me understand where the bulk of our website sessions are coming from, through yesterday?
I'd like to see a breakdown by UTM source, campaign and referring domain if possible. Thanks!
-Cindy
*/

-- ASSIGNMENT: Finding Top Traffic Sources
-- SOLUTION: Finding Top Traffic Sources
SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) as total_sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1, 2, 3
ORDER BY 4 DESC
;
-- FINDING: We can say that G search Non-brand is the most important thing for us to be focusing on right now.

/*
April 12, 2012
From: Cindy Sharp (CEO)
Subject: RE: Site traffic breakdown
Great analysis!
Based on your findings, it seems like we should probably dig into gsearch nonbrand a bit deeper to see what we can do to optimize there.
I'll loop in Tom tomorrow morning to get his thoughts on next steps.
-Cindy
*/

/*
April 14, 2012
From: Tom Parmesan (Marketing Director)
Subject: Gsearch conversion rate
Hi there,
Sounds like gsearch nonbrand is our major traffic source, but we need to understand if those sessions are driving sales.
Could you please calculate the conversion rate (CVR) from session to order? Based on what we're paying for clicks, we'll need a CVR of at least 4% to make the numbers work.
If we're much lower, we'll need to reduce bids. If we're higher, we can increase bids to drive more volume. Thanks, Tom
*/

-- ASSIGNMENT: Traffic Source Conversion Rates
-- SOLUTION: Traffic Source Conversion Rates
SELECT
    COUNT(DISTINCT website_sessions.website_session_id) as sessions,
    COUNT(DISTINCT orders.order_id) as orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) as session_to_order_conv_rate
FROM website_sessions
LEFT JOIN orders
	USING (website_session_id) 
WHERE website_sessions.created_at < '2012-04-12'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
;
-- FINDING: The CVR is 2.96%

/*
April 14, 2012
From: Tom Parmesan (Marketing Director)
Subject: RE: Gsearch conversion rate
Hmm, looks like we’re below the 4% threshold we need to make the economics work.
Based on this analysis, we’ll need to dial down our search bids a bit. We’re over-spending based on the current conversion rate.
Nice work, your analysis just saved us some $$$!
*/
