--This code copies the split yelp .json files from S3 account.

CREATE or REPLACE TABLE yelp_reviews (review_text variant)

COPY INTO yelp_reviews
FROM 's3://kspatiltest/yelp/yelp_review_files/'
CREDENTIALS = (
    AWS_KEY_ID = 'AGCBZKGKIAVQTRZBVHPZ',
    AWS_SECRET_KEY = 'izwB7w9WH2DMuvhEYxIjWafEEVl+HfpaGy9BdR2Y'
)
FILE_FORMAT = (TYPE=JSON);

--Just for testing
SELECT * FROM yelp_reviews LIMIT 10;