# Telco Customer Churn Analysis

## Introduction
This is a personal project using data analysis techniques to create A/B testing suggestions based on the EDA. The Telco Customer Churn dataset was suggested for those new to this style of analysis. The data was sourced from [Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn).

## Dataset Summary

The Telco Customer Churn dataset is originally from IBM, given my previous experience with IBM material it was a no brainer.

- **Churn Status:** Indicates if customers left within the last month.
- **Customer Services:** Phone, multiple lines, internet, online security, online backup, device protection, tech support, streaming TV, and movies.
- **Customer Info:** Tenure, contract type, payment method, paperless billing, monthly charges, total charges.
- **Demographic Info:** Gender, age range, partner status, dependents.


## Data Wrangling Overview
- **Loaded and previewed data** to get an initial understanding.
- **Ensured data integrity** by verifying unique CustomerID values.
- **Checked unique values** for key categorical columns.
- **Handled missing values** in TotalCharges by filling them with 0.
- **Created ResidualCharges column** to capture differences between calculated and actual TotalCharges.
- **Renamed columns** for consistency

  
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
  - The churn rate was slightly higher for customers with a phone line (36%) compared to those without (33%). Among customers who did not churn, 90% had a phone line, while only 10% did not.

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

## High-Influence Combination Analysis

### Factors:
- Senior Citizen
- Partner
- Tech Support
- Contract
- Multiple Lines

### Key Observations:

#### Zero Churn Combinations:
- **Count:** 26 combinations involving 588 customers (11% of total), none of whom churned.
- **Contract Type:** 
  - 2 occurrences with month-to-month contracts (4 customers).
  - 8 occurrences with 1-year contracts.
  - 16 occurrences with 2-year contracts.
- **Senior Citizens:** 
  - 20 combinations included senior citizens.
  - All month-to-month contract occurrences involved senior citizens.
- **Technical Support:** 
  - Mix of responses: 7 "Yes", 8 "No", and 11 with no internet.
- **Partner Status:** 
  - 15 with partners, 11 without partners.
  - Highest count combination: 247 with phone service, no internet, 2-year contract, and not a senior citizen.

#### High Churn Combinations:
- **Top 20 Combinations:** 
  - Month-to-month contracts dominated with 17 occurrences.
  - Even split between customers with and without partners.
  - 5 occurrences involved senior citizens.
- **Technical Support:** 
  - 12 "No", 6 "Yes", and 2 with no internet.
- **Customer Coverage:** 
  - Captures 4,103 customers (58% of total).
  - 1,529 customers who churned (81% of all churned).
- **Highest Churn Rate:** 
  - 65% for no partner, no phone service, no technical support, month-to-month, and senior citizen.
- **Highest Churn Count:** 
  - 349 for no partner, one phone line, no technical support, month-to-month, and not a senior citizen.


## Gender-Cost Combination Analysis

### Factors:
- Gender
- Partner
- StreamingTV
- StreamingMovies
- PaymentMethod
- MonthlyChargesRange: '< $50', '$50 - $90', '> $90'

### Key Observations:
- **Customer Count:** 64 observations with no combination having 0 churn.
- **Monthly Charges:** 
  - 10 instances < $50
  - 37 instances $50 - $90
  - 17 instances > $90
- **Streaming Services:**
  - Yes for both: 571 churn count
  - No for both: 695 churn count
  - Yes for StreamingMovies & No for StreamingTV: 247 churn count
  - No for StreamingMovies & Yes for StreamingTV: 243 churn count
- **Payment Methods:**
  - Electronic Check: 56% of churned customers (1056 churned)
  - Mailed Check: 12% of churned customers (237 churned)
  - Bank Transfer (automatic): 13% of churned customers (240 churned)
  - Credit Card (automatic): 12% of churned customers (233 churned)

### Data Slices:

#### Lower Churn Rate Slice (Churn Count < 40):
- **Customer Count:** 50 entries, 45% of total customers, 37% of churned.
- **Partner Status:** Having a partner occurred 29 times.
- **Payment Methods:**
  - Credit Card Automatic: Most common (19 occurrences).
  - Electronic Check: Least common (6 occurrences).
- **Monthly Charges Range:** Most common was $50 - $90 (32 times).

#### Higher Churn Rate Slice (Churn Count >= 40):
- **Customer Count:** 14 entries, 55% of total customers, 63% of churned.
- **Partner Status:** No partner occurred 8 times.
- **Payment Methods:** 
  - Electronic Check: 12 times
  - Mailed Check: 2 times
- **Monthly Charges Range:** 5 instances each of > $90 and $50 - $90, 4 instances of < $50.


### Overall Interpretation
While individual variables previously showed certain trends, combining them reveals more complex relationships. For example, in the zero churn customer group, the lack of technical support was less influential, as many combinations had no tech support. However, month-to-month contracts and the electronic check payment method consistently emerged as significant issues. With this in mind I have thought up the following three recommendations that could be tested to help reduce churn.



## Recommendations for A/B Testing

### 1. Implement a Price Reduction Scheme Based on Tenure
- **Hypothesis:** Offering a price reduction scheme based on tenure will reduce churn among month-to-month contract customers, especially in the early months.
- **Action:** Introduce a loyalty-based price reduction for month-to-month customers, where discounts increase with each month they stay subscribed, up to a certain period. This rewards early retention and encourages long-term commitment.
- **Target:** Reduce churn by 10% among month-to-month contract customers within the first year.
- **Time Frame:** 12 months for implementation and evaluation. Would need to observe the current pipeline of higher churning customers over a longer period because a 6-month window would be too short to capture actual trends and impacts.

### 2. Investigate and Address Issues with Electronic Check Payment Method
- **Hypothesis:** Addressing issues associated with electronic check payments will reduce churn among these users.
- **Action:** Conduct surveys to identify issues with electronic check payments while offering incentives to switch to more stable payment methods to those who complete the survey.
- **Target:** Reduce churn by 20% among customers using electronic check payments.
- **Time Frame:** 2 months to investigate and identify the issue. Followed by 3 months for implementing changes and evaluation.

### 3. Develop a Senior Citizen Support Program
- **Hypothesis:** Providing tailored support and benefits for senior citizens will reduce churn among this demographic.
- **Action:** Implement a specialized support program for senior citizens that includes:
  - **Dedicated Customer Service:** Offer a dedicated helpline with agents trained to assist senior citizens with any service-related issues.
  - **Discounts and Benefits:** Provide discounts on services and exclusive benefits tailored to the needs of senior citizens.
  - **Tech Support and Education:** Offer free or discounted technical support and education programs to help senior citizens utilize services more effectively.
- **Target:** Reduce churn by 15% among senior citizens.
- **Time Frame:** 12 months for implementation and evaluation. We need to observe the impact over a longer period to capture meaningful trends and outcomes.
