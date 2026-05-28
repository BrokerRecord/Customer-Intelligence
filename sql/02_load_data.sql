-- ============================================================================
-- SQL Script 02: Load Data
-- ============================================================================
USE retail_analytics;

-- ---------------------------
-- 1. FACT TABLE
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_transactions.csv' INTO
TABLE fact_transactions FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    @invoice,
    @stockcode,
    @description,
    @quantity,
    @invoicedate,
    @price,
    @customer_id,
    @country,
    @total_price,
    @year,
    @month,
    @month_name,
    @day,
    @hour,
    @day_of_week,
    @year_month,
    @transaction_type,
    @is_test_transaction,
    @customer_type
)
SET
    invoice = NULLIF(@invoice, ''),
    stockcode = NULLIF(@stockcode, ''),
    description = NULLIF(@description, ''),
    quantity = NULLIF(@quantity, ''),
    invoicedate = STR_TO_DATE(
        @invoicedate,
        '%Y-%m-%d %H:%i:%s'
    ),
    price = NULLIF(@price, ''),
    customer_id = NULLIF(@customer_id, ''),
    country = NULLIF(@country, ''),
    total_price = NULLIF(@total_price, ''),
    year = NULLIF(@year, ''),
    month = NULLIF(@month, ''),
    month_name = NULLIF(@month_name, ''),
    day = NULLIF(@day, ''),
    hour = NULLIF(@hour, ''),
    day_of_week = NULLIF(@day_of_week, ''),
    `year_month` = NULLIF(@year_month, ''),
    transaction_type = NULLIF(@transaction_type, ''),
    is_test_transaction = CASE
        WHEN @is_test_transaction = 'True' THEN 1
        WHEN @is_test_transaction = 'False' THEN 0
        ELSE 0
    END,
    customer_type = NULLIF(@customer_type, '');

SELECT COUNT(*) AS transactions_loaded FROM fact_transactions;

-- ---------------------------
-- 2. PRODUCT DIMENSION
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_product.csv' INTO
TABLE dim_product FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    @stockcode,
    @description,
    @product_category
)
SET
    stockcode = NULLIF(@stockcode, ''),
    description = NULLIF(@description, ''),
    product_category = NULLIF(@product_category, '');

SELECT COUNT(*) AS products_loaded FROM dim_product;

-- ---------------------------
-- 3. DATE DIMENSION
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_date.csv' INTO
TABLE dim_date FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    @date_key,
    @full_date,
    @year,
    @quarter,
    @month,
    @month_name,
    @day,
    @day_of_week,
    @day_name,
    @week_of_year,
    @is_weekend,
    @year_month,
    @year_quarter
)
SET
    date_key = NULLIF(@date_key, ''),
    full_date = STR_TO_DATE(@full_date, '%Y%m%d'), -- Changed from '%Y-%m-%d' to '%Y%m%d'
    year = NULLIF(@year, ''),
    quarter = NULLIF(@quarter, ''),
    month = NULLIF(@month, ''),
    month_name = NULLIF(@month_name, ''),
    day = NULLIF(@day, ''),
    day_of_week = NULLIF(@day_of_week, ''),
    day_name = NULLIF(@day_name, ''),
    week_of_year = NULLIF(@week_of_year, ''),
    is_weekend = CASE
        WHEN @is_weekend = 'True' THEN 1
        WHEN @is_weekend = 'False' THEN 0
        ELSE 0
    END,
    `year_month` = NULLIF(@year_month, ''),
    year_quarter = NULLIF(@year_quarter, '');

SELECT COUNT(*) AS dates_loaded FROM dim_date;

-- ---------------------------
-- 4. CUSTOMER DIMENSION
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_customer.csv' INTO
TABLE dim_customer FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    @customer_id,
    @customer_segment,
    @value_tier,
    @days_since_last_purchase,
    @total_orders,
    @total_spent,
    @r_score,
    @f_score,
    @m_score,
    @rfm_score,
    @rfm_total,
    @first_purchase_date,
    @customer_tenure_days,
    @customer_tenure_months
)
SET
    customer_id = NULLIF(@customer_id, ''),
    customer_segment = NULLIF(@customer_segment, ''),
    value_tier = NULLIF(@value_tier, ''),
    days_since_last_purchase = NULLIF(@days_since_last_purchase, ''),
    total_orders = NULLIF(@total_orders, ''),
    total_spent = NULLIF(@total_spent, ''),
    r_score = NULLIF(@r_score, ''),
    f_score = NULLIF(@f_score, ''),
    m_score = NULLIF(@m_score, ''),
    rfm_score = NULLIF(@rfm_score, ''),
    rfm_total = NULLIF(@rfm_total, ''),
    first_purchase_date = DATE(
        STR_TO_DATE(
            @first_purchase_date,
            '%Y-%m-%d %H:%i:%s'
        )
    ),
    customer_tenure_days = NULLIF(@customer_tenure_days, ''),
    customer_tenure_months = NULLIF(@customer_tenure_months, '');

SELECT COUNT(*) AS customers_loaded FROM dim_customer;

-- ---------------------------
-- 5. CUSTOMER CLV DIMENSION
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_customer_clv.csv' INTO
TABLE dim_customer_clv FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    @customer_id,
    @predicted_clv_12m,
    @clv_segment,
    @clv_tier,
    @expected_purchases_next_12m,
    @historical_frequency,
    @recency_days,
    @customer_age_days,
    @avg_order_value,
    @clv_percentile,
    @clv_score
)
SET
    customer_id = NULLIF(@customer_id, ''),
    predicted_clv_12m = NULLIF(@predicted_clv_12m, ''),
    clv_segment = NULLIF(@clv_segment, ''),
    clv_tier = NULLIF(@clv_tier, ''),
    expected_purchases_next_12m = NULLIF(
        @expected_purchases_next_12m,
        ''
    ),
    historical_frequency = NULLIF(@historical_frequency, ''),
    recency_days = NULLIF(@recency_days, ''),
    customer_age_days = NULLIF(@customer_age_days, ''),
    avg_order_value = NULLIF(@avg_order_value, ''),
    clv_percentile = NULLIF(@clv_percentile, ''),
    clv_score = NULLIF(@clv_score, '');

SELECT COUNT(*) AS clv_customers_loaded FROM dim_customer_clv;

-- ---------------------------
-- 6. CUSTOMER RISK DIMENSION
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_customer_risk.csv' INTO
TABLE dim_customer_risk FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    @customer_id,
    @churn_risk_score,
    @risk_level,
    @risk_bucket,
    @predicted_churn,
    @actual_churned
)
SET
    customer_id = NULLIF(@customer_id, ''),
    churn_risk_score = NULLIF(@churn_risk_score, ''),
    risk_level = NULLIF(@risk_level, ''),
    risk_bucket = CASE
        WHEN NULLIF(@risk_bucket, '') IS NULL THEN 'Unknown'
        ELSE NULLIF(@risk_bucket, '')
    END,
    predicted_churn = NULLIF(@predicted_churn, ''),
    actual_churned = NULLIF(@actual_churned, '');

SELECT COUNT(*) AS risk_customers_loaded FROM dim_customer_risk;

-- ---------------------------
-- 7. SEGMENT KPIs
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/segment_kpis.csv' INTO
TABLE segment_kpis FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

SELECT COUNT(*) AS segments_loaded FROM segment_kpis;

-- ---------------------------
-- 8. MONTHLY SEGMENT REVENUE
-- ---------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/monthly_segment_revenue.csv' INTO
TABLE monthly_segment_revenue FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

SELECT COUNT(*) AS monthly_segments_loaded
FROM monthly_segment_revenue;

-- ---------------------------
-- 9. BUILD CUSTOMER 360 VIEW
-- ---------------------------
TRUNCATE TABLE customer_360_view;

INSERT INTO
    customer_360_view
SELECT
    customer_id,
    customer_segment,
    value_tier,
    days_since_last_purchase,
    total_orders,
    total_spent,
    rfm_score,
    rfm_total,
    predicted_clv_12m,
    clv_segment,
    clv_tier,
    expected_purchases_next_12m,
    avg_order_value,
    churn_risk_score,
    risk_level,
    predicted_churn,
    country,
    first_purchase_date,
    customer_tenure_days,
    strategic_segment,
    snapshot_date
FROM (
        SELECT
            c.customer_id, c.customer_segment, c.value_tier, c.days_since_last_purchase, c.total_orders, c.total_spent, c.rfm_score, c.rfm_total, cl.predicted_clv_12m, cl.clv_segment, cl.clv_tier, cl.expected_purchases_next_12m, cl.avg_order_value, cr.churn_risk_score, cr.risk_level, cr.predicted_churn, f.country, c.first_purchase_date, c.customer_tenure_days, CASE
                WHEN cl.clv_tier IN (
                    'Premium Value (>$5,000)', 'High Value ($1,500-$5,000)'
                )
                AND cr.risk_level IN ('Critical', 'High') THEN 'CRITICAL: High-Value At Risk'
                WHEN cl.clv_tier IN (
                    'Premium Value (>$5,000)', 'High Value ($1,500-$5,000)'
                ) THEN 'NURTURE: High-Value Loyal'
                WHEN cl.clv_tier = 'Medium Value ($500-$1,500)'
                AND cr.risk_level IN ('Critical', 'High') THEN 'ACT NOW: Medium-Value At Risk'
                WHEN cl.clv_tier = 'Medium Value ($500-$1,500)' THEN 'GROW: Medium-Value Potential'
                WHEN cr.risk_level IN ('Critical', 'High') THEN 'MONITOR: Low-Value At Risk'
                ELSE 'AUTOMATE: Low-Value'
            END AS strategic_segment, CURDATE() AS snapshot_date, ROW_NUMBER() OVER (
                PARTITION BY
                    c.customer_id
                ORDER BY c.customer_id
            ) AS rn
        FROM
            dim_customer c
            LEFT JOIN dim_customer_clv cl ON c.customer_id = cl.customer_id
            LEFT JOIN dim_customer_risk cr ON c.customer_id = cr.customer_id
            LEFT JOIN (
                SELECT DISTINCT
                    customer_id, country
                FROM fact_transactions
                WHERE
                    customer_id IS NOT NULL
            ) f ON c.customer_id = f.customer_id
        WHERE
            c.customer_id IS NOT NULL
    ) AS sub
WHERE
    rn = 1;

SELECT COUNT(*) AS customer_360_loaded FROM customer_360_view;

-- ---------------------------
-- 10. FINAL VALIDATION
-- ---------------------------
SELECT 'fact_transactions' AS table_name, COUNT(*) AS row_count
FROM fact_transactions
UNION ALL
SELECT 'dim_product', COUNT(*)
FROM dim_product
UNION ALL
SELECT 'dim_date', COUNT(*)
FROM dim_date
UNION ALL
SELECT 'dim_customer', COUNT(*)
FROM dim_customer
UNION ALL
SELECT 'dim_customer_clv', COUNT(*)
FROM dim_customer_clv
UNION ALL
SELECT 'dim_customer_risk', COUNT(*)
FROM dim_customer_risk
UNION ALL
SELECT 'segment_kpis', COUNT(*)
FROM segment_kpis
UNION ALL
SELECT 'monthly_segment_revenue', COUNT(*)
FROM monthly_segment_revenue
UNION ALL
SELECT 'customer_360_view', COUNT(*)
FROM customer_360_view;

SELECT '✅ Data loading complete!' AS Status, NOW() AS load_timestamp;