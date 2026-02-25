/*
==================================================
Database Exploration
==================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.
*/

-- Retrieve a list of all tables in the database
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

GO;

-- Retrieve all columns for a specific table (dim_customers)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

/*
==================================================
Dimensions Exploration
==================================================
Purpose:
    - To explore the structure of dimension tables.
*/

-- 1. Explore All countries our customers come from
SELECT DISTINCT 
    country 
FROM gold.dim_customers;

-- 2. Explore All Categories, Subcategories & Products
SELECT DISTINCT 
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY 1,2,3;

/*
==================================================
Date Range Exploration 
==================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.
*/

-- 3. Explore Date Ranges
-- Find the date of the first & last order and order range
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(year, MIN(order_date), MAX(order_date)) order_range_years
FROM gold.fact_sales;

-- Find the youngest and oldest customers
SELECT
    MIN(birth_date) oldest_birthdate,
    MAX(birth_date) youngest_birthdate,
    DATEDIFF(year, MIN(birth_date), GETDATE()) oldest_age,
    DATEDIFF(year, MAX(birth_date), GETDATE()) youngest_age
FROM gold.dim_customers;
