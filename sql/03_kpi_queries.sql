-- ============================================================
-- SQL Script 03: Business KPI Queries
-- ============================================================

-- ============================================================
-- 1. OVERALL BUSINESS KPIs (from fact table)
-- ============================================================

SELECT
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        SUM(total_price) / NULLIF(COUNT(DISTINCT invoice), 0),
        2
    ) AS avg_order_value,
    ROUND(
        SUM(total_price) / NULLIF(
            COUNT(DISTINCT customer_id),
            0
        ),
        2
    ) AS revenue_per_customer,
    MIN(invoicedate) AS first_transaction,
    MAX(invoicedate) AS last_transaction
FROM fact_transactions;

-- ============================================================
-- 2. REVENUE METRICS (from dedicated table)
-- ============================================================

SELECT *
FROM revenue_metrics
WHERE
    snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM revenue_metrics
    );

-- ============================================================
-- 3. MONTHLY REVENUE TRENDS
-- ============================================================

WITH
    monthly_data AS (
        SELECT
            `year_month`,
            ROUND(SUM(total_price), 2) AS revenue,
            COUNT(DISTINCT invoice) AS orders,
            COUNT(DISTINCT customer_id) AS customers
        FROM fact_transactions
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
        ) / NULLIF(
            LAG(revenue) OVER (
                ORDER BY `year_month`
            ),
            0
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_data
ORDER BY `year_month`;

-- ============================================================
-- 4. RFM SEGMENT DISTRIBUTION (from dim_customer)
-- ============================================================

SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM dim_customer
        ),
        2
    ) AS percentage,
    ROUND(
        AVG(days_since_last_purchase),
        1
    ) AS avg_recency_days,
    ROUND(AVG(total_orders), 1) AS avg_frequency,
    ROUND(AVG(total_spent), 2) AS avg_monetary
FROM dim_customer
GROUP BY
    customer_segment
ORDER BY customer_count DESC;

-- ============================================================
-- 5. SEGMENT KPIs
-- ============================================================

SELECT * FROM segment_kpis ORDER BY total_revenue DESC;

-- ============================================================
-- 6. CLV SEGMENT ANALYSIS (from dim_customer_clv)
-- ============================================================

-- CLV distribution by segment
SELECT
    clv_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(predicted_clv_12m), 2) AS avg_clv,
    ROUND(SUM(predicted_clv_12m), 2) AS total_clv,
    ROUND(
        SUM(predicted_clv_12m) * 100.0 / (
            SELECT SUM(predicted_clv_12m)
            FROM dim_customer_clv
        ),
        2
    ) AS value_percentage
FROM dim_customer_clv
GROUP BY
    clv_segment
ORDER BY avg_clv DESC;

-- CLV tier summary (latest snapshot)
SELECT *
FROM clv_tier_summary
WHERE
    snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM clv_tier_summary
    )
ORDER BY avg_clv DESC;

-- ============================================================
-- 7. CHURN RISK ANALYSIS (from dim_customer_risk)
-- ============================================================

-- Risk level distribution
SELECT
    risk_level,
    COUNT(*) AS customer_count,
    ROUND(AVG(churn_risk_score), 3) AS avg_risk_score
FROM dim_customer_risk
GROUP BY
    risk_level
ORDER BY
    CASE risk_level
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
        WHEN 'Very Low' THEN 5
        ELSE 6
    END;

-- High-risk active customers
SELECT
    COUNT(*) AS high_risk_active_count,
    ROUND(SUM(total_spent), 2) AS total_value_at_risk,
    ROUND(AVG(churn_risk_score), 3) AS avg_risk_score
FROM high_risk_active_customers;

-- ============================================================
-- 8. CUSTOMER 360 VIEW (Strategic segments)
-- ============================================================

-- Strategic segment distribution
SELECT
    strategic_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spent), 2) AS total_revenue,
    ROUND(AVG(predicted_clv_12m), 2) AS avg_clv,
    ROUND(AVG(churn_risk_score), 3) AS avg_risk
FROM customer_360_view
WHERE
    snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM customer_360_view
    )
GROUP BY
    strategic_segment
ORDER BY total_revenue DESC;

-- ============================================================
-- 9. PRODUCT CATEGORY PERFORMANCE
-- ============================================================

SELECT
    p.product_category,
    COUNT(DISTINCT f.invoice) AS order_count,
    SUM(f.quantity) AS total_quantity_sold,
    ROUND(SUM(f.total_price), 2) AS total_revenue,
    COUNT(DISTINCT f.customer_id) AS unique_customers,
    ROUND(
        SUM(f.total_price) / NULLIF(COUNT(DISTINCT f.invoice), 0),
        2
    ) AS avg_order_value
FROM
    fact_transactions f
    JOIN dim_product p ON f.stockcode = p.stockcode
WHERE
    p.product_category IS NOT NULL
    AND p.product_category != 'Unknown'
GROUP BY
    p.product_category
ORDER BY total_revenue DESC;

-- ============================================================
-- 10. TIME-BASED CUSTOMER BEHAVIOR (using date dimension)
-- ============================================================

-- Revenue by day of week
SELECT
    d.day_name,
    ROUND(SUM(f.total_price), 2) AS total_revenue,
    COUNT(DISTINCT f.invoice) AS orders,
    ROUND(AVG(f.total_price), 2) AS avg_transaction_value
FROM
    fact_transactions f
    JOIN dim_date d ON f.date_key = d.date_key
GROUP BY
    d.day_name,
    d.day_of_week
ORDER BY d.day_of_week;

-- Revenue by hour of day
SELECT
    f.hour,
    ROUND(SUM(f.total_price), 2) AS total_revenue,
    COUNT(DISTINCT f.invoice) AS orders,
    ROUND(AVG(f.total_price), 2) AS avg_transaction_value
FROM fact_transactions f
GROUP BY
    f.hour
ORDER BY f.hour;

-- ============================================================
-- 11. MONTHLY SEGMENT REVENUE TRENDS
-- ============================================================

SELECT
    `year_month`,
    customer_segment,
    revenue
FROM monthly_segment_revenue
ORDER BY `year_month`, revenue DESC;

-- ============================================================
-- 12. A/B TEST RESULTS (Latest)
-- ============================================================

SELECT * FROM ab_test_results ORDER BY test_date DESC LIMIT 1;

-- ============================================================
-- 13. EXECUTIVE DASHBOARD SUMMARY
-- ============================================================

SELECT '📊 EXECUTIVE SUMMARY' AS section;

SELECT 'Total Revenue' AS metric, CONCAT(
        '£', FORMAT(SUM(total_price), 2)
    ) AS value
FROM fact_transactions
UNION ALL
SELECT 'Total Customers', FORMAT(
        COUNT(DISTINCT customer_id), 0
    )
FROM fact_transactions
UNION ALL
SELECT 'Avg Order Value', CONCAT(
        '£', FORMAT(
            SUM(total_price) / NULLIF(COUNT(DISTINCT invoice), 0), 2
        )
    )
FROM fact_transactions
UNION ALL
SELECT 'Champions', FORMAT(COUNT(*), 0)
FROM dim_customer
WHERE
    customer_segment = 'Champions'
UNION ALL
SELECT 'High-Risk Customers', FORMAT(COUNT(*), 0)
FROM dim_customer_risk
WHERE
    risk_level IN ('Critical', 'High')
    AND prediction_date = (
        SELECT MAX(prediction_date)
        FROM dim_customer_risk
    )
UNION ALL
SELECT 'Total Predicted CLV', CONCAT(
        '£', FORMAT(SUM(predicted_clv_12m), 2)
    )
FROM dim_customer_clv;

-- ============================================================
-- 14. DATA QUALITY CHECKS
-- ============================================================

SELECT 'DATA QUALITY CHECK' AS check_type;

SELECT
    'fact_transactions' AS table_name,
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN customer_id IS NULL THEN 1
            ELSE 0
        END
    ) AS null_customers,
    SUM(
        CASE
            WHEN stockcode IS NULL THEN 1
            ELSE 0
        END
    ) AS null_products,
    SUM(
        CASE
            WHEN total_price <= 0 THEN 1
            ELSE 0
        END
    ) AS invalid_prices
FROM fact_transactions
UNION ALL
SELECT 'dim_customer', COUNT(*), SUM(
        CASE
            WHEN customer_segment IS NULL THEN 1
            ELSE 0
        END
    ), 0, 0
FROM dim_customer
UNION ALL
SELECT 'dim_customer_clv', COUNT(*), SUM(
        CASE
            WHEN predicted_clv_12m IS NULL THEN 1
            ELSE 0
        END
    ), 0, 0
FROM dim_customer_clv
UNION ALL
SELECT 'dim_customer_risk', COUNT(*), SUM(
        CASE
            WHEN churn_risk_score IS NULL THEN 1
            ELSE 0
        END
    ), 0, 0
FROM dim_customer_risk;

SELECT '✅ All queries ready for Power BI dashboard!' AS message;