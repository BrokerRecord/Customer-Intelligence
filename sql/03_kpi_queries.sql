-- ============================================================
-- SQL Script 03: Business KPI Queries
-- Purpose: Calculate key business metrics for dashboard
-- ============================================================

-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

-- Total Revenue, Orders, Customers, AOV
SELECT
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        SUM(total_price) / COUNT(DISTINCT invoice),
        2
    ) AS avg_order_value,
    ROUND(
        SUM(total_price) / COUNT(DISTINCT customer_id),
        2
    ) AS revenue_per_customer,
    MIN(invoicedate) AS first_transaction,
    MAX(invoicedate) AS last_transaction
FROM online_retail;

-- ============================================================
-- 2. MONTHLY REVENUE TRENDS
-- ============================================================

-- Monthly revenue with growth rate
WITH
    monthly_data AS (
        SELECT
            `year_month`,
            ROUND(SUM(total_price), 2) AS revenue,
            COUNT(DISTINCT invoice) AS orders,
            COUNT(DISTINCT customer_id) AS customers
        FROM online_retail
        GROUP BY
            `year_month`
    )
SELECT
    `year_month`,
    revenue,
    orders,
    customers,
    ROUND(
        revenue - LAG(revenue) OVER (
            ORDER BY `year_month`
        ),
        2
    ) AS revenue_change,
    ROUND(
        (
            revenue - LAG(revenue) OVER (
                ORDER BY `year_month`
            )
        ) / LAG(revenue) OVER (
            ORDER BY `year_month`
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_data
ORDER BY `year_month`;

-- ============================================================
-- 3. HOURLY SALES PATTERNS
-- ============================================================

-- Revenue by hour of day
SELECT
    hour,
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS orders,
    COUNT(*) AS transactions,
    ROUND(AVG(total_price), 2) AS avg_transaction_value
FROM online_retail
GROUP BY
    hour
ORDER BY hour;

-- Peak hours (top 5 by revenue)
SELECT hour, ROUND(SUM(total_price), 2) AS total_revenue
FROM online_retail
GROUP BY
    hour
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================================
-- 4. WEEKDAY SALES PATTERNS
-- ============================================================

-- Revenue by day of week
SELECT
    day_of_week,
    CASE day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END AS day_order,
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS orders,
    COUNT(DISTINCT customer_id) AS customers
FROM online_retail
GROUP BY
    day_of_week
ORDER BY day_order;

-- ============================================================
-- 5. COUNTRY PERFORMANCE
-- ============================================================

-- Top countries by revenue (excluding UK as it dominates)
SELECT
    country,
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(
        SUM(total_price) / COUNT(DISTINCT invoice),
        2
    ) AS avg_order_value,
    ROUND(
        SUM(total_price) * 100.0 / (
            SELECT SUM(total_price)
            FROM online_retail
        ),
        2
    ) AS revenue_percentage
FROM online_retail
WHERE
    country != 'United Kingdom'
GROUP BY
    country
ORDER BY total_revenue DESC
LIMIT 10;

-- All countries summary
SELECT
    country,
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS customers
FROM online_retail
GROUP BY
    country
ORDER BY total_revenue DESC;

-- ============================================================
-- 6. PRODUCT PERFORMANCE
-- ============================================================

-- Top 10 products by revenue
SELECT
    stockcode,
    LEFT(description, 60) AS description,
    ROUND(SUM(total_price), 2) AS total_revenue,
    SUM(quantity) AS total_quantity_sold,
    COUNT(DISTINCT invoice) AS number_of_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(price), 2) AS avg_price
FROM online_retail
WHERE
    description IS NOT NULL
    AND description != ''
GROUP BY
    stockcode,
    description
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 products by quantity sold
SELECT
    stockcode,
    LEFT(description, 60) AS description,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM online_retail
WHERE
    description IS NOT NULL
    AND description != ''
GROUP BY
    stockcode,
    description
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- ============================================================
-- 7. CUSTOMER VALUE ANALYSIS
-- ============================================================

-- Customer value tiers
SELECT
    CASE
        WHEN total_spent < 100 THEN 'Bronze (<$100)'
        WHEN total_spent < 500 THEN 'Silver ($100-$500)'
        WHEN total_spent < 1000 THEN 'Gold ($500-$1000)'
        WHEN total_spent < 5000 THEN 'Platinum ($1000-$5000)'
        ELSE 'Diamond (>$5000)'
    END AS customer_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_spent,
    ROUND(SUM(total_spent), 2) AS total_revenue,
    ROUND(AVG(order_count), 1) AS avg_orders,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value
FROM (
        SELECT
            customer_id, SUM(total_price) AS total_spent, COUNT(DISTINCT invoice) AS order_count, AVG(total_price) AS avg_order_value
        FROM online_retail
        GROUP BY
            customer_id
    ) AS customer_stats
GROUP BY
    customer_tier
ORDER BY MIN(total_spent);

-- Top 20 customers by total spend
SELECT
    customer_id,
    ROUND(SUM(total_price), 2) AS total_spent,
    COUNT(DISTINCT invoice) AS order_count,
    MIN(invoicedate) AS first_purchase,
    MAX(invoicedate) AS last_purchase,
    DATEDIFF(
        MAX(invoicedate),
        MIN(invoicedate)
    ) AS customer_lifetime_days,
    ROUND(
        SUM(total_price) / COUNT(DISTINCT invoice),
        2
    ) AS avg_order_value
FROM online_retail
GROUP BY
    customer_id
ORDER BY total_spent DESC
LIMIT 20;

-- ============================================================
-- 8. SEASONALITY ANALYSIS
-- ============================================================

-- Monthly seasonality across years
SELECT
    month,
    month_name,
    ROUND(AVG(revenue), 2) AS avg_monthly_revenue,
    ROUND(STDDEV(revenue), 2) AS revenue_stddev
FROM (
        SELECT YEAR(invoicedate) AS year, MONTH(invoicedate) AS month, month_name, ROUND(SUM(total_price), 2) AS revenue
        FROM online_retail
        GROUP BY
            YEAR(invoicedate), MONTH(invoicedate), month_name
    ) AS monthly
GROUP BY
    month,
    month_name
ORDER BY month;
-- ============================================================
-- 9. CUSTOMER RETENTION ANALYSIS
-- ============================================================

-- Cohort retention analysis (simplified)
WITH
    first_purchases AS (
        SELECT customer_id, DATE_FORMAT(MIN(invoicedate), '%Y-%m') AS cohort_month
        FROM online_retail
        GROUP BY
            customer_id
    ),
    cohort_data AS (
        SELECT f.cohort_month, DATE_FORMAT(o.invoicedate, '%Y-%m') AS purchase_month, COUNT(DISTINCT o.customer_id) AS customers
        FROM
            first_purchases f
            JOIN online_retail o ON f.customer_id = o.customer_id
        GROUP BY
            f.cohort_month,
            purchase_month
    )
SELECT
    cohort_month,
    MAX(
        CASE
            WHEN purchase_month = cohort_month THEN customers
        END
    ) AS month_0,
    MAX(
        CASE
            WHEN purchase_month = DATE_ADD(
                STR_TO_DATE(
                    CONCAT(cohort_month, '-01'),
                    '%Y-%m-%d'
                ),
                INTERVAL 1 MONTH
            ) THEN customers
        END
    ) AS month_1,
    MAX(
        CASE
            WHEN purchase_month = DATE_ADD(
                STR_TO_DATE(
                    CONCAT(cohort_month, '-01'),
                    '%Y-%m-%d'
                ),
                INTERVAL 2 MONTH
            ) THEN customers
        END
    ) AS month_2,
    MAX(
        CASE
            WHEN purchase_month = DATE_ADD(
                STR_TO_DATE(
                    CONCAT(cohort_month, '-01'),
                    '%Y-%m-%d'
                ),
                INTERVAL 3 MONTH
            ) THEN customers
        END
    ) AS month_3
FROM cohort_data
GROUP BY
    cohort_month
ORDER BY cohort_month;

-- ============================================================
-- 10. RFM SEGMENT ANALYSIS (from pre-calculated table)
-- ============================================================

-- Segment distribution
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM rfm_customer_scores
        ),
        2
    ) AS percentage,
    ROUND(AVG(recency), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 1) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM rfm_customer_scores
GROUP BY
    customer_segment
ORDER BY customer_count DESC;

-- Champions vs At Risk comparison
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency), 1) AS avg_recency,
    ROUND(AVG(frequency), 1) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM rfm_customer_scores
WHERE
    customer_segment IN ('Champions', 'At Risk')
GROUP BY
    customer_segment
ORDER BY customer_count DESC;

-- ============================================================
-- 11. DATA QUALITY CHECKS
-- ============================================================

-- Check for missing values
SELECT
    'customer_id' AS column_name,
    COUNT(*) - COUNT(customer_id) AS missing_count
FROM online_retail
UNION ALL
SELECT 'description', COUNT(*) - COUNT(description)
FROM online_retail
UNION ALL
SELECT 'country', COUNT(*) - COUNT(country)
FROM online_retail;

-- Check for negative quantities or prices
SELECT
    SUM(
        CASE
            WHEN quantity < 0 THEN 1
            ELSE 0
        END
    ) AS negative_quantity_count,
    SUM(
        CASE
            WHEN price < 0 THEN 1
            ELSE 0
        END
    ) AS negative_price_count,
    SUM(
        CASE
            WHEN total_price < 0 THEN 1
            ELSE 0
        END
    ) AS negative_total_count
FROM online_retail;

-- ============================================================
-- 12. BUSINESS INSIGHTS SUMMARY QUERY
-- ============================================================

SELECT '📊 BUSINESS INSIGHTS SUMMARY' AS insight;

SELECT CONCAT(
        'Total Revenue: $', FORMAT(SUM(total_price), 2)
    ) AS metric
FROM online_retail
UNION ALL
SELECT CONCAT(
        'Total Orders: ', FORMAT(COUNT(DISTINCT invoice), 0)
    )
FROM online_retail
UNION ALL
SELECT CONCAT(
        'Unique Customers: ', FORMAT(
            COUNT(DISTINCT customer_id), 0
        )
    )
FROM online_retail
UNION ALL
SELECT CONCAT(
        'Average Order Value: $', FORMAT(
            SUM(total_price) / COUNT(DISTINCT invoice), 2
        )
    )
FROM online_retail
UNION ALL
SELECT CONCAT(
        'Top Country: ', (
            SELECT country
            FROM online_retail
            GROUP BY
                country
            ORDER BY SUM(total_price) DESC
            LIMIT 1
        )
    )
FROM online_retail
UNION ALL
SELECT CONCAT(
        'Peak Sales Hour: ', (
            SELECT hour
            FROM online_retail
            GROUP BY
                hour
            ORDER BY SUM(total_price) DESC
            LIMIT 1
        ), ':00'
    )
FROM online_retail
UNION ALL
SELECT CONCAT(
        'Top Product: ', (
            SELECT description
            FROM online_retail
            GROUP BY
                description
            ORDER BY SUM(total_price) DESC
            LIMIT 1
        )
    )
FROM online_retail;