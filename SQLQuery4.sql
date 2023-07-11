SELECT *
FROM StockX

-- Check for null values in the StockX table
-- This query counts the number of null values in various columns of the StockX table. It provides  an overview of the data quality and helps identify any missing or incomplete information.
SELECT COUNT(*) FROM StockX WHERE OrderDate IS NULL;
SELECT COUNT(*) FROM StockX WHERE Brand IS NULL;
SELECT COUNT(*) FROM StockX WHERE SneakerName IS NULL;
SELECT COUNT(*) FROM StockX WHERE SalePrice IS NULL;
SELECT COUNT(*) FROM StockX WHERE RetailPrice IS NULL;
SELECT COUNT(*) FROM StockX WHERE ReleaseDate IS NULL;
SELECT COUNT(*) FROM StockX WHERE ShoeSize IS NULL;
SELECT COUNT(*) FROM StockX WHERE BuyerRegion IS NULL;


-- Create a new table for unique sneaker models
-- This query creates a new table called "SneakerModels" to store unique sneaker models. It extracts distinct combinations of data from the StockX table and inserts them into the SneakerModels table. This step helps organize and centralize information about unique sneaker models for further analysis.
CREATE TABLE SneakerModels (
  SneakerID INT IDENTITY(1001, 1) PRIMARY KEY,
  Brand VARCHAR(50) NOT NULL,
  SneakerName VARCHAR(100) NOT NULL,
  RetailPrice DECIMAL(10, 2) NOT NULL,
  ReleaseDate DATE NOT NULL
);

-- Insert unique sneaker models into the SneakerModels table
INSERT INTO SneakerModels (Brand, SneakerName, RetailPrice, ReleaseDate)
SELECT DISTINCT Brand, SneakerName, RetailPrice, ReleaseDate
FROM StockX;

-- Add a foreign key constraint to the StockX table and populate the SneakerID column
--These queries add a foreign key constraint to the StockX table, referencing the SneakerModels table. It ensures referential integrity between the two tables. The subsequent UPDATE statement populates the SneakerID column in the StockX table by matching the Brand, SneakerName, RetailPrice, and ReleaseDate columns in both tables. This associates each entry in the StockX table with a unique sneaker model.
ALTER TABLE StockX ADD IF NOT EXISTS SneakerID INT;
ALTER TABLE StockX ADD CONSTRAINT IF NOT EXISTS FK_SneakerModel
  FOREIGN KEY (SneakerID) REFERENCES SneakerModels(SneakerID);

-- Update the SneakerID column in the StockX table
UPDATE StockX
SET StockX.SneakerID = SneakerModels.SneakerID
FROM StockX
JOIN SneakerModels
ON StockX.Brand = SneakerModels.Brand
  AND StockX.SneakerName = SneakerModels.SneakerName
  AND StockX.RetailPrice = SneakerModels.RetailPrice
  AND StockX.ReleaseDate = SneakerModels.ReleaseDate
WHERE StockX.SneakerID IS NULL;

SELECT *
FROM SneakerModels

-- Add columns for ProfitMargin and DaysOnMarket to the StockX table
--These queries add two new columns, ProfitMargin and DaysOnMarket, to the StockX table. ProfitMargin represents the percentage profit made on each sale, and DaysOnMarket measures the number of days between the release date and the order date. These columns provide insights into profitability and market demand.
ALTER TABLE StockX ADD IF NOT EXISTS ProfitMargin DECIMAL(5, 2);
ALTER TABLE StockX ADD IF NOT EXISTS DaysOnMarket INT;

-- Calculate the ProfitMargin and DaysOnMarket and update the StockX table
--This UPDATE statement calculates the ProfitMargin and DaysOnMarket values for each record in the StockX table based on the SalePrice, RetailPrice, and OrderDate. It populates the newly added columns with the calculated values.
UPDATE StockX
SET ProfitMargin = (SalePrice - RetailPrice) / RetailPrice,
    DaysOnMarket = DATEDIFF(DAY, ReleaseDate, OrderDate);

--The subsequent queries (1-18) perform various analyses on the StockX data. I have commented a summary of their purposes and key insights.
        
-- Query 1: Average sale price by sneaker brand and model
--This query calculates the average sale price for each unique combination of sneaker brand and model. It helps identify the most popular and high-priced sneakers in the dataset.
SELECT Brand, SneakerName, AVG(SalePrice) AS AvgSalePrice
FROM StockX
GROUP BY Brand, SneakerName
ORDER BY AvgSalePrice DESC;

-- Query 2: Total revenue by buyer region
-- This query calculates the total revenue generated from sales in each buyer region. It highlights the regions that contribute the most to the overall revenue.
SELECT BuyerRegion, SUM(SalePrice) AS TotalRevenue
FROM StockX
GROUP BY BuyerRegion
ORDER BY TotalRevenue DESC;

-- Query 3: Total revenue by sneaker release year and month
---This query aggregates the total revenue by the release year and month of the sneakers. It provides insights into the revenue distribution over time and identifies popular release periods.
SELECT 
  YEAR(ReleaseDate) AS ReleaseYear, 
  MONTH(ReleaseDate) AS ReleaseMonth, 
  SUM(SalePrice) AS TotalRevenue
FROM StockX
GROUP BY YEAR(ReleaseDate), MONTH(ReleaseDate)
ORDER BY ReleaseYear, ReleaseMonth;

-- Query 4: Total revenue by brand and year
--This query calculates the total revenue for each brand in each year between 2017 and 2019. It helps track the revenue performance of different brands over time.
SELECT
  YEAR(OrderDate) AS SalesYear,
  Brand,
  SUM(SalePrice) AS TotalRevenue
FROM StockX
WHERE YEAR(OrderDate) BETWEEN 2017 AND 2019
GROUP BY YEAR(OrderDate), Brand
ORDER BY SalesYear, Brand;

-- Query 5: Profit by brand and year
-- This query calculates the total profit margin for each brand in each year between 2017 and 2019. It provides insights into the profitability of different brands over time.
SELECT
  YEAR(OrderDate) AS SalesYear,
  Brand,
  SUM(ProfitMargin) AS TotalProfit
FROM StockX 
WHERE YEAR(OrderDate) BETWEEN 2017 AND 2019
GROUP BY YEAR(OrderDate), Brand
ORDER BY SalesYear, Brand;

-- Query 6: Total orders by brand and year
-- This query counts the total number of orders for each brand in each year between 2017 and 2019. It helps analyze the sales volume and market share of different brands.
SELECT
  YEAR(OrderDate) AS SalesYear,
  Brand,
  COUNT(*) AS TotalOrders
FROM StockX
WHERE YEAR(OrderDate) BETWEEN 2017 AND 2019
GROUP BY YEAR(OrderDate), Brand
ORDER BY SalesYear, Brand;

-- Query 7: Number of orders by buyer region
-- This query counts the total number of orders from each buyer region. It helps understand the market demand and popularity of sneakers in different regions.
SELECT 
  BuyerRegion, 
  COUNT(*) AS TotalOrders
FROM StockX
GROUP BY BuyerRegion
ORDER BY TotalOrders DESC;

-- Query 8: Distribution of sale prices by sneaker model
-- This query calculates the number of sales, average sale price, minimum sale price, and maximum sale price for each unique combination of sneaker brand and model. It provides insights into the price distribution and popularity of different sneaker models.
SELECT TOP 10 
  Brand, 
  SneakerName, 
  COUNT(*) AS NumSales, 
  AVG(SalePrice) AS AvgSalePrice, 
  MIN(SalePrice) AS MinSalePrice, 
  MAX(SalePrice) AS MaxSalePrice
FROM SneakerModels sm
JOIN StockX sx ON sm.SneakerID = sx.SneakerID
GROUP BY Brand, SneakerName
ORDER BY AvgSalePrice DESC;

-- Query 9: Top 10 most profitable sneaker models
-- This query identifies the top 10 sneaker models with the highest total profit. It helps pinpoint the most profitable products in the dataset.
SELECT TOP 10
  Brand,
  SneakerName,
  SUM(SalePrice - RetailPrice) AS TotalProfit
FROM StockX
GROUP BY Brand, SneakerName
ORDER BY TotalProfit DESC;

-- Query 10: Total number of unique sneaker models by brand
-- This query counts the number of unique sneaker models for each brand. It provides an overview of the variety and diversity of sneakers offered by different brands.
SELECT Brand, COUNT(DISTINCT SneakerName) AS UniqueModels
FROM SneakerModels
GROUP BY Brand;

-- Query 11: Average retail price by brand and release year
-- This query calculates the average retail price for each brand in each release year. It helps analyze the pricing strategy and trends of different brands over time.
SELECT Brand, YEAR(ReleaseDate) AS ReleaseYear, AVG(RetailPrice) AS AvgRetailPrice
FROM SneakerModels
GROUP BY Brand, YEAR(ReleaseDate);

-- Query 12: Total number of sales by sneaker model and buyer region
-- This query counts the total number of sales for each unique combination of sneaker brand, model, and buyer region. It provides insights into the popularity and sales distribution across different regions.
SELECT sm.Brand, sm.SneakerName, sx.BuyerRegion, COUNT(*) AS TotalSales
FROM StockX sx
JOIN SneakerModels sm ON sx.SneakerID = sm.SneakerID
GROUP BY sm.Brand, sm.SneakerName, sx.BuyerRegion;

-- Query 13: Customer segmentation analysis
--This query adds a new column called "CustomerSegment" to the StockX table and assigns a segment to each customer based on their buyer region. It then calculates the number of distinct buyer regions for each customer segment. This analysis helps understand the distribution of customers across different segments.
ALTER TABLE StockX ADD IF NOT EXISTS CustomerSegment VARCHAR(50);

UPDATE StockX SET CustomerSegment = 
  CASE
    WHEN BuyerRegion IN ('North America', 'South America') THEN 'Americas'
    WHEN BuyerRegion IN ('Europe', 'Africa') THEN 'EMEA'
    WHEN BuyerRegion IN ('Asia', 'Oceania') THEN 'APAC'
    ELSE 'Other'
  END;

SELECT CustomerSegment, COUNT(DISTINCT BuyerRegion) AS NumCustomers
FROM StockX
GROUP BY CustomerSegment;

-- Query 14: Cohort analysis
--This query adds a new column called "CohortMonth" to the StockX table, which represents the month in which each customer made their first purchase. It creates a separate table called "CustomerCohorts" to store unique cohort months. The subsequent UPDATE statement populates the CohortID column in the StockX table by matching the CohortMonth between the two tables. Finally, the query performs a cohort analysis by counting the number of distinct buyer regions, customers, orders, and calculating the total revenue for each cohort month.
ALTER TABLE StockX ADD IF NOT EXISTS CohortMonth DATE;

UPDATE StockX
SET CohortMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDate), 0);

CREATE TABLE IF NOT EXISTS CustomerCohorts (
  CohortID INT IDENTITY(1, 1) PRIMARY KEY,
  CohortMonth DATE NOT NULL
);

INSERT INTO CustomerCohorts (CohortMonth)
SELECT DISTINCT CohortMonth
FROM StockX;

-- Add a foreign key constraint to the StockX table and populate the CohortID column
ALTER TABLE StockX ADD IF NOT EXISTS CohortID INT;
ALTER TABLE StockX ADD CONSTRAINT IF NOT EXISTS FK_CustomerCohort
  FOREIGN KEY (CohortID) REFERENCES CustomerCohorts(CohortID);

UPDATE StockX
SET StockX.CohortID = CustomerCohorts.CohortID
FROM StockX
JOIN CustomerCohorts
ON StockX.CohortMonth = CustomerCohorts.CohortMonth
WHERE StockX.CohortID IS NULL;

-- Perform cohort analysis
SELECT 
  cc.CohortMonth AS CohortPeriod,
  COUNT(DISTINCT sx.BuyerRegion) AS NumRegions,
  COUNT(DISTINCT sx.BuyerID) AS NumCustomers,
  COUNT(*) AS NumOrders,
  SUM(sx.SalePrice) AS TotalRevenue
FROM StockX sx
JOIN CustomerCohorts cc ON sx.CohortID = cc.CohortID
GROUP BY cc.CohortMonth
ORDER BY cc.CohortMonth;

-- Query 15: Total revenue by month
--This query calculates the total revenue for each month by extracting the year and month from the OrderDate column in the StockX table. It groups the data by year and month and calculates the sum of the SalePrice column. The result provides an overview of the revenue distribution over time.
SELECT
  YEAR(OrderDate) AS SalesYear,
  MONTH(OrderDate) AS SalesMonth,
  SUM(SalePrice) AS TotalRevenue
FROM StockX
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;

-- Query 16: Moving average of revenue for the past 3 months
--This query calculates the moving average of revenue for the past three months. It uses a subquery to aggregate the revenue by year and month, and then uses the AVG function with a window function to calculate the moving average. The result includes the sales year, sales month, total revenue, and the moving average of revenue.
SELECT
  SalesYear,
  SalesMonth,
  TotalRevenue,
  AVG(TotalRevenue) OVER (ORDER BY SalesYear, SalesMonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAverage
FROM (
  SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    SUM(SalePrice) AS TotalRevenue
  FROM StockX
  GROUP BY YEAR(OrderDate), MONTH(OrderDate)
) AS RevenueByMonth
ORDER BY SalesYear, SalesMonth;

-- Query 17: Performance comparison - Average sale price, total revenue, and profit margin by brand
--This query calculates the average sale price, total revenue, and average profit margin for each brand in the StockX table. It groups the data by brand and provides insights into the performance of different brands based on these metrics. The result is ordered by total revenue in descending order.
SELECT
  Brand,
  AVG(SalePrice) AS AvgSalePrice,
  SUM(SalePrice) AS TotalRevenue,
  AVG(ProfitMargin) AS AvgProfitMargin
FROM StockX
GROUP BY Brand
ORDER BY TotalRevenue DESC;

