-- ============================================================
-- SQL Script 04: Advanced Analytical Queries
-- Purpose: Deeper analytical insights for business decisions
-- ============================================================

-- ============================================================
-- 1. CUSTOMER LIFETIME VALUE TRENDS
-- ============================================================

-- Customer lifetime value distribution
SELECT
    CASE
        WHEN lifetime_value < 100 THEN '0-100'
        WHEN lifetime_value < 500 THEN '100-500'
        WHEN lifetime_value < 1000 THEN '500-1,000'
        WHEN lifetime_value < 5000 THEN '1,000-5,000'
        ELSE '5,000+'
    END AS ltv_range,
    COUNT(*) AS customer_count,
    ROUND(AVG(lifetime_value), 2) AS avg_ltv,
    ROUND(SUM(lifetime_value), 2) AS total_value,
    ROUND(AVG(order_count), 1) AS avg_orders,
    ROUND(AVG(recency_days), 1) AS avg_recency
FROM (
        SELECT
            customer_id, SUM(total_price) AS lifetime_value, COUNT(DISTINCT invoice) AS order_count, DATEDIFF(
                MAX(invoicedate), MIN(invoicedate)
            ) AS customer_lifetime_days, DATEDIFF(
                (
                    SELECT MAX(invoicedate)
                    FROM online_retail
                ), MAX(invoicedate)
            ) AS recency_days
        FROM online_retail
        GROUP BY
            customer_id
    ) AS customer_metrics
GROUP BY
    ltv_range
ORDER BY MIN(lifetime_value);

-- ============================================================
-- 2. PRODUCT AFFINITY / MARKET BASKET ANALYSIS
-- ============================================================

-- Find products frequently bought together
WITH
    invoice_pairs AS (
        SELECT
            a.invoice,
            a.stockcode AS product_a,
            b.stockcode AS product_b,
            a.description AS desc_a,
            b.description AS desc_b
        FROM
            online_retail a
            JOIN online_retail b ON a.invoice = b.invoice
            AND a.stockcode < b.stockcode
        WHERE
            a.description IS NOT NULL
            AND b.description IS NOT NULL
    )
SELECT
    product_a,
    LEFT(desc_a, 40) AS product_a_name,
    product_b,
    LEFT(desc_b, 40) AS product_b_name,
    COUNT(*) AS times_bought_together,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(DISTINCT invoice)
            FROM online_retail
        ),
        2
    ) AS affinity_score
FROM invoice_pairs
GROUP BY
    product_a,
    product_b,
    desc_a,
    desc_b
HAVING
    times_bought_together > 5
ORDER BY times_bought_together DESC
LIMIT 20;

-- ============================================================
-- 3. CUSTOMER PURCHASE VELOCITY
-- ============================================================

-- Customers with increasing purchase frequency
WITH
    purchase_timeline AS (
        SELECT
            customer_id,
            YEAR(invoicedate) AS year,
            MONTH(invoicedate) AS month,
            COUNT(DISTINCT invoice) AS monthly_orders,
            SUM(total_price) AS monthly_spend
        FROM online_retail
        GROUP BY
            customer_id,
            year,
            month
    ),
    velocity AS (
        SELECT
            customer_id,
            AVG(monthly_orders) AS avg_monthly_orders,
            STDDEV(monthly_orders) AS order_volatility,
            SUM(monthly_spend) AS total_spend,
            COUNT(*) AS active_months
        FROM purchase_timeline
        GROUP BY
            customer_id
    )
SELECT
    CASE
        WHEN avg_monthly_orders >= 5 THEN 'High Velocity (>5 orders/month)'
        WHEN avg_monthly_orders >= 2 THEN 'Medium Velocity (2-5 orders/month)'
        ELSE 'Low Velocity (<2 orders/month)'
    END AS velocity_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_monthly_orders), 2) AS avg_orders_per_month,
    ROUND(AVG(total_spend), 2) AS avg_total_spend,
    ROUND(AVG(order_volatility), 2) AS avg_volatility
FROM velocity
GROUP BY
    velocity_segment
ORDER BY avg_orders_per_month DESC;

-- ============================================================
-- 4. SEASONAL PRODUCT DEMAND
-- ============================================================

-- Products with strong seasonality
SELECT
    stockcode,
    LEFT(description, 50) AS description,
    MONTH(invoicedate) AS month,
    month_name,
    SUM(quantity) AS quantity_sold,
    ROUND(SUM(total_price), 2) AS revenue
FROM online_retail
WHERE
    description LIKE '%CHRISTMAS%'
    OR description LIKE '%SEASONAL%'
    OR description LIKE '%HALLOWEEN%'
GROUP BY
    stockcode,
    description,
    month,
    month_name
ORDER BY month, revenue DESC;

-- ============================================================
-- 5. CUSTOMER CHURN RISK SCORES (from predictions table)
-- ============================================================

-- High-risk customers summary
SELECT
    risk_level,
    COUNT(*) AS customer_count,
    ROUND(AVG(churn_risk_score), 3) AS avg_risk_score,
    ROUND(SUM(c.monetary), 2) AS total_at_risk_value
FROM
    churn_predictions p
    JOIN rfm_customer_scores c ON p.customer_id = c.customer_id
WHERE
    p.prediction_date = (
        SELECT MAX(prediction_date)
        FROM churn_predictions
    )
GROUP BY
    risk_level
ORDER BY avg_risk_score DESC;

-- Top 50 highest risk customers with their value
SELECT
    p.customer_id,
    p.churn_risk_score,
    c.monetary AS lifetime_value,
    c.frequency AS total_orders,
    c.recency AS days_since_last_purchase,
    c.customer_segment
FROM
    churn_predictions p
    JOIN rfm_customer_scores c ON p.customer_id = c.customer_id
WHERE
    p.prediction_date = (
        SELECT MAX(prediction_date)
        FROM churn_predictions
    )
    AND p.churn_risk_score > 0.7
ORDER BY p.churn_risk_score DESC, c.monetary DESC
LIMIT 50;

-- ============================================================
-- 6. MARKETING CAMPAIGN ROI ANALYSIS (simulated)
-- ============================================================

-- Segment-level marketing efficiency
SELECT
    customer_segment,
    customer_count,
    total_revenue,
    ROUND(
        total_revenue / customer_count,
        2
    ) AS revenue_per_customer,
    CASE
        WHEN customer_segment = 'Champions' THEN total_revenue * 0.05
        WHEN customer_segment = 'Loyal Customers' THEN total_revenue * 0.10
        WHEN customer_segment = 'At Risk' THEN total_revenue * 0.15
        WHEN customer_segment = 'New Customers' THEN total_revenue * 0.20
        ELSE total_revenue * 0.05
    END AS recommended_budget,
    CASE
        WHEN customer_segment = 'Champions' THEN 'Retention'
        WHEN customer_segment = 'Loyal Customers' THEN 'Cross-sell'
        WHEN customer_segment = 'At Risk' THEN 'Win-back'
        WHEN customer_segment = 'New Customers' THEN 'Onboarding'
        ELSE 'General'
    END AS campaign_type
FROM segment_kpis
ORDER BY total_revenue DESC;

-- ============================================================
-- 7. TIME-BASED CUSTOMER BEHAVIOR
-- ============================================================

-- Customer purchase lifecycle analysis
WITH
    customer_lifecycle AS (
        SELECT
            customer_id,
            MIN(invoicedate) AS first_purchase,
            MAX(invoicedate) AS last_purchase,
            COUNT(DISTINCT invoice) AS total_orders,
            DATEDIFF(
                MAX(invoicedate),
                MIN(invoicedate)
            ) AS active_days
        FROM online_retail
        GROUP BY
            customer_id
    )
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time buyers'
        WHEN total_orders <= 3 THEN 'Occasional (2-3 orders)'
        WHEN total_orders <= 10 THEN 'Regular (4-10 orders)'
        ELSE 'Frequent (10+ orders)'
    END AS buyer_type,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_orders), 1) AS avg_orders,
    ROUND(AVG(active_days), 1) AS avg_active_days,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM customer_lifecycle
        ),
        2
    ) AS percentage
FROM customer_lifecycle
GROUP BY
    buyer_type
ORDER BY avg_orders;

-- ============================================================
-- 8. WEEKLY SALES PERFORMANCE
-- ============================================================

-- 4-week rolling average revenue
WITH
    weekly_revenue AS (
        SELECT
            YEARWEEK(invoicedate, 1) AS year_week,
            DATE_SUB(
                invoicedate,
                INTERVAL WEEKDAY(invoicedate) DAY
            ) AS week_start,
            ROUND(SUM(total_price), 2) AS weekly_revenue
        FROM online_retail
        GROUP BY
            year_week,
            week_start
    )
SELECT
    week_start,
    weekly_revenue,
    ROUND(
        AVG(weekly_revenue) OVER (
            ORDER BY week_start ROWS BETWEEN 3 PRECEDING
                AND CURRENT ROW
        ),
        2
    ) AS rolling_4wk_avg,
    ROUND(
        (
            weekly_revenue - LAG(weekly_revenue) OVER (
                ORDER BY week_start
            )
        ) / LAG(weekly_revenue) OVER (
            ORDER BY week_start
        ) * 100,
        2
    ) AS week_over_week_pct
FROM weekly_revenue
ORDER BY week_start DESC
LIMIT 20;

-- ============================================================
-- 9. CROSS-SELL OPPORTUNITIES
-- ============================================================

-- Customers who bought from one category but not another
WITH
    category_customers AS (
        SELECT DISTINCT
            customer_id,
            CASE
                WHEN description LIKE '%GARDEN%'
                OR description LIKE '%PLANT%' THEN 1
                ELSE 0
            END AS bought_garden,
            CASE
                WHEN description LIKE '%KITCHEN%'
                OR description LIKE '%MUG%'
                OR description LIKE '%CUP%' THEN 1
                ELSE 0
            END AS bought_kitchen,
            CASE
                WHEN description LIKE '%DECOR%'
                OR description LIKE '%FRAME%'
                OR description LIKE '%LIGHT%' THEN 1
                ELSE 0
            END AS bought_home_decor,
            CASE
                WHEN description LIKE '%TOY%'
                OR description LIKE '%GAME%' THEN 1
                ELSE 0
            END AS bought_toys
        FROM online_retail
    )
SELECT
    'Garden → Kitchen' AS cross_sell_opportunity,
    SUM(bought_garden) AS garden_customers,
    SUM(
        bought_garden
        AND NOT bought_kitchen
    ) AS potential_cross_sell,
    ROUND(
        SUM(
            bought_garden
            AND NOT bought_kitchen
        ) * 100.0 / SUM(bought_garden),
        2
    ) AS opportunity_pct
FROM category_customers
UNION ALL
SELECT 'Home Decor → Garden', SUM(bought_home_decor), SUM(
        bought_home_decor
        AND NOT bought_garden
    ), ROUND(
        SUM(
            bought_home_decor
            AND NOT bought_garden
        ) * 100.0 / SUM(bought_home_decor), 2
    )
FROM category_customers
UNION ALL
SELECT 'Toys → Home Decor', SUM(bought_toys), SUM(
        bought_toys
        AND NOT bought_home_decor
    ), ROUND(
        SUM(
            bought_toys
            AND NOT bought_home_decor
        ) * 100.0 / SUM(bought_toys), 2
    )
FROM category_customers;

-- ============================================================
-- 10. STORE PERFORMANCE COMPARISON (by invoice prefix)
-- ============================================================

-- UK vs International performance
SELECT
    CASE
        WHEN country = 'United Kingdom' THEN 'UK'
        ELSE 'International'
    END AS region,
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(total_price), 2) AS avg_order_value,
    ROUND(
        SUM(total_price) / COUNT(DISTINCT customer_id),
        2
    ) AS revenue_per_customer
FROM online_retail
GROUP BY
    region;

-- ============================================================
-- 11. CUSTOMER SEGMENT MIGRATION (if you have historical data)
-- ============================================================

-- This query shows how customers move between segments over time
-- Requires historical segment assignments

-- Placeholder for segment migration analysis
SELECT 'Implement with historical segment snapshots' AS note;

-- ============================================================
-- 12. FINAL EXECUTIVE SUMMARY
-- ============================================================

SELECT
    '=' AS separator1,
    'EXECUTIVE DASHBOARD READY' AS title,
    '=' AS separator2
UNION ALL
SELECT '', 'Run Power BI dashboard for full visualization', ''
UNION ALL
SELECT '', 'Connect to online_retail, rfm_customer_scores, and segment_kpis tables', '';