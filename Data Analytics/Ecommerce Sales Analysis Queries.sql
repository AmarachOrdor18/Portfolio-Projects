--Pre processing : Data Cleaning
-- Created a table called Cleaned Online retail that excluded rows where CustomerID, InvoiceNo, or Description is NULL to remove  rows with missing values, since they can't be linked to a customer
SELECT *
INTO CleanedOnlineRetail
FROM [Ecommerce Assignment]..['Online Retail$']
WHERE CustomerID IS NOT NULL
  AND InvoiceNo IS NOT NULL
  AND Description IS NOT NULL;

-- Overview of Created table
SELECT TOP 10 *
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]

--Filter out rows where the InvoiceNo starts with 'C', indicating canceled orders
 DELETE FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
 WHERE LEFT(InvoiceNo, 1) = 'C';

 --Ensured 'Quantity' and 'Unit Price' have valid positive values to indicate succesful Transactions
 DELETE FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
 WHERE [Quantity] <= 0 OR [UnitPrice] <= 0;

 --Checking if there are invalid Transactions still present
 SELECT *
 FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
 WHERE [Quantity] <= 0 OR [UnitPrice] <= 0;

--NUMBER 1: BASIC EXPLORATION
-- Finding the total transactions, total unique customers, and total revenue
SELECT	
	--Total Number of Transactions
	COUNT(InvoiceNo) AS Total_Transactions,
	--Total Unique Customers
	COUNT (DISTINCT [CustomerID]) AS Unique_Customers,
	--Total revenue generated
	SUM([Quantity] *[UnitPrice]) AS Total_Revenue
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail];

--Separated the Date column, into date and time
SELECT 
    CAST(InvoiceDate AS DATE) AS Invoice_Date,
    CAST(InvoiceDate AS TIME) AS Invoice_Time
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail];

-- Altered the table by adding two new columns to store the separated date and time
ALTER TABLE [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
ADD Invoice_Date DATE, Invoice_Time TIME;

-- Updated the Cleaned Online Retail table by adding the new columns with separated date and time values
UPDATE [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
SET Invoice_Date = CAST(InvoiceDate AS DATE),
    Invoice_Time = CAST(InvoiceDate AS TIME);

-- Verify that the columns have been updated correctly
SELECT InvoiceDate, Invoice_Date, Invoice_Time
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail];

-- Earliest and Latest Transaction Dates
SELECT
	MIN([InvoiceDate]) AS Earliest_Transaction,
	MAX([InvoiceDate]) AS Latest_Transaction
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail];

-- Top 5 most frequently purchased products
SELECT TOP 5
	[Description],
	SUM([Quantity]) AS Total_Quantity
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
GROUP BY [Description]
ORDER BY Total_Quantity DESC;

--NUMBER 2:CUSTOMER BEHAVIOR ANALYSIS
--The Average Order Value for each Customer
SELECT
	CustomerID,
	 AVG(Quantity * UnitPrice) AS Average_Order_Value
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
GROUP BY CustomerID;

-- Top 10 Customers Based on Total Revenue
SELECT TOP 10
	CustomerID,
	SUM(Quantity * UnitPrice) AS TotalRevenue
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
GROUP BY CustomerID
ORDER BY TotalRevenue DESC

--Identified Customers who have placed more than 5 Orders
SELECT
	CustomerID, 
  COUNT(DISTINCT InvoiceNo) AS Number_of_Orders
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) > 5;

--Data Overview
SELECT Top 10*
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]


--Number 3: Sales Performance by Month
--Total Monthly sales for the last 12 month
-- Created a temporary table to hold necessary data for monthly sales
CREATE TABLE #TempMonthlySales (
    InvoiceDate DATE,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    TotalSales DECIMAL(18, 2)
);

-- Declared a variable to store the latest date in the dataset
DECLARE @LatestDate DATETIME;
SET @LatestDate = '2011-12-09'; 

-- Inserted data into the temp table for the last 12 months
INSERT INTO #TempMonthlySales (InvoiceDate, Quantity, UnitPrice, TotalSales)
SELECT 
    CAST(InvoiceDate AS DATE) AS InvoiceDate,  
	-- To get just the date part
    Quantity, 
    UnitPrice, 
    (Quantity * UnitPrice) AS TotalSales 
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
WHERE InvoiceDate >= DATEADD(MONTH, -12, @LatestDate);  
-- Filtered for last 12 months based on the latest date

--Review of Temp Table
SELECT * 
FROM #TempMonthlySales;

-- Query to calculate total monthly sales

SELECT 
    YEAR(InvoiceDate) AS SalesYear,
    MONTH(InvoiceDate) AS SalesMonth,
    SUM(TotalSales) AS TotalMonthlySales
FROM #TempMonthlySales
GROUP BY 
    YEAR(InvoiceDate), 
    MONTH(InvoiceDate)
ORDER BY 
    SalesYear DESC, 
    SalesMonth DESC;

SELECT TOP 10 *
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail];


--NUMBER 4: PRODUCT RETURN ANALYSIS
-- Checking to see if there are any returns in the original data set
SELECT *
FROM [Ecommerce Assignment]..['Online Retail$']
WHERE [Quantity] < 0 OR [UnitPrice] < 0;

-- I observed that the returns have null values in either InvoiceNO, Description Or CutomerID

-- Found the Total Number of Returned Items and Revenue Lost Due to Returns

SELECT 
    ABS(SUM(Quantity)) AS TotalReturnedItems, 
	--Summing the negative quantities (returns)
    ABS(SUM(Quantity * UnitPrice)) AS RevenueLost  
	-- Summing the revenue lost (Quantity * Price)
FROM [Ecommerce Assignment]..['Online Retail$']
WHERE Quantity < 0;  
-- Filtering for returns (negative quantities)

-- Found the top 5 products with the most returns
SELECT TOP 5
    Description,
    SUM(Quantity) AS TotalReturnedQuantity 
FROM [Ecommerce Assignment]..['Online Retail$']
WHERE Quantity < 0  
    -- Only including rows where Quantity is negative (indicating a return)
    AND Description IS NOT NULL
    AND InvoiceNo IS NOT NULL  
	-- To ensure the Invoice and Description column is not null
GROUP BY Description
ORDER BY TotalReturnedQuantity ASC;

-- Sorting by the total returned quantity in ascending order



--NUMBER 5: SALES BY COUNTRY
-- Calculated total revenue and number of transactions by country
SELECT
  Country, 
  SUM(Quantity * UnitPrice) AS Total_Revenue,
  COUNT(DISTINCT InvoiceNo) AS Number_of_Transactions
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
GROUP BY Country;

--Found the country with the highest revenue outside the UK
SELECT TOP 1
  Country, 
  SUM(Quantity * UnitPrice) AS Total_Revenue
FROM [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
WHERE Country != 'United Kingdom'
GROUP BY Country
ORDER BY Total_Revenue DESC; 
--Order by highest revenue

ALTER TABLE [Ecommerce Assignment].[dbo].[CleanedOnlineRetail]
DROP COLUMN Invoice_Date, Invoice_Time;

