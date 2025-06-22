# yelp_dataset_analysis
Yelp review data analysis using Python, AWS S3, and Snowflake SQL.

# 📊 Yelp Review Analysis on Snowflake

This project demonstrates how to process and analyse the Yelp Open Dataset using Python, AWS S3, and Snowflake SQL.

---

## ✅ Steps to Perform This Project

1. **Download the dataset** from the [Yelp Open Dataset](https://business.yelp.com/data/resources/open-dataset/).
2. Use **`Split_Files.ipynb`** (a Python Jupyter Notebook created in Anaconda) to split the large JSON files into manageable chunks.
3. **Upload** the split files to your AWS **S3 bucket**.
4. Generate **Access Key ID** and **Secret Access Key** for your **IAM User** on AWS.
5. Execute the setup and transformation queries provided in the **`Snowflake Queries/`** folder.
6. Perform data analysis tasks (e.g. sentiment analysis, top users, review insights) using the SQL scripts in the same folder.

---

## 📂 Project Structure


