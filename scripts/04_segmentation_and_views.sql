/*
========================================================================================
Data Segmentation
========================================================================================
Purpose:
    - To group data into logical buckets (e.g., pricing tiers, customer value).
*/

-- Segment products into cost ranges
WITH price_segments AS (
    SELECT
        product_name,
        cost,
        CASE WHEN cost < 100 THEN 'Below 100'
             WHEN cost BETWEEN 100 AND 500 THEN '100-500'
             WHEN cost BETWEEN 501 AND 1000 THEN '501-1000'
             ELSE 'Above 1000'
        END AS price_seg
    FROM gold.dim_products
)
SELECT
    price_seg,
    COUNT(product_name) product_count
FROM price_segments
GROUP BY price_seg
ORDER BY COUNT(product_name) DESC;

-- Segment customers by spending behavior (VIP, Regular, New)
WITH customer_sales_and_tenure AS (
    SELECT 
        b.customer_id customer_id,
        DATEDIFF(month, MIN(a.order_date), MAX(a.order_date)) lifespan,
        SUM(a.sales_amount) sales_amount
    FROM gold.fact_sales a
    LEFT JOIN gold.dim_customers b
        ON a.customer_key = b.customer_key
    GROUP BY b.customer_id, b.create_date
)
SELECT
    CASE WHEN lifespan >= 12 AND sales_amount > 5000 THEN 'VIP'
         WHEN lifespan >= 12 AND sales_amount <= 5000 THEN 'Regular'
         ELSE 'New'
    END AS customer_seg,
    COUNT(customer_id) customer_count
FROM customer_sales_and_tenure
GROUP BY CASE WHEN lifespan >= 12 AND sales_amount > 5000 THEN 'VIP'
              WHEN lifespan >= 12 AND sales_amount <= 5000 THEN 'Regular'
              ELSE 'New' END;

/*
========================================================================================
Customer Report (View Creation)
========================================================================================
Purpose:
    - Consolidates key customer metrics and behaviors into a queryable view for BI tools.
*/

CREATE VIEW gold.report_customers AS

WITH base_query AS (
    SELECT
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) customer_name,
        DATEDIFF(year, c.birth_date, GETDATE()) age
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
), 
customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) total_orders,
        SUM(sales_amount) total_sales,
        SUM(quantity) total_quantity,
        COUNT(DISTINCT product_key) total_products,
        MAX(order_date) last_order_date,
        MIN(order_date) first_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 30 THEN 'Below 30 years'
        WHEN age BETWEEN 30 AND 60 THEN '30-60 years'
        ELSE 'Above 60'
    END AS age_segment,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    CASE WHEN total_sales = 0 THEN 0 ELSE total_sales / total_orders END AS avg_order_value,
    CASE WHEN total_sales = 0 THEN 0 WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS avg_monthly_spend
FROM customer_aggregation;
