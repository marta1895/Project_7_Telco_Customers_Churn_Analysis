


---- SECTION 1: Business Overview

select * from telco

-- 1. Total customers, churned count, overall churn rate, monthly revenue, revenue lost to churn
WITH base_1 AS (
    SELECT
        COUNT(customer_id)                                   					AS total_customers,
        COUNT(CASE WHEN churn = 1 THEN 1 END)                					AS churned_count,
       	ROUND(SUM(monthly_charges)::numeric, 2)                               	AS total_monthly_revenue,
		ROUND(SUM(CASE WHEN churn = 1 THEN monthly_charges END)::numeric, 2)  	AS revenue_lost_to_churn
    FROM telco
)
SELECT
    total_customers,
    churned_count,
    ROUND(churned_count * 100.0 / total_customers, 2)        AS churn_rate_pct,
    total_monthly_revenue,
    revenue_lost_to_churn
FROM base_1;



---- SECTION 2: Cohort Analysis by Tenure


-- 2.
-- 2.1 Bucket customers into tenure cohorts (0–12 months, 13–24, 25–48, 48+)
-- 2.2 Churn rate per cohort
-- 2.3 Average monthly charges per cohort

WITH cohort AS (
	SELECT 
		*,
		CASE
			WHEN tenure BETWEEN 0 AND 12 THEN '0-12 months'
		 	WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
		 	WHEN tenure BETWEEN 25 AND 48 THEN '25-48 months'
		ELSE '48+ months' END							AS tenure_cohorts
	FROM telco
),
calculations AS (
	SELECT 
		tenure_cohorts,
		COUNT(customer_id)								AS total_customers,
	    COUNT(CASE WHEN churn = 1 THEN 1 END)			AS churned_count,
	    AVG(monthly_charges) AS avg_monthly_charges
	FROM cohort
	GROUP BY tenure_cohorts
)

SELECT 
	tenure_cohorts,
	ROUND(churned_count * 100.0 / total_customers, 2)	AS churn_rate_pct,
	avg_monthly_charges
FROM calculations
ORDER BY
    CASE tenure_cohorts
        WHEN '0-12 months'  THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-48 months' THEN 3
        WHEN '48+ months'   THEN 4
    END;

/*
KEY FINDING — Cohort Analysis:
Churn rate drops 5x from the first year (47.44%) to customers past 48 months (9.51%).
The 0-12 month cohort is the highest-risk and lowest-revenue segment simultaneously.
Longer-tenure customers pay ~32% more per month on average ($74 vs $56),
meaning early churn cuts off both the relationship and future revenue growth.
Intervention should be concentrated in the first 12 months.
*/



---- SECTION 3: Contract and Payment Risk



-- 3.1 Churn rate by contract type
WITH calculations AS (
	SELECT 
		contract,
		COUNT(customer_id)								AS total_customers,
	    COUNT(CASE WHEN churn = 1 THEN 1 END)			AS churned_count
	FROM telco
	GROUP BY contract
)

SELECT 
	contract AS contract_type,
	ROUND(churned_count * 100.0 / total_customers, 2)	AS churn_rate_pct
FROM calculations
ORDER BY churn_rate_pct;

-- 3.2 Churn rate by payment method
WITH calculations AS (
	SELECT 
		payment_method,
		COUNT(customer_id)								AS total_customers,
	    COUNT(CASE WHEN churn = 1 THEN 1 END)			AS churned_count
	FROM telco
	GROUP BY payment_method
)

SELECT 
	payment_method,
	ROUND(churned_count * 100.0 / total_customers, 2)	AS churn_rate_pct
FROM calculations
ORDER BY churn_rate_pct;


-- 3.3 Average tenure before churn by contract type
SELECT
    contract                            AS contract_type,
    ROUND(AVG(tenure), 1)               AS avg_tenure_months,
    COUNT(customer_id)                  AS churned_customers
FROM telco
WHERE churn = 1
GROUP BY contract
ORDER BY avg_tenure_months;

/*
KEY FINDING — Contract and Payment Risk:
Month-to-month customers churn at 42.71% vs 2.83% for two-year contracts — a 15x gap.
When they do churn, month-to-month customers last only 14 months on average vs 61 months
for two-year contracts. 88% of all churned customers (1,655 of 1,869) were on
month-to-month contracts. Electronic check users churn at 45.29%, nearly 3x higher
than automatic payment methods (~15-17%).
*/



---- SECTION 4: Revenue at Risk



-- 4.1 For each customer segment (contract × payment method), calculate: customer count, churn rate, avg monthly charges, and monthly revenue at risk
WITH calculations_1 AS (
	SELECT
		contract,
		payment_method,
		COUNT(customer_id) 						AS total_customers,
		COUNT(CASE WHEN churn = 1 THEN 1 END)	AS churned_count,
		AVG(monthly_charges)					AS avg_monthly_charges
	FROM telco
	GROUP BY contract, payment_method
),

calculations_2 AS (
SELECT
	contract,
	payment_method,
	total_customers,
	ROUND(churned_count * 100.0 / total_customers, 2)		AS churn_rate_pct,
	ROUND(avg_monthly_charges::numeric, 2) 					AS avg_monthly_charges,
	ROUND(churned_count * avg_monthly_charges::numeric, 2)	AS monthly_revenue_at_risk
FROM calculations_1
)

-- 4.2 Rank segments by revenue at risk
SELECT
    contract,
    payment_method,
    total_customers,
    churn_rate_pct,
    avg_monthly_charges,
    monthly_revenue_at_risk,
    RANK() OVER (ORDER BY monthly_revenue_at_risk DESC) AS risk_rank
FROM calculations_2
ORDER BY risk_rank;

/*
KEY FINDING — Revenue at Risk:
The single highest-risk segment is month-to-month + electronic check customers:
1,850 customers, 53.73% churn rate, $74,539 monthly revenue at risk —
more than all other segments combined.
The top 4 segments are all month-to-month contracts, accounting for the
vast majority of total revenue at risk.
Two-year contract segments (ranks 8-12) are near-negligible risk by comparison,
with the lowest segment losing only $115/month.
Retention effort should be almost entirely concentrated on month-to-month customers,
with electronic check users as the highest priority within that group.
*/



---- SECTION 5:  High-Risk Customer Flagging



-- 5.1 Write a query that flags individual customers as High Risk: month-to-month contract AND tenure < 12 months AND no TechSupport AND no OnlineSecurity
WITH flags AS (
	SELECT
		*,
		CASE 
			WHEN contract = 'Month-to-month' AND tenure < 12 AND tech_support = 'No' AND online_security = 'No' THEN 'High Risk'
		ELSE 'Low Risk' END AS customer_flag
	FROM telco
),

high_risk_flag AS (
	SELECT 
		*
	FROM flags
	WHERE customer_flag = 'High Risk'
)

-- 5.2 Count them, sum their monthly charges
SELECT 
	COUNT(*) AS total_high_risk_customers,
	SUM(monthly_charges) AS total_monthly_charges
FROM high_risk_flag;

/*
KEY FINDING — High-Risk Customer Flagging:
1,146 customers meet all four high-risk criteria: month-to-month contract,
tenure under 12 months, no TechSupport, no OnlineSecurity.
This segment represents $77,618 in monthly recurring revenue at risk —
a concrete, targetable group for proactive retention intervention.
*/