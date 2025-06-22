--This code creates a function using python code in SQL codes of Snowflake.

CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING

LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('textblob')
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;


--This below is just a sample table for testing the above function
DROP TABLE IF EXISTS reviews;
CREATE TABLE IF NOT EXISTS reviews (review VARCHAR(2000));

INSERT INTO reviews VALUES ('I love this product. It works perfectly');
INSERT INTO reviews VALUES ('This product is ok, but it could be better');
INSERT INTO reviews VALUES ('I hate this product. It stopped working after a month');
INSERT INTO reviews VALUES ('This product is okay, not that great.');
INSERT INTO reviews VALUES ('This product is not good, but I can use.');
INSERT INTO reviews VALUES ('I hate this product so much that I threw it away in the dustbin after one month.');
INSERT INTO reviews VALUES ('I am putting this review after the usage of 2 months. The sound quality is very great, and it was not noisy The stereo speaker was good, but after some time, it got degraded. After 45 minutes of gaming, the cell get heated quickly.');

SELECT * FROM reviews;

SELECT review,analyze_sentiment(review) AS sentiments FROM reviews;


