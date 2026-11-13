
# Data Cleaning in MySQL: Layoffs Dataset

Cleaning a layoffs dataset using MySQL Workbench.
Based on Alex The Analyst's project. The write-up and comments are mine,
and I used AI tools to review code and understand errors.

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
## Problems I faced and how I solved them
- Date error 1292: I used %y instead of %Y.
- Blank values were not NULL ('' or text), so I used TRIM and IN ('', 'NULL').
- Rows multiplied (14,136 instead of ~2,356) because I ran the INSERT twice,
  so I rebuilt the table with SELECT DISTINCT.
