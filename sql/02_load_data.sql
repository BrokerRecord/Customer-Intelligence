-- ============================================================
-- SQL Script 02: Load Data
-- Purpose: Import processed data from CSV files into tables
-- ============================================================

USE retail_analytics;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_transactions.csv' INTO
TABLE online_retail FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    invoice,
    stockcode,
    `description`,
    quantity,
    invoicedate,
    price,
    customer_id,
    country,
    total_price,
    `year`,
    `month`,
    month_name,
    `day`,
    `hour`,
    day_of_week,
    `year_month`
);

-- Verify load
SELECT COUNT(*) AS transactions_loaded FROM online_retail;

-- ============================================================
-- 2. LOAD RFM CUSTOMER SCORES
-- ============================================================

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rfm_customer_scores.csv' INTO
TABLE rfm_customer_scores FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_score,
    rfm_total,
    customer_segment
);

-- Verify load
SELECT COUNT(*) AS rfm_customers_loaded FROM rfm_customer_scores;

-- ============================================================
-- 3. LOAD/UPDATE SEGMENT KPIs
-- ============================================================

-- Clear existing data
TRUNCATE TABLE segment_kpis;

-- Insert from RFM scores with aggregations
INSERT INTO
    segment_kpis (
        customer_segment,
        customer_count,
        avg_recency,
        avg_frequency,
        avg_monetary,
        total_revenue,
        revenue_percentage
    )
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(
        SUM(monetary) * 100.0 / (
            SELECT SUM(monetary)
            FROM rfm_customer_scores
        ),
        2
    ) AS revenue_percentage
FROM rfm_customer_scores
GROUP BY
    customer_segment;

-- ============================================================
-- 4. LOAD MONTHLY REVENUE (from transactions table)
-- ============================================================

TRUNCATE TABLE monthly_revenue;

INSERT INTO
    monthly_revenue (
        `year_month`,
        total_revenue,
        total_orders,
        unique_customers,
        avg_order_value
    )
SELECT
    `year_month`,
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(
        SUM(total_price) / COUNT(DISTINCT invoice),
        2
    ) AS avg_order_value
FROM online_retail
GROUP BY
    `year_month`
ORDER BY `year_month`;

-- ============================================================
-- 5. LOAD PRODUCT PERFORMANCE
-- ============================================================

TRUNCATE TABLE product_performance;

INSERT INTO
    product_performance (
        stockcode,
        description,
        total_quantity_sold,
        total_revenue,
        avg_price,
        number_of_orders,
        unique_customers
    )
SELECT
    stockcode,
    MAX(description) AS description,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(DISTINCT invoice) AS number_of_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM online_retail
WHERE
    description IS NOT NULL
    AND description != ''
GROUP BY
    stockcode
ORDER BY total_revenue DESC;

-- ============================================================
-- 6. LOAD COUNTRY PERFORMANCE
-- ============================================================

TRUNCATE TABLE country_performance;

INSERT INTO
    country_performance (
        country,
        total_revenue,
        total_orders,
        unique_customers,
        avg_order_value,
        revenue_percentage
    )
SELECT
    country,
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
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
GROUP BY
    country
ORDER BY total_revenue DESC;

-- ============================================================
-- 7. LOAD CHURN PREDICTIONS
-- ============================================================

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/high_risk_active_customers.csv' INTO
TABLE churn_predictions FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    @customer_id,
    @churn_risk_score,
    @predicted_churn,
    @days_since_last,
    @churned,
    @total_price_total_spent,
    @invoice_total_orders
)
SET
    customer_id = @customer_id,
    churn_risk_score = @churn_risk_score,
    days_since_last = @days_since_last,
    predicted_churn = (
        @predicted_churn = 1
        OR @predicted_churn = '1'
    ),
    churned = @churned,
    risk_level = CASE
        WHEN @churn_risk_score >= 0.8 THEN 'Very High'
        WHEN @churn_risk_score >= 0.6 THEN 'High'
        WHEN @churn_risk_score >= 0.4 THEN 'Medium'
        ELSE 'Low'
    END,
    prediction_date = CURDATE(),
    model_version = 'random_forest_v1';
-- ============================================================
-- 8. LOAD CLV PREDICTIONS
-- ============================================================

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_clv.csv' INTO
TABLE clv_predictions FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS (
    customer_id,
    frequency,
    recency,
    T,
    monetary_value,
    predicted_purchases_12m,
    predicted_clv_12m,
    clv_segment
)
SET
    prediction_date = CURDATE();

-- ============================================================
-- 9. LOAD A/B TEST RESULTS
-- ============================================================

-- This would typically be inserted manually or from your simulation results
INSERT INTO
    ab_test_results (
        test_name,
        test_start_date,
        test_end_date,
        control_group_size,
        test_group_size,
        control_conversion_rate,
        test_conversion_rate,
        p_value,
        is_significant,
        lift_percentage,
        recommended_action
    )
VALUES (
        'Re-engagement Campaign - 15% Discount',
        DATE_SUB(CURDATE(), INTERVAL 30 DAY),
        DATE_SUB(CURDATE(), INTERVAL 16 DAY),
        637,
        648,
        0.04396,
        0.08025,
        0.00998,
        TRUE,
        82.56,
        'DEPLOY - Significant conversion lift with positive ROI'
    );

-- ============================================================
-- 10. UPDATE DAILY KPI SNAPSHOT (for time-series)
-- ============================================================

INSERT INTO
    daily_kpi_snapshot (
        snapshot_date,
        total_revenue,
        total_orders,
        unique_customers,
        avg_order_value
    )
SELECT
    CURDATE() - INTERVAL 1 DAY AS snapshot_date,
    ROUND(
        SUM(
            CASE
                WHEN DATE(invoicedate) = CURDATE() - INTERVAL 1 DAY THEN total_price
                ELSE 0
            END
        ),
        2
    ) AS total_revenue,
    COUNT(
        DISTINCT CASE
            WHEN DATE(invoicedate) = CURDATE() - INTERVAL 1 DAY THEN invoice
        END
    ) AS total_orders,
    COUNT(
        DISTINCT CASE
            WHEN DATE(invoicedate) = CURDATE() - INTERVAL 1 DAY THEN customer_id
        END
    ) AS unique_customers,
    ROUND(
        SUM(
            CASE
                WHEN DATE(invoicedate) = CURDATE() - INTERVAL 1 DAY THEN total_price
                ELSE 0
            END
        ) / NULLIF(
            COUNT(
                DISTINCT CASE
                    WHEN DATE(invoicedate) = CURDATE() - INTERVAL 1 DAY THEN invoice
                END
            ),
            0
        ),
        2
    ) AS avg_order_value
FROM online_retail
ON DUPLICATE KEY UPDATE
    total_revenue = VALUES(total_revenue),
    total_orders = VALUES(total_orders),
    unique_customers = VALUES(unique_customers),
    avg_order_value = VALUES(avg_order_value);

-- ============================================================
-- DATA VALIDATION QUERIES
-- ============================================================

-- Show row counts for all tables
SELECT 'online_retail' AS table_name, COUNT(*) AS row_count
FROM online_retail
UNION ALL
SELECT 'rfm_customer_scores', COUNT(*)
FROM rfm_customer_scores
UNION ALL
SELECT 'segment_kpis', COUNT(*)
FROM segment_kpis
UNION ALL
SELECT 'monthly_revenue', COUNT(*)
FROM monthly_revenue
UNION ALL
SELECT 'product_performance', COUNT(*)
FROM product_performance
UNION ALL
SELECT 'country_performance', COUNT(*)
FROM country_performance
UNION ALL
SELECT 'churn_predictions', COUNT(*)
FROM churn_predictions
UNION ALL
SELECT 'clv_predictions', COUNT(*)
FROM clv_predictions
UNION ALL
SELECT 'ab_test_results', COUNT(*)
FROM ab_test_results;

-- Show recent activity summary
SELECT
    'Data loaded successfully!' AS status,
    NOW() AS load_timestamp,
    (
        SELECT COUNT(*)
        FROM online_retail
    ) AS transactions,
    (
        SELECT COUNT(*)
        FROM rfm_customer_scores
    ) AS customers_analyzed;

-- ============================================================
-- CREATE VIEWS FOR EASY DASHBOARD CONNECTION
-- ============================================================

-- Customer 360 view
CREATE OR REPLACE VIEW v_customer_360 AS
SELECT o.customer_id, o.country, r.recency, r.frequency, r.monetary, r.r_score, r.f_score, r.m_score, r.rfm_score, r.customer_segment, c.churn_risk_score, c.risk_level, cl.predicted_clv_12m, cl.clv_segment, o.year_month
FROM
    online_retail o
    LEFT JOIN rfm_customer_scores r ON o.customer_id = r.customer_id
    LEFT JOIN churn_predictions c ON o.customer_id = c.customer_id
    AND c.prediction_date = (
        SELECT MAX(prediction_date)
        FROM churn_predictions
    )
    LEFT JOIN clv_predictions cl ON o.customer_id = cl.customer_id;

-- Dashboard summary view
CREATE OR REPLACE VIEW v_dashboard_summary AS
SELECT (
        SELECT ROUND(SUM(total_price), 2)
        FROM online_retail
    ) AS total_revenue,
    (
        SELECT COUNT(DISTINCT invoice)
        FROM online_retail
    ) AS total_orders,
    (
        SELECT COUNT(DISTINCT customer_id)
        FROM online_retail
    ) AS total_customers,
    (
        SELECT COUNT(*)
        FROM rfm_customer_scores
        WHERE
            customer_segment = 'Champions'
    ) AS champions_count,
    (
        SELECT ROUND(SUM(monetary), 2)
        FROM rfm_customer_scores
        WHERE
            customer_segment = 'Champions'
    ) AS champions_revenue,
    (
        SELECT COUNT(*)
        FROM churn_predictions
        WHERE
            risk_level IN ('High', 'Very High')
            AND prediction_date = (
                SELECT MAX(prediction_date)
                FROM churn_predictions
            )
    ) AS high_risk_customers;

SELECT '✅ Data loading complete! Ready for Power BI dashboard.' AS message;