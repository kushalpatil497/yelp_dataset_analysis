SELECT * FROM yelp_business LIMIT 10;

DROP TABLE IF EXISTS yelp_business_final;
CREATE OR REPLACE TABLE yelp_business_final AS
SELECT 
    business_text:business_id::string AS business_id
    ,business_text:name::string AS business_name
    ,business_text:city::string AS city
    ,business_text:state::string AS state
    ,business_text:review_count::INT AS review_count
    ,business_text:stars::number AS stars
    ,business_text:categories::string AS categories
FROM 
    yelp_business
;

--Just for testing
SELECT * FROM yelp_business_final;



