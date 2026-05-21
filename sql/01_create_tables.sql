-- ============================================================
-- SQL Script 01: Tables
-- Purpose: Set up the database schema for retail analytics
-- ============================================================

USE retail_analytics;

-- ============================================================
-- 1. MAIN TRANSACTIONS TABLE
-- ============================================================
DROP TABLE IF EXISTS online_retail;

CREATE TABLE online_retail (
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

-- Indexes for performance
INDEX idx_customer (customer_id),
    INDEX idx_date (invoicedate),
    INDEX idx_country (country),
    INDEX idx_product (stockcode),
    INDEX idx_year_month ( `year_month`)
);

-- ============================================================
-- 2. RFM CUSTOMER SCORES TABLE
-- ============================================================
DROP TABLE IF EXISTS rfm_customer_scores;

CREATE TABLE rfm_customer_scores (
    customer_id INT PRIMARY KEY,
    recency INT NOT NULL,
    frequency INT NOT NULL,
    monetary DECIMAL(12, 2) NOT NULL,
    r_score INT NOT NULL,
    f_score INT NOT NULL,
    m_score INT NOT NULL,
    rfm_score VARCHAR(5) NOT NULL,
    rfm_total INT NOT NULL,
    customer_segment VARCHAR(50) NOT NULL,
    INDEX idx_segment (customer_segment),
    INDEX idx_rfm_score (rfm_total),
    INDEX idx_recency (recency)
);

-- ============================================================
-- 3. SEGMENT KPIS TABLE (Aggregated)
-- ============================================================
DROP TABLE IF EXISTS segment_kpis;

CREATE TABLE segment_kpis (
    segment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_segment VARCHAR(50) NOT NULL,
    customer_count INT NOT NULL,
    avg_recency DECIMAL(10, 2),
    avg_frequency DECIMAL(10, 2),
    avg_monetary DECIMAL(12, 2),
    total_revenue DECIMAL(14, 2),
    revenue_percentage DECIMAL(5, 2),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_segment (customer_segment)
);

-- ============================================================
-- 4. MONTHLY REVENUE TRACKING TABLE
-- ============================================================
DROP TABLE IF EXISTS monthly_revenue;

CREATE TABLE monthly_revenue (
    id INT AUTO_INCREMENT PRIMARY KEY,
	`year_month` VARCHAR(7) NOT NULL,
    total_revenue DECIMAL(14, 2) NOT NULL,
    total_orders INT NOT NULL,
    unique_customers INT NOT NULL,
    avg_order_value DECIMAL(10, 2),
    INDEX idx_year_month ( `year_month`)
);

-- ============================================================
-- 5. PRODUCT PERFORMANCE TABLE
-- ============================================================
DROP TABLE IF EXISTS product_performance;

CREATE TABLE product_performance (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    stockcode VARCHAR(20) NOT NULL,
    description VARCHAR(255),
    total_quantity_sold INT NOT NULL,
    total_revenue DECIMAL(14, 2) NOT NULL,
    avg_price DECIMAL(10, 2),
    number_of_orders INT NOT NULL,
    unique_customers INT NOT NULL,
    INDEX idx_revenue (total_revenue DESC),
    INDEX idx_quantity (total_quantity_sold DESC),
    UNIQUE KEY uk_stockcode (stockcode)
);

-- ============================================================
-- 6. COUNTRY PERFORMANCE TABLE
-- ============================================================
DROP TABLE IF EXISTS country_performance;

CREATE TABLE country_performance (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    total_revenue DECIMAL(14, 2) NOT NULL,
    total_orders INT NOT NULL,
    unique_customers INT NOT NULL,
    avg_order_value DECIMAL(10, 2),
    revenue_percentage DECIMAL(5, 2),
    INDEX idx_revenue (total_revenue DESC),
    UNIQUE KEY uk_country (country)
);

-- ============================================================
-- 7. DAILY KPI SNAPSHOT TABLE (for time-series analysis)
-- ============================================================
DROP TABLE IF EXISTS daily_kpi_snapshot;

CREATE TABLE daily_kpi_snapshot (
    snapshot_date DATE PRIMARY KEY,
    total_revenue DECIMAL(14, 2),
    total_orders INT,
    unique_customers INT,
    avg_order_value DECIMAL(10, 2),
    new_customers INT,
    returning_customers INT,
    retention_rate DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 8. CHURN PREDICTION RESULTS TABLE
-- ============================================================
DROP TABLE IF EXISTS churn_predictions;

CREATE TABLE churn_predictions (
    customer_id INT NOT NULL PRIMARY KEY,
    churn_risk_score DECIMAL(5, 4) NOT NULL,
    predicted_churn BOOLEAN DEFAULT FALSE,
    days_since_last INT NOT NULL,
    churned INT,  -- Adding this to match your CSV (0=active, 1=churned)
    risk_level VARCHAR(20),
    prediction_date DATE NOT NULL,
    model_version VARCHAR(50),
    INDEX idx_customer (customer_id),
    INDEX idx_risk_score (churn_risk_score DESC),
    INDEX idx_prediction_date (prediction_date)
);

-- ============================================================
-- 9. A/B TEST RESULTS TABLE
-- ============================================================
DROP TABLE IF EXISTS ab_test_results;

CREATE TABLE ab_test_results (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    test_name VARCHAR(100) NOT NULL,
    test_start_date DATE NOT NULL,
    test_end_date DATE,
    control_group_size INT,
    test_group_size INT,
    control_conversion_rate DECIMAL(5, 4),
    test_conversion_rate DECIMAL(5, 4),
    p_value DECIMAL(10, 6),
    is_significant BOOLEAN,
    lift_percentage DECIMAL(5, 2),
    recommended_action VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 10. CLV PREDICTIONS TABLE
-- ============================================================
DROP TABLE IF EXISTS clv_predictions;

CREATE TABLE clv_predictions (
    customer_id INT PRIMARY KEY,
    frequency DECIMAL(10, 2),
    recency DECIMAL(10, 2),
    T INT,
    monetary_value DECIMAL(10, 2),
    predicted_purchases_12m DECIMAL(10, 2),
    predicted_clv_12m DECIMAL(12, 2),
    clv_segment VARCHAR(20),
    prediction_date DATE NOT NULL,
    INDEX idx_clv (predicted_clv_12m DESC),
    INDEX idx_segment (clv_segment)
);

-- ============================================================
-- Verification queries
-- ============================================================
SELECT '✅ All tables created successfully!' AS Status;

-- Show all tables
SHOW TABLES;