USE mavenfuzzyfactory;

/*
January 02, 2013
From: Cindy Sharp (CEO)
Subject: Understanding Seasonality
Good morning,
2012 was a great year for us. As we continue to grow, we should take a look at 2012’s monthly and weekly volume patterns, to see if we can find any seasonal trends we should plan for in 2013.
If you can pull session volume and order volume, that would be excellent.
Thanks,
-Cindy
*/

-- ASSIGNMENT: Analyzing Seasonality
-- SOLUTION: Analyzing Seasonality
SELECT
    YEAR(website_sessions.created_at) AS yr,
    WEEK(website_sessions.created_at) AS wk,
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
    LEFT JOIN orders
        USING (website_session_id) 
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1, 2
;
-- FINDING: From the week 46 to 47, we see a doubling of our order volume.And then for the end of the year, it remains pretty high, but not quite as high as week 47, 48.

/*
January 02, 2013
From: Cindy Sharp (CEO)
Subject: RE: Understanding Seasonality
This is great to see.
Looks like we grew fairly steadily all year, and saw significant volume around the holiday months (especially the weeks of Black Friday and Cyber Monday).
We’ll want to keep this in mind in 2013 as we think about customer support and inventory management. 
Great analysis!
-Cindy
*/

/*
January 05, 2013
From: Cindy Sharp (CEO)
Subject: Data for Customer Service
Good morning,
We’re considering adding live chat support to the website to improve our customer experience. Could you analyze the average website session volume, by hour of day and by day week, so that we can staff appropriately? 
Let’s avoid the holiday time period and use a date range of Sep 15 - Nov 15, 2013.
Thanks, Cindy
*/

-- ASSIGNMENT: Analyzing Business Patterns
-- SOLUTION: Analyzing Business Patterns
SELECT
	hr,
	ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) AS mon,
	ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions  ELSE NULL END),1) AS tue,
	ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions  ELSE NULL END),1) AS wed,
	ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions  ELSE NULL END),1) AS thu,
	ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions  ELSE NULL END),1) AS fri,
	ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions  ELSE NULL END),1) AS sat,
	ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions  ELSE NULL END),1) AS sun
FROM(
SELECT
    DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15' -- before holiday surge
GROUP BY 1, 2, 3
) AS daily_hourly_sessions
GROUP BY hr
ORDER BY hr
;
-- FINDING: 8am to 5pm Monday through Friday is where we sort of get a nice swell of traffic coming in.

/*
January 05, 2013
From: Cindy Sharp (CEO)
Subject: RE: Data for Customer Service
Thanks, this is really helpful.
I’ve been speaking with support companies, and it sounds like ~10 sessions per hour per employee staffed is about right. 
Looks like we can plan on one support staff around the clock and then we should double up to two staff members from 8am to 5pm Monday through Friday.
-Cindy 
*/