--This code copies the yelp business .json files from S3 account.

CREATE or REPLACE TABLE yelp_business (business_text variant)

COPY INTO yelp_business
FROM 's3://kspatiltest/yelp/yelp_academic_dataset_business.json'
CREDENTIALS = (
    AWS_KEY_ID = 'AGCBZKGKIAVQTRZBVHPZ',
    AWS_SECRET_KEY = 'izwB7w9WH2DMuvhEYxIjWafEEVl+HfpaGy9BdR2Y'
)
FILE_FORMAT = (TYPE=JSON);

--Just for testing
SELECT * FROM yelp_business LIMIT 10;