USE mavenfuzzyfactory;

/*
May 10, 2012
From: Tom Parmesan (Marketing Director)
Subject: Gsearch volume trends
Hi there,
Based on your conversion rate analysis, we bid down gsearch nonbrand on 2012-04-15.
Can you pull gsearch nonbrand trended session volume, by week, to see if the bid changes have caused volume to drop at all?
Thanks, Tom
*/

-- ASSIGNMENT: Traffic Source Trending
-- SOLUTION: Traffic Source Trending
SELECT
    -- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
    MIN(DATE(created_at))  AS week_started_at,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
	WEEK(created_at)
;
-- FINDING: we were around 900 over 1000 and now we're down in the roughly 600 to 680 range for the last four weeks. It does look like there was an impact to volume.

/*
May 10, 2012
From: Tom Parmesan (Marketing Director)
Subject: RE: Gsearch volume trends
Hi there, great analysis!
Okay, based on this, it does look like gsearch nonbrand is fairly sensitive to bid changes.
We want maximum volume, but don’t want to spend more on ads than we can afford.
Let me think on this. I will likely follow up with some ideas.
Thanks, Tom
*/


/*
May 11, 2012
From: Tom Parmesan (Marketing Director)
Subject: Gsearch device-level performance
Hi there,
I was trying to use our site on my mobile device the other day, and the experience was not great.
Could you pull conversion rates from session to order, by device type?
If desktop performance is better than on mobile we may be able to bid up for desktop specifically to get more volume?
Thanks, Tom
*/

-- ASSIGNMENT: Bid Optimization for Paid Traffic
-- SOLUTION: Bid Optimization for Paid Traffic
SELECT
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) as sessions,
    COUNT(DISTINCT orders.order_id) as orders,
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
FROM website_sessions
LEFT JOIN orders
	USING (website_session_id) 
WHERE website_sessions.created_at < '2012-05-11'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1
;
-- FINDING: The conversion rate for desktop traffic is about 3.7%, while it's less than 1% for mobile traffic.

/*
May 11, 2012
From: Tom Parmesan (Marketing Director)
Subject: RE: Gsearch device-level performance
Great!
I’m going to increase our bids on desktop.
When we bid higher, we’ll rank higher in the auctions, so I think your insights here should lead to a sales boost.
Well done!!
-Tom
*/
