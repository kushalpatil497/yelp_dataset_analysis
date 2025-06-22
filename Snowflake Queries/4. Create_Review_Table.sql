SELECT * FROM yelp_reviews LIMIT 10;

--This code creates a table called 'yelp_reviews_final'
DROP TABLE IF EXISTS yelp_reviews_final;
CREATE OR REPLACE TABLE yelp_reviews_final AS
SELECT 
    review_text:business_id::string AS business_id
    ,review_text:user_id::string AS user_id
    ,review_text:date::date AS review_date
    ,review_text:stars::number AS review_stars
    ,review_text:text::string AS review_text
    ,analyze_sentiment(review_text) AS sentiments
    
FROM 
    yelp_reviews 
--LIMIT 10
;

--Just for testing
SELECT * FROM yelp_reviews_final WHERE business_id ='NqMRyM39K87frumPIJDekg' ORDER BY review_stars DESC;