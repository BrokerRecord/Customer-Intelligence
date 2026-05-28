import pandas as pd
import numpy as np
from datetime import datetime
import os
import sys
import json


try:
    from fpdf import FPDF
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False
    print("⚠️ fpdf not installed. Run: pip install fpdf")
    print("   Generating text report instead...")

# ============================================================================
# CONFIGURATION
# ============================================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, 'data', 'processed')
REPORTS_DIR = os.path.join(BASE_DIR, 'reports')

os.makedirs(REPORTS_DIR, exist_ok=True)

# ============================================================================
# DATA LOADING
# ============================================================================

def load_all_data():
    """Load all processed data files."""
    print("📂 Loading project data...")
    
    data = {}
    
    # Fact transactions
    data['transactions'] = pd.read_csv(
        os.path.join(DATA_DIR, 'cleaned_transactions.csv'),
        parse_dates=['invoicedate']
    )
    
    # Customer data (from dim_customer.csv)
    data['customers'] = pd.read_csv(os.path.join(DATA_DIR, 'dim_customer.csv'))
    
    # CLV data
    data['clv'] = pd.read_csv(os.path.join(DATA_DIR, 'dim_customer_clv.csv'))
    
    # Risk data
    data['risk'] = pd.read_csv(os.path.join(DATA_DIR, 'dim_customer_risk.csv'))
    
    # Segment KPIs
    try:
        data['segment_kpis'] = pd.read_csv(os.path.join(DATA_DIR, 'segment_kpis.csv'))
    except:
        data['segment_kpis'] = pd.DataFrame()
    
    # CLV summaries
    try:
        data['clv_segment'] = pd.read_csv(os.path.join(DATA_DIR, 'clv_segment_summary.csv'))
    except:
        data['clv_segment'] = pd.DataFrame()
    
    try:
        data['clv_tier'] = pd.read_csv(os.path.join(DATA_DIR, 'clv_tier_summary.csv'))
    except:
        data['clv_tier'] = pd.DataFrame()
    
    print(f"   ✅ Transactions: {len(data['transactions']):,}")
    print(f"   ✅ Customers: {len(data['customers']):,}")
    print(f"   ✅ CLV records: {len(data['clv']):,}")
    print(f"   ✅ Risk records: {len(data['risk']):,}")
    
    return data

# ============================================================================
# METRICS CALCULATION
# ============================================================================

def calculate_metrics(data):
    """Calculate all key metrics from loaded data."""
    
    metrics = {}
    
    # ========================================================================
    # 1. Overall Business Metrics
    # ========================================================================
    df = data['transactions']
    metrics['total_revenue'] = df['total_price'].sum()
    metrics['total_customers'] = df['customer_id'].nunique()
    metrics['total_orders'] = df['invoice'].nunique()
    metrics['avg_order_value'] = metrics['total_revenue'] / metrics['total_orders'] if metrics['total_orders'] > 0 else 0
    metrics['revenue_per_customer'] = metrics['total_revenue'] / metrics['total_customers'] if metrics['total_customers'] > 0 else 0
    metrics['date_range'] = f"{df['invoicedate'].min().strftime('%b %Y')} - {df['invoicedate'].max().strftime('%b %Y')}"
    
    # Top countries
    country_revenue = df.groupby('country')['total_price'].sum().sort_values(ascending=False)
    metrics['top_country'] = country_revenue.index[0] if len(country_revenue) > 0 else 'UK'
    metrics['top_country_revenue'] = country_revenue.iloc[0] if len(country_revenue) > 0 else 0
    metrics['uk_revenue_pct'] = (metrics['top_country_revenue'] / metrics['total_revenue'] * 100) if metrics['total_revenue'] > 0 else 0
    
    # ========================================================================
    # 2. Customer Segmentation (RFM)
    # ========================================================================
    customers = data['customers']
    
    # Check column names (dim_customer has 'customer_segment' and 'total_spent')
    segment_col = 'customer_segment' if 'customer_segment' in customers.columns else 'segment'
    spent_col = 'total_spent' if 'total_spent' in customers.columns else 'monetary'
    
    segment_counts = customers[segment_col].value_counts()
    segment_revenue = customers.groupby(segment_col)[spent_col].sum()
    
    metrics['top_segment'] = str(segment_counts.index[0]) if len(segment_counts) > 0 else 'None'
    metrics['top_segment_count'] = int(segment_counts.iloc[0]) if len(segment_counts) > 0 else 0
    metrics['top_segment_pct'] = (metrics['top_segment_count'] / len(customers) * 100) if len(customers) > 0 else 0
    
    metrics['champions_count'] = int(segment_counts.get('Champions', 0))
    metrics['champions_revenue'] = float(segment_revenue.get('Champions', 0))
    metrics['champions_revenue_pct'] = (metrics['champions_revenue'] / metrics['total_revenue'] * 100) if metrics['total_revenue'] > 0 else 0
    
    metrics['at_risk_count'] = int(segment_counts.get('At Risk', 0))
    metrics['at_risk_revenue'] = float(segment_revenue.get('At Risk', 0))
    
    metrics['segment_count'] = len(segment_counts)
    
    # ========================================================================
    # 3. Churn Prediction
    # ========================================================================
    risk = data['risk']
    
    # Check for actual_churned column
    if 'actual_churned' in risk.columns:
        metrics['churn_rate'] = risk['actual_churned'].mean() * 100
    else:
        metrics['churn_rate'] = 56.6  # Default from your analysis
    
    metrics['high_risk_count'] = len(risk[risk['risk_level'].isin(['Critical', 'High'])]) if 'risk_level' in risk.columns else 0
    metrics['critical_risk_count'] = len(risk[risk['risk_level'] == 'Critical']) if 'risk_level' in risk.columns else 0
    metrics['avg_risk_score'] = risk['churn_risk_score'].mean() if 'churn_risk_score' in risk.columns else 0
    
    # Active high-risk customers
    if 'risk_level' in risk.columns and 'actual_churned' in risk.columns:
        active_high_risk = risk[(risk['risk_level'].isin(['Critical', 'High'])) & (risk['actual_churned'] == 0)]
    else:
        active_high_risk = risk[risk['risk_level'].isin(['Critical', 'High'])] if 'risk_level' in risk.columns else pd.DataFrame()
    
    metrics['active_high_risk_count'] = len(active_high_risk)
    
    # Revenue at risk
    if len(active_high_risk) > 0 and 'customer_id' in active_high_risk.columns:
        high_risk_customers = active_high_risk.merge(
            customers[['customer_id', spent_col]], 
            on='customer_id', 
            how='left'
        )
        metrics['revenue_at_risk'] = high_risk_customers[spent_col].sum()
        
        # Expected loss (probability-weighted)
        expected_loss = 0
        if 'churn_risk_score' in high_risk_customers.columns:
            for _, row in high_risk_customers.iterrows():
                expected_loss += row['churn_risk_score'] * row[spent_col]
        metrics['expected_revenue_loss'] = expected_loss
    else:
        metrics['revenue_at_risk'] = 0
        metrics['expected_revenue_loss'] = 0
    
    # ========================================================================
    # 4. Customer Lifetime Value
    # ========================================================================
    clv = data['clv']
    
    # Check column names
    clv_value_col = 'predicted_clv_12m' if 'predicted_clv_12m' in clv.columns else 'clv_12m'
    
    metrics['total_clv'] = clv[clv_value_col].sum() if clv_value_col in clv.columns else 0
    metrics['avg_clv'] = clv[clv_value_col].mean() if clv_value_col in clv.columns else 0
    metrics['median_clv'] = clv[clv_value_col].median() if clv_value_col in clv.columns else 0
    metrics['clv_customers'] = len(clv)
    
    # CLV segments
    clv_segment = data['clv_segment']
    if len(clv_segment) > 0:
        # Check column names
        segment_col = 'clv_segment' if 'clv_segment' in clv_segment.columns else clv_segment.columns[0]
        count_col = 'customer_count' if 'customer_count' in clv_segment.columns else 'count'
        value_col = 'total_clv' if 'total_clv' in clv_segment.columns else 'total_clv_12m'
        pct_col = 'pct_of_value' if 'pct_of_value' in clv_segment.columns else clv_segment.columns[-1]
        
        high_segment = clv_segment[clv_segment[segment_col] == 'High']
        if len(high_segment) > 0:
            metrics['high_clv_count'] = int(high_segment[count_col].iloc[0]) if count_col in high_segment.columns else 0
            metrics['high_clv_value'] = float(high_segment[value_col].iloc[0]) if value_col in high_segment.columns else 0
            metrics['high_clv_pct'] = float(high_segment[pct_col].iloc[0]) if pct_col in high_segment.columns else 0
        else:
            metrics['high_clv_count'] = 0
            metrics['high_clv_value'] = 0
            metrics['high_clv_pct'] = 0
    else:
        metrics['high_clv_count'] = 0
        metrics['high_clv_value'] = 0
        metrics['high_clv_pct'] = 0
    
    # CLV tiers
    clv_tier = data['clv_tier']
    if len(clv_tier) > 0:
        tier_col = 'clv_tier' if 'clv_tier' in clv_tier.columns else clv_tier.columns[0]
        avg_col = 'avg_clv' if 'avg_clv' in clv_tier.columns else clv_tier.columns[-1]
        
        premium = clv_tier[clv_tier[tier_col] == 'Premium Value (>$5,000)']
        if len(premium) > 0:
            metrics['premium_clv_avg'] = float(premium[avg_col].iloc[0]) if avg_col in premium.columns else 0
        else:
            metrics['premium_clv_avg'] = 0
    else:
        metrics['premium_clv_avg'] = 0
    
    # ========================================================================
    # 5. A/B Test Results (from your simulation)
    # ========================================================================
    metrics['ab_test_conversion_lift'] = 0.612  # 61.2% from your notebook
    metrics['ab_test_p_value'] = 0.015  # from your notebook
    metrics['ab_test_roi'] = 6.482  # 648.2% from your notebook
    metrics['ab_test_significant'] = True
    
    # ========================================================================
    # 6. Product Analysis
    # ========================================================================
    if 'description' in df.columns:
        product_revenue = df.groupby('description')['total_price'].sum().sort_values(ascending=False)
        metrics['top_product'] = str(product_revenue.index[0]) if len(product_revenue) > 0 else 'Unknown'
        metrics['top_product_revenue'] = product_revenue.iloc[0] if len(product_revenue) > 0 else 0
    else:
        metrics['top_product'] = 'Unknown'
        metrics['top_product_revenue'] = 0
    
    # ========================================================================
    # 7. Time-based Metrics
    # ========================================================================
    if 'hour' in df.columns:
        peak_hours = df[df['hour'].between(10, 16)]
        metrics['peak_hour_revenue_pct'] = (peak_hours['total_price'].sum() / metrics['total_revenue'] * 100) if metrics['total_revenue'] > 0 else 0
    else:
        metrics['peak_hour_revenue_pct'] = 0
    
    # Weekend vs Weekday
    if 'day_of_week' in df.columns:
        weekend_days = ['Saturday', 'Sunday']
        weekend_mask = df['day_of_week'].isin(weekend_days)
        weekend_revenue = df[weekend_mask]['total_price'].sum()
        metrics['weekend_revenue_pct'] = (weekend_revenue / metrics['total_revenue'] * 100) if metrics['total_revenue'] > 0 else 0
    else:
        metrics['weekend_revenue_pct'] = 0
    
    return metrics

# ============================================================================
# TEXT REPORT GENERATION
# ============================================================================

def generate_text_report(metrics):
    """Generate formatted text report."""
    
    report = f"""
================================================================================
                    CUSTOMER INTELLIGENCE SYSTEM
                         FINAL EXECUTIVE REPORT
================================================================================

Report Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Analysis Period: {metrics['date_range']}

================================================================================
1. EXECUTIVE SUMMARY
================================================================================
┌─────────────────────────────────────────────────────────────────────────────┐
│ Metric                    │ Value                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│ Total Revenue             │ £{metrics['total_revenue']:,.2f}                                  │
│ Total Customers           │ {metrics['total_customers']:,}                                           │
│ Total Orders              │ {metrics['total_orders']:,}                                           │
│ Average Order Value       │ £{metrics['avg_order_value']:.2f}                                    │
│ Revenue per Customer      │ £{metrics['revenue_per_customer']:.2f}                                 │
│ Top Country               │ {metrics['top_country']} ({metrics['uk_revenue_pct']:.1f}% of revenue)    │
└─────────────────────────────────────────────────────────────────────────────┘

================================================================================
2. CUSTOMER SEGMENTATION (RFM Analysis)
================================================================================
📊 SEGMENT DISTRIBUTION:
   • Total Segments Identified: {metrics['segment_count']}
   • Largest Segment: {metrics['top_segment']} ({metrics['top_segment_count']:,} customers - {metrics['top_segment_pct']:.1f}%)

⭐ CHAMPIONS (Highest Value):
   • Count: {metrics['champions_count']:,} customers
   • Revenue: £{metrics['champions_revenue']:,.2f}
   • Contribution: {metrics['champions_revenue_pct']:.1f}% of total revenue

⚠️ AT RISK CUSTOMERS:
   • Count: {metrics['at_risk_count']:,} customers
   • Revenue: £{metrics['at_risk_revenue']:,.2f}

================================================================================
3. CHURN PREDICTION MODEL
================================================================================
🎯 MODEL PERFORMANCE:
   • Best Model: Logistic Regression
   • ROC-AUC Score: 72.9%
   • Optimal Threshold: 0.10
   • Validation: Time-based split (NO LEAKAGE)

⚠️ RISK ASSESSMENT:
   • Overall Churn Rate: {metrics['churn_rate']:.1f}%
   • High-Risk Customers: {metrics['high_risk_count']:,}
   • Critical Risk Customers: {metrics['critical_risk_count']:,}
   • Average Risk Score: {metrics['avg_risk_score']:.3f}

💰 REVENUE IMPACT:
   • Active High-Risk Customers: {metrics['active_high_risk_count']:,}
   • Revenue at Risk: £{metrics['revenue_at_risk']:,.2f}
   • Expected Revenue Loss: £{metrics['expected_revenue_loss']:,.2f}

================================================================================
4. CUSTOMER LIFETIME VALUE (12-Month Forecast)
================================================================================
💎 CLV STATISTICS:
   • Total Predicted CLV: £{metrics['total_clv']:,.2f}
   • Average CLV per Customer: £{metrics['avg_clv']:.2f}
   • Median CLV: £{metrics['median_clv']:.2f}
   • Customers with CLV Data: {metrics['clv_customers']:,}

🏆 HIGH VALUE SEGMENT:
   • Customers: {metrics['high_clv_count']:,}
   • Total Value: £{metrics['high_clv_value']:,.2f}
   • Value Share: {metrics['high_clv_pct']:.1f}%

💎 PREMIUM TIER (>$5,000):
   • Average CLV: £{metrics['premium_clv_avg']:,.2f}

================================================================================
5. A/B TEST RESULTS (Re-engagement Campaign)
================================================================================
🧪 EXPERIMENT DESIGN:
   • Target Segments: At Risk, About to Sleep, Hibernating, Lost
   • Sample Size: 1,446 customers
   • Test Group: 15% discount offer
   • Control Group: No offer

📊 RESULTS:
   • Conversion Lift: {metrics['ab_test_conversion_lift']:.1%}
   • P-Value: {metrics['ab_test_p_value']:.4f}
   • Statistically Significant: {'YES' if metrics['ab_test_significant'] else 'NO'}
   • Projected ROI: {metrics['ab_test_roi']:.1%}

🎯 RECOMMENDATION: {'DEPLOY CAMPAIGN TO FULL POPULATION' if metrics['ab_test_significant'] and metrics['ab_test_roi'] > 0 else 'OPTIMIZE BEFORE DEPLOYMENT'}

================================================================================
6. PRODUCT & TIME INSIGHTS
================================================================================
🏆 TOP PERFORMING PRODUCT:
   • {metrics['top_product']}
   • Revenue: £{metrics['top_product_revenue']:,.2f}

⏰ PEAK SHOPPING HOURS (10am-4pm):
   • Revenue Share: {metrics['peak_hour_revenue_pct']:.1f}%

📅 WEEKEND SHOPPING:
   • Revenue Share: {metrics['weekend_revenue_pct']:.1f}%

================================================================================
7. KEY RECOMMENDATIONS
================================================================================

1. 🎯 RETAIN HIGH-VALUE CUSTOMERS
   → Champions ({metrics['champions_count']:,} customers) drive {metrics['champions_revenue_pct']:.1f}% of revenue
   → Implement VIP loyalty program with early access and exclusive benefits

2. ⚠️ RECOVER AT-RISK CUSTOMERS
   → {metrics['at_risk_count']:,} customers represent £{metrics['at_risk_revenue']:,.2f}
   → Launch targeted win-back campaigns with personalized offers

3. 🔴 PREVENT CHURN IN HIGH-RISK SEGMENT
   → {metrics['active_high_risk_count']:,} active customers at risk (£{metrics['revenue_at_risk']:,.2f})
   → Expected loss of £{metrics['expected_revenue_loss']:,.2f} if no action taken
   → Deploy A/B tested campaign with {metrics['ab_test_conversion_lift']:.1%} expected lift

4. 💎 MAXIMIZE CLV
   → Premium tier customers average £{metrics['premium_clv_avg']:,.2f} CLV
   → Focus retention efforts on high-value segment ({metrics['high_clv_count']:,} customers)

5. 📈 OPTIMIZE MARKETING TIMING
   → {metrics['peak_hour_revenue_pct']:.1f}% of revenue during peak hours (10am-4pm)
   → {metrics['weekend_revenue_pct']:.1f}% of revenue on weekends

================================================================================
8. FINANCIAL SUMMARY
================================================================================
┌─────────────────────────────────────────────────────────────────────────────┐
│ Category                    │ Amount                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ Total Revenue               │ £{metrics['total_revenue']:,.2f}                              │
│ Total Predicted CLV         │ £{metrics['total_clv']:,.2f}                              │
│ Revenue at Risk             │ £{metrics['revenue_at_risk']:,.2f}                              │
│ Expected Revenue Loss       │ £{metrics['expected_revenue_loss']:,.2f}                              │
│ Champions Revenue           │ £{metrics['champions_revenue']:,.2f}                              │
└─────────────────────────────────────────────────────────────────────────────┘

================================================================================
Report Generated by Customer Intelligence System
================================================================================
"""
    return report

# ============================================================================
# PDF REPORT GENERATION (Optional)
# ============================================================================

class PDFReport(FPDF):
    def header(self):
        self.set_font('Courier', 'B', 12)  
        self.cell(0, 10, 'Customer Intelligence System', 0, 1, 'C')
        self.set_font('Courier', '', 10)
        self.cell(0, 5, 'Final Executive Report', 0, 1, 'C')
        self.ln(10)
    
    def footer(self):
        self.set_y(-15)
        self.set_font('Courier', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

def generate_pdf_report(metrics, output_path):
    """Generate PDF version of the report."""
    if not PDF_AVAILABLE:
        print("   ⚠️ PDF generation skipped (fpdf not installed)")
        return
    
    pdf = PDFReport()
    pdf.add_page()
    pdf.set_font('Arial', '', 10)
    
    # Convert text report to PDF (simplified)
    text_report = generate_text_report(metrics)
    
    # Write to PDF (basic)
    for line in text_report.split('\n'):
        # Handle encoding issues
        line = line.encode('latin-1', 'replace').decode('latin-1')
        pdf.cell(0, 5, line, 0, 1)
    
    pdf.output(output_path)
    print(f"   ✅ PDF report saved to {output_path}")

# ============================================================================
# MAIN FUNCTION
# ============================================================================

def main():
    print("\n" + "="*80)
    print(" CUSTOMER INTELLIGENCE - FINAL EXECUTIVE REPORT")
    print("="*80 + "\n")
    
    try:
        # Load all data
        data = load_all_data()
        
        # Calculate metrics
        print("\n📊 Calculating metrics...")
        metrics = calculate_metrics(data)
        
        # Generate text report
        print("\n📝 Generating report...")
        report_text = generate_text_report(metrics)
        
        # Save text report
        txt_path = os.path.join(REPORTS_DIR, "final_executive_report.txt")
        with open(txt_path, 'w', encoding='utf-8') as f:
            f.write(report_text)
        print(f"   ✅ Text report saved to {txt_path}")
        
        # Generate PDF report (optional)
        pdf_path = os.path.join(REPORTS_DIR, "final_executive_report.pdf")
        generate_pdf_report(metrics, pdf_path)
        
        # Save metrics as JSON
        json_path = os.path.join(REPORTS_DIR, "final_metrics.json")
        
        # Convert numpy types to Python types for JSON
        def convert_to_serializable(obj):
            if isinstance(obj, (np.int64, np.int32)):
                return int(obj)
            if isinstance(obj, (np.float64, np.float32)):
                return float(obj)
            if isinstance(obj, np.bool_):
                return bool(obj)
            return obj
        
        serializable_metrics = {k: convert_to_serializable(v) for k, v in metrics.items()}
        
        with open(json_path, 'w') as f:
            json.dump(serializable_metrics, f, indent=2, default=str)
        print(f"   ✅ JSON metrics saved to {json_path}")
        
        # Print report to console
        print(report_text)
        
        print("\n" + "="*80)
        print(" ✅ FINAL REPORT GENERATION COMPLETE!")
        print("="*80)
        print(f"\n📁 Reports saved to: {REPORTS_DIR}")
        print("   - final_executive_report.txt")
        print("   - final_executive_report.pdf")
        print("   - final_metrics.json")
        print("\n")
        
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()