USE mavenfuzzyfactory;

/*
June 09, 2012
From: Morgan Rockwell (Website Manager)
Subject: Top Website Pages
Hi there! 
I’m Morgan, the new Website Manager. 
Could you help me get my head around the site by pulling the most-viewed website pages, ranked by session volume?
Thanks! 
-Morgan
*/

-- ASSIGNMENT: Finding Top Website Pages
-- SOLUTION: Finding Top Website Pages
SELECT
    pageview_url,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY
    pageview_url
ORDER BY
    sessions DESC
;
-- FINDING: The home page gets the vast majority of the page views during this time period, followedby the products and the original Mr Fuzzy Page.

/*
June 09, 2012
From: Morgan Rockwell (Website Manager)
Subject: RE: Top Website Pages
Thank you! 
It definitely seems like the homepage, the products page, and the Mr. Fuzzy page get the bulk of our traffic. 
I would like to understand traffic patterns more. 
I’ll follow up soon with a request to look at entry pages. 
Thanks! 
-Morgan
*/


/*
June 12, 2012
From: Morgan Rockwell (Website Manager)
Subject: Top Entry Pages
Hi there! 
Would you be able to pull a list of the top entry pages? I want to confirm where our users are hitting the site. 
If you could pull all entry pages and rank them on entry volume, that would be great.
Thanks! 
-Morgan

*/

-- ASSIGNMENT: Finding Top Entry Pages
-- SOLUTION: Finding Top Entry Pages
CREATE TEMPORARY TABLE first_pageviews 
SELECT 
    website_session_id, 
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews 
WHERE created_at < '2012-06-12' 
GROUP BY 
    website_session_id;

SELECT 
    website_pageviews.pageview_url AS landing_page, 
    COUNT(first_pageviews.website_session_id) AS sessions_hitting_this_landing_page 
FROM first_pageviews 
    LEFT JOIN website_pageviews 
        ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id 
GROUP BY 
    website_pageviews.pageview_url
;
-- FINDING: The landing page URL of the home page is getting all of the sessions at this point in the life of the business.

/*
June 12, 2012
From: Morgan Rockwell (Website Manager)
Subject: Top Entry Pages
Wow, looks like our traffic all comes in through the homepage right now!
Seems pretty obvious where we should focus on making any improvements ☺
I will likely have some follow up requests to look into performance for the homepage – stay tuned!
Thanks, 
-Morgan
*/





