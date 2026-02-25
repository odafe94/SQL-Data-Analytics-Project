# 📊 SQL Exploratory Data Analysis (EDA) - Retail Sales

> An end-to-end exploratory data analysis project that utilizes advanced T-SQL techniques, including window functions and CTEs, to extract actionable business insights from a curated warehouse environment.

## 🎯 Project Objective
Following the successful implementation of the [Medallion Data Warehouse Architecture](https://github.com/odafe94/SQL-data-warehouse-project), this project focuses on the **Exploratory Data Analysis (EDA)** of the curated Gold layer. The goal is to uncover business trends, understand customer demographics, and evaluate product performance using advanced SQL querying techniques.

## 🗄️ Dataset Context
This analysis is performed on the final analytical layer of the data warehouse, consisting of:
* `gold.dim_customers`: Enriched customer demographic data.
* `gold.dim_products`: Categorized product metadata.
* `gold.fact_sales`: Cleaned and standardized transactional sales data.

## 🔍 Analytical Focus Areas & Insights

### 1. Temporal & Cumulative Analysis

* **Change Over Time:** Aggregated total sales, customer counts, and item quantities by month and year using `DATETRUNC`.
* **Running Totals:** Calculated cumulative sales over time using advanced Window Functions (`SUM() OVER`) to track overall business growth.
* **Moving Averages:** Computed moving average prices across monthly timelines.

### 2. Performance Tracking & Comparisons
* **Year-Over-Year (YoY) Growth:** Utilized the `LAG()` function to compare current year product sales directly against the previous year's performance.
* **Benchmarking:** Compared individual product sales against their historical average to flag whether a product was performing "Above," "Below," or "Equal to" its historical baseline.

### 3. Part-to-Whole Analysis

* **Category Contribution:** Calculated the percentage each product category contributes to overall revenue by combining CTEs with total Window aggregates (`SUM(total_sales) OVER ()`).

### 4. Data Segmentation
* **Product Pricing Tiers:** Segmented the product catalog into distinct price brackets (e.g., Below 100, 100-500) using `CASE WHEN` statements to understand inventory distribution.
* **Customer Value Buckets:** Classified customers into 'VIP', 'Regular', and 'New' segments based on a combination of their historical lifespan (calculated via `DATEDIFF`) and total spending behavior.

### 5. Customer 360 Reporting (Data View)
Compiled all customer-centric metrics into a permanent, queryable database object (`CREATE VIEW gold.report_customers`). This view acts as a robust backend source for BI dashboards, containing:
* Demographic segments (Age groups).
* Behavioral segments (VIP vs. Regular).
* Key Performance Indicators: Recency (months since last order), Average Order Value (AOV), and Average Monthly Spend.

## 🛠️ SQL Techniques & Functions Showcased
* **Advanced Window Functions:** `LAG()` for YoY comparisons, and `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` for running totals.
* **Common Table Expressions (CTEs):** Used extensively (`WITH`) to break down complex multi-step calculations (like part-to-whole percentages and segmentation) into readable, modular code.
* **Database Objects:** `CREATE VIEW` to persist complex analytical transformations for end-users and visualization tools.
* **Control Flow:** Complex nested `CASE WHEN` logic for dynamic bucketing and categorical tagging.
* **Date Manipulation:** `DATETRUNC()`, `DATEDIFF()`, and `GETDATE()` for precise time-series analysis and cohort tracking.

## 🚀 Next Steps
The insights and Views generated from this SQL analysis serve as the foundation for the next phase of the data lifecycle: **Data Visualization**. The aggregated datasets produced here are optimized to be exported directly into a BI tool for interactive dashboarding.
