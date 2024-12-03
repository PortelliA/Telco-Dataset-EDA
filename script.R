setwd("C:/Users/alexa/OneDrive/Documents/telcom")
library(tidyverse)
telco_data <- read.csv("WA_Fn-UseC_-Telco-Customer-Churn.csv")
summary(telco_data)
# 21 different columns, 11 NA's in total charges, 17 of the columns are characters, I'll check customer ID column first to ensure all unique & then dive further
customer_id_dupes <- !any(duplicated(telco_data$customerID))
print(customer_id_dupes)
# answer came back true, so all columns are unique
unique(telco_data$gender)
# gender is 1 of 2 options being Male or Female
unique(telco_data$Partner)
# 2 options yes or no
unique(telco_data$Dependents)
# once again 2 answers yes or no
unique(telco_data$PhoneService)
# yes or no
unique(telco_data$MultipleLines)
# 3 options, No phone service, no & yes
unique(telco_data$InternetService)
# DSL, Fiber optic or no
unique(telco_data$OnlineSecurity)
# No, yes
unique(telco_data$OnlineBackup)
# Yes, no, no internet service
unique(telco_data$DeviceProtection)
unique(telco_data$TechSupport)
unique(telco_data$StreamingTV)
unique(telco_data$StreamingMovies)
# All these following columns had same values, what I need to check now is if internet is No, then do the rest of the columns have values that align with this
unique(telco_data$Contract)
check_internet <- telco_data[telco_data$InternetService == "No", c("OnlineSecurity", "OnlineBackup", "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies")]
unique(check_internet)
# All values are "No internet service" great, also a bit early but because it filtered by "no" there are 1,526 customers with no internet
unique(telco_data$Contract)
# Month-to_month, One year or Tow year
unique(telco_data$PaperlessBilling)
# Only yes or no
unique(telco_data$PaymentMethod)
# Electronic check, mailed check, Bank transfer (Automatic) or Credit card (automatic)
unique(telco_data$Churn)
# yes or no
# A collumn that is similiar is Senior citizen, which is an indicator column I presume as its min and max was 0,1
unique(telco_data$SeniorCitizen)
# Sure is, the remaining collumns I have are tenure, monthly charges and total charges, first I want to ensure all of tenure values are whole numbers
whole_numbers <- all(telco_data$tenure %% 1 == 0)
print(whole_numbers)
# Nice its true, now to check the 11 NA's in total charges
na_totals <- telco_data[is.na(telco_data$TotalCharges), ]
print(na_totals)
# Answer is simply being their tenure is, 0 so new customers. I'll apply 0 to the columns and then ensure the column tenure * monthly charge = total charge
telco_data$TotalCharges[is.na(telco_data$TotalCharges)] <- 0
summary(telco_data$TotalCharges)
# No more NA's
telco_data$calculate <- telco_data$tenure * telco_data$MonthlyCharges
equaldata <- all.equal(telco_data$calculate, telco_data$TotalCharges, tolerance = 0)
print(equaldata)
# There is a difference of 0.01978869, this could be installation charges, one off charges related to late payment or even discounts. 
# All of which we can explore in SQL, but I'll need to make the calculated column the difference
telco_data <- telco_data %>%
  mutate(ResidualCharges = TotalCharges - calculate) %>%
  select(-calculate)
summary(telco_data$ResidualCharges)
# min = -370.850, Q1 = -28.6, median = 0, mean = 0.153, Q3 = 28.5 & max = 373.25. 
# As we can see its a mixture of all most likely with discounts/additional charges and such
telco_data <- telco_data %>% 
  rename(CustomerID = customerID,
         Gender = gender,
         Tenure = tenure)

# that finalises data wrangling, quick summaries then SQL
summary(telco_data$MonthlyCharges)
# min is $18.25, Q1 is $35.50, Median is $70.35, Mean is $64.76, Q3 is $89.85 and max is $118.75
sum(telco_data$Gender == "Male")
sum(telco_data$Gender == "Female")
# 3,555 for male, 3488 for female
summary(telco_data$Tenure)
# Tenure is being measured in months, range is 0 - 72. Median is 29 Q1/Q3 are 9 and 55 with a median of 32.37, so skewed to the lower end
sum(telco_data$Contract == "Month-to-month")
sum(telco_data$Contract == "One year")
sum(telco_data$Contract == "Two year")
# Month to month contracts are 3,875, 1 year are 1,473 & 2 year contracts are 1,695 


library(RSQLite)
library(DBI)
con <-dbConnect(SQLite(), dbname = "my_database.sqlite")
# For customer ID because its unique ill make that the primary key(in my case its not needed as I'll only ever measure this data against itself. But good habit and realistically this is what would happen internally for telco employee's
# Customer ID, payment method & contract will be VARCHAR because customer id has mix of number and letters, while payment method has (automatic) not sure how () is treated in SQL & Contract has - within row values
dbExecute(con, "CREATE TABLE telco_data(
          customerID VARCHAR(15) PRIMARY KEY,
          Gender TEXT,
          SeniorCitizen INT,
          Partner TEXT,
          Dependents TEXT,
          Tenure INT,
          PhoneService TEXT,
          MultipleLines TEXT,
          InternetService TEXT,
          OnlineSecurity TEXT,
          OnlineBackup TEXT,
          DeviceProtection TEXT,
          TechSupport TEXT,
          StreamingTV TEXT,
          StreamingMovies TEXT,
          Contract VARCHAR(15),
          PaperlessBilling TEXT,
          PaymentMethod VARCHAR(15),
          MonthlyCharges REAL,
          TotalCharges REAL,
          Churn TEXT,
          ResidualCharges REAL
          )")
dbWriteTable(con, "telco_data", telco_data, overwrite = TRUE, row.names = FALSE)



# Find top 5 tenure customers, find there customer ID, tenure duration, gender, monthly charge, churn status & payment method
top5bytenure <- dbGetQuery(con, "SELECT CustomerID,
                           Tenure, Gender, MonthlyCharges,
                           Churn, PaymentMethod
                           FROM telco_data
                           ORDER BY Tenure DESC LIMIT 5;")
print(top5bytenure)
# All 5 customers have 72 month tenure, 3 of which are male and 2 are female. Monthly charges 4 entries are between $90.25 and $107.5 while one is $42.1
# All methods are (automatic) but 3 are Bank Transfer & 2 Credit Card, all customers were retained




# What is the distribution of tenure between customers who have "churned" and still retained
tenurebucketCHURNED <- dbGetQuery(con, "SELECT CASE
                                 WHEN Tenure < 6 THEN 'Under 6 months'
                                 WHEN Tenure < 12 THEN '6-12 months'
                                 WHEN Tenure < 24 THEN '12-24 months'
                                 WHEN Tenure < 48 THEN '24-48 months'
                                 ELSE 'Over 48 months'
                                 END AS Tenure_Group,
                                 COUNT(*) AS Customer_Count
                                 FROM telco_data
                                 WHERE Churn = 'Yes'
                                 GROUP BY Tenure_Group
                                 ORDER BY Customer_Count DESC;")
print(tenurebucketCHURNED)
# Under 6 months = 744, 6-12 months = 255, 12-24 = 309, 24-48 = 339, over 48 = 222
744 + 255 + 309 + 339 + 222
# 1,869 total, this is the count of all churned in the last month


tenuredbucketRETAINED <- dbGetQuery(con, " SELECT CASE
                                    WHEN Tenure < 6 THEN 'Under 6 months'
                                    WHEN Tenure < 12 THEN '6-12 months'
                                    WHEN Tenure < 24 THEN '12-24 months'
                                    WHEN Tenure < 48 THEN '24-48 months'
                                    ELSE 'Over 48 months'
                                    END AS Tenure_Group,
                                    COUNT(*) AS Customer_Count
                                    FROM telco_data
                                    Where Churn = 'No'
                                    GROUP BY Tenure_Group
                                    ORDER BY Customer_Count DESC;")
print(tenuredbucketRETAINED)                                    
# Under 6 months = 627, 6-12 months = 443, 12-24 months = 738, 24-48 months = 1,285, over 48 months = 2,081
627 + 443 + 738 + 1285 + 2081
# 5,174 total, this is the total amount of retained customers




# Whats the distribution split between churned customers payment method 
paymentmethodCHURNED <- dbGetQuery(con, "SELECT PaymentMethod,
                                   COUNT(*) AS Total_Customers,
                                   SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Count,
                                   (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_Rate
                                   FROM telco_data
                                   GROUP BY PaymentMethod;")
print(paymentmethodCHURNED)
# Bank transfer(automatic) = 1,544 total customers, 258 churned at 16%
# Credit card (automatic) = 1,522 total customers, 232 churned at 15%
# Electronic check = 2,365 total customers, 1,071 churned at 45%
# Mailed check = 1,612 total customers, 308 churned at 19%




# Seeing as roughly the range is 0-100 (min was 18 and max 118), find churn in 3 brackets of monthly charge
monthlychargeIMPACT <- dbGetQuery(con, "SELECT CASE
                                  WHEN MonthlyCharges < 50 THEN '< $50'
                                  WHEN MonthlyCharges BETWEEN 50 AND 90 THEN '$50-$90'
                                  ELSE '> $90' END AS MonthlyChargesRange,
                                  COUNT(*) AS Customer_count,
                                  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churn_count,
                                  (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                                  FROM telco_data
                                  GROUP BY MonthlyChargesRange;")
print(monthlychargeIMPACT)
# 2,294 customers fall into the < $50 bracket, 361 churned at 15%
# 3,010 customers fall into the $50-$90 bracket, 938 churned at 31%
# 1,739 customers fall into the > $90 bracket, 570 churned at 32%




# Whats the distribution split between churned customers contract types
contracttypeCHURNED <- dbGetQuery(con, "SELECT Contract,
                                  COUNT(*) AS Total_Customers,
                                  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Count,
                                 (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) *  100) / COUNT(*) AS Churn_Rate
                                  FROM telco_data
                                  GROUP BY Contract;")
print(contracttypeCHURNED)
# Distribution goes Month to month = 3,875 with 1,655 churned, 42%
# One year 1,473 with 166 churned, 11%
# Two year 1,695 with 48 churned, 2%





# whats the breakdown of customer with phone services and which left
phoneserviceBREAKDOWN <- dbGetQuery(con, "SELECT PhoneService, Churn,
                                    COUNT(*) AS Customer_Count
                                    FROM telco_data
                                    Group BY PhoneService, Churn;")
print(phoneserviceBREAKDOWN)
# Distribution goes as such: When customer doesn't have phone service and current = 512
# When customer doesn't have phone service and churned = 170
170 / 512 * 100
# 33% of customers without a phone churned
# When customer does have phone service and current = 4,662
# When customer does have phone service and churned = 1,699
1699 / 4662 * 100
# 36% of customers with a phone line churned, hard to say it has an impact
512 / 5174 * 100
# nearly 10%
4662 / 5174 * 100
# a bit over 90%, having a phone line is alot more common

# Whats the distribution split of Senior citizen counts and which left
seniorcitizenBREAKDOWN <- dbGetQuery(con, " SELECT SeniorCitizen, Churn,
                                    Count(*) AS Customer_Count
                                    FROM telco_data
                                    WHERE SeniorCitizen = 1
                                    GROUP BY SeniorCitizen, Churn;")
print(seniorcitizenBREAKDOWN)
# Senior citizen's retained = 666 & churned = 476
666 + 476
# 1,142 senior citizens in data
476 / 1869 * 100
# 25% of churned customers were senior citizen
476 / 1142 * 100
# 41% of senior citizen's churned
1142 / 7043 * 100
# While only  contributing 16% of the customer base




# Considering Payment Method Electronic check has a high churn rate, do we see this within senior citizens?
seniorcitizenPAYMENT <- dbGetQuery(con, "SELECT PaymentMethod,
                                   COUNT(*) AS Senior_Customers,
                                   SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Seniors,
                                   (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_Rate
                                   FROM telco_data
                                   WHERE SeniorCitizen = 1
                                   GROUP BY PaymentMethod;")
print(seniorcitizenPAYMENT)
# Count for Bank transfer (automatic) was 233, 53 seniors churned at 22%
# Count for Credit card (automatic) was 221, 62 seniors churned at 28%
# Count for Electronic check was 594, 317 seniors churned at 53%
# Count for Mailed check was 94, 44 seniors churned at 46%
94 / 1612 * 100
# Senior customers contributed only 5.8% to total number of Mailed check method of payment in database
594 / 2365 * 100
# Seniors contributed 25% to electronic check method in database
221 /1552 *  100
# Seniors contribute 14% to Credit card (automatic) method in the database
233 / 1544 * 100 
# Seniors contribute 15% to Bank transfer (automatic) method in the database



# Following on payment methods, is there a method that has more residual charges evident for seniors
paymentmethodRESIDUAL <- dbGetQuery(con, "SELECT PaymentMethod,
                                    CASE
                                    WHEN ResidualCharges > 0 THEN 'Yes'
                                    ELSE 'No'
                                    END AS Has_Residual_Charge,
                                    COUNT(*) AS Customer_Count,
                                    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_count,
                                    (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_Rate
                                    FROM telco_data
                                    WHERE SeniorCitizen = 1
                                    GROUP BY PaymentMethod, Has_Residual_Charge;")
print(paymentmethodRESIDUAL)
# All results had lower percentage of churn in senior customers with residual. Doesn't seem to be an influence



# What is the impact of residual charges on customer churn rate overall
residualchargeIMPACT <- dbGetQuery(con, "SELECT CASE
                                   WHEN ResidualCharges > 0 THEN 'Yes'
                                   ELSE 'No'
                                   END AS Has_Residual_charge,
                                   Churn,
                                   COUNT(*) AS Customer_count
                                   FROM telco_data
                                   GROUP BY Has_Residual_Charge, Churn;")
print(residualchargeIMPACT)
# No residual charge + retained = 2,708, No residual charge + churned = 1,131
# Residual charged + retained = 2,466, residual charged + churned = 738
# It's hard to say additional fee's have an impact, I'll run the same query but filter by contract




residualchargeCONTRACT <- dbGetQuery(con, "SELECT CASE
                                  WHEN ResidualCharges > 0 THEN 'Yes'
                                  ELSE 'No'
                                  END AS Has_Residual_charge,
                                  churn, Contract,
                                  COUNT(*) AS Customer_count
                                  FROM telco_data
                                  GROUP BY Has_Residual_charge, Churn, Contract;")
print(residualchargeCONTRACT)
# The only contract type to have higher churn when has residual charge is One year contract with 79 for no residual and 87 for residual
# I don't think any assumptions can be made




# Tech support breakdown, when customers opt for technical support does it help retain?
techsupportIMPACT <- dbGetQuery(con, " SELECT TechSupport,
                                COUNT(*) AS Total_Customers,
                                SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_count,
                                (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                                FROM telco_data
                                GROUP BY TechSupport;")
print(techsupportIMPACT)
# Customers who don't opt for technical support have a total count of 3,473, 1,446 churned at 41%
# Customers with no internet we already know account for 1,526, 113 churned at 7%
# Customers with technical support had a count of 2,044, 310 churned at 15%
1449 / 1869 * 100
# 77% of all customers who churned had no technical support




# streaming services, what is the count and does it impact churn
streamingIMPACT <- dbGetQuery(con, "SELECT StreamingTV, StreamingMovies,
                              COUNT(*) AS Total_Customers,
                              SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_count,
                              (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                              FROM telco_data
                              GROUP BY StreamingTV, StreamingMovies;")
print(streamingIMPACT)
# No streaming for TV or Movies Count was 2,018, 695 churned at 34%
2018 / 7043 * 100
# 28.6% of customers
# No streaming for TV but stream for Movies Count was 792, 247 churned at 31%
792 / 7043 * 100
# 11.2% of customers
# Streaming of TV but not Movies count was 767, 243 churned at 31%
767 / 7043 * 100
# 10.8% of customers
# Streaming of both TV and Movies count was 1,940, 571 churned at 29%
1940 / 7043 * 100
# 27.5% of customers
# Customers with no internet make up the rest which we already know.




# What does the breakdown of paperless billing look like
paperlessIMPACT <- dbGetQuery(con, "SELECT PaperlessBilling,
                              COUNT(*) AS Total_Customers,
                              SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_count,
                              (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                              FROM telco_data
                              GROUP BY PaperlessBilling;")
print(paperlessIMPACT)
# Customers who have paper billing are 2,872, 469 churned at 16%
# Customers who are paperless billing are 4,171, 1,400 churned at 33%
# Realistically with what has been queried, I don't necessarily think paperless is an impact but more of a correlating factor, just a result of everything else.




# What is the counts of male & female & their churn rate in the data set
genderIMPACT <- dbGetQuery(con, "SELECT Gender,
                           COUNT(*) AS Total_Customers,
                           SUM(CaSE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) As Churned_count,
                           (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) as Churn_rate
                           FROM telco_data
                           GROUP BY Gender;")
print(genderIMPACT)
# Female total customers are 3,488, 939 churned at 26%
# Male total customers are 3,555, 930 churned at 26%
# Even distribution, now Dependents




dependentsBREAKDOWN <- dbGetQuery(con, "SELECT Dependents,
                                  COUNT(*) AS Total_customers,
                                  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_count,
                                  (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) as churn_rate
                                  FROM telco_data
                                  GROUP BY Dependents;")
print(dependentsBREAKDOWN)
# customers with no dependents count was 4,933, 1,543 churned at 31%
# customers with dependents count was 2,110, 326 churned at 15%
# while on this, add contract terms to see if correlation can be seen



dependentscontracts <- dbGetQuery(con, "SELECT Dependents, Contract,
                                   COUNT(*) AS Total_customers,
                                   SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as Churned_count,
                                   (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) as Churn_rate
                                   FROM telco_data
                                   GROUP BY Dependents, contract;")
print(dependentscontracts)
# The churn rate depending on the contract aligns a lot with the rate previously need, but the different is seen in the contracts.
# Customers with no dependents on month to month contract count was 3,086, one year 942 and 905 for 2 yeas.
# Where customers with dependents on month to month contract count was 789, 531 for 1 year and 790 for 2 years
# The popularity of month to month is x3 more popular than the other contracts with no dependents
# While popularity of month to month apposed to 2 year contract is virtually the same for customers with dependents.






# Check the distribution of Online Security, Protection & backup & churn rate - excluding option 'No internet service' from search
SecurityProtectionBackup <- dbGetQuery(con, "SELECT OnlineSecurity, DeviceProtection,
                                       OnlineBackup, COUNT(*) AS Total_customers,
                                       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churn_count,
                                       (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                                       FROM telco_data
                                       WHERE OnlineSecurity != 'No internet service'
                                       AND DeviceProtection != 'No internet service'
                                       AND OnlineBackup != 'No internet service'
                                       GROUP BY OnlineSecurity, DeviceProtection, OnlineBackup;")
print(SecurityProtectionBackup)
# First column with No for all 3 options(No internet service) shows the highest churn rate at 52%, while customers with all three have the least with 7% churn rate
# Churn rate of customers with 1/3 of the options have churn rate between 24-38%
# Churn rate of customers with 2/3 of the options have a churn rate between 13-26%






# Popularity of Internet type with Streaming TV & Movies column for customers with customers & dependents
entertainmentSOCIO <- dbGetQuery(con, "SELECT Partner, Dependents,
                                 StreamingTV, StreamingMovies, InternetService,
                                 SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churn_count,
                                 (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                                 FROM telco_data
                                 GROUP BY Partner, Dependents, InternetService, StreamingTV, StreamingMovies;")
print(entertainmentSOCIO)
# Customers with partners show less churn rate when it comes to the multiple combinations
# Customers without internet show significantly less churn rate between 3-11%
# Fiber optic users with no Partners & no streaming services have the highest churn rate of 51%
# Fiber optic users in general have higher churn rate that DSL customers




# Senior Citizens, Partner, Tech support & Contract seem to be highly influential on churn, combine together with multiple lines to see phone usage in the mixture
highinfluencecombination <- dbGetQuery(con, "SELECT Partner, MultipleLines,
                                       TechSupport, Contract, CASE
                                       WHEN SeniorCitizen = 1 THEN 'Yes' ELSE 'No' END as Senior_Citizen,
                                       COUNT(*) AS Customer_Count,
                                       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churn_count, 
                                       (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                                       FROM telco_data
                                       GROUP BY Partner, MultipleLines, Contract, TechSupport, Senior_citizen;")
print(highinfluencecombination)
# This combination breakdown the data in 93 rows
HICsummary1 <- highinfluencecombination %>% 
  filter(Churn_count == 0)
print(HICsummary1)
# 26 combinations when customers didn't churn, only 2 occurrences on month to month contract, but the added count is only 4 customers.
# 20 combinations the customer was a senior citizen and includes the only occurrences of month to month contract
# The total customers in this combination are 588
588 / 5174 * 100
# This combination on shows 11% of the customers, non of which churned
# There were 8 occurrences of 1 year contract, 16 for 2 year contracts
# Technical Support had a mix response of 7 "yes", 8 for "no" and 11 with no internet, which shows variability as having technical support previously was shown to lower churn
# With the 1 year contract 5 instances with internet, 3 instances without internet
# With the 2 year contract 11 instances with internet & five instances without internet
# Occurrences of no partner was 11 and 15 for with partner, with partner had the highest count combination. 247 with phone service, no internet, 2 year contract and not senior citizen.
HICsummary2 <- highinfluencecombination %>% 
  arrange(desc(Churn_count)) %>% 
  slice_head(n = 20)
print(HICsummary2)
# Month-to-month contract type dominant with 17 occurrences in the top 20, even split between customers with and without Partners
# 5 out of the 20 occurrences are Senior Citizens.
# Technical Support breakdown is 12 for "No", 6 for "Yes" and 2 occurrences of "No internet".
# This slice of Data captures 4,103 of the customer base & 1529 of those who churned
1529 / 1869 * 100
4103 / 7043 * 100
# It captures 81% of all customers who churned & 58% of all the customers
# Highest churn rate of 65% was No Partner, No phone service, No Technical support, month-to-month & senior Citizen.
# Highest churn count of 349 was No Partner, 1 phone line, No Technical support, month-to-month & not a senior citizen




# Gender split was a nearly 50/50 split previously for churn, see if you can spot any differences using other variables 
gendercostcombination <- dbGetQuery(con, "SELECT Gender, Partner,
                                    StreamingTV, StreamingMovies, 
                                    PaymentMethod, CASE
                                    WHEN MonthlyCharges < 50 THEN '< $50'
                                    WHEN MonthlyCharges BETWEEN 50 AND 90 THEN '$50 - $90'
                                    ELSE '> $90' END AS MonthlyChargesRange,
                                    COUNT(*) AS Customer_count,
                                    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churn_Count,
                                    (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Churn_rate
                                    FROM telco_data
                                    WHERE StreamingTV != 'No internet service'
                                    AND StreamingMovies != 'No internet service'
                                    GROUP BY Gender, Partner, StreamingTV, StreamingMovies, PaymentMethod;")
print(gendercostcombination)
#No combination had 0 churn with a total of 64 observations
sum(gendercostcombination$MonthlyChargesRange == "< $50")
sum(gendercostcombination$MonthlyChargesRange == "$50 - $90")
sum(gendercostcombination$MonthlyChargesRange == "> $90")
# 10 instances were < $50, 37 instances of between $50-$90 & 17 instances were > $90
sum(gendercostcombination$Churn_Count[gendercostcombination$StreamingMovies == "Yes" & gendercostcombination$StreamingTV == "Yes"])
# The combination of Yes for both streaming services with a total of 571 churn count
sum(gendercostcombination$Churn_Count[gendercostcombination$StreamingMovies == "No" & gendercostcombination$StreamingTV == "No"])
# The combination of No for both streaming services with a total of 695 churn count
sum(gendercostcombination$Churn_Count[gendercostcombination$StreamingMovies == "Yes" & gendercostcombination$StreamingTV == "No"])
# The combination of Yes for StreamingMovies & No for StreamingTV had a churn count of 247
sum(gendercostcombination$Churn_Count[gendercostcombination$StreamingMovies == "No" & gendercostcombination$StreamingTV == "Yes"])
# The combination of No for StreamingMovies & Yes for StreamingTV had a churn count of 243
sum(gendercostcombination$Churn_Count[gendercostcombination$PaymentMethod == "Electronic check"])
1056 / 1869 * 100
# Electronic check accounts for 56% of the churned customers in this combination, with a count of 1056
sum(gendercostcombination$Churn_Count[gendercostcombination$PaymentMethod == "Mailed check"])
237 / 1869 * 100
# Mailed check accounts for 12% of the churned customers in this combination, with a count of 237
sum(gendercostcombination$Churn_Count[gendercostcombination$PaymentMethod == "Bank transfer (automatic)"])
240 / 1869 * 100
# Bank transfer automatic accounts for nearly 13% of the churned customers in this combination, with a count of 240
sum(gendercostcombination$Churn_Count[gendercostcombination$PaymentMethod == "Credit card (automatic)"])
233 / 1869 * 100
# Credit card automatic accounts for 12% of the churned customers in this combination, with a count of 233
GCCsummary1 <- gendercostcombination %>% 
  filter(Churn_Count < 40)
print(GCCsummary1)
# This data slice has exactly 50 entries where churn count was under 40, it has an even split of 25 per gender.
# Having a partner occurred 29 times, 11 no partner for female and 10 for male
# Credit card Automatic occurred the most with 19 occurrences. 12 for male, 7 for female
# Electronic check occurred the least with 6 occurrences, 1 for female and 5 for male
# The most common monthly charge range was $50-$90 32 times, only 1 of those occurrences was electronic check
sum(GCCsummary1$Customer_count)
3194 / 7043 * 100
# This slice includes 3194 of the customer base which is 45% of all customers
sum(GCCsummary1$Churn_Count)
694 / 1869 * 100
# It includes 694 customers who churned and is 37% of all that churned
GCCsummary2 <- gendercostcombination %>% 
  filter(Churn_Count >= 40)
print(GCCsummary2)
# This includes the last 14 observations where churn count was 40 or higher, once again an even split between male and female.
# Having no partner occurred 8 times while having a partner occurred 4 times.
# Only Electronic Check and Mailed Check appear in this slice, 12 times for electronic and 2 for mailed.
# There are 5 occurrences of > $90 & $50-$90 occurrence. 4 occurrences of < $50
summary(GCCsummary2$Churn_rate)
#The churn rate is between 32% and 59%, it has a customer count of 3,849(55%) & 1,175(63%) of the churned customers.
# The occurrence of "No" to streaming movies or TV was 6 & "Yes" for both occurred 4 times. Having "Yes for one and "No" for other appeared 2 times for each.


dbDisconnect(con)
write.csv(telco_data, "telco_customer_churn_clean.csv", row.names = FALSE)
write.csv(highinfluencecombination, "HIC_churn.csv", row.names = FALSE)
write.csv(gendercostcombination, "GCC_churn.csv", row.names = FALSE)
