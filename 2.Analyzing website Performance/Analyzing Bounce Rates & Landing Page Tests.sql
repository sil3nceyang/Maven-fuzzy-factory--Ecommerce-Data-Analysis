USE mavenfuzzyfactory;

/*
June 14, 2012
From: Morgan Rockwell (Website Manager)
Subject: Bounce Rate Analysis
Hi there! 
The other day you showed us that all of our traffic is landing on the homepage right now. We should check how that landing page is performing. 
Can you pull bounce rates for traffic landing on the homepage? I would like to see three numbers…Sessions, Bounced Sessions, and % of Sessions which Bounced (aka “Bounce Rate”).
Thanks! 
-Morgan
*/

-- ASSIGNMENT: Calculating Bounce Rates
-- SOLUTION: Calculating Bounce Rates
-- Solution is a multi-step query. See video for details
-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing by counting total sessions and bounced sessions
CREATE TEMPORARY TABLE first_pageviews 
SELECT 
	website_session_id, 
	MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews 
WHERE created_at < '2012-06-14' 
GROUP BY 
	website_session_id;

-- next, we'll bring in the landing page, like last time, but restrict to home only 
-- this is redundant in this case, since all is to the homepage 
CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT
    first_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
    LEFT JOIN website_pageviews
        ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url = '/home';

-- then a table to have count of pageviews per session
	-- then limit it to just bounced_sessions
CREATE TEMPORARY TABLE bounced_sessions
SELECT
	sessions_w_home_landing_page.website_session_id,
	sessions_w_home_landing_page.landing_page,
	COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews
	USING (website_session_id)
GROUP BY 1, 2
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

-- final output for Assignment_Calculating_Bounce_Rates 
SELECT 
	COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS total_sessions, 
	COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions, 
	COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate 
FROM sessions_w_home_landing_page 
	LEFT JOIN bounced_sessions 
		USING (website_session_id)
;
-- FINDING: The home page has a 59.18% bounce rate.

/*
June 14, 2012
From: Morgan Rockwell (Website Manager)
Subject: RE: Bounce Rate Analysis
Ouch…almost a 60% bounce rate! 
That’s pretty high from my experience, especially for paid search, which should be high quality traffic. 
I will put together a custom landing page for search, and set up an experiment to see if the new page does better. I will likely need your help analyzing the test once we get enough data to judge performance.
Thanks, Morgan
*/


/*
July 28, 2012
From: Morgan Rockwell (Website Manager)
Subject: Help Analyzing LP Test
Hi there! 
Based on your bounce rate analysis, we ran a new custom landing page (/lander-1) in a 50/50 test against the homepage (/home) for our gsearch nonbrand traffic. 
Can you pull bounce rates for the two groups so we can evaluate the new page? Make sure to just look at the time period where /lander-1 was getting traffic, so that it is a fair comparison.
Thanks, Morgan
*/

-- ASSIGNMENT: Analyzing Landing Page Tests
-- SOLUTION: Analyzing Landing Page Tests
-- STEP 0: find out when the new page /lander launched 
-- STEP 1: finding the first website_pageview_id for relevant sessions 
-- STEP 2: identifying the landing page of each session 
-- STEP 3: counting pageviews for each session, to identify "bounces" 
-- STEP 4: summarizing total sessions and bounced sessions, by LP
SELECT
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
    AND created_at IS NOT NULL;
-- first_created_at = '2012-06-19 00:35:54'
-- first_pageview_id = 23504

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
    INNER JOIN website_sessions
        ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
        AND website_pageviews.website_pageview_id > 23504 -- the min_pageview_id we found for the test
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY
    website_pageviews.website_session_id;
    
-- next, we'll bring in the landing page to each session, like last time, but restricting to home or lander-1 this time
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
    LEFT JOIN website_pageviews
        ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');
        
-- then a table to have count of pageviews per session
   -- then limit it to just bouncedsessions
CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
    nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews
		USING (website_session_id)
GROUP BY
    nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;
    
-- final output
SELECT 
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions, 
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS bounce_rate
FROM nonbrand_test_sessions_w_landing_page
    LEFT JOIN nonbrand_test_bounced_sessions
        USING (website_session_id)
GROUP BY 
    nonbrand_test_sessions_w_landing_page.landing_page
;
-- FINDING: The new lander that Morgan has put together has a bounce rate of 53% versus the home page for the same traffic was at 58%. So it does look like this was an improvement in terms of performance.

/*
July 28, 2012
From: Morgan Rockwell (Website Manager)
Subject: Re: Help Analyzing LP Test
Hey! 
This is so great. It looks like the custom lander has a lower bounce rate…success! 
I will work with Tom to get campaigns updated so that all nonbrand paid traffic is pointing to the new page.
In a few weeks, I would like you to take a look at trends to make sure things have moved in the right direction. 
Thanks, Morgan
*/


/*
August 31, 2012
From: Morgan Rockwell (Website Manager)
Subject: Landing Page Trend Analysis
Hi there,
Could you pull the volume of paid search nonbrand traffic landing on /home and /lander-1, trended weekly since June 1st? I want to confirm the traffic is all routed correctly.
Could you also pull our overall paid search bounce rate trended weekly? I want to make sure the lander change has improved the overall picture.
Thanks!
*/

-- ASSIGNMENT: Landing Page Trend Analysis
-- SOLUTION: Landing Page Trend Analysis
-- Solution is a multi-step query.
-- STEP 1: finding the first website_pageview_id for relevant sessions 
-- STEP 2: identifying the landing page of each session 
-- STEP 3: counting pageviews for each session, to identify "bounces" 
-- STEP 4: summarizing by week (bounce rate, sssions to each lander)

CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at >'2012-06-01'
	AND website_sessions.created_at <'2012-08-31'
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign ='Nonbrand'
GROUP BY 
	website_sessions.website_session_id;

-- SELECT * FROM  sessions_w_min_pv_id_and_view_count;
    
CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT 
	sessions_w_min_pv_id_and_view_count.website_session_id,
	sessions_w_min_pv_id_and_view_count.first_pageview_id,
	sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews
		ON sessions_w_min_pv_id_and_view_count.first_pageview_id =  website_pageviews.website_pageview_id;
    
SELECT 
	-- YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
    -- COUNT(DISTINCT website_session_id) AS total_sessions,
    -- COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)  AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM sessions_w_counts_lander_and_created_at
GROUP BY
	YEARWEEK(session_created_at)
;
-- FINDING: The bounce rate started in the 60%. And then over time, as it switched over to traffic, primarily going to the lander, we're seeing bounce rate closer to the 50% range. So that's definitely a remarkable improvement from 60% down to 50%.

/*
August 31, 2012
From: Morgan Rockwell (Website Manager)
Subject: RE: Landing Page Trend Analysis
This is great. Thank you! 
Looks like both pages were getting traffic for a while, and then we fully switched over to the custom lander, as intended. And it looks like our overall bounce rate has come down over time…nice! 
I am going to do a full deep dive into our site, and will follow up with asks.
Thanks! 
-Morgan
*/
