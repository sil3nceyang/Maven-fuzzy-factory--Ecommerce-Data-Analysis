USE mavenfuzzyfactory;

/*
November 29, 2012
From: Tom Parmesan (Marketing Director)
Subject: Expanded Channel Portfolio
Hi there,
With gsearch doing well and the site performing better, we launched a second paid search channel, bsearch, around August 22.
Can you pull weekly trended session volume since then and compare to gsearch nonbrand so I can get a sense for how important this will be for the business?
Thanks, Tom
*/

-- ASSIGNMENT: Analyzing Channel Portfolios
-- SOLUTION: Analyzing Channel Portfolios
SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN utm_source ='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source ='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-29'
    AND utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at)
;
-- FINDING: In general, gsearch is about three times as big as bsearch.
/*
November 29, 2012
From: Tom Parmesan (Marketing Director)
Subject: Re: Expanded Channel Portfolio
Hi there,
This is very helpful to see. It looks like bsearch tends to get roughly a third the traffic of gsearch. This is big enough that we should really get to know the channel better. 
I will follow up with some requests to understand channel characteristics and conversion performance.
Thanks, Tom
*/

/*
November 30, 2012
From: Tom Parmesan (Marketing Director)
Subject: Comparing Our Channels
Hi there,
I’d like to learn more about the bsearch nonbrand campaign. Could you please pull the percentage of traffic coming on Mobile, and compare that to gsearch?
Feel free to dig around and share anything else you find interesting. Aggregate data since August 22nd is great, no need to show trending at this point. 
Thanks, Tom
*/

-- ASSIGNMENT: Comparing Channel Characteristics
-- SOLUTION: Comparing Channel Characteristics
SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
    AND utm_campaign = 'nonbrand'
GROUP BY
	utm_source
;
-- FINDING: gsearch is about 24.5% mobile, where bsearch is only about 8.6% mobile.

/*
November 30, 2012
From: Tom Parmesan (Marketing Director)
Subject: RE: Comparing Our Channels
Wow, the desktop to mobile splits are very interesting. These channels are quite different from a device standpoint.
Let’s keep this in mind as we continue to learn and optimize. Now that we know these channels are pretty different, I’m going to need your help digging in a bit more so that we can get our bids right.
Thanks, and keep up the great work!
-Tom 
*/

/*
December 01, 2012
From: Tom Parmesan (Marketing Director)
Subject: Multi-Channel Bidding
Hi there,
I’m wondering if bsearch nonbrand should have the same bids as gsearch. Could you pull nonbrand conversion rates from session to order for gsearch and bsearch, and slice the 
data by device type?
Please analyze data from August 22 to September 18; we ran a special pre-holiday campaign for gsearch starting on September 19th, so the data after that isn’t fair game.
Thanks, Tom
*/

/*
December 01, 2012
From: Tom Parmesan (Marketing Director)
Subject: Multi-Channel Bidding
Hi there,
I’m wondering if bsearch nonbrand should have the same bids as gsearch. Could you pull nonbrand conversion rates from session to order for gsearch and bsearch, and slice the 
data by device type?
Please analyze data from August 22 to September 18; we ran a special pre-holiday campaign for gsearch starting on September 19th, so the data after that isn’t fair game.
Thanks, Tom
*/

-- ASSIGNMENT: Cross-Channel Bid Optimization
-- SOLUTION: Cross-Channel Bid Optimization
SELECT 
    website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM website_sessions
	LEFT JOIN orders
	    USING (website_session_id)
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
    AND utm_campaign = 'nonbrand'
GROUP BY
     website_sessions.device_type,
     website_sessions.utm_source
;
-- FINDING: Within the desktop and mobile, gsearch looks like it outperforms against bsearch.

/*
December 01, 2012
From: Tom Parmesan (Marketing Director)
Subject: RE: Multi-Channel Bidding
Thanks, this is good to see.
As I suspected, the channels don’t perform identically, so we should differentiate our bids in order to optimize our overall paid marketing budget.
I'll bid down bsearch based on its under-performance. 
Great work!
-Tom
*/

/*
December 22, 2012
From: Tom Parmesan (Marketing Director)
Subject: Impact of Bid Changes
Hi there,
Based on your last analysis, we bid down bsearch nonbrand on December 2nd.
Can you pull weekly session volume for gsearch and bsearch nonbrand, broken down by device, since November 4th?
If you can include a comparison metric to show bsearch as a percent of gsearch for each device, that would be great too. 
Thanks, Tom
*/

-- ASSIGNMENT: Analyzing Channel Portfolio Trends
-- SOLUTION: Analyzing Channel Portfolio Trends
SELECT
    -- YEARWEEK(created_at) AS year_vweek,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
    FROM website_sessions
    WHERE created_at > '2012-11-04' -- specified in the request
    AND created_at < '2012-12-22' -- dedicated by the time of the request
    AND utm_campaign = 'nonbrand' -- limiting to nonbrand paid search
    GROUP BY
		YEARWEEK(created_at)
-- FINDING: after the bid down, we do see bsearch falling more than gsearch. So now it's down to 23%, 27% for destop. It does look like that bid change impacted volume here. For mobile, it's interesting that it looks pretty steady here.So perhaps bsearch is less price elastic on mobile and the volume here is potentially less sensitive to bid changes.

/*
December 22, 2012
From: Tom Parmesan (Marketing Director)
Subject: RE: Impact of Bid Changes
Hi there,
Thanks for pulling this together! 
Looks like bsearch traffic dropped off a bit after the bid down. Seems like gsearch was down too after Black Friday and Cyber Monday, but bsearch dropped even more. 
I think this is okay given the low conversion rate.
Thanks, Tom
*/
