-- ============================================================================
-- SQL Script 01: Database and Table Creation
-- ============================================================================

USE retail_analytics;

-- ============================================================================
-- 1. FACT TABLE: Cleaned Transactions
-- ============================================================================
DROP TABLE IF EXISTS fact_transactions;

CREATE TABLE fact_transactions (
    invoice VARCHAR(20) NOT NULL,
    stockcode VARCHAR(20) NOT NULL,
    `description` TEXT,
    quantity INT NOT NULL,
    invoicedate DATETIME NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    customer_id INT NULL,
    country VARCHAR(100) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    `year` INT NOT NULL,
    `month` INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    `day` INT NOT NULL,
    `hour` INT NOT NULL,
    day_of_week VARCHAR(20) NOT NULL,
    `year_month` VARCHAR(7) NOT NULL,
    transaction_type VARCHAR(50),
    is_test_transaction INT DEFAULT 0,
    customer_type VARCHAR(50),
    INDEX idx_customer (customer_id),
    INDEX idx_date (invoicedate)
);

-- ============================================================================
-- 2. PRODUCT DIMENSION
-- ============================================================================
DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product (
    stockcode VARCHAR(20) PRIMARY KEY,
    `description` TEXT,
    product_category VARCHAR(100)
);

-- ============================================================================
-- 3. DATE DIMENSION
-- ============================================================================
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_key VARCHAR(20) PRIMARY KEY,
    full_date DATE NOT NULL,
    `year` INT NOT NULL,
    quarter INT NOT NULL,
    `month` INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    `day` INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    week_of_year INT NOT NULL,
    is_weekend INT NOT NULL,
    `year_month` VARCHAR(7) NOT NULL,
    year_quarter VARCHAR(10) NOT NULL
);

-- ============================================================================
-- 4. CUSTOMER DIMENSION (RFM)
-- ============================================================================
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_segment VARCHAR(50) NOT NULL,
    value_tier VARCHAR(50),
    days_since_last_purchase INT NOT NULL,
    total_orders INT NOT NULL,
    total_spent DECIMAL(14, 2) NOT NULL,
    r_score INT NOT NULL,
    f_score INT NOT NULL,
    m_score INT NOT NULL,
    rfm_score VARCHAR(5) NOT NULL,
    rfm_total INT NOT NULL,
    first_purchase_date DATE, -- DATE only, not DATETIME
    customer_tenure_days INT,
    customer_tenure_months DECIMAL(6, 1)
);

-- ============================================================================
-- 5. CUSTOMER CLV DIMENSION
-- ============================================================================
DROP TABLE IF EXISTS dim_customer_clv;

CREATE TABLE dim_customer_clv (
    customer_id INT PRIMARY KEY,
    predicted_clv_12m DECIMAL(14, 2) NOT NULL,
    clv_segment VARCHAR(50) NOT NULL,
    clv_tier VARCHAR(50) NOT NULL,
    expected_purchases_next_12m DECIMAL(10, 4) NOT NULL,
    historical_frequency INT NOT NULL,
    recency_days INT NOT NULL,
    customer_age_days INT NOT NULL,
    avg_order_value DECIMAL(14, 2) NOT NULL,
    clv_percentile DECIMAL(6, 2),
    clv_score INT
);

-- ============================================================================
-- 6. CUSTOMER RISK DIMENSION
-- ============================================================================
DROP TABLE IF EXISTS dim_customer_risk;

CREATE TABLE dim_customer_risk (
    customer_id INT PRIMARY KEY,
    churn_risk_score DECIMAL(6, 5) NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    risk_bucket VARCHAR(20) DEFAULT 'Unknown',
    predicted_churn INT NOT NULL,
    actual_churned INT
);

-- ============================================================================
-- 7. HIGH RISK ACTIVE CUSTOMERS
-- ============================================================================
DROP TABLE IF EXISTS high_risk_active_customers;

CREATE TABLE high_risk_active_customers (
    customer_id INT PRIMARY KEY,
    churn_risk_score DECIMAL(6, 5) NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    predicted_churn INT NOT NULL,
    actual_churned INT NOT NULL,
    total_spent DECIMAL(14, 2) NOT NULL,
    total_orders INT NOT NULL
);

-- ============================================================================
-- 8. SEGMENT KPIs
-- ============================================================================
DROP TABLE IF EXISTS segment_kpis;

CREATE TABLE segment_kpis (
    customer_segment VARCHAR(50) PRIMARY KEY,
    customer_count INT NOT NULL,
    avg_recency DECIMAL(8, 2) NOT NULL,
    avg_frequency DECIMAL(8, 2) NOT NULL,
    avg_monetary DECIMAL(14, 2) NOT NULL,
    total_revenue DECIMAL(16, 2) NOT NULL,
    revenue_percentage DECIMAL(6, 2) NOT NULL
);

-- ============================================================================
-- 9. CLV SEGMENT SUMMARY
-- ============================================================================
DROP TABLE IF EXISTS clv_segment_summary;

CREATE TABLE clv_segment_summary (
    clv_segment VARCHAR(50) NOT NULL,
    customer_count INT NOT NULL,
    avg_clv DECIMAL(14, 2) NOT NULL,
    total_clv DECIMAL(16, 2) NOT NULL,
    avg_frequency DECIMAL(10, 2) NOT NULL,
    avg_monetary DECIMAL(14, 2) NOT NULL,
    avg_predicted_purchases DECIMAL(10, 4) NOT NULL,
    pct_of_customers DECIMAL(6, 2) NOT NULL,
    pct_of_value DECIMAL(6, 2) NOT NULL,
    snapshot_date DATE NOT NULL,
    PRIMARY KEY (clv_segment, snapshot_date)
);

-- ============================================================================
-- 10. CLV TIER SUMMARY
-- ============================================================================
DROP TABLE IF EXISTS clv_tier_summary;

CREATE TABLE clv_tier_summary (
    clv_tier VARCHAR(50) NOT NULL,
    customer_count INT NOT NULL,
    total_clv DECIMAL(16, 2) NOT NULL,
    avg_clv DECIMAL(14, 2) NOT NULL,
    avg_frequency DECIMAL(10, 2) NOT NULL,
    avg_order_value DECIMAL(14, 2) NOT NULL,
    snapshot_date DATE NOT NULL,
    PRIMARY KEY (clv_tier, snapshot_date)
);

-- ============================================================================
-- 11. MONTHLY SEGMENT REVENUE
-- ============================================================================
DROP TABLE IF EXISTS monthly_segment_revenue;

CREATE TABLE monthly_segment_revenue (
    `year_month` VARCHAR(7) NOT NULL,
    customer_segment VARCHAR(50) NOT NULL,
    revenue DECIMAL(16, 2) NOT NULL,
    PRIMARY KEY (
        `year_month`,
        customer_segment
    )
);

-- ============================================================================
-- 12. REVENUE METRICS
-- ============================================================================
DROP TABLE IF EXISTS revenue_metrics;

CREATE TABLE revenue_metrics (
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(16, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'GBP',
    snapshot_date DATE NOT NULL,
    PRIMARY KEY (metric_name, snapshot_date)
);

-- ============================================================================
-- 13. RISK SUMMARY
-- ============================================================================
DROP TABLE IF EXISTS risk_summary;

CREATE TABLE risk_summary (
    risk_level VARCHAR(20) NOT NULL,
    customer_count INT NOT NULL,
    avg_risk_score DECIMAL(6, 5) NOT NULL,
    risk_order INT NOT NULL,
    snapshot_date DATE NOT NULL,
    PRIMARY KEY (risk_level, snapshot_date)
);

-- ============================================================================
-- 14. A/B TEST RESULTS
-- ============================================================================
DROP TABLE IF EXISTS ab_test_results;

CREATE TABLE ab_test_results (
    test_name VARCHAR(100) NOT NULL,
    test_date DATE NOT NULL,
    target_segments VARCHAR(255) NOT NULL,
    control_size INT NOT NULL,
    test_size INT NOT NULL,
    control_conversion DECIMAL(6, 5) NOT NULL,
    test_conversion DECIMAL(6, 5) NOT NULL,
    conversion_lift DECIMAL(6, 5) NOT NULL,
    p_value DECIMAL(10, 6) NOT NULL,
    is_significant INT NOT NULL, -- Changed to INT
    control_arpu DECIMAL(10, 2) NOT NULL,
    test_arpu DECIMAL(10, 2) NOT NULL,
    revenue_lift DECIMAL(6, 5) NOT NULL,
    revenue_p_value DECIMAL(10, 6) NOT NULL,
    roi DECIMAL(10, 4) NOT NULL,
    recommendation VARCHAR(50) NOT NULL
);

-- ============================================================================
-- 15. CUSTOMER 360 VIEW
-- ============================================================================
DROP TABLE IF EXISTS customer_360_view;

CREATE TABLE customer_360_view (
    customer_id INT PRIMARY KEY,
    customer_segment VARCHAR(50),
    value_tier VARCHAR(50),
    days_since_last_purchase INT,
    total_orders INT,
    total_spent DECIMAL(14, 2),
    rfm_score VARCHAR(5),
    rfm_total INT,
    predicted_clv_12m DECIMAL(14, 2),
    clv_segment VARCHAR(50),
    clv_tier VARCHAR(50),
    expected_purchases_next_12m DECIMAL(10, 4),
    avg_order_value DECIMAL(14, 2),
    churn_risk_score DECIMAL(6, 5),
    risk_level VARCHAR(20),
    predicted_churn INT,
    country VARCHAR(100),
    first_purchase_date DATE,
    customer_tenure_days INT,
    strategic_segment VARCHAR(100),
    snapshot_date DATE
);

-- ============================================================================
-- 16. DATA VALIDATION
-- ============================================================================
SELECT '✅ All 15 tables created successfully!' AS Status;

SHOW TABLES;