# Telco Customer Churn Analysis

## Overview
Analysis of customer churn for a telecommunications company using Python, PostgreSQL, and Tableau.
The goal: identify which customers are most likely to churn, why, and what the business can do about it.

**Dataset:** [IBM Telco Customer Churn — Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
7,043 customers | 21 variables | fictional IBM sample dataset

---

## Tools & Stack
- **Python** (pandas, matplotlib, seaborn) — data cleaning & EDA
- **PostgreSQL** — business metric queries & cohort analysis
- **Tableau** — interactive dashboard

---

## Project Structure
```
├── Telco_Customer_Churn.ipynb     # Data cleaning and EDA
├── telco_customers_churn.sql      # SQL analysis (5 sections)
├── telco_customers_churn.twbx     # Tableau workbook
├── telco_dashboard.png            # Dashboard screenshot
└── README.md
```

---

## Key Findings

**1. Contract type is the strongest churn predictor**
Month-to-month customers churn at 42.71% vs 2.83% for two-year contracts — a 15× gap.
88% of all churned customers (1,655 of 1,869) were on month-to-month contracts.

**2. Early tenure is the danger zone**
Churn drops 5× from the first year (47.44%) to customers past 48 months (9.51%).
Customers who churn on month-to-month contracts last only 14 months on average.

**3. Payment method signals commitment**
Electronic check users churn at 45.29% — nearly 3× higher than automatic payment methods (15–17%).
Automatic payment correlates strongly with retention.

**4. One segment drives most of the revenue risk**
Month-to-month + electronic check customers: 1,850 customers, 53.73% churn rate,
$74,540 monthly revenue at risk — more than all other segments combined.

**5. 1,146 high-risk customers are identifiable and targetable**
Customers meeting all four criteria (month-to-month, tenure < 12 months,
no TechSupport, no OnlineSecurity) represent $77,618 in monthly revenue at risk.

---

## Business Recommendations

**1. Prioritize contract conversion in months 1–12**
Offer a discounted first-year annual plan to month-to-month customers at signup and at the
3-month mark. The 0–12 month cohort churns at 47.44% and represents the highest
concentration of revenue at risk. Even a 20% conversion rate to annual contracts would
materially reduce the top churn segment.

**2. Incentivize automatic payment enrollment**
Electronic check customers churn at 3× the rate of automatic payment users.
Offer a small monthly discount or service credit for switching to autopay.
This targets a behavioral signal that correlates directly with churn risk.

**3. Bundle TechSupport and OnlineSecurity for new customers**
1,146 customers meet all high-risk criteria including missing both services.
A free 3-month trial of both services for new month-to-month customers addresses
the service gap while increasing switching costs — making it harder to leave.

---

## Dashboard
[View Interactive Dashboard on Tableau Public](https://public.tableau.com/app/profile/marta.narozhnyak/viz/Telco_customers_churn/TelcoDashboard)

<img width="1300" height="888" alt="Telco Dashboard" src="https://github.com/user-attachments/assets/04610c7e-023b-4efb-86e4-91043840f380" />
