# 🎯 Customer Intelligence & Churn Prediction System

> **Enterprise-grade retail analytics platform**: From raw transaction data to predictive insights

[![Python 3.10+](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-1.0+-orange.svg)](https://scikit-learn.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow.svg)](https://powerbi.microsoft.com/)
[![MySQL](https://img.shields.io/badge/MySQL-Database-blue.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📊 Project Overview

This project delivers a **complete customer intelligence solution** for retail businesses, transforming raw transaction data into actionable business insights through:

- **RFM Customer Segmentation** - Identify your most valuable customers
- **Churn Prediction** - Predict which customers are likely to leave
- **Customer Lifetime Value (CLV)** - Forecast future customer value
- **A/B Testing Framework** - Data-driven marketing decisions
- **Interactive Power BI Dashboard** - Real-time business monitoring

### 🎯 Business Impact

| Metric                               | Value                |
| ------------------------------------ | -------------------- |
| **High-Risk Customers Identified**   | 579                  |
| **Potential Revenue at Risk**        | $213,075.61          |
| **Churn Prediction Accuracy**        | 78% ROC-AUC          |
| **Customer Segments Identified**     | 11 Distinct Groups   |
| **Top Segment Revenue Contribution** | 75.9% from Champions |

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ DATA PIPELINE │
├───────────────┬───────────────┬───────────────┬────────────────┤
│ Raw Data │ Cleaning │ Feature │ Modeling │
│ (Excel/CSV) │ → Python │ Engineering │ → ML Models │
├───────────────┼───────────────┼───────────────┼────────────────┤
│ SQL Database │ Analytics │ Power BI │ Automated │
│ (MySQL) │ → KPIs │ Dashboard │ Reporting │
└───────────────┴───────────────┴───────────────┴────────────────┘
```

## 🛠️ Technology Stack

| Layer                | Technologies                  |
| -------------------- | ----------------------------- |
| **Data Processing**  | Python (Pandas, NumPy)        |
| **Machine Learning** | scikit-learn, XGBoost, SHAP   |
| **Database**         | MySQL                         |
| **Visualization**    | Power BI, Matplotlib, Seaborn |
| **Automation**       | GitHub Actions, Cron          |
| **Version Control**  | Git, GitHub                   |

## 📁 Repository Structure

```

customer-intelligence/
│
├── data/
│ ├── raw/ # Original data
│ └── processed/ # Cleaned and feature-engineered data
│
├── notebooks/
│ ├── 01_data_cleaning.ipynb # Data preparation(done)
│ ├── 02_rfm_analysis.ipynb # Customer segmentation(done)
│ ├── 03_churn_prediction.ipynb # ML churn model(done)
│ ├── 04_clv_analysis.ipynb # Lifetime value(to do)
│ └── 05_ab_testing_simulation.ipynb # A/B test framework(to do)
│
├── scripts/
│ ├── generate_daily_report.py # Automated reporting(to do)
│ └── run_pipeline.py # End-to-end pipeline(to do)
│
├── sql/
│ ├── 01_create_tables.sql(to do)
│ ├── 02_kpi_queries.sql(to do)
│ └── 03_analytical_queries.sql(to do)
│
├── models/ # Saved ML models(to do)
├── reports/ # Generated reports & visualizations(to do)
├── powerbi/ # Power BI dashboard files(to do)
├── .github/workflows/ # CI/CD automation(to do)
├── requirements.txt(done)
└── README.md

```

## 📧 Contact

Awa Mbaye - [evash0uwha@gmail.com]

Project Link: [https://github.com/BrokerRecord/Customer-Intelligence]

```


```
