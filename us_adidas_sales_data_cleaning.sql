#Create a backup table to keep the original data untouched
CREATE TABLE us_adidas_sales_backup AS SELECT * FROM us_adidas_sales;

#We will work on the table us_adidas_sales
SELECT * FROM us_adidas_sales; 

#1.Standardize data
#Change the column's name
ALTER TABLE us_adidas_sales
RENAME COLUMN `ï»¿Retailer` TO `Retailer`;

#Standardize Retailer
SELECT DISTINCT Retailer
FROM us_adidas_sales; 

UPDATE us_adidas_sales
SET Retailer = 'Amazon'
WHERE Retailer LIKE '%Ama%';

UPDATE us_adidas_sales
SET Retailer = TRIM(TRAILING '.' FROM Retailer)
WHERE Retailer LIKE '%Walmart%';

#Standardize Invoice Date
#Change format from text to date
SELECT `Invoice Date`,
CASE WHEN `Invoice Date` LIKE '%/%/%' THEN STR_TO_DATE(`Invoice Date`, '%m/%d/%Y')
	 WHEN `Invoice Date` LIKE '%-%-%' THEN STR_TO_DATE(`Invoice Date`, '%d-%m-%y')
END
FROM us_adidas_sales;

UPDATE us_adidas_sales
SET `Invoice Date` = CASE WHEN `Invoice Date` LIKE '%/%/%' THEN STR_TO_DATE(`Invoice Date`, '%m/%d/%Y')
						  WHEN `Invoice Date` LIKE '%-%-%' THEN STR_TO_DATE(`Invoice Date`, '%d-%m-%y')
                     END;

ALTER TABLE us_adidas_sales
MODIFY COLUMN `Invoice Date` DATE;

#Break down Address column into 3 columns (region, city, state)
SELECT `Address`,
	SUBSTRING_INDEX(`Address`,',', 1) AS region,
    SUBSTRING_INDEX(SUBSTRING_INDEX(`Address`,',', 2),',', -1) AS state,
    SUBSTRING_INDEX(`Address`,',', -1) AS city
FROM us_adidas_sales; 

ALTER TABLE us_adidas_sales
ADD COLUMN Region VARCHAR(50) AFTER Address,
ADD COLUMN State VARCHAR(50) AFTER Region,
ADD COLUMN City VARCHAR(50) AFTER State;

UPDATE us_adidas_sales
SET Region = SUBSTRING_INDEX(`Address`,',', 1),
	State = SUBSTRING_INDEX(SUBSTRING_INDEX(`Address`,',', 2),',', -1),
    City = SUBSTRING_INDEX(`Address`,',', -1);

#Standardize Product 
SELECT DISTINCT Product
FROM us_adidas_sales; 

UPDATE us_adidas_sales
SET Product = 'Men''s Apparel'
WHERE Product = 'Men''s aparel';


#Price per unit: change format from text to numeric and remove '$' sign 
SELECT `Price per Unit`,
	CAST(REGEXP_REPLACE(`Price per Unit`,'[$ % + - USD]','') AS DECIMAL(10,2))
FROM us_adidas_sales; 

UPDATE us_adidas_sales
SET `Price per Unit` = CAST(REGEXP_REPLACE(`Price per Unit`,'[$ % + - USD]','') AS DECIMAL(10,2))
WHERE `Price per Unit` IS NOT NULL 
	OR `Price per Unit` <> '';
    

ALTER TABLE us_adidas_sales
MODIFY COLUMN `Price per Unit` DECIMAL(10,2);

#Total Sales: change format from text to numeric and remove ',' 
SELECT `Total Sales`,
	CAST(REGEXP_REPLACE(`Total Sales`,'[$ % + - USD,]','') AS DECIMAL(10,2))
FROM us_adidas_sales; 

UPDATE us_adidas_sales
SET `Total Sales` = CAST(REGEXP_REPLACE(`Total Sales`,'[$ % + - USD,]','') AS DECIMAL(10,2))
WHERE `Total Sales` IS NOT NULL 
	OR `Total Sales` <> '';
    
ALTER TABLE us_adidas_sales
MODIFY COLUMN `Total Sales` DECIMAL(10,2);

#Operating Profit
UPDATE us_adidas_sales
SET `Operating Profit` = TRIM(`Operating Profit`);

UPDATE us_adidas_sales
SET `Operating Profit` = CAST(REGEXP_REPLACE(`Operating Profit`,'[$ % + - USD,]','') AS DECIMAL(10,2))
WHERE `Operating Profit` IS NOT NULL 
	OR `Operating Profit` <> '';
    
ALTER TABLE us_adidas_sales
MODIFY COLUMN `Operating Profit` DECIMAL(10,2);

SELECT DISTINCT `Sales Method`
FROM us_adidas_sales;

#2.Remove Duplicates
#There is no unique identifier column in this table
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Retailer`, `Retailer ID`, `Invoice Date`, `Address`, `Product`, `Price per Unit`, `Units Sold`, `Sales Method`) AS row_num
FROM us_adidas_sales;

#Check if there is any row_num > 1
SELECT *
FROM (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY `Retailer`, `Retailer ID`, `Invoice Date`, `Address`, `Product`, `Price per Unit`, `Units Sold`, `Sales Method`) AS row_num
	FROM us_adidas_sales
     ) AS row_table
WHERE row_num > 1;

#Double check before removing duplicates
SELECT *
FROM us_adidas_sales
WHERE retailer = 'Foot Locker'
	AND `Invoice Date`= '2020-03-17'
    AND `Units Sold` = 359;
    
SELECT *
FROM us_adidas_sales
WHERE retailer = 'Walmart'
	AND `Invoice Date`= '2021-09-16'
    AND `Units Sold` = 400;

#MySQL does not support DELETE statement within CTE 
#Create a temporary table to store the unique rows we want to keep
CREATE TEMPORARY TABLE duplicate_CTE AS
SELECT *
FROM 
	(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY `Retailer`, `Retailer ID`, `Invoice Date`, `Address`, `Product`, `Price per Unit`, `Units Sold`, 	   `Sales Method`) AS row_num
	FROM us_adidas_sales
    ) AS row_table
WHERE row_num = 1;

#Delete all the rows from us_adidas_sales
DELETE FROM us_adidas_sales;

ALTER TABLE us_adidas_sales
ADD COLUMN row_num INT(5);

#Insert all the unique rows back from the temporary table to the us_adidas_sales
INSERT INTO us_adidas_sales
SELECT *
FROM duplicate_CTE;

#3.Look at NULL values 
SELECT *
FROM us_adidas_sales
WHERE `Price per Unit` IS NULL
OR `Price per Unit` = '';

#Populate data
UPDATE us_adidas_sales
SET `Price per Unit` = ROUND((`Total Sales`/`Units Sold`),2)
WHERE `Price per Unit` IS NULL;

SELECT *
FROM us_adidas_sales
WHERE `Total Sales` IS NULL
OR `Total Sales` = '';

UPDATE us_adidas_sales
SET `Total Sales` = ROUND((`Price per Unit`*`Units Sold`),2)
WHERE `Total Sales` IS NULL;

#4.Remove unused data
#Because we already broke down the column 'address' into 3 detail columns so we can delete it now
ALTER TABLE us_adidas_sales
DROP COLUMN `Address`;

DELETE FROM us_adidas_sales
WHERE `Units Sold` = 0
 AND `Total Sales` = 0
 AND `Operating Profit` = 0;