SELECT * 
FROM us_adidas_sales
ORDER BY `Invoice Date`;

#Overview
#Look at the sales performance year-over-year
SELECT 
	YEAR(`Invoice Date`) as `year`,
	ROUND(SUM(`Total Sales`),2) as total_sales, 
	COUNT(`Total Sales`) as number_of_sales,
	ROUND(AVG(`Total Sales`),2) as avg_sales,
	ROUND(SUM(`Units Sold`),2) as total_units_sold,
	ROUND(SUM(`Operating Profit`),2) as total_profit
FROM us_adidas_sales
GROUP BY year;

#Look at the sales performance by season
SELECT season, SUM(`Total Sales`) as total_sales
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

#Look at the sales performance month-over-month
SELECT 
	YEAR(`Invoice Date`) as `year`,
	MONTH(`Invoice Date`) as `month`,
	ROUND(SUM(`Total Sales`),2) as total_sales,
    COUNT(`Total Sales`) as number_of_sales,
	ROUND(AVG(`Total Sales`),2) as avg_sales,
	ROUND(SUM(`Units Sold`),2) as total_units_sold,
	ROUND(SUM(`Operating Profit`),2) as total_profit
FROM us_adidas_sales
GROUP BY year, month
ORDER BY year, month;

#What could be the reasons for these trends?
#Expand sales area?
SELECT 
	YEAR(`Invoice Date`) as `year`,
    COUNT(DISTINCT region) as num_of_region,
    COUNT(DISTINCT state) as num_of_state
FROM us_adidas_sales
GROUP BY year;

SELECT  DISTINCT state,
	YEAR(`Invoice Date`) as `year`
FROM us_adidas_sales
ORDER BY year;

#Number of retailers increased?
SELECT 
	YEAR(`Invoice Date`) as `year`,
    COUNT(DISTINCT retailer) as num_of_retailer
FROM us_adidas_sales
GROUP BY year;

#Launched new products?
SELECT 
	YEAR(`Invoice Date`) as `year`,
    COUNT(DISTINCT product) as num_of_product
FROM us_adidas_sales
GROUP BY year;

#Look at some key sales metrics
#Sales Growth Rate 2020 - 2021
SELECT 
    ROUND(((y2021.total_sales - y2020.total_sales) /y2020.total_sales) * 100,2) AS growth_rate
FROM (
	SELECT YEAR(`Invoice Date`) AS year, 
			SUM(`Total Sales`) AS total_sales 
    FROM us_adidas_sales 
    WHERE YEAR(`Invoice Date`) = 2021 
    GROUP BY YEAR(`Invoice Date`)
    ) AS y2021
JOIN (
    SELECT YEAR(`Invoice Date`) AS year, 
    SUM(`Total Sales`) AS total_sales 
    FROM us_adidas_sales 
    WHERE YEAR(`Invoice Date`) = 2020 
    GROUP BY YEAR(`Invoice Date`)
    ) AS y2020
ON  y2021.year = 2021 
AND y2020.year = 2020;

#Return on Sales (ROS)
SELECT 
	YEAR(`Invoice Date`) as `year`, 
	ROUND(SUM(`Operating Profit`)/SUM(`Total Sales`)*100,2) as return_on_sales
FROM us_adidas_sales
GROUP BY YEAR(`Invoice Date`);

#Average Selling Price (ASP)
SELECT 
	YEAR(`Invoice Date`) as `year`, 
	SUM(`Total Sales`)/SUM(`Units Sold`) as average_selling_price
FROM us_adidas_sales
GROUP BY YEAR(`Invoice Date`);

SELECT 
	YEAR(`Invoice Date`) as `year`, 
	retailer, 
    product,
	SUM(`Total Sales`)/SUM(`Units Sold`) as average_selling_price
FROM us_adidas_sales
GROUP BY `year`, product, retailer
ORDER BY retailer, `year`;

#Product Analysis
#Which product is the best-seller? 
SELECT 
	YEAR(`Invoice Date`) as `year`, 
	product,
	SUM(`Total Sales`) as product_sales
FROM us_adidas_sales
GROUP BY YEAR(`Invoice Date`), product
ORDER BY `year`, product_sales DESC;

#Which product brings the most profit?
SELECT 
	YEAR(`Invoice Date`) as `year`, 
	product,
	SUM(`Operating Profit`) as product_profit
FROM us_adidas_sales
GROUP BY YEAR(`Invoice Date`), product
ORDER BY `year`, product_profit DESC;

#Retailer Analysis
#Which retailers generated the highest sales revenue for Adidas?
SELECT 
	retailer,
	YEAR(`Invoice Date`) as year,
	SUM(`Total Sales`) as total_sales
FROM us_adidas_sales
GROUP BY retailer, YEAR(`Invoice Date`)
ORDER BY YEAR(`Invoice Date`), total_sales DESC;

#Total sales by retailer in each state
SELECT 
	retailer,
    state,
	SUM(`Total Sales`) as total_sales
FROM us_adidas_sales
GROUP BY retailer, state
ORDER BY retailer, total_sales DESC;

#How do sales trends differ between online and offline retail channels?
SELECT 
	`sales method`,
    retailer,
	SUM(`Total Sales`) as total_sales
FROM us_adidas_sales
GROUP BY `Sales Method`, retailer
ORDER BY `Sales Method`, total_sales DESC;

#Sales Method Analysis
#Which sales methods were most effective in driving sales?
SELECT 
	`Sales Method`, 
	 SUM(`Total Sales`) as total_sales
FROM us_adidas_sales
GROUP BY `Sales Method`
ORDER BY total_sales DESC;

#Is there any significant change in sales method trends during the period?
SELECT 
	`Sales Method`, 
	 YEAR(`Invoice Date`),
	 SUM(`Total Sales`) as total_sales
FROM us_adidas_sales
GROUP BY `Sales Method`, YEAR(`Invoice Date`)
ORDER BY total_sales DESC;

#Location Analysis
#Which regions, states or cities showed the highest and lowest sales performance?
SELECT 
	region,
	COUNT(DISTINCT retailer),
	SUM(`Total Sales`) as total_sales,
    AVG(`Total sales`) as avg_sales
FROM us_adidas_sales
GROUP BY region
ORDER BY total_sales DESC;

SELECT 
	state,
    COUNT(DISTINCT retailer),
	SUM(`Total Sales`) as total_sales,
    AVG(`Total sales`) as avg_sales
FROM us_adidas_sales
GROUP BY state
ORDER BY total_sales DESC;

SELECT 
	city,
	COUNT(DISTINCT retailer),
	SUM(`Total Sales`) as total_sales,
    AVG(`Total sales`) as avg_sales
FROM us_adidas_sales
GROUP BY city
ORDER BY total_sales DESC;

SELECT 
	state,
	YEAR(`Invoice Date`) as `year`,
    COUNT(DISTINCT retailer),
	SUM(`Total Sales`) as total_sales
FROM us_adidas_sales
GROUP BY state,`year`
ORDER BY state,`year`;
