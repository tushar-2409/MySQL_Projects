----------------------------------------------------------- E-Commerce Churn Analysis ---------------------------------------------------------

USE e_commerce_data; 

                                                               ## Data Cleaning ##

/* Checking the glimpse of the data */
SELECT *
FROM churn_data;

/* Displaying the total number of customers in the data */
select count(customerid)
FROM churn_Data;  # There are 5630 customers in the data

/* Renaming a column */
ALTER table churn_data
rename column S to DaySinceLastOrder;

/* Checking if the data has duplicate records */
select customerid, count(customerid)
FROM churn_data
GROUP BY customerid
having count(customerid)>1;  # There are no duplicate records in the data. */

/* Checking if the data has null values. */
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM churn_data
WHERE Tenure IS NULL 
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM churn_data
WHERE warehousetohome IS NULL 
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM churn_data
WHERE hourspendonapp IS NULL
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM churn_data
WHERE orderamounthikefromlastyear IS NULL 
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM churn_data
WHERE couponused IS NULL 
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM churn_data
WHERE ordercount IS NULL 
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM churn_data
WHERE daysincelastorder IS NULL;  # As there is null values present in the data, will fill the missing values in the next step


## Filling NULL Values ##
/* AS THE COLUMNS WITH NULL VALUES ARE CONTINUOUS IN NATURE, SO FILLING THE NULL VALUES WITH THEIR RESPECTIVE MEANS */

SET @average_tenure := (
    SELECT AVG(tenure)
    FROM churn_Data
    WHERE tenure IS NOT NULL);
UPDATE churn_data
SET Tenure = coalesce(tenure, @average_tenure);

SET @average_hoursonapp := (
    SELECT AVG(HourSpendOnApp)
    FROM churn_Data
    WHERE HourSpendOnApp IS NOT NULL);
UPDATE churn_data
SET HourSpendOnApp = coalesce(HourSpendOnApp, @average_hoursonapp);

SET @average_orderamt := (
    SELECT AVG(orderamounthikefromlastyear)
    FROM churn_Data
    WHERE orderamounthikefromlastyear IS NOT NULL);
UPDATE churn_data
SET orderamounthikefromlastyear = coalesce(orderamounthikefromlastyear, @average_orderamt);

SET @average_warehouse := (
    SELECT AVG(WarehouseToHome)
    FROM churn_Data
    WHERE WarehouseToHome IS NOT NULL);
UPDATE churn_data
SET WarehouseToHome = coalesce(WarehouseToHome,@average_warehouse);

SET @average_coupon := (
    SELECT AVG(couponused)
    FROM churn_Data
    WHERE couponused IS NOT NULL);
UPDATE churn_data
SET couponused = coalesce(couponused,@average_coupon) ;

SET @average_ordercount := (
    SELECT AVG(ordercount)
    FROM churn_Data
    WHERE ordercount IS NOT NULL);
UPDATE churn_data
SET ordercount = coalesce(ordercount,@average_ordercount);

SET @average_lastorder := (
    SELECT AVG(daysincelastorder)
    FROM churn_Data
    WHERE daysincelastorder IS NOT NULL);
UPDATE churn_data
SET daysincelastorder = coalesce(daysincelastorder, @average_lastorder);  # All the null values have been replaced with their respective mean values.

										

## Handling Unwanted values from the columns.

# 1.) PreferredLoginDevice Column
UPDATE churn_data
SET preferredlogindevice = 'Mobile Phone'
WHERE preferredlogindevice = 'Phone';

SELECT DISTINCT preferredlogindevice
from churn_data;

# 2.) PreferedOrderCat
UPDATE churn_data
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

SELECT DISTINCT PreferedOrderCat
FROM CHURN_DATA;

# 3.) PreferredPaymentMode
UPDATE CHURN_DATA
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

UPDATE CHURN_DATA
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

# 4.) Warehouse To Home  
# Two ouliers are present in the column i.e 126 and 127, treating these outliers by replacing them with 26 and 27 respectively.

UPDATE churn_data
SET warehousetohome = '27'
WHERE warehousetohome = '127';

UPDATE churn_data
SET warehousetohome = '26'
WHERE warehousetohome = '126';


## Mapping the values from existing columns to new columns ##
                                                         
/* Creating new column to identify the customer status with the help of churn column which is numeric format
1 means that customer is churned, and 0 means that customer is retained */
ALTER TABLE churn_data
ADD COLUMN CustomerStatus varchar(35);
UPDATE churn_data
SET CustomerStatus = 
CASE
	WHEN churn = 1 THEN 'Churned'
    WHEN churn = 0 THEN  'Retained'
END;

/* Similarly, creating a new column to identify the customers with complaints and customers with no complaints using complain column,
where 1 means that customer has filled a complaint and 0 means that customer has no issues. */
ALTER TABLE churn_data
ADD COLUMN ComplainReceived varchar(35);
UPDATE churn_data
SET ComplainReceived = 
CASE
	WHEN COMPLAIN = 1 THEN 'Yes'
    WHEN COMPLAIN = 0 THEN 'No'
END;

/* Creating a new column to map the new values for warehousetohome */
ALTER TABLE churn_data
ADD warehousetohomerange VARCHAR(50);
UPDATE churn_data
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END;

/* Creating a new column to handle the values of tenure which are present in the numeric form */
ALTER TABLE churn_data
ADD TenureRange VARCHAR(50);
UPDATE churn_data
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END;

/* Mapping the values of cashback amount into the categories by creating a new column */
ALTER TABLE churn_data
ADD cashbackamountrange VARCHAR(50);
UPDATE churn_data
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END;


									/* Univariate Analysis */
/* Overall Customer Churn Rate */
WITH CHURN AS (SELECT COUNT(CUSTOMERSTATUS) AS Churned_customers FROM CHURN_DATA WHERE CUSTOMERSTATUS = "CHURNED"),
	 `ALL` AS (SELECT COUNT(*) AS ALL_DATA FROM CHURN_DATA)
SELECT `ALL`.ALL_DATA as TotalNumberofCustomers , CHURN.Churned_customers as TotalNumberofChurnedCustomers, 
		CONCAT(ROUND(CHURN.Churned_customers/`ALL`.ALL_DATA*100,2),'%') as Churn_Rate
FROM CHURN, `ALL`;   # There is a Churn_Rate of 16.84% in the data.


/* Gender Share in the data */
SELECT 
	concat(round(sum(CASE WHEN Gender="Male" THEN 1 ELSE 0 END)/count(Gender)*100,0),"%") as Male_Share,
	concat(round(sum(CASE WHEN Gender="Female" THEN 1 ELSE 0 END)/count(Gender)*100,0),"%") as Female_Share
FROM churn_data; # The split of gender in the data is of 60% (Males) and 40% (Females)

  
/* Percentage of various Preferred Payment Mode */
SELECT 
    	concat(round(sum(CASE WHEN PreferredPaymentMode="Debit Card" THEN 1 ELSE 0 END)/count(PreferredPaymentMode)*100,0),"%") as Debit_Card,
    	concat(round(sum(CASE WHEN PreferredPaymentMode="Credit Card" THEN 1 ELSE 0 END)/count(PreferredPaymentMode)*100,0),"%") as Credit_Card,
      concat(round(sum(CASE WHEN PreferredPaymentMode="Cash on Delivery" THEN 1 ELSE 0 END)/count(PreferredPaymentMode)*100,0),"%") as Cash_on_Delivery,
      concat(round(sum(CASE WHEN PreferredPaymentMode="UPI" THEN 1 ELSE 0 END)/count(PreferredPaymentMode)*100,0),"%") as UPI,
      concat(round(sum(CASE WHEN PreferredPaymentMode="E Wallet" THEN 1 ELSE 0 END)/count(PreferredPaymentMode)*100,0),"%") as E_Wallet
FROM churn_data; # Highest Preferrence rate in Payment Mode is given to Debit Card by the customers (41% Approx)
 
  
/* Rate of Marital Status */
SELECT 
	concat(round(sum(CASE WHEN MaritalStatus="Single" THEN 1 ELSE 0 END)/count(Gender)*100,0),"%") as Single,
	concat(round(sum(CASE WHEN MaritalStatus="Divorced" THEN 1 ELSE 0 END)/count(Gender)*100,0),"%") as Divorced,
    concat(round(sum(CASE WHEN MaritalStatus="Married" THEN 1 ELSE 0 END)/count(Gender)*100,0),"%") as Married
FROM churn_data;  # Approx 32% of the customers are single, while 15% are Divorced and 53% of the customers are Married.

  
/* Rate of customers who have filed a complaint and those who haven't */
SELECT 
	concat(round(sum(CASE WHEN Complain=1 THEN 1 ELSE 0 END)/count(Gender)*100,0),"%") as Complain,
	concat(round(sum(CASE WHEN Complain=0 THEN 1 ELSE 0 END)/count(Gender)*100,0),"%") as Didnot_Compalin
FROM churn_data; # Approx 28% of the customers have filled a complain against the services provided by the company while the rest (72%) Didn't complain



                                                                   /* Bivariate Analysis */
/* Churn rate based on the preferred login device */
SELECT preferredlogindevice, 
        COUNT(*) AS TotalCustomers,
        sum(churn) AS ChurnedCustomers,
        CAST(sum(churn)/ COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM churn_data
GROUP BY preferredlogindevice; # Computer has the high churn rate as compared to mobile phone, This can indicate that customers who use computer as their
                               # Preferred login device have different usage patterns or preferences.

  
/* Distribution of Churned customers accross different city tiers. */
SELECT citytier, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY citytier; # Customers from City Tier 3 and 2 are the ones who have high churn rate i.e 21.37 and 14.51 respectively
				   # as compared to customers belonging city tier 1. This shows that city tier 3 and 2 refers to smaller towns and have less development

  
/* Checking if there is any correlation between distance from warehouse to home and churn rate. */
SELECT warehousetohomerange, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRates
FROM churn_data
GROUP BY 1
ORDER BY 4 desc;  # This shows that there is a direct positive relation between the warehouse to home distance and churn rate.
                  # As the distance from warehouse to home increases, the churn rate also tend to increase. This could mean that the company lacks in 
				  # delivering the products to the customers who live far away. 

  
/* Churned rates with respect to preferred payment mode. */
SELECT PreferredPaymentMode, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc; # Here, customers who prefer to use COD and E-wallet as their payment mode tend to have the higher churn rate as compared to customers 
                 # Using other payment modes.

  
/* Churned Rates as per the Tenure of the Customer. */
SELECT TenureRange, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc; # Here, customers who are with the company for two or more years have very low churn rates as compared to those who are with the company for about 6 months.

  
/* Difference in churn rates between male and female customers */
SELECT Gender, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc; # There is very slight difference in the churn rate between male and female customers. This could infer that gender might not be the reason for the churn.


# Average time spent on the companys app among churned customers and retained customers
SELECT CustomerStatus, round(avg(HourSpendOnApp)) as AverageHourSpentonApp
FROM churn_data
GROUP BY 1; # For Churned as well as Retained customers, average hour spent on app is the same i.e 3 hours. This indicates that the average app usage time
            # might not be the factor affecting the churn rates. 

  
/* Customer Churn Rate with respect to Number of Devices Registered. */
SELECT NumberOfDeviceRegistered, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc; # There seems to be a positive relation between the number of devices registered and the churn rates. 
                 # As the number of devices registered increases, the churn rate also increases.

  
/* Checking if Preferred order category affects the churn rates */
SELECT PreferedOrderCat, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc; # Mobile Phone as the preferred order category has the highest churn rates as compared to other categories
                 # This might be due to several reasons such as company is not maintaining the regular stocks of Mobile Phones or some specific models
                 # That the customers are interested in are not available with the company.

  
/* Customer Churn rates with respect to Satisfaction Score */
SELECT SatisfactionScore, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc; # Here, customers with higher satisfaction score have the higher churn rates as compared to the customers with low satisfaction rate.
                 # This highlights that the company should focus on retention strategies for all satisfaction levels. 

  
/* Checking if Marital Status has any effect on churn rates */
SELECT MaritalStatus, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc; # Customers who are single have the highest churn rate, while the divorced and married customers have lower churn rates

  
/* Checking if there is any difference between average number of address between the churned customers and retained customers. */
SELECT customerstatus, round(AVG(numberofaddress)) AS Averagenumofchurnedcustomeraddress
FROM churn_data
GROUP BY 1; # Both customers (Churned & Retained) have the same average number of address i.e 4)

  
/* Checking if customer comaplains have an impact on the churn rates */
SELECT ComplainReceived, count(*) as TotalCustomers, sum(churn) as ChurnedCustomers, round(sum(churn)/count(*)*100,2) as ChurnedRate
FROM churn_data
GROUP BY 1
order by 4 desc;
# For obvious reason if, the customers would have compalins from the company, the customer would get churned. Here, churn rate is much higher for the customers
# Who have complains from the company, the churn rate is approx. 32. This might be the most important factor that is affecting the churn rate.

  
/* Does the use of coupons differ between churned and non-churned customers? */
SELECT customerstatus, SUM(couponused) AS SumofCouponUsed
FROM churn_data
GROUP BY customerstatus;
# The higher amount of Coupon is used by the customers who are retained in the company. By implementing strategies or encouraging the churned customers to use more
# Coupons might result in lowering the churn rates.

  
/* Checking if there is any correlation between cashback amount and the churn rates. */
SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM churn_data
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC;
#Customers who received moderate cashback amounts had a relatively higher churn rate, 
# while those who received higher and very high cashback amounts exhibited lower churn rates. This suggests that offering a high cashback amount can help in reducing
# the churn rates.


/*                                                              ## Insights ##

- The dataset includes 5,630 customers, providing a substantial sample size for analysis.

- The overall churn rate is 16.84%, indicating significant customer attrition.

- The share of the gender is 60% (Males) and 40% (Females).

- There is a high preferrence given to Debit Cards while making the payment by the customers (Approx 41%).

- Customers who prefer logging in with a computer have slightly higher churn rates compared to phone users, suggesting different usage patterns and preferences.

- Tier 1 cities have lower churn rates than Tier 2 and Tier 3 cities, possibly due to competition and customer preferences.

- Proximity to the warehouse affects churn rates, with closer customers showing lower churn, highlighting the importance of optimizing logistics and delivery strategies.

- “Cash on Delivery” and “E-wallet” payment modes have higher churn rates, while “Credit Card” and “Debit Card” have lower churn rates, 
   indicating the influence of payment preferences on churn.
   
- Longer tenure is associated with lower churn rates, emphasizing the need for building customer loyalty early on.

- Male customers have slightly higher churn rates than female customers, although the difference is minimal.

- App usage time does not significantly differentiate between churned and non-churned customers.

- More registered devices correlate with higher churn rates, suggesting the need for consistent experiences across multiple devices.

- “Mobile Phone” order category has the highest churn rate, while “Grocery” has the lowest, indicating the importance of tailored retention strategies for specific categories.

- Highly satisfied customers (rating 5) have a relatively higher churn rate, highlighting the need for proactive retention strategies at all satisfaction levels.

- Single customers have the highest churn rate, while married customers have the lowest, indicating the influence of marital status on churn.

- Churned customers have an average of four associated addresses, suggesting higher mobility.

- Customer complaints are prevalent among churned customers, emphasizing the importance of addressing concerns to minimize churn.

- Coupon usage is higher among non-churned customers, showcasing the effectiveness of loyalty rewards and personalized offers.

- Churned customers have had a short time since their last order, indicating recent disengagement and the need for improved customer experience and retention initiatives.

- Moderate cashback amounts correspond to higher churn rates, while higher amounts lead to lower churn, suggesting the positive impact of higher cashback on loyalty. */




