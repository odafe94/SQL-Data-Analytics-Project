/*
====================================================
Measures Exploration (Key Metrics)
====================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.
*/

-- Find Total Sales
SELECT SUM(sales_amount) total_sales FROM gold.fact_sales;

-- Find Total number of sold items
SELECT SUM(quantity) sold_item_count FROM gold.fact_sales;

-- Find the average sale price
SELECT AVG(price) average_price FROM gold.fact_sales;

-- Find the total number of orders
SELECT COUNT(order_number) total_orders FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) total_orders FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_key) total_number_products FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) total_number_customers FROM gold.dim_customers;

-- Find the total number of customers that have placed an order
SELECT COUNT(DISTINCT customer_key) number_of_customers_with_orders FROM gold.fact_sales;

-- =================================================
-- Collate all measures above in one query
-- =================================================

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' as measure_name, SUM(sales_amount) measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' as measure_name, AVG(price) average_price FROM gold.fact_sales
UNION ALL
SELECT 'Number of Orders' as measure_name, COUNT(DISTINCT order_number) total_orders FROM gold.fact_sales
UNION ALL
SELECT 'Number of Products' as measure_name, COUNT(product_key) total_number_products FROM gold.dim_products
UNION ALL
SELECT 'Number of Customers' as measure_name, COUNT(customer_key) total_number_customers FROM gold.dim_customers
UNION ALL
SELECT 'Number of Customers with at least 1 order' as measure_name, COUNT(DISTINCT customer_key) number_of_customers_with_orders FROM gold.fact_sales;

/*
====================================================
Magnitude Analysis
====================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.
*/

-- Find total customers by country
SELECT country, COUNT(*) total_customers FROM gold.dim_customers GROUP BY country ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT gender, COUNT(*) total_customers FROM gold.dim_customers GROUP BY gender ORDER BY total_customers DESC;

-- Find total products by category
SELECT category, COUNT(*) product_count FROM gold.dim_products GROUP BY category ORDER BY product_count DESC;

-- Average cost by category
SELECT category, AVG(cost) average_cost FROM gold.dim_products GROUP BY category ORDER BY average_cost DESC;

-- Total revenue by category
SELECT pr.category, SUM(sl.sales_amount) total_revenue FROM gold.fact_sales sl LEFT JOIN gold.dim_products pr ON sl.product_key = pr.product_key GROUP BY pr.category ORDER BY total_revenue DESC;

-- Total revenue by customer
SELECT ci.customer_key, SUM(sl.sales_amount) total_revenue FROM gold.fact_sales sl LEFT JOIN gold.dim_customers ci ON sl.customer_key = ci.customer_key GROUP BY ci.customer_key ORDER BY total_revenue DESC;

-- Distribution of sold items across countries
SELECT ci.country, SUM(sl.sales_amount) total_revenue FROM gold.fact_sales sl LEFT JOIN gold.dim_customers ci ON sl.customer_key = ci.customer_key GROUP BY ci.country ORDER BY total_revenue DESC;
