
# Data Cleaning in MySQL: Layoffs Dataset

Cleaning a layoffs dataset using MySQL Workbench.
Based on Alex The Analyst's project. The code and explanations are mine.

## Steps
1. Create a staging table
2. Remove duplicates with ROW_NUMBER()
3. Standardize data (trim, industry, country, date format)
4. Handle NULL and blank values
5. Remove unnecessary rows and columns

## Result
Final table: 1995 rows.

## How to run
Import the raw layoffs table, then run layoffs_cleaning.sql one statement at a time, in order.
