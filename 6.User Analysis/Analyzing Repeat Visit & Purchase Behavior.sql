USE mavenfuzzyfactory;

/*
November 01, 2014
From: Tom Parmesan (Marketing Director)
Subject: Repeat Visitors
Hey there,
We’ve been thinking about customer value based solely on their first session conversion and revenue. But if customers have repeat sessions, they may be more valuable than we thought. If that’s the case, we might be able to spend a bit 
more to acquire them.
Could you please pull data on how many of our website visitors come back for another session? 2014 to date is good. 
Thanks, Tom
*/

-- ASSIGNMENT: Identifying Repeat Visitors
-- SOLUTION: Identifying Repeat Visitors
-- STEP 1: Identify the relevant new sessions
-- STEP 2: User the user_id values form Step 1 to find any repeat sessions those users had
-- STEP 3: Analyze the data at the user level (how many sessions did each user have?)
-- STEP 4: Aggregate the user-level analysis to generate your behavioral analysis
CREATE TEMPORARY TABLE sessions_w_repeats
SELECT
	new_sessions.user_id,
	new_sessions.website_session_id AS new_session_id,
	website_sessions.website_session_id AS repeat_session_id
FROM(
SELECT
	user_id,
	website_session_id
FROM website_sessions
WHERE created_at < '2014-11-01' -- the date of the assignment
AND created_at >= '2014-01-01' -- prescribed date range in assignment
AND is_repeat_session = 0 -- new sessions only
) AS new_sessions
	LEFT JOIN website_sessions
		ON website_sessions.user_id = new_sessions.user_id
		AND website_sessions.is_repeat_session = 1 -- was a repeat session (redundant, but good to illustrate)
		AND website_sessions.website_session_id >  new_sessions.website_session_id -- session was later than new session
		AND website_sessions.created_at < '2014-11-01' -- the date of the assignment
		AND website_sessions.created_at >= '2014-01-01'; -- prescribed date range in assignment

SELECT
	repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM(
SELECT
	user_id,
	COUNT(DISTINCT new_session_id) AS new_sessions,
    COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM sessions_w_repeats
GROUP BY 1
ORDER BY 3 DESC
) AS user_level
GROUP BY 1
;
-- FINDING: So that tells us that 126,813 users had no repeat sessions. 14,086 users had one repeat session and 314 users had two repeat sessions and 4686 users had three repeat sessions

/*
November 01, 2014
From: Tom Parmesan (Marketing Director)
Subject: RE: Repeat Visitors
Thanks, it’s really interesting to see this breakdown. 
Looks like a fair number of our customers do come back to our site after the first session. 
Seems like we should learn more about this – I’ll follow up with some next steps soon. 
-Tom
*/

/*
November 03, 2014
From: Tom Parmesan (Marketing Director)
Subject: Deeper Dive on Repeat
Ok, so the repeat session data was really interesting to see. 
Now you’ve got me curious to better understand the behavior of these repeat customers.
Could you help me understand the minimum, maximum, and average time between the first and second session for customers who do come back? Again, analyzing 2014 to date is probably the right time period.
Thanks, Tom
*/

-- ASSIGNMENT: Analyzing Time to Repeat
-- SOLUTION: Analyzing Time to Repeat
-- STEP 1: Identify the relevant new sessions
-- STEP 2: User the user_id values form Step 1 to find any repeat sessions those users had
-- STEP 3: Find the created_at times for first and second sessions
-- STEP 4: Find the differences between first and second sessions at a user level
-- STEP 5: Aggregate the user level data to find the average, min, max
CREATE TEMPORARY TABLE sessions_w_repeats_for_time_diff
SELECT
	new_sessions.user_id,
	new_sessions.website_session_id AS new_session_id,
	new_sessions.created_at AS new_session_created_at,
    website_sessions.website_session_id AS repeat_session_id,
    website_sessions.created_at AS repeat_session_created_at
FROM(
SELECT
	user_id,
	website_session_id,
    created_at
FROM website_sessions
WHERE created_at < '2014-11-03' -- the date of the assignment
AND created_at >= '2014-01-01' -- prescribed date range in assignment
AND is_repeat_session = 0 -- new sessions only
) AS new_sessions
	LEFT JOIN website_sessions
		ON website_sessions.user_id = new_sessions.user_id
		AND website_sessions.is_repeat_session = 1 -- was a repeat session (redundant, but good to illustrate)
		AND website_sessions.website_session_id >  new_sessions.website_session_id -- session was later than new session
		AND website_sessions.created_at < '2014-11-03' -- the date of the assignment
		AND website_sessions.created_at >= '2014-01-01'; -- prescribed date range in assignment

CREATE TEMPORARY TABLE users_first_to_second
SELECT
	user_id,
    DATEDIFF(second_session_created_at, new_session_created_at) AS days_first_to_second_session
FROM(
SELECT
	user_id,
    new_session_id,
	new_session_created_at,
    MIN(repeat_session_id) AS second_session_id,
    MIN( repeat_session_created_at) AS second_session_created_at
FROM sessions_w_repeats_for_time_diff
WHERE repeat_session_id IS NOT NULL
GROUP BY 1, 2, 3
) AS first_second;

SELECT
	AVG(days_first_to_second_session) AS avg_days_first_to_second,
	MIN(days_first_to_second_session) AS min_days_first_to_second,
	MAX(days_first_to_second_session) AS max_days_first_to_second
FROM users_first_to_second
;
-- FINDING: Repeat visitors are coming back about a month later, on average.

/*
November 03, 2014
From: Tom Parmesan (Marketing Director)
Subject: RE: Deeper Dive on Repeat
Thanks! 
Interesting to see that our repeat visitors are coming back about a month later, on average.
I think we should investigate the channels that these visitors are using. I’ll follow up with some additional asks. 
-Tom
*/

/*
November 05, 2014
From: Tom Parmesan (Marketing Director)
Subject: Repeat Channel Mix
Hi there,
Let’s do a bit more digging into our repeat customers. 
Can you help me understand the channels they come back through? Curious if it’s all direct type-in, or if we’re paying for these customers with paid search ads multiple times. 
Comparing new vs. repeat sessions by channel would be really valuable, if you’re able to pull it! 2014 to date is great. 
Thanks, Tom
*/

-- ASSIGNMENT: Analyzing Repeat Channel Behavior
-- SOLUTION: Analyzing Repeat Channel Behavior
SELECT 
	 utm_source,
	 utm_campaign,
	 http_referer,
     COUNT(CASE WHEN is_repeat_session = 0 THEN	website_session_id ELSE NULL END) AS new_sessions,
     COUNT(CASE WHEN is_repeat_session = 1 THEN	website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1, 2, 3
ORDER BY 5 DESC;

SELECT
	CASE
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_searrch'
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
		WHEN utm_campaign = 'brand' THEN 'paid-brand'
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
		WHEN utm_source = 'socialbook' THEN 'paid_social'
	END AS channel_group,
-- utm_source,
-- utm_campaign,
-- http referer,
	COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_shessions,
	COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_shessions
FROM website_sessions
WHERE created_at < '2014-11-05' -- the date of the assignment
AND created_at >= '2014-01-01' -- prescribed date range in assignment
GROUP BY 1
ORDER BY 3 DESC
;
-- FINDING: It looks like when customers come back for repeat visits, they come mainly through organic search, direct type-in, and paid brand. 

/*
November 05, 2014
From: Tom Parmesan (Marketing Director)
Subject: RE: Repeat Channel Mix
Hi there,
So, it looks like when customers come back for repeat visits, they come mainly through organic search, direct type-in, and paid brand. 
Only about 1/3 come through a paid channel, and brand clicks are cheaper than nonbrand. So all in all, we’re not paying very much for these subsequent visits.
This make me wonder whether these convert to orders…
-Tom
*/

/*
November 08, 2014
From: Morgan Rockwell (Website Manager)
Subject: Top Website Pages
Hi there! 
Sounds like you and Tom have learned a lot about our repeat customers. Can I trouble you for one more thing? 
I’d love to do a comparison of conversion rates and revenue per session for repeat sessions vs new sessions. 
Let’s continue using data from 2014, year to date.
Thank you!
-Morgan
*/

-- ASSIGNMENT: Analyzing New & Repeat Conversion Rates
-- SOLUTION: Analyzing New & Repeat Conversion Rates
SELECT
	is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2014-11-08'
	AND website_sessions.created_at >= '2014-01-01'
GROUP BY 1
;
-- FINDING: the repeat sessions are more likely to convert, and produce more revenue per session

/*
November 08, 2014
From: Morgan Rockwell (Website Manager)
Subject: RE: Top Website Pages
Hey!
This is so interesting to see. Looks like repeat sessions are more likely to convert, and produce more revenue per session.
I’ll circle up with Tom on this one. Since we aren’t paying much for repeat sessions, we should probably take them into account when bidding on paid traffic.
Thanks! 
-Morgan
*/