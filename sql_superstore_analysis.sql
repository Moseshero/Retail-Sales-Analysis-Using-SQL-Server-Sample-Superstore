/*
PROJECT: Retail Sales & Customer Analytics
DATABASE: RetailSalesDB
PLATFORM: Microsoft SQL Server / SSMS
SOURCE: Sample - Superstore.csv
*/

/* ================================================================
   SCRIPT 00 — DATABASE CONTEXT
   Purpose: Select the project database.
   ================================================================ */
USE RetailSalesDB;
GO

/* ================================================================
   SCRIPT 01 — DATASET OVERVIEW
   Business question: How many records and fields are in the dataset?
   ================================================================ */
SELECT COUNT(*) AS Total_Records
FROM dbo.SuperstoreSales;

SELECT TOP (10) *
FROM dbo.SuperstoreSales;

EXEC sys.sp_help N'dbo.SuperstoreSales';
GO

/* ================================================================
   SCRIPT 02 — DATA COMPLETENESS CHECK
   Business question: Are key fields missing values?
   ================================================================ */
SELECT
    SUM(CASE WHEN Row_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Row_ID,
    SUM(CASE WHEN Order_ID IS NULL OR LTRIM(RTRIM(Order_ID)) = '' THEN 1 ELSE 0 END) AS Missing_Order_ID,
    SUM(CASE WHEN Order_date IS NULL THEN 1 ELSE 0 END) AS Missing_Order_Date,
    SUM(CASE WHEN Customer_ID IS NULL OR LTRIM(RTRIM(Customer_ID)) = '' THEN 1 ELSE 0 END) AS Missing_Customer_ID,
    SUM(CASE WHEN Product_ID IS NULL OR LTRIM(RTRIM(Product_ID)) = '' THEN 1 ELSE 0 END) AS Missing_Product_ID,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Missing_Sales,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Missing_Quantity,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS Missing_Discount,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Missing_Profit
FROM dbo.SuperstoreSales;
GO

/* ================================================================
   SCRIPT 03 — DUPLICATE CHECKS
   Business question: Are row identifiers duplicated?
   ================================================================ */
SELECT Row_ID, COUNT(*) AS Occurrences
FROM dbo.SuperstoreSales
GROUP BY Row_ID
HAVING COUNT(*) > 1;

-- Check for fully duplicated records across all supplied columns.
SELECT
    Row_ID, Order_ID, Order_date, Ship_date, Ship_mode,
    Customer_ID, Customer_name, Segment, Country, City, State,
    Postal_code, Region, Product_ID, Category, Sub_Category,
    Product_name, Sales, Quantity, Discount, Profit,
    COUNT(*) AS Occurrences
FROM dbo.SuperstoreSales
GROUP BY
    Row_ID, Order_ID, Order_date, Ship_date, Ship_mode,
    Customer_ID, Customer_name, Segment, Country, City, State,
    Postal_code, Region, Product_ID, Category, Sub_Category,
    Product_name, Sales, Quantity, Discount, Profit
HAVING COUNT(*) > 1;
GO

/* ================================================================
   SCRIPT 04 — DATE VALIDATION
   Business question: Can dates be parsed, and are shipping dates valid?
   Style 101 supports dates formatted as M/D/YYYY or MM/DD/YYYY.
   ================================================================ */
SELECT
    SUM(CASE WHEN TRY_CONVERT(date, Order_date, 101) IS NULL THEN 1 ELSE 0 END) AS Unparseable_Order_Dates,
    SUM(CASE WHEN TRY_CONVERT(date, Ship_date, 101) IS NULL THEN 1 ELSE 0 END) AS Unparseable_Ship_Dates,
    SUM(CASE
            WHEN TRY_CONVERT(date, Order_date, 101) IS NOT NULL
             AND TRY_CONVERT(date, Ship_date, 101) IS NOT NULL
             AND TRY_CONVERT(date, Ship_date, 101) < TRY_CONVERT(date, Order_date, 101)
            THEN 1 ELSE 0
        END) AS Ship_Date_Before_Order_Date
FROM dbo.SuperstoreSales;

-- Display any rows with invalid or logically inconsistent dates.
SELECT *
FROM dbo.SuperstoreSales
WHERE TRY_CONVERT(date, Order_date, 101) IS NULL
   OR TRY_CONVERT(date, Ship_date, 101) IS NULL
   OR TRY_CONVERT(date, Ship_date, 101) < TRY_CONVERT(date, Order_date, 101);
GO

/* ================================================================
   SCRIPT 05 — NUMERIC VALIDATION
   Business question: Are there unexpected values in sales, quantity,
   discount, or profit?
   Negative profit can be legitimate; it represents a loss.
   ================================================================ */
SELECT
    MIN(Sales) AS Minimum_Sales,
    MAX(Sales) AS Maximum_Sales,
    MIN(Quantity) AS Minimum_Quantity,
    MAX(Quantity) AS Maximum_Quantity,
    MIN(Discount) AS Minimum_Discount,
    MAX(Discount) AS Maximum_Discount,
    MIN(Profit) AS Minimum_Profit,
    MAX(Profit) AS Maximum_Profit
FROM dbo.SuperstoreSales;

SELECT *
FROM dbo.SuperstoreSales
WHERE Sales < 0
   OR Quantity <= 0
   OR Discount < 0
   OR Discount > 1;
GO

/* ================================================================
   SCRIPT 06 — OVERALL BUSINESS PERFORMANCE
   Business question: What are total sales, profit, quantity and margin?
   Profit margin = total profit / total sales.
   ================================================================ */
SELECT
    COUNT(*) AS Total_Line_Items,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Product_ID) AS Unique_Products,
    SUM(Quantity) AS Units_Sold,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS decimal(10,2)) AS Profit_Margin_Percent,
    CAST(AVG(Discount) * 100.0 AS decimal(10,2)) AS Average_Discount_Percent
FROM dbo.SuperstoreSales;
GO

/* ================================================================
   SCRIPT 07 — SALES AND PROFIT BY YEAR
   Business question: How does annual performance change over time?
   ================================================================ */
WITH AnnualPerformance AS (
    SELECT
        YEAR(TRY_CONVERT(date, Order_date, 101)) AS Order_Year,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM dbo.SuperstoreSales
    GROUP BY YEAR(TRY_CONVERT(date, Order_date, 101))
)
SELECT
    Order_Year,
    CAST(Total_Sales AS decimal(18,2)) AS Total_Sales,
    CAST(Total_Profit AS decimal(18,2)) AS Total_Profit,
    CAST(100.0 * Total_Profit / NULLIF(Total_Sales, 0) AS decimal(10,2)) AS Profit_Margin_Percent,
    CAST(100.0 * (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Order_Year))
         / NULLIF(LAG(Total_Sales) OVER (ORDER BY Order_Year), 0) AS decimal(10,2)) AS Sales_Growth_Percent
FROM AnnualPerformance
WHERE Order_Year IS NOT NULL
ORDER BY Order_Year;
GO

/* ================================================================
   SCRIPT 08 — MONTHLY SALES TREND
   Business question: Which months have higher or lower sales?
   ================================================================ */
SELECT
    DATEFROMPARTS(YEAR(TRY_CONVERT(date, Order_date, 101)),
                  MONTH(TRY_CONVERT(date, Order_date, 101)), 1) AS Sales_Month,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Unique_Orders
FROM dbo.SuperstoreSales
WHERE TRY_CONVERT(date, Order_date, 101) IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(TRY_CONVERT(date, Order_date, 101)),
                       MONTH(TRY_CONVERT(date, Order_date, 101)), 1)
ORDER BY Sales_Month;
GO

/* ================================================================
   SCRIPT 09 — CATEGORY PERFORMANCE
   Business question: Which product categories drive sales and profit?
   ================================================================ */
SELECT
    Category,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    SUM(Quantity) AS Units_Sold,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS decimal(10,2)) AS Profit_Margin_Percent
FROM dbo.SuperstoreSales
GROUP BY Category
ORDER BY Total_Sales DESC;
GO

/* ================================================================
   SCRIPT 10 — SUB-CATEGORY PERFORMANCE
   Business question: Which sub-categories are strongest or weakest?
   ================================================================ */
SELECT
    Category,
    Sub_Category,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS decimal(10,2)) AS Profit_Margin_Percent,
    SUM(Quantity) AS Units_Sold
FROM dbo.SuperstoreSales
GROUP BY Category, Sub_Category
ORDER BY Total_Profit DESC;

-- Sub-categories with an overall loss.
SELECT
    Category, Sub_Category,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.SuperstoreSales
GROUP BY Category, Sub_Category
HAVING SUM(Profit) < 0
ORDER BY SUM(Profit) ASC;
GO

/* ================================================================
   SCRIPT 11 — TOP 10 PRODUCTS BY SALES
   Business question: Which individual products generate the most sales?
   ================================================================ */
SELECT TOP (10)
    Product_ID, Product_name, Category, Sub_Category,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    SUM(Quantity) AS Units_Sold
FROM dbo.SuperstoreSales
GROUP BY Product_ID, Product_name, Category, Sub_Category
ORDER BY SUM(Sales) DESC;
GO

/* ================================================================
   SCRIPT 12 — BOTTOM 10 PRODUCTS BY PROFIT
   Business question: Which products have the lowest total profit?
   ================================================================ */
SELECT TOP (10)
    Product_ID, Product_name, Category, Sub_Category,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    SUM(Quantity) AS Units_Sold,
    CAST(AVG(Discount) * 100.0 AS decimal(10,2)) AS Average_Discount_Percent
FROM dbo.SuperstoreSales
GROUP BY Product_ID, Product_name, Category, Sub_Category
ORDER BY SUM(Profit) ASC;
GO

/* ================================================================
   SCRIPT 13 — CUSTOMER VALUE ANALYSIS
   Business question: Which customers contribute the most sales and profit?
   ================================================================ */
SELECT TOP (10)
    Customer_ID, Customer_name, Segment,
    COUNT(DISTINCT Order_ID) AS Number_Of_Orders,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.SuperstoreSales
GROUP BY Customer_ID, Customer_name, Segment
ORDER BY SUM(Sales) DESC;
GO


/* SCRIPT 14 — TOP 10 CUSTOMERS BY SALES CONTRIBUTION
   Business question:
   Who are the top 10 customers by sales, and what
   percentage of total company sales does each represent?
*/

WITH CustomerSales AS (
    SELECT
        Customer_ID,
        Customer_name,
        SUM(Sales) AS Total_Sales
    FROM dbo.SuperstoreSales
    GROUP BY Customer_ID, Customer_name
),
OverallSales AS (
    SELECT SUM(Sales) AS Total_Company_Sales
    FROM dbo.SuperstoreSales
)
SELECT TOP (10)
    c.Customer_ID,
    c.Customer_name,
    CAST(c.Total_Sales AS DECIMAL(18,2)) AS Total_Sales,
    CAST(
        100.0 * c.Total_Sales /
        NULLIF(o.Total_Company_Sales, 0)
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percent
FROM CustomerSales AS c
CROSS JOIN OverallSales AS o
ORDER BY c.Total_Sales DESC;

/* ================================================================
   SCRIPT 15 — REGIONAL PERFORMANCE
   Business question: Which regions and states generate sales and profit?
   ================================================================ */
SELECT
    Region,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS decimal(10,2)) AS Profit_Margin_Percent,
    COUNT(DISTINCT Order_ID) AS Unique_Orders
FROM dbo.SuperstoreSales
GROUP BY Region
ORDER BY SUM(Profit) DESC;

SELECT TOP (15)
    State,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.SuperstoreSales
GROUP BY State
ORDER BY SUM(Profit) ASC;
GO

/* ================================================================
   SCRIPT 16 — CUSTOMER SEGMENT ANALYSIS
   Business question: Which customer segments contribute sales and profit?
   ================================================================ */
SELECT
    Segment,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS decimal(10,2)) AS Profit_Margin_Percent
FROM dbo.SuperstoreSales
GROUP BY Segment
ORDER BY SUM(Sales) DESC;
GO

/* ================================================================
   SCRIPT 17 — DISCOUNT AND PROFITABILITY
   Business question: How do discount bands relate to sales and profit?
   Note: This is descriptive analysis, not proof that discounts caused losses.
   ================================================================ */
WITH DiscountBands AS (
    SELECT
        CASE
            WHEN Discount = 0 THEN '0%'
            WHEN Discount <= 0.10 THEN '>0% to 10%'
            WHEN Discount <= 0.20 THEN '>10% to 20%'
            WHEN Discount <= 0.30 THEN '>20% to 30%'
            WHEN Discount <= 0.50 THEN '>30% to 50%'
            ELSE '>50%'
        END AS Discount_Band,
        Sales, Profit, Quantity, Discount
    FROM dbo.SuperstoreSales
)
SELECT
    Discount_Band,
    COUNT(*) AS Line_Items,
    SUM(Quantity) AS Units_Sold,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(AVG(Discount) * 100.0 AS decimal(10,2)) AS Average_Discount_Percent,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS decimal(10,2)) AS Profit_Margin_Percent
FROM DiscountBands
GROUP BY Discount_Band
ORDER BY MIN(Discount);
GO

/* ================================================================
   SCRIPT 18 — SHIPPING PERFORMANCE
   Business question: How long does shipping take by ship mode?
   ================================================================ */
WITH ShippingTimes AS (
    SELECT
        Ship_mode, Order_ID,
        DATEDIFF(DAY,
            TRY_CONVERT(date, Order_date, 101),
            TRY_CONVERT(date, Ship_date, 101)) AS Shipping_Days
    FROM dbo.SuperstoreSales
    WHERE TRY_CONVERT(date, Order_date, 101) IS NOT NULL
      AND TRY_CONVERT(date, Ship_date, 101) IS NOT NULL
)
SELECT
    Ship_mode,
    COUNT(*) AS Line_Items,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    AVG(CAST(Shipping_Days AS decimal(10,2))) AS Average_Shipping_Days,
    MIN(Shipping_Days) AS Minimum_Shipping_Days,
    MAX(Shipping_Days) AS Maximum_Shipping_Days
FROM ShippingTimes
GROUP BY Ship_mode
ORDER BY Average_Shipping_Days;
GO


/* SCRIPT 19 — TOP 10 PRODUCTS WITHIN EACH CATEGORY
   Business question: Which products generate the highest sales within each product category?
*/

WITH ProductPerformance AS (
    SELECT
        Category,
        Product_ID,
        Product_name,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM dbo.SuperstoreSales
    GROUP BY Category, Product_ID, Product_name
),
RankedProducts AS (
    SELECT
        Category,
        Product_ID,
        Product_name,
        Total_Sales,
        Total_Profit,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY Total_Sales DESC, Product_ID
        ) AS Sales_Rank_In_Category
    FROM ProductPerformance
)
SELECT
    Category,
    Product_ID,
    Product_name,
    CAST(Total_Sales AS DECIMAL(18,2)) AS Total_Sales,
    CAST(Total_Profit AS DECIMAL(18,2)) AS Total_Profit,
    Sales_Rank_In_Category
FROM RankedProducts
WHERE Sales_Rank_In_Category <= 10
ORDER BY Category, Sales_Rank_In_Category;

/* ================================================================
   SCRIPT 20 — MONTH-OVER-MONTH SALES CHANGE
   Business question: How do monthly sales compare with the prior month?
   ================================================================ */
WITH MonthlySales AS (
    SELECT
        DATEFROMPARTS(YEAR(TRY_CONVERT(date, Order_date, 101)),
                      MONTH(TRY_CONVERT(date, Order_date, 101)), 1) AS Sales_Month,
        SUM(Sales) AS Total_Sales
    FROM dbo.SuperstoreSales
    WHERE TRY_CONVERT(date, Order_date, 101) IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(TRY_CONVERT(date, Order_date, 101)),
                           MONTH(TRY_CONVERT(date, Order_date, 101)), 1)
),
SalesWithPreviousMonth AS (
    SELECT
        Sales_Month,
        Total_Sales,
        LAG(Total_Sales) OVER (ORDER BY Sales_Month) AS Previous_Month_Sales
    FROM MonthlySales
)
SELECT
    Sales_Month,
    CAST(Total_Sales AS decimal(18,2)) AS Total_Sales,
    CAST(Previous_Month_Sales AS decimal(18,2)) AS Previous_Month_Sales,
    CAST(100.0 * (Total_Sales - Previous_Month_Sales)
         / NULLIF(Previous_Month_Sales, 0) AS decimal(10,2)) AS Month_Over_Month_Growth_Percent
FROM SalesWithPreviousMonth
ORDER BY Sales_Month;
GO

/* ================================================================
   SCRIPT 21 — SUMMARY TABLE FOR REPORTING
   Business question: Can the core KPIs be returned in one compact result?
   ================================================================ */
SELECT
    COUNT(*) AS Total_Line_Items,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Product_ID) AS Total_Products,
    SUM(Quantity) AS Total_Units_Sold,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS decimal(10,2)) AS Overall_Profit_Margin_Percent
FROM dbo.SuperstoreSales;
GO

/* ================================================================
   END OF PROJECT ANALYSIS
   ================================================================ */
