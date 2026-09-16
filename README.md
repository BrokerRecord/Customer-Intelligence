# Customer Intelligence & Retail Analytics

**End-to-end data analytics and machine learning portfolio project** · Python · MySQL · Power BI · scikit-learn

[![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/) [![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow.svg)](https://powerbi.microsoft.com/) [![MySQL](https://img.shields.io/badge/MySQL-8.0%2B-blue.svg)](https://www.mysql.com/) [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Portfolio project using historical retail transactions.** Customer lifetime value and churn-risk outputs are model estimates; the marketing A/B test is a **simulation**, not a real campaign. No production or real-time deployment is claimed.

## Project overview

This independent project explores how retail transaction data can support customer segmentation, churn analysis, customer lifetime value (CLV) forecasting, and business reporting. It combines data cleaning, SQL modeling, statistical analysis, machine learning, and an interactive Power BI dashboard.

| Project metric | Reported value |
|---|---:|
| Raw transactions | 1,067,371 |
| Cleaned transactions | 779,425 |
| Unique customers | 5,878 |
| Revenue in cleaned data | £17,374,804.27 |
| RFM segments | 11 |
| Machine-learning models compared | 4 |
| Power BI pages | 8 |

**Dataset:** [Online Retail II — UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (transactions from 2009–2011).

### Questions addressed

- How do purchasing patterns differ across customer segments?
- Which customers might be at risk of churn, given a defined observation and outcome window?
- What future customer value do probabilistic CLV models estimate?
- How can business users explore customer, product, geographic, and time-series trends?
- How could a re-engagement campaign be evaluated statistically in a *simulated* experiment?

## Dashboard preview

### Executive overview

![Executive dashboard](powerbi/screenshots/executive_overview.PNG)

### Customer analytics

![Customer analytics dashboard](powerbi/screenshots/customer_analytics.PNG)

[Open the Power BI report](powerbi/Customer%20Intelligence%20Dashboard.pbix)

> The image and report paths above come from the documented repository structure. Verify the exact filenames and capitalization before publishing. The `.pbix` file may require updating local data-source paths when opened on another computer.

## Analytical workflow

```text
Online Retail II (Excel/CSV)
       |
       v
Python: cleaning and feature engineering
       |
       v
MySQL: transaction fact and analytical tables
       |
       +--> RFM customer segmentation
       +--> Churn classification and risk scoring
       +--> CLV estimation
       +--> Simulated campaign A/B analysis
       |
       v
Power BI: interactive reporting
```

The README documents 15 analytical database tables and 25 features used in the churn modeling stage. The diagram represents the analytical workflow, not an automated production orchestration system.

## Methods and results

### 1. Data cleaning and preparation

**Notebook:** `notebooks/01_data_cleaning.ipynb`

- Input: 1,067,371 historical transactions.
- Documented cleaning: missing customer identifiers, duplicate records, and cancelled orders.
- Missing `customer_id` values: 22.77% in the original analysis.
- Output: 779,425 cleaned transactions, with time-based and customer-related features.
- Analytical outputs include a transaction fact table and customer, product, and date dimensions.

See the notebook for the exact inclusion/exclusion rules and feature definitions.

### 2. RFM customer segmentation

**Notebook:** `notebooks/02_rfm_analysis.ipynb`

RFM scores summarize **recency**, **frequency**, and **monetary value**. The project uses quartile-based scoring to assign customers to 11 segments, including Champions, Loyal, At Risk, and Hibernating.

| Reported descriptive finding | Value |
|---|---:|
| Champions | 1,821 customers (30.98%) |
| Revenue associated with Champions | £13.19M (75.89% of total) |
| At Risk segment | 687 customers |
| Revenue associated with At Risk segment | £787.7K |

These figures describe the historical dataset and segmentation rules; they are not measured effects of marketing interventions.

### 3. Churn classification

**Notebook:** `notebooks/03_churn_prediction.ipynb`

The project describes churn as **no purchase during a 90-day period** and compares Logistic Regression, Random Forest, Gradient Boosting, and XGBoost using behavioral features.

| Reported result | Value |
|---|---:|
| Overall churn prevalence | 56.60% (3,490 / 5,878 customers) |
| Best model reported in this README | Logistic Regression |
| ROC-AUC | 0.7294 |
| Selected decision threshold | 0.10 |
| Active customers flagged as high risk | 2,161 |
| High-risk active customers in revenue-at-risk subset | 414 |
| Historical revenue associated with that subset | £307,781 |

**Interpretation:** £307,781 is a revenue-at-risk *estimate based on historical customer value and risk rules*, not a verified future loss or a realized financial impact.

**Methodology to verify before presenting this as prospective prediction:** Document the observation cutoff, the subsequent 90-day label window, the feature-generation cutoff, the train/test split, and whether preprocessing was fitted on training data only. Confirm that no transactions from the outcome period enter the predictors. Also reconcile the F1 values **0.7413** and **0.7428** appearing in the earlier README against the actual notebook output; an F1 figure is intentionally omitted here until verified.

### 4. Customer lifetime value forecasting

**Notebook:** `notebooks/04_clv_analysis.ipynb`

The analysis uses BG/NBD and Gamma-Gamma models to estimate customer purchasing behavior and monetary value over a 12-month horizon.

| Reported model output | Value |
|---|---:|
| Customers with CLV predictions | 3,626 |
| Total predicted 12-month CLV | £6,485,330.27 |
| Correlation reported for 90-day holdout | 0.783 |
| Share of modeled CLV attributed to top 25% of customers | 76.0% |

These are **forecasts and validation statistics**, not realized future revenue. Model assumptions, eligible-customer criteria, and the holdout procedure should be checked in the notebook.

### 5. Simulated A/B test: customer re-engagement

**Notebook:** `notebooks/05_ab_testing_simulation.ipynb`

This module demonstrates a *hypothetical* campaign evaluation rather than reporting a campaign deployed to real customers.

- **Scenario:** 15% discount for re-engagement.
- **Target population:** 1,446 customers across At Risk, About to Sleep, Hibernating, and Lost segments.
- **Design described in the project:** stratified randomization by monetary tier.
- **Statistical methods:** chi-square test for conversion and Welch's t-test for revenue.

| Simulated outcome | Value |
|---|---:|
| Conversion lift | 61.2% |
| Simulated p-value | 0.015 |
| Projected ROI | 648.2% |
| Projected net profit | £29,636 |

**Important:** These results depend on simulated outcomes and assumptions. The p-value does not establish an effect in real customers, and projected ROI is not earned revenue. A real randomized trial would be necessary before making deployment decisions.

## Power BI dashboard

The documented eight-page report includes:

| Page | Focus |
|---|---|
| Executive Overview | Revenue, customers, churn rate, products |
| Customer Segmentation | RFM distribution and revenue by segment |
| Churn Risk Analysis | Risk distribution and estimated revenue at risk |
| CLV Forecasting | Predicted value by tier and segment |
| Time Series & Seasonality | Revenue and purchasing patterns over time |
| Product Performance | Product and category analysis |
| Geographic Analysis | Country and regional revenue |
| Marketing ROI | **Simulated** A/B test and projected campaign economics |

The report is an interactive analysis of historical data; it is not described here as a real-time monitoring service.

## Technology stack

| Area | Tools |
|---|---|
| Data processing | Python, pandas, NumPy |
| Database | MySQL 8.0, MySQL Workbench |
| Machine learning | scikit-learn, XGBoost, SHAP |
| CLV modeling | Lifetimes (BG/NBD, Gamma-Gamma) |
| Statistical analysis | SciPy, statsmodels |
| Visualization | Power BI, Matplotlib, Seaborn |
| Version control | Git, GitHub |

## Repository structure

```text
Customer-Intelligence/
├── data/
│   ├── raw/                         # Original input data, if distributed
│   └── processed/                   # Derived analytical datasets
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   ├── 02_rfm_analysis.ipynb
│   ├── 03_churn_prediction.ipynb
│   ├── 04_clv_analysis.ipynb
│   └── 05_ab_testing_simulation.ipynb
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_load_data.sql
│   └── 03_kpi_queries.sql
├── models/                           # Saved model and preprocessing artifacts
├── reports/
├── powerbi/
│   ├── screenshots/
│   └── Customer Intelligence Dashboard.pbix
├── requirements.txt
└── README.md
```

> This is the structure documented in the original README, not an independently verified listing of the current GitHub repository. Update it if filenames, folders, or data distribution differ.

### Analytical database

The project documents 15 tables, including `fact_transactions`, `dim_customer`, `dim_product`, `dim_date`, `dim_customer_clv`, `dim_customer_risk`, `segment_kpis`, `monthly_segment_revenue`, and `customer_360_view`. See `sql/` for the authoritative schema and queries. Some tables are derived summaries rather than separate dimensions.

## Getting started

### Prerequisites

- Python 3.10 or newer
- MySQL 8.0 or newer for the SQL workflow
- Power BI Desktop to open the `.pbix` report (Windows)
- Git and Jupyter Notebook
- Access to the Online Retail II dataset, subject to its distribution terms

### 1. Clone and install

```bash
git clone https://github.com/BrokerRecord/Customer-Intelligence.git
cd Customer-Intelligence
python -m venv .venv
```

Activate the environment:

```powershell
# Windows PowerShell
.venv\Scripts\Activate.ps1
```

```bash
# Linux / macOS
source .venv/bin/activate
```

Install dependencies:

```bash
python -m pip install -r requirements.txt
```

### 2. Prepare the input data

Download the historical Online Retail II dataset from the [UCI dataset page](https://archive.ics.uci.edu/dataset/502/online+retail+ii). Place the source files in the input location expected by `01_data_cleaning.ipynb` and update any machine-specific paths.

**Before publishing:** Specify the exact input filenames and destination directory used by the notebook. The original README does not provide enough information to guarantee a fresh-clone run.

### 3. Run the notebooks

```bash
jupyter notebook
```

Execute notebooks `01` through `05` in order, checking their input/output paths and dependencies. The README does not establish that this sequence is fully automated.

### 4. Set up MySQL

The documented SQL files are:

```text
sql/01_create_tables.sql
sql/02_load_data.sql
sql/03_kpi_queries.sql
```

Run the scripts using MySQL Workbench or the MySQL client, in the order required by their contents. Configure database credentials and local CSV import paths as needed.

**Before publishing:** Confirm which script creates/selects the database. The previous README referred to `sql/db.sql`, but that file was absent from its documented directory tree; this version does not invent a replacement command.

### 5. Open Power BI

Open `powerbi/Customer Intelligence Dashboard.pbix` in Power BI Desktop and update the data-source paths or connection settings before refreshing. Check that all eight pages and linked visuals load correctly.

## Reproducibility checklist

- [ ] Confirm all documented paths and filenames against the repository.
- [ ] Specify the exact raw input files and download instructions.
- [ ] Run the workflow from a fresh clone and clean Python environment.
- [ ] Document the MySQL database-creation step and any import-path configuration.
- [ ] Document the churn observation/outcome windows and leakage controls.
- [ ] Reconcile the conflicting F1 values in the original README.
- [ ] Verify the dashboard page count, screenshots, and `.pbix` link.
- [ ] Verify that the numerical outputs above match the current notebooks and dashboard.

## Limitations

1. **Historical data:** The dataset covers 2009–2011; findings may not generalize to present-day retail behavior.
2. **Operational churn definition:** Ninety days without a purchase is a project-specific proxy, not a confirmed customer cancellation.
3. **Prediction validation:** Prospective churn claims require documented time-aware evaluation and safeguards against data leakage.
4. **CLV uncertainty:** Forecasts depend on behavioral and model assumptions; predicted value is not realized revenue.
5. **Simulated experiment:** Campaign uplift, significance, profit, and ROI are simulated or projected, not observed in production.
6. **Deployment scope:** The repository demonstrates analytics and dashboarding, not production monitoring or real-time ingestion.

## Potential improvements

- Add a reproducible configuration file or example environment settings without committing secrets.
- Add automated checks for data quality and key metric consistency.
- Publish an explicit time-based churn validation protocol and baseline comparison.
- Add uncertainty estimates and calibration checks for risk and CLV predictions.
- Test the pipeline and dashboard refresh on a fresh machine.
- Evaluate the campaign design with real randomized data if such data becomes available and appropriate permissions are in place.

## Troubleshooting

| Issue | Suggested check |
|---|---|
| MySQL date conversion (`1292`) | Confirm source date format and `STR_TO_DATE()` format string. |
| Boolean-to-integer import (`1366`) | Convert textual `True`/`False` values explicitly. |
| `ONLY_FULL_GROUP_BY` (`1055`) | Correct grouping and aggregation logic; do not disable SQL mode merely to suppress the error. |
| Data truncation (`1265`) | Inspect source values and destination column types/precision before changing the schema. |
| Power BI missing data | Update local paths, credentials, and data-source settings. |

## Contributing

Issues and pull requests are welcome. For changes affecting reported metrics, please include the relevant notebook output and explain any updated assumptions.

## License

See [LICENSE](LICENSE) for the repository's license, if that file is present.

## Acknowledgments

- [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) for the Online Retail II dataset.
- The maintainers and contributors of Python, scikit-learn, Lifetimes, MySQL, and Power BI.

---

**Project repository:** https://github.com/BrokerRecord/Customer-Intelligence
