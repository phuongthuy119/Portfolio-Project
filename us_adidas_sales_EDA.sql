SELECT * 
FROM us_adidas_sales
ORDER BY `Invoice Date`;

# Total Sales 2020 vs 2021
SELECT YEAR(`Invoice Date`) as `year`, 
MAX(`Total Sales`) as max,
MIN(`Total Sales`) as min,
ROUND(SUM(`Total Sales`),2) as total_sales, 
COUNT(`Total Sales`) as number_of_sales,
ROUND(AVG(`Total Sales`),2) as avg_sales
FROM us_adidas_sales
GROUP BY YEAR(`Invoice Date`);

#Return on Sales (ROS) 2020 vs 2021
SELECT YEAR(`Invoice Date`) as `year`, 
ROUND(SUM(`Operating Profit`)/SUM(`Total Sales`)*100,2) as return_on_sales
FROM us_adidas_sales
GROUP BY YEAR(`Invoice Date`);

#Total sales and profit by month
SELECT YEAR(`Invoice Date`) as year, 
MONTH(`Invoice Date`) as month,
SUM(`Total Sales`) as sales_per_month,
SUM(`Operating Profit`) as profit_per_month
FROM us_adidas_sales
GROUP BY year, month;

#What is the best-selling product? What product generates the most profit?
SELECT YEAR(`Invoice Date`) as Year, 
product,
SUM(`Total Sales`) as product_sales,
SUM(`Operating Profit`) as product_profit
FROM us_adidas_sales
GROUP BY YEAR(`Invoice Date`), product
ORDER BY product_sales DESC, product_profit DESC;

#Which retailer is the best-sellers?
SELECT retailer,
YEAR(`Invoice Date`) as year,
SUM(`Total Sales`) as total_sales,
AVG(`Total Sales`) as avg_sales,
SUM(`Operating Profit`) as total_profit
FROM us_adidas_sales
GROUP BY retailer, YEAR(`Invoice Date`)
ORDER BY YEAR(`Invoice Date`), total_sales DESC;

# Total Sales by Sales Method
SELECT `Sales Method`, YEAR(`Invoice Date`),
SUM(`Total Sales`) as sales_per_method
FROM us_adidas_sales
GROUP BY `Sales Method`, YEAR(`Invoice Date`)
ORDER BY sales_per_method DESC;

#Total Sales by Season
SELECT season, SUM(`Total Sales`)
FROM (
SELECT *,
CASE WHEN MONTH(`Invoice Date`) BETWEEN 3 AND 5 THEN 'Spring'
	 WHEN MONTH(`Invoice Date`) BETWEEN 6 AND 8 THEN 'Summer'
     WHEN MONTH(`Invoice Date`) BETWEEN 9 AND 11 THEN 'Autumn'
     WHEN MONTH(`Invoice Date`) IN (12, 1, 2) THEN 'Winter'
END AS season
FROM us_adidas_sales
) AS season_table
GROUP BY season
ORDER BY SUM(`Total Sales`) DESC;

SELECT season, product, SUM(`Total Sales`)
FROM (
SELECT *,
CASE WHEN MONTH(`Invoice Date`) BETWEEN 3 AND 5 THEN 'Spring'
	 WHEN MONTH(`Invoice Date`) BETWEEN 6 AND 8 THEN 'Summer'
     WHEN MONTH(`Invoice Date`) BETWEEN 9 AND 11 THEN 'Autumn'
     WHEN MONTH(`Invoice Date`) IN (12, 1, 2) THEN 'Winter'
END AS season
FROM us_adidas_sales
) AS season_table
GROUP BY season, product
ORDER BY season, SUM(`Total Sales`) DESC;

#Look at total sales by location
SELECT region,
SUM(`Total Sales`) as sales_per_region
FROM us_adidas_sales
GROUP BY region
ORDER BY sales_per_region DESC;

SELECT state,
SUM(`Total Sales`) as sales_per_state
FROM us_adidas_sales
GROUP BY state
ORDER BY sales_per_state DESC;

SELECT city,
SUM(`Total Sales`) as sales_per_city
FROM us_adidas_sales
GROUP BY city
ORDER BY sales_per_city DESC;