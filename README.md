# 🎯 Customer Intelligence & Churn Prediction System

> **Enterprise-grade retail analytics platform**: From raw transaction data to predictive insights

[![Python 3.10+](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-1.0+-orange.svg)](https://scikit-learn.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow.svg)](https://powerbi.microsoft.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📊 Project Overview

This project delivers a **complete customer intelligence solution** for retail businesses, transforming raw transaction data (1.06M+ rows) into actionable insights through advanced analytics and machine learning. The system provides a 360-degree view of customer behavior, predicts churn risk, forecasts customer lifetime value, and enables data-driven marketing decisions.

### 🎯 Key Capabilities

| Capability             | Description                              | Business Impact                  |
| ---------------------- | ---------------------------------------- | -------------------------------- |
| **RFM Segmentation**   | 11 distinct customer segments identified | Targeted marketing campaigns     |
| **Churn Prediction**   | 72.9% ROC-AUC predictive model           | £307K revenue at risk identified |
| **CLV Forecasting**    | 12-month value predictions               | £6.48M+ total predicted CLV      |
| **A/B Testing**        | Statistical campaign evaluation          | 648% ROI on re-engagement        |
| **Power BI Dashboard** | Real-time business monitoring            | Executive decision support       |

## 📈 Key Business Insights

### Customer Segmentation

- **Champions** (1,821 customers - 30.98% of base) generate **£13.19M** (75.89% of total revenue)
- **At Risk** customers (687) represent **£787.7K** in potential churn revenue
- **New Customers** (336) show 56% churn rate within first 90 days
- **Hibernating + Lost** customers (732) represent **£176.3K** in inactive revenue

### Churn Prediction Results

- **Overall churn rate**: 56.60% (3,490 of 5,878 customers)
- **Best performing model**: Logistic Regression (ROC-AUC: 0.7294)
- **Optimal threshold**: 0.10 (maximizes F1 score to 0.7413)
- **Top churn predictors**: Peak hour purchases, spend per item, total orders
- **High-risk customers identified**: 2,161 active customers
- **High-risk active customers**: 414 customers with £307,781 revenue at risk

### Customer Lifetime Value

- **Total predicted CLV (12 months)**: **£6,485,330.27**
- **High CLV segment** (25% of customers) drives **76.0%** of total CLV
- **Premium tier customers** (>£5,000 CLV) average **£15,073** each
- **Model validation**: 0.783 correlation with 90-day holdout data

### A/B Test Results

- **Tested campaign**: Re-engagement with 15% discount
- **Target segments**: At Risk, About to Sleep, Hibernating, Lost (1,446 customers)
- **Conversion lift**: 61.2% (statistically significant, p=0.015)
- **Projected ROI**: **648.2%** with net profit of **£29,636**
- **Recommendation**: Deploy to full population

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA PIPELINE                                     │
├───────────────┬─────────────────┬─────────────────┬───────────────────────┤
│   RAW DATA    │    CLEANING      │    FEATURE       │      MODELING         │
│  (Excel/CSV)  │      →           │   ENGINEERING    │          →            │
│  1.06M rows   │  779K rows       │   25 features    │   4 ML models         │
├───────────────┼─────────────────┼─────────────────┼───────────────────────┤
│   SQL DB      │    ANALYTICS     │      POWER BI    │     AUTOMATED         │
│   (MySQL)     │      →           │    DASHBOARD     │      REPORTS          │
│   15 tables   │   RFM/CLV/Churn  │   Interactive    │   Executive Summary   │
└───────────────┴─────────────────┴─────────────────┴───────────────────────┘
```

## 🛠️ Technology Stack

| Layer                    | Technologies                                                 |
| ------------------------ | ------------------------------------------------------------ |
| **Data Processing**      | Python (Pandas, NumPy)                                       |
| **Machine Learning**     | scikit-learn, XGBoost, SHAP, Lifetimes (BG/NBD, Gamma-Gamma) |
| **Statistical Analysis** | SciPy, StatsModels (Chi-square, T-tests, Power analysis)     |
| **Database**             | MySQL 8.0, MySQL Workbench                                   |
| **Visualization**        | Power BI, Matplotlib, Seaborn                                |
| **Version Control**      | Git, GitHub                                                  |

## 📁 Repository Structure

```
customer-intelligence/
│
├── data/
│   ├── raw/                      # Original transaction data (Excel)
│   └── processed/                # Cleaned data and model outputs (CSVs)
│       ├── cleaned_transactions.csv      # 779K rows, 19 columns
│       ├── dim_customer.csv              # 5,878 rows, 14 columns
│       ├── dim_customer_clv.csv          # 3,626 rows, 11 columns
│       ├── dim_customer_risk.csv         # 5,281 rows, 6 columns
│       ├── dim_product.csv               # 4,631 rows, 3 columns
│       ├── dim_date.csv                  # 365+ rows, 13 columns
│       ├── segment_kpis.csv              # 11 rows
│       ├── monthly_segment_revenue.csv   # 193 rows
│       └── customer_360_view.csv         # 5,878 rows, 20 columns
│
├── notebooks/                    # Core analysis (Jupyter)
│   ├── 01_data_cleaning.ipynb    # Data preparation & cleaning ✅
│   ├── 02_rfm_analysis.ipynb     # RFM customer segmentation ✅
│   ├── 03_churn_prediction.ipynb # ML churn model training & evaluation ✅
│   ├── 04_clv_analysis.ipynb     # CLV modeling (BG/NBD + Gamma-Gamma) ✅
│   └── 05_ab_testing_simulation.ipynb # A/B test framework & ROI analysis ✅
│
├── sql/                          # Database scripts
│   ├── 01_create_tables.sql      # Complete schema definition (15 tables) ✅
│   ├── 02_load_data.sql          # Loading data from CSVs into MySQL ✅
│   └── 03_kpi_queries.sql        # Business KPI calculations ✅
│
├── models/                       # Saved ML models (joblib files)
│   ├── churn_prediction_model.pkl    # Logistic Regression model
│   ├── feature_scaler.pkl            # StandardScaler for features
│   └── feature_list.csv              # 25 feature names
│
├── reports/                      # Generated reports & visualizations
│   ├── rfm_analysis_visualization.png
│   ├── clv_analysis_visualization.png
│   ├── churn_feature_importance.png
│   ├── churn_confusion_roc.png
│   ├── ab_test_results.png
│   ├── rfm_insights_summary.txt
│   ├── final_executive_report.txt
│   ├── final_executive_report.pdf
│   └── final_metrics.json
│
├── powerbi/                      # Power BI dashboard files
│   └── Customer Intelligence Dashboard.pbix
│
├── scripts/
│   └── generate_final_report.py    # generate the final report
├── requirements.txt              # Python dependencies
└── README.md                     # Project documentation
```

## 🗄️ Database Schema (15 Tables)

| Table Name                   | Description                          | Row Count |
| ---------------------------- | ------------------------------------ | --------- |
| `fact_transactions`          | Cleaned transaction data             | 779,425   |
| `dim_product`                | Product master with categories       | 4,631     |
| `dim_date`                   | Date dimension for time intelligence | 365+      |
| `dim_customer`               | Customer master with RFM scores      | 5,878     |
| `dim_customer_clv`           | CLV predictions by customer          | 3,626     |
| `dim_customer_risk`          | Churn risk scores by customer        | 5,281     |
| `high_risk_active_customers` | At-risk active customers             | 414       |
| `segment_kpis`               | RFM segment performance metrics      | 11        |
| `clv_segment_summary`        | CLV segment aggregates               | 4         |
| `clv_tier_summary`           | CLV tier aggregates                  | 4         |
| `monthly_segment_revenue`    | Monthly revenue by segment           | 193       |
| `revenue_metrics`            | Revenue at risk calculations         | 4         |
| `risk_summary`               | Risk level distribution              | 5         |
| `ab_test_results`            | A/B test experiment results          | 1         |
| `customer_360_view`          | Complete customer view (all data)    | 5,878     |

## 🚀 Getting Started

### Prerequisites

```bash
Python 3.10+
MySQL 8.0+
Power BI Desktop (for dashboard)
Git (for version control)
```

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/BrokerRecord/Customer-Intelligence.git
   cd Customer-Intelligence
   ```

2. **Create and activate a virtual environment**

   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

3. **Install required Python packages**

   ```bash
   pip install -r requirements.txt
   ```

4. **Set up the MySQL database**

   ```sql
   -- Create database
   CREATE DATABASE retail_analytics;
   USE retail_analytics;

   -- Run schema creation
   source sql/01_create_tables.sql;

   -- Load data (update file paths first)
   source sql/02_load_data.sql;
   ```

5. **Run the analysis pipeline**

   ```bash
   jupyter notebook notebooks/
   # Execute notebooks in order (01 → 05)
   ```

6. **Open the Power BI dashboard**
   - Open `powerbi/Customer Intelligence Dashboard.pbix`
   - Update MySQL connection settings
   - Refresh data

## 📊 Analysis Modules

### 1. Data Cleaning (`01_data_cleaning.ipynb`)

- **Input**: 1,067,371 raw transactions (2009-2011)
- **Process**: Handled missing values (22.77% customer_id), removed duplicates, canceled orders
- **Feature Engineering**: Created 16 new features (time-based, transaction type, customer type)
- **Output**: 779,425 clean transactions, star schema tables (fact + dimensions)

### 2. RFM Analysis (`02_rfm_analysis.ipynb`)

- **Methodology**: Recency, Frequency, Monetary (RFM) scoring with quartile-based segmentation
- **Segments**: 11 customer segments (Champions, Loyal, At Risk, Hibernating, etc.)
- **Insights**: Champions (30.98% of customers) contribute 75.89% of revenue
- **Outputs**: Customer dimension table, segment KPIs, monthly revenue trends

### 3. Churn Prediction (`03_churn_prediction.ipynb`)

- **Definition**: No purchase in last 90 days of data
- **Features**: 25 behavioral features (transaction history, purchase patterns, temporal)
- **Models Trained**: Logistic Regression (best), Random Forest, Gradient Boosting, XGBoost
- **Performance**: 72.9% ROC-AUC, F1 score of 0.7428 with optimal threshold (0.10)
- **Outputs**: Customer risk scores, high-risk target lists, revenue at risk calculations

### 4. CLV Analysis (`04_clv_analysis.ipynb`)

- **Models**: BG/NBD (frequency/recency) + Gamma-Gamma (monetary value)
- **Time Horizon**: 12-month predictions
- **Validation**: Holdout period correlation of 0.783
- **Segmentation**: CLV tiers (Premium, High, Medium, Low)
- **Outputs**: CLV predictions for 3,626 customers, segment summaries

### 5. A/B Testing (`05_ab_testing_simulation.ipynb`)

- **Design**: Stratified randomization by monetary tier
- **Target Segments**: At Risk, About to Sleep, Hibernating, Lost (1,446 customers)
- **Analysis**: Chi-square test (conversion), Welch's t-test (revenue)
- **Result**: 61.2% conversion lift, p=0.015 (significant), 648% ROI
- **Outputs**: Experiment results, statistical analysis, ROI projections

## 📈 Power BI Dashboard

The interactive dashboard provides 8 key pages:

| Page                          | Content                                            |
| ----------------------------- | -------------------------------------------------- |
| **Executive Overview**        | Total revenue, customers, churn rate, top products |
| **Customer Segmentation**     | RFM segment distribution, revenue by segment       |
| **Churn Risk Analysis**       | Risk heatmap, revenue at risk, high-risk customers |
| **CLV Forecasting**           | 12-month CLV predictions by tier and segment       |
| **Time Series & Seasonality** | Revenue trends, hourly/daily patterns              |
| **Product Performance**       | Top products, category analysis                    |
| **Geographic Analysis**       | Country performance, revenue by region             |
| **Marketing ROI**             | A/B test results, campaign performance             |

### Executive Dashboard

_Key metrics at a glance: £17.4M revenue, 5,878 customers, 56.6% churn rate_

![Executive Overview](powerbi/screenshots/executive_overview.png)

### Customer Intelligence View

_RFM segmentation (11 segments) + Churn risk analysis + CLV forecasting_

![Customer Analytics](powerbi/screenshots/customer_analytics.png)

[Download Power BI File](powerbi/Customer%20Intelligence%20Dashboard.pbix)

## 🔧 Troubleshooting

### Common MySQL Issues

| Error                                                | Solution                                                                     |
| ---------------------------------------------------- | ---------------------------------------------------------------------------- |
| `Error Code: 1292. Incorrect date value`             | Use `STR_TO_DATE()` with correct format (`%Y%m%d` for dates like `20091201`) |
| `Error Code: 1366. Incorrect integer value: 'False'` | Convert booleans: `CASE WHEN @col = 'True' THEN 1 ELSE 0 END`                |
| `Error Code: 1055. Expression not in GROUP BY`       | Use `DISTINCT` instead of `GROUP BY` or disable `only_full_group_by`         |
| `Error Code: 1265. Data truncated`                   | Increase column precision (e.g., `DECIMAL(16,2)` instead of `DECIMAL(10,2)`) |

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📧 Contact

**Awa Mbaye** - [evash0uwha@gmail.com](mailto:evash0uwha@gmail.com)

**Project Link**: [https://github.com/BrokerRecord/Customer-Intelligence](https://github.com/BrokerRecord/Customer-Intelligence)

## 🙏 Acknowledgments

- **UCI Machine Learning Repository** for the Online Retail II dataset
- **Lifetimes library** for CLV modeling implementation
- **scikit-learn community** for machine learning tools
- **Power BI team** for visualization capabilities
- All open-source contributors whose libraries made this project possible

---

### 📊 Final Project Statistics

| Metric                          | Value          |
| ------------------------------- | -------------- |
| **Total Transactions Analyzed** | 779,425        |
| **Unique Customers**            | 5,878          |
| **Total Revenue**               | £17,374,804.27 |
| **Features Engineered**         | 25             |
| **ML Models Trained**           | 4              |
| **Database Tables**             | 15             |
| **Power BI Dashboard Pages**    | 8              |
| **Customer Segments**           | 11             |
| **Churn Prediction AUC**        | 72.9%          |
| **Total Predicted CLV**         | £6,485,330.27  |
| **A/B Test ROI**                | 648.2%         |

---

### ⭐ If you find this project useful, please give it a star on GitHub!

```

```
