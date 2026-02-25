/*
=====================================================
Ranking & Advanced Analytics
=====================================================
Purpose:
    - To rank items based on performance.
    - To track changes over time, cumulative totals, and YoY growth.
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5
    pr.product_name,
    SUM(sl.sales_amount) total_revenue
FROM gold.fact_sales sl
LEFT JOIN gold.dim_products pr
    ON sl.product_key = pr.product_key
GROUP BY pr.product_name
ORDER BY total_revenue DESC;

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    pr.product_name,
    SUM(sl.sales_amount) total_revenue
FROM gold.fact_sales sl
LEFT JOIN gold.dim_products pr
    ON sl.product_key = pr.product_key
GROUP BY pr.product_name
ORDER BY total_revenue;

-- Change Over Time
SELECT 
    DATETRUNC(month, order_date) order_date,
    SUM(sales_amount) total_sales,
    COUNT(DISTINCT customer_key) as total_customers,
    SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- Cumulative Analysis & Running Totals
SELECT 
    DATETRUNC(month, order_date) order_date,
    SUM(sales_amount) total_sales,
    SUM(SUM(sales_amount)) OVER (ORDER BY DATETRUNC(month, order_date)) total_sales_cumm
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- Moving Average
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) cumm_sum,
    AVG(average_price) OVER (PARTITION BY order_date ORDER BY order_date) moving_average
FROM (
    SELECT 
        DATETRUNC(month, order_date) order_date,
        SUM(sales_amount) total_sales,
        AVG(price) average_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL 
    GROUP BY DATETRUNC(month, order_date)
) t;

-- Yearly Performance: Compare to average and previous year (YoY)
WITH yearly_sales AS (
    SELECT 
        YEAR(sl.order_date) order_year,
        pr.product_name,
        SUM(sales_amount) sales_sum
    FROM gold.fact_sales sl
    LEFT JOIN gold.dim_products pr
        ON sl.product_key = pr.product_key
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(sl.order_date), pr.product_name
)
SELECT
    order_year,
    product_name,
    sales_sum,
    AVG(sales_sum) OVER (PARTITION BY product_name) avg_sales_by_product,
    sales_sum - AVG(sales_sum) OVER (PARTITION BY product_name) diff_avg,
    CASE WHEN sales_sum - AVG(sales_sum) OVER (PARTITION BY product_name) > 0 THEN 'above product avg'
         WHEN sales_sum - AVG(sales_sum) OVER (PARTITION BY product_name) = 0 THEN 'Equal to product avg'
         ELSE 'Below product avg'
    END AS avg_change,
    LAG(sales_sum, 1) OVER (PARTITION BY product_name ORDER BY order_year) previous_year_sales,
    sales_sum - LAG(sales_sum, 1) OVER (PARTITION BY product_name ORDER BY order_year) diff_prev_sales,
    CASE WHEN sales_sum - LAG(sales_sum, 1) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'above prev year'
         WHEN sales_sum - LAG(sales_sum, 1) OVER (PARTITION BY product_name ORDER BY order_year) = 0 THEN 'Equal prev year'
         WHEN sales_sum - LAG(sales_sum, 1) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'below prev year'
         ELSE 'n/a'
    END AS prev_year_change
FROM yearly_sales
ORDER BY product_name, order_year;

-- Part-to-whole analysis: Category Contribution
WITH total_catergory_sales AS (
    SELECT
        b.category,
        SUM(a.sales_amount) total_sales
    FROM gold.fact_sales a
    LEFT JOIN gold.dim_products b
        ON a.product_key = b.product_key
    GROUP BY b.category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () overall_sales,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') percentage_total
FROM total_catergory_sales
ORDER BY total_sales DESC;
