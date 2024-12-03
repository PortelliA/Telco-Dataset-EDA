# Telco Customer Churn Analysis

## Introduction
This is a personal project using data analysis techniques to create A/B testing suggestions based on the EDA. The Telco Customer Churn dataset was suggested for those new to this style of analysis. The data was sourced from [Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn).

## Dataset Summary

The Telco Customer Churn dataset is originally from IBM, given my previous experience with IBM material it was a no brainer.

- **Churn Status:** Indicates if customers left within the last month.
- **Customer Services:** Phone, multiple lines, internet, online security, online backup, device protection, tech support, streaming TV, and movies.
- **Customer Account Info:** Tenure, contract type, payment method, paperless billing, monthly charges, total charges.
- **Demographic Info:** Gender, age range, partner status, dependents.


## Data Wrangling Overview
- **Loaded and previewed data** to get an initial understanding.
- **Ensured data integrity** by verifying unique CustomerID values.
- **Checked unique values** for key categorical columns.
- **Handled missing values** in TotalCharges by filling them with 0.
- **Created ResidualCharges column** to capture differences between calculated and actual TotalCharges.
- **Renamed columns** for consistency and summarized MonthlyCharges.

## Exploratory Data Analysis (EDA) Insights

### General Trends
- **Tenure Analysis:**
  - Top 5 tenure customers are all retained, with tenure of 72 months.
  - Higher churn rates observed in customers with shorter tenures.

- **Payment Methods:**
  - Highest churn rate with Electronic check (45%).
  - Lowest churn rates with Credit card automatic (15%) and Bank transfer automatic (16%).

- **Monthly Charges Impact:**
  - Monthly charges > $90 have the highest churn rate (32%).
  - Monthly charges < $50 have the lowest churn rate (15%).

- **Contract Types:**
  - Month-to-month contracts have the highest churn rate (42%).
  - One-year (11%) and two-year (2%) contracts have lower churn rates.

- **Phone Services:**
  - The churn rate was higher for customers with a phone line (36%) compared to those without (33%). Among customers who did not churn, 90% had a phone line, while only 10% did not.

### Senior Citizens Analysis
- **Churn Contribution:**
  - Senior citizens make up 25% of all churned customers with a higher churn rate (41%).

- **Payment Methods:**
  - Higher churn rates with Electronic check (53%) and Mailed check (46%).

### Service and Billing Analysis
- **Technical Support:**
  - Customers without tech support have a churn rate of 41%; with tech support, 15%.

- **Streaming Services:**
  - Customers with both streaming TV and movies have a churn rate of 29%.
  - Customers without streaming services have a higher churn rate of 34%.

- **Paperless Billing:**
  - Paperless billing customers show a higher churn rate (33%) compared to those with paper billing (16%).

### High-Influence Combination Analysis
- **Factors:** Senior Citizen, Partner, Tech Support, Contract, Multiple Lines.
- **Zero churn combinations:** 26 different combinations created, involving 588 customers (11% of total).

### Gender-Cost Combination Analysis
- **Monthly Charges:** Most common range is $50-$90.
- **Streaming Services:** Preference for both streaming TV and movies.
- **Payment Methods:** Most common is Credit card automatic (19 times), least common is Electronic check (6 times).



## Recommendations for A/B Testing

### 1. Bundle and Discount Packages with Technical Support
- **Hypothesis:** Bundling technical support with other services at a discounted rate will reduce churn.
- **Action:** Create and promote bundled packages that include technical support to evaluate their impact on churn rates.
- **Target:** Reduce churn by 10% among customers who have technical support apart of their package.
- **Time Frame:** 6 months for implementation and evaluation.

### 2. Investigate and Address Issues with Electronic Check Payment Method
- **Hypothesis:** Addressing issues associated with electronic check payments will reduce churn among these users.
- **Action:** Conduct surveys to identify issues with electronic check payments while offering incentives to switch to more stable payment methods to those who complete the survey.
- **Target:** Reduce churn by 20% among customers using electronic check payments.
- **Time Frame:** 2 months to investigate and identify the issue. Followed by 3 months for implementing changes and evaluation.

### 3. Implement a Loyalty Program for Long-Tenure Customers
- **Hypothesis:** A loyalty program offering benefits for long-tenure customers will enhance retention.
- **Action:** Develop and promote a loyalty program that provides discounts, upgrades, or exclusive services based on customer tenure.
- **Target:** Increase retention rates by 10% among long-tenure customers.
- **Time Frame:** 12 months for program development, promotion, and evaluation.



