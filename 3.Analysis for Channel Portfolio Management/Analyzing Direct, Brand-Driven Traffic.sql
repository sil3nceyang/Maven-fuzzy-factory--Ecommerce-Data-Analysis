USE mavenfuzzyfactory;

/*
December 23, 2012
From: Cindy Sharp (CEO)
Subject: Site traffic breakdown
Good morning,
A potential investor is asking if we’re building any momentum with our brand or if we’ll need to keep relying on paid traffic.
Could you pull organic search, direct type in, and paid brand search sessions by month, and show those sessions as a % of paid search nonbrand?
-Cindy
*/

-- ASSIGNMENT: Analyzing Direct Traffic
-- SOLUTION: Analyzing Direct Traffic
SELECT 
	website_session_id, 
	created_at, 
	CASE 
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search' 
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand' 
		WHEN utm_campaign = 'brand' THEN 'paid-brand' 
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in' 
	END AS channel_group 
    FROM website_sessions
WHERE created_at < '2012-12-23';

SELECT
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mo,
	COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
	COUNT(DISTINCT CASE WHEN channel_group = 'paid-brand' THEN  website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid-brand' THEN  website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) AS direct,
	COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) AS organic,
	COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM(
SELECT 
	website_session_id, 
	created_at, 
	CASE 
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search' 
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand' 
		WHEN utm_campaign = 'brand' THEN 'paid-brand' 
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in' 
	END AS channel_group 
    FROM website_sessions
WHERE created_at < '2012-12-23'
) AS sessions_w_channel_group
GROUP BY
	YEAR(created_at),
	MONTH(created_at)
;	
-- FINDING: In April of 2012, organic is about 2% of non-brand and then it builds over time. And in December, it's been almost 7.5% of the non-brand traffic. Same story with direct as a percent of non-brand. Again, we're starting out around 2%, kind of similar to organic and again building all the way upto 7.2% by December.

/*
December 23, 2012
From: Cindy Sharp (CEO)
Subject: RE: Site traffic breakdown
This is great to see! 
Looks like not only are our brand, direct, and organic volumes growing, but they are growing as a percentage of our paid traffic volume. 
Now this is a story I can sell to an investor!
-Cindy
*/
