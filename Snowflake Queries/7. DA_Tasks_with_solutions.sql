/*1. Find the number of businesses in each category.

2. Find the top 10 users who have reviewed the most businesses in the 'Restaurants' category.

3. Find the most popular categories of business (based on number of reviews).

4. Find the top 3 most recent reviews for each business.

5. Find the month with the highest number of reviews.

6. Find the percentage of five star reviews for each business.

7. Find the top 5 most reviewed business in each city.

8. Find the average rating of businesses that have at least 100 reviews.

9. List the top 10 users who have written the most reviews, along with the businesses they viewed.

10. Find top 10 businesses with highest positive sentiment reviews.*/

--Universally required table:
SELECT
    *
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
LIMIT 10
;

--1. Find the number of businesses in each category.
WITH c1 AS
(
    SELECT
        business_id, TRIM(A.value) AS category
    FROM
        yelp_business_final,
        LATERAL split_to_table(categories, ',') A
)
SELECT
    category
    ,COUNT(DISTINCT business_id) AS no_of_businesses
FROM
    c1
--WHERE category = 'Doctors'
GROUP BY category
ORDER BY no_of_businesses DESC
;

--2. Find the top 10 users who have reviewed the most businesses in the 'Restaurants' category.
SELECT
    user_id
    ,COUNT(DISTINCT rf.business_id) AS no_of_reviews
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
WHERE bf.categories ILIKE '%restaurant%'
GROUP BY user_id
ORDER BY no_of_reviews DESC
LIMIT 10
;

--3. Find the most popular categories of businesses (based on number of reviews).
WITH c1 AS
(
    SELECT
        business_id, TRIM(A.value) AS category
    FROM
        yelp_business_final,
        LATERAL split_to_table(categories, ',') A
)
SELECT
    category, COUNT(*) AS no_of_reviews
FROM
    c1
    JOIN yelp_reviews_final rf ON c1.business_id=rf.business_id
GROUP BY 1
ORDER BY 2 DESC
;


--4. Find the top 3 most recent reviews for each business.
--(by Me)
SELECT
    a.business_id
    ,a.business_name
    ,a.review_date
    ,a.review_stars
    ,a.review_text
FROM
(
    SELECT
        bf.business_id
        ,TRIM(bf.business_name) AS business_name
        ,rf.review_date
        ,rf.review_stars
        ,rf.review_text
        ,ROW_NUMBER() OVER (PARTITION BY bf.business_id ORDER BY rf.review_date DESC) AS rn
    FROM
        yelp_business_final bf
        JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
) a
WHERE a.rn <=3 --AND business_name ILIKE 'jimmy the%'
ORDER BY business_name, business_id, rn
;

--OR (by Ankit Bansal)
WITH cte AS (
    SELECT
        bf.business_id,
        TRIM(bf.business_name) AS business_name,
        rf.review_date,
        rf.review_stars,
        rf.review_text,
        ROW_NUMBER() OVER (PARTITION BY bf.business_id ORDER BY rf.review_date DESC) AS rn
    FROM yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id = rf.business_id
)
SELECT
    business_id,
    business_name,
    review_date,
    review_stars,
    review_text
FROM cte
WHERE rn <= 3
ORDER BY business_name, business_id, rn;

--OR (Recommended by ChatGPT)
SELECT
    bf.business_id,
    TRIM(bf.business_name) AS business_name,
    rf.review_date,
    rf.review_stars,
    rf.review_text
FROM yelp_business_final bf
JOIN yelp_reviews_final rf ON bf.business_id = rf.business_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY bf.business_id ORDER BY rf.review_date DESC) <= 3
ORDER BY business_name, business_id
;



--5. Find the month with the highest number of reviews.
--(by me)Considering only month for the highest number of reviews over the years.
SELECT
    MONTHNAME(review_date) AS review_month
    ,COUNT(review_text) reviews_in_month
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
;
--(by me)Considering the month for the highest number of reviews every year.
SELECT
    YEAR(review_date) AS review_year
    ,MONTHNAME(review_date) AS review_month
    ,COUNT(review_text) reviews_in_month
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
GROUP BY 1,2
QUALIFY ROW_NUMBER() OVER(PARTITION BY review_year ORDER BY reviews_in_month DESC) = 1
ORDER BY 1,2 DESC
;

--6. Find the percentage of five star reviews for each business.
--(by me)
WITH cte_total_reviews AS
(
    SELECT 
        business_id,
        COUNT(review_stars) AS total_reviews
    FROM 
        yelp_reviews_final
    GROUP BY business_id
),
cte_five_star_reviews AS
(
    SELECT 
        business_id,
        COUNT(CASE WHEN review_stars = 5 THEN 1 ELSE NULL END) AS five_star_reviews
    FROM 
        yelp_reviews_final
    GROUP BY business_id
)
SELECT 
    c1.business_id
    ,TRIM(bf.business_name) AS business_name
    ,ROUND(c2.five_star_reviews/c1.total_reviews*100,2) AS five_star_percentage
FROM
    cte_total_reviews c1
    JOIN cte_five_star_reviews c2 ON c1.business_id = c2.business_id
    JOIN yelp_business_final bf ON c1.business_id = bf.business_id
ORDER BY 2
;

--OR (by Me)

SELECT
    rf.business_id
    ,TRIM(bf.business_name) AS business_name
    ,ROUND(COUNT(CASE WHEN rf.review_stars = 5 THEN 1 ELSE NULL END)/COUNT(rf.review_stars)*100,2) AS five_star_percentage
FROM
    yelp_reviews_final rf
    JOIN yelp_business_final bf ON rf.business_id = bf.business_id
GROUP BY 1,2
ORDER BY 2
;

--OR (by AB (Not working))

SELECT
    rf.business_id
    ,TRIM(bf.business_name) AS business_name
    ,COUNT(CASE WHEN rf.review_stars = 5 THEN 1 ELSE NULL END) AS five_star_count
    ,COUNT(rf.review_text) AS review_count
    ,ROUND(five_star_count*100/review_count,2) AS five_star_percentage
FROM
    yelp_reviews_final rf
    JOIN yelp_business_final bf ON rf.business_id = bf.business_id
GROUP BY 1,2
ORDER BY 2
;

--7. Find the top 5 most reviewed business in each city.
--(By me)
SELECT * FROM 
(SELECT
    city
    ,bf.business_name
    ,COUNT(rf.review_text) AS review_count
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
GROUP BY 1,2
) a
QUALIFY ROW_NUMBER() OVER (PARTITION BY city ORDER BY review_count DESC) <=5
ORDER BY 1,3 DESC
;
--OR (By AB)
WITH c1 AS 
(
    SELECT
        city
        ,bf.business_name
        ,COUNT(rf.review_text) AS review_count
    FROM
        yelp_business_final bf
        JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
    GROUP BY 1,2
)
SELECT 
    * 
FROM 
    c1
QUALIFY ROW_NUMBER() OVER (PARTITION BY city ORDER BY review_count DESC) <=5
ORDER BY 1,3 DESC
;


--8. Find the average rating of businesses that have at least 100 reviews.
SELECT
    rf.business_id
    ,bf.business_name
    ,ROUND(AVG(review_stars),2) AS avg_rating
FROM
    yelp_reviews_final rf
    JOIN yelp_business_final bf ON rf.business_id=bf.business_id
GROUP BY 1,2
HAVING COUNT(*)>=100
ORDER BY 2
;

--9. List the top 10 users who have written the most reviews, along with the businesses they viewed.
--(by me) Case in which business names are written within the row.
SELECT
    user_id
    ,COUNT(*) AS no_of_reviews
    ,LISTAGG(DISTINCT TRIM(bf.business_name),', ') WITHIN GROUP (ORDER BY TRIM(bf.business_name)) AS businesses_reviewed
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;

--(by AB) Case in which business names are written on multiple rows.
WITH cte AS
(
    SELECT
        user_id
        ,COUNT(*) AS no_of_reviews
    FROM
        yelp_reviews_final
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10
)
SELECT
    user_id
    ,rf.business_id
    ,bf.business_name
FROM
    yelp_reviews_final rf
    JOIN yelp_business_final bf ON rf.business_id = bf.business_id
WHERE user_id IN (SELECT user_id FROM cte)
ORDER BY user_id
;


--10. Find top 10 businesses with highest positive sentiment reviews.
--(by me)
SELECT
    rf.business_id
    ,bf.business_name
    ,COUNT_IF(sentiments = 'Positive') AS no_of_positive_reviews
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10
;

--(by AB)
SELECT
    rf.business_id
    ,bf.business_name
    ,COUNT(*) AS no_of_positive_reviews
FROM
    yelp_business_final bf
    JOIN yelp_reviews_final rf ON bf.business_id=rf.business_id
WHERE sentiments = 'Positive'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10
;
