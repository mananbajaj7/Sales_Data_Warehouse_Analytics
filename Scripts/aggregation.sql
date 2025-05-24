-- Changes over time analysis
SELECT
    substr(order_date, 1, 4) AS order_year,
	substr(order_date, 6, 2) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL AND  substr(order_date, 6, 2)  IS NOT '' AND substr(order_date, 1, 4) IS NOT ''
GROUP BY substr(order_date, 1, 4), substr(order_date, 6, 2) 
ORDER BY substr(order_date, 1, 4), substr(order_date, 6, 2) ;



-- Advanced aggregation using Cumalative analysis
-- WINDOW FUNCTIONS 
-- Calculate total sales and average price per year
-- Then compute the running total of yearly sales
-- And the moving average of yearly average price
SELECT
  order_date,
  total_sales,
  SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
  SELECT
    substr(order_date, 1, 7) AS order_date, 
    SUM(sales_amount) AS total_sales
  FROM fact_sales
  WHERE order_date IS NOT NULL AND substr(order_date, 1, 7) IS NOT ''
  GROUP BY substr(order_date, 1, 7)
) t;


SELECT
  order_date,
  total_sales,
  SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
  AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
  SELECT
    substr(order_date, 1, 4) AS order_date,              
    SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
  FROM fact_sales
  WHERE order_date IS NOT NULL AND substr(order_date, 1, 4) IS NOT ''
  GROUP BY substr(order_date, 1, 4)
) t;
