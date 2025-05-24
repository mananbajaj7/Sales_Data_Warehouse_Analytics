/* 
Performance analysis
  Analyze product performance by year:
  - Calculate total yearly sales per product
  - Compare each year's sales to the product's average annual sales
  - Compare to the previous year's sales to observe trends over time
*/


-- Step 1: CTE to calculate yearly sales per product
WITH yearly_product_sales AS (
  SELECT
    substr(f.order_date, 1, 4) AS order_year, -- extract year
    p.product_name,
    SUM(f.sales_amount) AS current_sales
  FROM fact_sales f
  LEFT JOIN dim_products p ON f.product_key = p.product_key
  WHERE f.order_date IS NOT NULL
    AND substr(f.order_date, 1, 4) != ''
  GROUP BY order_year, p.product_name
)

-- Step 2: Compare each year's sales to the product's average performance
SELECT
  order_year,
  product_name,
  current_sales,
  AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
  current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
  CASE
    WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
    WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
    ELSE 'Avg'
  END AS avg_change,
  
   LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
  current_sales -  LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
  CASE
    WHEN LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
    WHEN LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)< 0 THEN 'Decrease'
    ELSE 'No change'
  END AS py_change
  
FROM yearly_product_sales
ORDER BY product_name, order_year;


-- Which product categories contribute the most to total sales?

-- Step 1: Aggregate total sales by product category
WITH category_sales AS (
  SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales
  FROM fact_sales f
  LEFT JOIN dim_products p
    ON f.product_key = p.product_key
  GROUP BY p.category
)

-- Step 2: Calculate overall sales and % contribution per category
SELECT
  category,
  total_sales,
  SUM(total_sales) OVER () AS overall_sales,
  ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER () * 100, 2) || '%' AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;


	
