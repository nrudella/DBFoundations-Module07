--*************************************************************************--
-- Title: Assignment07
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2026-11-23,NRudella,Created File
--**************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS (SELECT	Name
				FROM		SysDatabases
				WHERE	Name = 'Assignment07DB_NRudella')
		BEGIN
			ALTER DATABASE [Assignment07DB_NRudella]
				SET SINGLE_USER 
				WITH ROLLBACK IMMEDIATE;
			DROP DATABASE Assignment07DB_NRudella;
		END
	CREATE DATABASE Assignment07DB_NRudella;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH


GO
USE Assignment07DB_NRudella;

-- Create Tables (Module 01)-- 
CREATE TABLE Categories (
	[CategoryID]	INT				IDENTITY (1, 1) NOT NULL,
	[CategoryName]	NVARCHAR (100)	NOT NULL
);


GO
CREATE TABLE Products (
	[ProductID]		INT				IDENTITY (1, 1) NOT NULL,
	[ProductName]	NVARCHAR (100)	NOT NULL,
	[CategoryID]	INT				NULL,
	[UnitPrice]		MONEY			NOT NULL
);


GO
CREATE TABLE Employees (
	-- New Table
	[EmployeeID]		INT				IDENTITY (1, 1) NOT NULL,
	[EmployeeFirstName]	NVARCHAR (100)	NOT NULL,
	[EmployeeLastName]	NVARCHAR (100)	NOT NULL,
	[ManagerID]			INT				NULL
);


GO
CREATE TABLE Inventories (
	[InventoryID]	INT		IDENTITY (1, 1) NOT NULL,
	[InventoryDate]	DATE	NOT NULL,
	[EmployeeID]	INT		NOT NULL,
	[ProductID]		INT		NOT NULL,
	[ReorderLevel]	INT		NOT NULL, -- New Column 
	[Count]			INT		NOT NULL
);


GO
-- Add Constraints (Module 02) -- 
BEGIN
	-- Categories
	ALTER TABLE Categories
		ADD CONSTRAINT pkCategories PRIMARY KEY (CategoryId);
	ALTER TABLE Categories
		ADD CONSTRAINT ukCategories UNIQUE (CategoryName);
END


GO
BEGIN
	-- Products
	ALTER TABLE Products
		ADD CONSTRAINT pkProducts PRIMARY KEY (ProductId);
	ALTER TABLE Products
		ADD CONSTRAINT ukProducts UNIQUE (ProductName);
	ALTER TABLE Products
		ADD CONSTRAINT fkProductsToCategories FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId);
	ALTER TABLE Products
		ADD CONSTRAINT ckProductUnitPriceZeroOrHigher CHECK (UnitPrice >= 0);
END


GO
BEGIN
	-- Employees
	ALTER TABLE Employees
		ADD CONSTRAINT pkEmployees PRIMARY KEY (EmployeeId);
	ALTER TABLE Employees
		ADD CONSTRAINT fkEmployeesToEmployeesManager FOREIGN KEY (ManagerId) REFERENCES Employees (EmployeeId);
END


GO
BEGIN
	-- Inventories
	ALTER TABLE Inventories
		ADD CONSTRAINT pkInventories PRIMARY KEY (InventoryId);
	ALTER TABLE Inventories
		ADD CONSTRAINT dfInventoryDate DEFAULT GetDate() FOR InventoryDate;
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToProducts FOREIGN KEY (ProductId) REFERENCES Products (ProductId);
	ALTER TABLE Inventories
		ADD CONSTRAINT ckInventoryCountZeroOrHigher CHECK ([Count] >= 0);
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToEmployees FOREIGN KEY (EmployeeId) REFERENCES Employees (EmployeeId);
END


GO
-- Adding Data (Module 04) -- 
INSERT	INTO Categories (
	CategoryName
)
SELECT		CategoryName
FROM		Northwind.dbo.Categories
ORDER BY	CategoryID;


GO
INSERT	INTO Products (
	ProductName,
	CategoryID,
	UnitPrice
)
SELECT		ProductName,
			CategoryID,
			UnitPrice
FROM		Northwind.dbo.Products
ORDER BY	ProductID;


GO
INSERT	INTO Employees (
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
)
SELECT		E.FirstName,
			E.LastName,
			IsNull(E.ReportsTo, E.EmployeeID)
FROM		Northwind.dbo.Employees AS E
ORDER BY	E.EmployeeID;


GO
INSERT	INTO Inventories (
	InventoryDate,
	EmployeeID,
	ProductID,
	[Count],
	[ReorderLevel]
)
-- New column added this week
SELECT		'20170101' AS InventoryDate,
			5 AS EmployeeID,
			ProductID,
			UnitsInStock,
			ReorderLevel
FROM		Northwind.dbo.Products
UNION
SELECT		'20170201' AS InventoryDate,
			7 AS EmployeeID,
			ProductID,
			UnitsInStock + 10,
			ReorderLevel -- Using this is to create a made up value
FROM		Northwind.dbo.Products
UNION
SELECT		'20170301' AS InventoryDate,
			9 AS EmployeeID,
			ProductID,
			abs(UnitsInStock - 10),
			ReorderLevel -- Using this is to create a made up value
FROM		Northwind.dbo.Products
ORDER BY	1, 2;


GO
-- Adding Views (Module 06) -- 
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
SELECT	CategoryID,
		CategoryName
FROM	dbo.Categories;


GO
CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT	ProductID,
		ProductName,
		CategoryID,
		UnitPrice
FROM	dbo.Products;


GO
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT	EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
FROM	dbo.Employees;


GO
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
SELECT	InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		ReorderLevel,
		[Count]
FROM	dbo.Inventories;


GO
-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT	*
FROM	vCategories;


GO
SELECT	*
FROM	vProducts;


GO
SELECT	*
FROM	vEmployees;


GO
SELECT	*
FROM	vInventories;


GO
/********************************* Questions and Answers *********************************/
PRINT 'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------';

-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
/*
-- Step 1: Select base columns from vProducts
SELECT ProductName, UnitPrice FROM vProducts;

-- Step 2: Format UnitPrice as US currency
SELECT
    ProductName,
    [UnitPrice] = FORMAT(UnitPrice, 'C', 'en-US')
FROM vProducts;
*/
SELECT		ProductName,
			FORMAT(UnitPrice, 'C', 'en-US') AS [UnitPrice]
FROM		vProducts
ORDER BY	ProductName;


GO
-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
/*
-- Step 1: Select base columns from the basic views
SELECT CategoryName FROM vCategories;
SELECT ProductName, UnitPrice FROM vProducts;

-- Step 2: Join vCategories and vProducts (unformatted, unordered)
SELECT
    C.CategoryName,
    P.ProductName,
    P.UnitPrice
FROM vCategories AS C
INNER JOIN vProducts AS P
    ON C.CategoryID = P.CategoryID;

-- Step 3: Format UnitPrice as US currency (unordered)
SELECT
    C.CategoryName,
    P.ProductName,
    [UnitPrice] = FORMAT(P.UnitPrice, 'C', 'en-US')
FROM vCategories AS C
INNER JOIN vProducts AS P
    ON C.CategoryID = P.CategoryID;
*/
SELECT		C.CategoryName,
			P.ProductName,
			FORMAT(P.UnitPrice, 'C', 'en-US') AS [UnitPrice]
FROM		vCategories AS C
			INNER JOIN
			vProducts AS P
			ON C.CategoryID = P.CategoryID
ORDER BY	C.CategoryName, P.ProductName;


GO
-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/* 
-- Step 1: Select base columns from the basic views
SELECT ProductName FROM vProducts;
SELECT InventoryDate, [Count] FROM vInventories;

-- Step 2: Join vProducts and vInventories (unformatted, unordered)
SELECT
    P.ProductName,
    I.InventoryDate,
    [InventoryCount] = I.[Count]
FROM vProducts AS P
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID;

-- Step 3: Format InventoryDate as 'Month, Year' (unordered)
SELECT
    P.ProductName,
    [InventoryDate] = DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate),
    [InventoryCount] = I.[Count]
FROM vProducts AS P
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID;
*/
SELECT		P.ProductName,
			DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate) AS [InventoryDate],
			I.[Count] AS [InventoryCount]
FROM		vProducts AS P
			INNER JOIN
			vInventories AS I
			ON P.ProductID = I.ProductID
ORDER BY	P.ProductName, I.InventoryDate;


GO
-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/*
-- Step 1: Select base columns from the basic views
SELECT ProductName FROM vProducts;
SELECT InventoryDate, [Count] FROM vInventories;

-- Step 2: Join vProducts and vInventories (unformatted, unordered)
SELECT
    P.ProductName,
    I.InventoryDate,
    [InventoryCount] = I.[Count]
FROM vProducts AS P
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID;

-- Step 3: Format InventoryDate as 'Month, Year' (unordered)
SELECT
    P.ProductName,
    [InventoryDate] = DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate),
    [InventoryCount] = I.[Count]
FROM vProducts AS P
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID;

-- Step 4: Add chronological ORDER BY before wrapping in a View
SELECT
    P.ProductName,
    [InventoryDate] = DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate),
    [InventoryCount] = I.[Count]
FROM vProducts AS P
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID
ORDER BY P.ProductName, I.InventoryDate;
*/
CREATE VIEW vProductInventories
AS
SELECT		TOP 1000000000 P.ProductName,
						DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate) AS [InventoryDate],
						I.[Count] AS [InventoryCount]
FROM		vProducts AS P
			INNER JOIN
			vInventories AS I
			ON P.ProductID = I.ProductID
ORDER BY	P.ProductName, I.InventoryDate;


GO
-- Check that it works:
SELECT	*
FROM	vProductInventories;


GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/*
-- Step 1: Select base columns from the basic views
SELECT CategoryName FROM vCategories;
SELECT ProductID, CategoryID FROM vProducts;
SELECT InventoryDate, ProductID, [Count] FROM vInventories;

-- Step 2: Join vCategories, vProducts, and vInventories (unformatted, ungrouped)
SELECT
    C.CategoryName,
    I.InventoryDate,
    I.[Count]
FROM vCategories AS C
INNER JOIN vProducts AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID;

-- Step 3: Format InventoryDate, SUM([Count]), and GROUP BY (unordered)
SELECT
    C.CategoryName,
    [InventoryDate] = DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate),
    [InventoryCountByCategory] = SUM(I.[Count])
FROM vCategories AS C
INNER JOIN vProducts AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID
GROUP BY C.CategoryName, I.InventoryDate;

-- Step 4: Add chronological ORDER BY before wrapping in a View
SELECT
    C.CategoryName,
    [InventoryDate] = DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate),
    [InventoryCountByCategory] = SUM(I.[Count])
FROM vCategories AS C
INNER JOIN vProducts AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I
    ON P.ProductID = I.ProductID
GROUP BY C.CategoryName, I.InventoryDate
ORDER BY C.CategoryName, I.InventoryDate;
*/
CREATE VIEW vCategoryInventories
AS
SELECT		TOP 1000000000 C.CategoryName,
						DATENAME(mm, I.InventoryDate) + ', ' + DATENAME(yy, I.InventoryDate) AS [InventoryDate],
						SUM(I.[Count]) AS [InventoryCountByCategory]
FROM		vCategories AS C
			INNER JOIN
			vProducts AS P
			ON C.CategoryID = P.CategoryID
			INNER JOIN
			vInventories AS I
			ON P.ProductID = I.ProductID
GROUP BY	C.CategoryName, I.InventoryDate
ORDER BY	C.CategoryName, I.InventoryDate;


GO
-- Check that it works:
SELECT	*
FROM	vCategoryInventories;


GO
-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
/*
-- Step 1: Select base columns from vProductInventories
SELECT ProductName, InventoryDate, InventoryCount
FROM vProductInventories;

-- Step 2: Add LAG() partitioned by ProductName and ordered by date (leaves January as NULL)
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    [PreviousMonthCount] = LAG(InventoryCount) OVER (
        PARTITION BY ProductName
        ORDER BY CAST(InventoryDate AS DATE)
    )
FROM vProductInventories;

-- Step 3: Wrap LAG() in ISNULL() to set January NULLs to 0 (unordered)
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    [PreviousMonthCount] = ISNULL(
        LAG(InventoryCount) OVER (
            PARTITION BY ProductName
            ORDER BY CAST(InventoryDate AS DATE)
        ),
        0
    )
FROM vProductInventories;

-- Step 4: Add chronological ORDER BY before wrapping in a View
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    [PreviousMonthCount] = ISNULL(
        LAG(InventoryCount) OVER (
            PARTITION BY ProductName
            ORDER BY CAST(InventoryDate AS DATE)
        ),
        0
    )
FROM vProductInventories
ORDER BY ProductName, CAST(InventoryDate AS DATE);
*/
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS
SELECT		TOP 1000000000 ProductName,
						InventoryDate,
						InventoryCount,
						ISNULL(LAG(InventoryCount) OVER (PARTITION BY ProductName ORDER BY		CAST (InventoryDate AS DATE)), 0) AS [PreviousMonthCount]
FROM		vProductInventories
ORDER BY	ProductName, CAST (InventoryDate AS DATE);


GO
-- Check that it works:
SELECT	*
FROM	vProductInventoriesWithPreviousMonthCounts;


GO
-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
/*
-- Step 1: Select base columns from vProductInventoriesWithPreviousMonthCounts
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount
FROM vProductInventoriesWithPreviousMonthCounts;

-- Step 2: Add CASE statement for CountVsPreviousCountKPI (unordered)
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    [CountVsPreviousCountKPI] = CASE
        WHEN InventoryCount > PreviousMonthCount THEN  1
        WHEN InventoryCount = PreviousMonthCount THEN  0
        WHEN InventoryCount < PreviousMonthCount THEN -1
    END
FROM vProductInventoriesWithPreviousMonthCounts;

-- Step 3: Add chronological ORDER BY before wrapping in a View
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    [CountVsPreviousCountKPI] = CASE
        WHEN InventoryCount > PreviousMonthCount THEN  1
        WHEN InventoryCount = PreviousMonthCount THEN  0
        WHEN InventoryCount < PreviousMonthCount THEN -1
    END
FROM vProductInventoriesWithPreviousMonthCounts
ORDER BY ProductName, CAST(InventoryDate AS DATE);
*/
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
SELECT		TOP 1000000000 ProductName,
						InventoryDate,
						InventoryCount,
						PreviousMonthCount,
						CASE WHEN InventoryCount > PreviousMonthCount THEN 1 WHEN InventoryCount = PreviousMonthCount THEN 0 WHEN InventoryCount < PreviousMonthCount THEN -1 END AS [CountVsPreviousCountKPI]
FROM		vProductInventoriesWithPreviousMonthCounts
ORDER BY	ProductName, CAST (InventoryDate AS DATE);


GO
-- Check that it works:
SELECT	*
FROM	vProductInventoriesWithPreviousMonthCountsWithKPIs;


GO
-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Verify that the results are ordered by the Product and Date.
/*
-- Step 1: Select all columns from vProductInventoriesWithPreviousMonthCountsWithKPIs
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;

-- Step 2: Add WHERE clause to test filtering by a single KPI value (unordered)
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
WHERE CountVsPreviousCountKPI = 1;

-- Step 3: Add chronological ORDER BY before wrapping in an Inline TVF
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
WHERE CountVsPreviousCountKPI = 1
ORDER BY ProductName, CAST(InventoryDate AS DATE);
*/
CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs
(@KPIValue INT)
RETURNS TABLE 
AS
RETURN 
	(SELECT		TOP 1000000000 ProductName,
								InventoryDate,
								InventoryCount,
								PreviousMonthCount,
								CountVsPreviousCountKPI
		FROM		vProductInventoriesWithPreviousMonthCountsWithKPIs
		WHERE		CountVsPreviousCountKPI = @KPIValue
		ORDER BY	ProductName, CAST (InventoryDate AS DATE))



GO
-- Check that Question 8 works:
SELECT	*
FROM	dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1);

SELECT	*
FROM	dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(0);

SELECT	*
FROM	dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);


/***************************************************************************************/