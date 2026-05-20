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
| **Campaign ROI**                     | 491.76%              |

## 📈 Key Findings

### Customer Segmentation Insights

- **Champions** (1,821 customers) generate **75.9%** of total revenue
- **At Risk** customers (687) represent **$787,723.78** in potential churn
- **New Customers** (336) show high post-first-purchase churn risk

### Churn Prediction Results

- **Overall churn rate**: 50.78%
- **Model performance**: 0.78 ROC-AUC (Random Forest)
- **Top predictors**: Total orders, quantity purchased, total spend
- **579 active customers** identified as high-risk

### Customer Lifetime Value

- **Total predicted CLV**: **$7,942,867.88**
- **High-value segment** (25% of customers) drives **72.8%** of value
- **Average CLV** ranges from $214 (Low) to **$5,525** (High)

### A/B Test Results

- **Tested campaign**: Re-engagement with 15% discount
- **Conversion lift**: 82.56% statistically significant (p < 0.01)
- **ROI**: **491.76%** with projected net profit of **$15,706**

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

## 🛠️ Technology Stack

| Layer                    | Technologies                           |
| ------------------------ | -------------------------------------- |
| **Data Processing**      | Python (Pandas, NumPy)                 |
| **Machine Learning**     | scikit-learn, XGBoost, SHAP, Lifetimes |
| **Statistical Analysis** | SciPy, StatsModels                     |
| **Database**             | MySQL                                  |
| **Visualization**        | Power BI, Matplotlib, Seaborn          |
| **Automation**           | GitHub Actions, Cron                   |
| **Version Control**      | Git, GitHub                            |

## 📁 Repository Structure

```

customer-intelligence/
│
├── data/
│ ├── raw/ # Original transaction data
│ └── processed/ # Cleaned and feature-engineered data
│
├── notebooks/
│ ├── 01_data_cleaning.ipynb # Data preparation ✅
│ ├── 02_rfm_analysis.ipynb # Customer segmentation ✅
│ ├── 03_churn_prediction.ipynb # ML churn model ✅
│ ├── 04_clv_analysis.ipynb # Lifetime value ✅
│ └── 05_ab_testing_simulation.ipynb # A/B test framework ✅
│
├── scripts/
│ ├── generate_daily_report.py # Automated reporting (coming soon)
│ └── run_pipeline.py # End-to-end pipeline (coming soon)
│
├── sql/
│ ├── 01_create_tables.sql # Schema definition (coming soon)
│ ├── 02_kpi_queries.sql # KPI calculations (coming soon)
│ └── 03_analytical_queries.sql # Advanced analytics (coming soon)
│
├── models/ # Saved ML models
├── reports/ # Generated reports & visualizations
├── powerbi/ # Power BI dashboard files
├── .github/workflows/ # CI/CD automation (coming soon)
├── requirements.txt # Python dependencies
└── README.md # Project documentation

````

## 🚀 Getting Started

### Prerequisites

```bash
Python 3.10+
MySQL 8.0+
Power BI Desktop (for dashboard)
````

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/BrokerRecord/Customer-Intelligence.git
cd Customer-Intelligence
```

2. **Create virtual environment**

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**

```bash
pip install -r requirements.txt
```

4. **Run the analysis pipeline**

```bash
# Run notebooks in order
jupyter notebook notebooks/
```

## 📊 Analysis Modules

### 1. Data Cleaning (`01_data_cleaning.ipynb`)

- 1,067,371 → 779,425 clean transactions
- Missing value handling (22.77% customer_id)
- Data type optimization
- Feature engineering (16 features)

### 2. RFM Analysis (`02_rfm_analysis.ipynb`)

- 11 customer segments identified
- Revenue-based segmentation
- Segment-specific KPIs
- Marketing recommendations

### 3. Churn Prediction (`03_churn_prediction.ipynb`)

- 90-day churn definition
- 12 behavioral features
- Random Forest model (0.78 AUC)
- SHAP feature importance analysis

### 4. CLV Analysis (`04_clv_analysis.ipynb`)

- BG/NBD + Gamma-Gamma models
- 12-month CLV predictions
- Segment-based value distribution
- Retention strategy recommendations

### 5. A/B Testing (`05_ab_testing_simulation.ipynb`)

- Power analysis (80% power, α=0.05)
- Statistical significance testing
- ROI calculation (491.76%)
- Production deployment recommendation

## 📈 Power BI Dashboard

The interactive dashboard includes:

- **Customer Overview**: Total customers, revenue, churn rate
- **Segment Performance**: Distribution and trends by segment
- **Churn Risk Heatmap**: High-risk customer identification
- **CLV Forecast**: Lifetime value projections
- **Campaign ROI Tracker**: Real-time A/B test monitoring

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📧 Contact

**Awa Mbaye** - [evash0uwha@gmail.com](mailto:evash0uwha@gmail.com)

**Project Link**: [https://github.com/BrokerRecord/Customer-Intelligence](https://github.com/BrokerRecord/Customer-Intelligence)

## 🙏 Acknowledgments

- UCI Machine Learning Repository for the retail dataset
- Lifetimes library for CLV modeling
- scikit-learn community for ML tools
- Power BI team for visualization capabilities

---

### ⭐ Star this repo if you found it helpful!

```

```
