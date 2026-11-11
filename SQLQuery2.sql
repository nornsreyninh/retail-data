-- ============================================================
-- MASTER SCRIPT: RETAIL DATA CLEANUP AND LOAD
-- ============================================================

-- 0. Create and select the Database
IF DB_ID('RetailDB') IS NULL
    CREATE DATABASE RetailDB;
GO
USE RetailDB;
GO

-- ============================================================
-- 1. CREATE FINAL TYPED TABLE
-- ============================================================
IF OBJECT_ID('dbo.retail','U') IS NOT NULL 
    DROP TABLE dbo.retail;

CREATE TABLE retail (
    transaction_id    INT,
    customer_id       INT,
    name              VARCHAR(200),
    email             VARCHAR(200),
    phone             VARCHAR(50),
    address           VARCHAR(300),
    city              VARCHAR(100),
    state             VARCHAR(100),
    zipcode           VARCHAR(50),
    country           VARCHAR(100),
    age               INT,
    gender            VARCHAR(50),
    income            VARCHAR(50),
    customer_segment  VARCHAR(50),
    order_date        DATE,
    [year]            INT,
    [month]           VARCHAR(50),
    order_time        VARCHAR(50),
    total_purchases   INT,
    amount            DECIMAL(18,2),
    total_amount      DECIMAL(18,2),
    product_category  VARCHAR(100),
    product_brand     VARCHAR(100),
    product_type      VARCHAR(100),
    feedback          VARCHAR(50),
    shipping_method   VARCHAR(50),
    payment_method    VARCHAR(50),
    order_status      VARCHAR(50),
    ratings           INT,
    products          VARCHAR(200)
);
GO

-- ============================================================
-- 2. INSERT AND CONVERT DATA FROM RETAIL_CLEAN
-- This pulls from the table you successfully imported via SSMS.
-- It safely handles 'Unknown' text and strips the '.0' decimals.
-- ============================================================
TRUNCATE TABLE retail;

INSERT INTO retail
SELECT
    TRY_CAST(TRY_CAST(transaction_id AS DECIMAL(18,2)) AS INT),
    TRY_CAST(TRY_CAST(customer_id AS DECIMAL(18,2)) AS INT),
    name, 
    email, 
    phone, 
    address, 
    city, 
    state, 
    zipcode, 
    country,
    TRY_CAST(TRY_CAST(age AS DECIMAL(18,2)) AS INT),
    gender, 
    income, 
    customer_segment,
    TRY_CAST([date] AS DATE),
    TRY_CAST(TRY_CAST([year] AS DECIMAL(18,2)) AS INT),
    [month],
    [time],
    TRY_CAST(TRY_CAST(total_purchases AS DECIMAL(18,2)) AS INT),
    TRY_CAST(amount AS DECIMAL(18,2)),
    TRY_CAST(total_amount AS DECIMAL(18,2)),
    product_category, 
    product_brand, 
    product_type,
    feedback, 
    shipping_method, 
    payment_method, 
    order_status,
    TRY_CAST(TRY_CAST(ratings AS DECIMAL(18,2)) AS INT),
    products
FROM retail_clean;
GO

-- ============================================================
-- 3. VERIFY (Should return 302,006 rows)
-- ============================================================
SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(age) AS Valid_Ages,
    COUNT([year]) AS Valid_Years,
    COUNT(ratings) AS Valid_Ratings
FROM retail;
GO

--top 5 product categories by revenue
select top 5
product_category,
sum(total_amount) as Total_Revenue,
count(*) as Total_Orders
from retail
group by product_category
order by Total_Revenue Desc;
 
 -- Revenue by customer Segment
 select customer_segment,
 count(*) as Total_Orders,
 count(total_amount) as Total_revenue,
 avg(total_amount) as Avg_Order_Value
 from retail
 group by customer_segment
 order by Total_Revenue Desc;
  
 --Best Rated Brands  with at least 100 reviews
 select product_brand,
 count(ratings) as Review_count,
 cast(AVG(CAST( ratings as decimal(10,2))) AS DECIMAL(10,2)) AS Average_Rating
 from retail
 where ratings is not null
 group by product_brand
 having count(ratings)>= 100
 order by Average_Rating Desc;

 --order status vs shipping method
 select shipping_method,
 order_status,
 count(*) as Total_Orders
 from retail
 group by shipping_method,order_status
 order by shipping_method, Total_Orders Desc;
 --Monthly Revenue Trend

 select transaction_id, [year],[month], count(*) as Orders,sum(total_amount) as Revenue

 from retail
 group by  transaction_id, [year],[month]
 order by [year] , Orders desc;

SELECT COUNT(*) AS Total_Orders FROM retail;
SELECT COUNT(DISTINCT customer_id) AS Total_Customers FROM retail;
select sum(total_amount) as Revenue from retail;
select CAST(SUM(total_amount) /COUNT(*) AS DECIMAL(10,2)) from retail;

SELECT 
    customer_segment,
    SUM(total_amount) AS Revenue,
    CAST((SUM(total_amount) / (SELECT SUM(total_amount) FROM retail)) * 100 AS DECIMAL(5,2)) AS [Percentage]
FROM retail
GROUP BY customer_segment
ORDER BY Revenue DESC;
Go
SELECT TOP 5
    product_category,
    SUM(total_amount) AS Revenue
FROM retail
GROUP BY product_category
ORDER BY Revenue DESC;
Go

SELECT 
    shipping_method,
    order_status,
    COUNT(*) AS Total_Orders
FROM retail
GROUP BY shipping_method, order_status
ORDER BY shipping_method, order_status;
Go

SELECT 
    country,
    COUNT(DISTINCT customer_id) AS Total_Customers
FROM retail
GROUP BY country
ORDER BY Total_Customers DESC;