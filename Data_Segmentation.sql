-- Data Segmentation 
-- Segment products into cost ranges using a CTE
WITH product_segments AS (
  SELECT
    product_key,
    product_name,
    cost,
    CASE
      WHEN cost < 100 THEN 'Below 100'
      WHEN cost BETWEEN 100 AND 500 THEN '100-500'
      WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
      ELSE 'Above 1000'
    END AS cost_range
  FROM dim_products  -- removed "gold."
)

-- Count how many products fall into each cost range
SELECT
  cost_range,
  COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/* 
Segment customers into three groups based on their purchase behavior:
  - VIP:     Customers with at least 12 months of history AND total spending > 5,000
  - Regular: Customers with at least 12 months of history AND total spending ≤ 5,000
  - New:     Customers with less than 12 months of purchase history

Step 1: Calculate each customer's total spending and lifespan (in months)
Step 2: Assign each customer to a segment based on their behavior
*/

-- Step 1: Calculate each customer's spending and lifespan
WITH customer_spending AS (
  SELECT
    c.customer_key,
    SUM(f.sales_amount) AS total_spending,
    MIN(f.order_date) AS first_order,
    MAX(f.order_date) AS last_order,

    -- Calculate lifespan in months between first and last order
    CASE
      WHEN MIN(f.order_date) != '' AND MAX(f.order_date) != '' THEN
        (CAST(strftime('%Y', MAX(f.order_date)) AS INTEGER) - CAST(strftime('%Y', MIN(f.order_date)) AS INTEGER)) * 12 +
        (CAST(strftime('%m', MAX(f.order_date)) AS INTEGER) - CAST(strftime('%m', MIN(f.order_date)) AS INTEGER))
      ELSE 0
    END AS lifespan
  FROM fact_sales f
  LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
  WHERE f.order_date IS NOT NULL AND f.order_date != ''
  GROUP BY c.customer_key
),

-- Step 2: Assign each customer to a segment
segmented_customers AS (
  SELECT
    customer_key,
    total_spending,
    lifespan,
    CASE
      WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
      WHEN lifespan >= 12 THEN 'Regular'
      ELSE 'New'
    END AS customer_segment
  FROM customer_spending
)

-- Step 3: Output segment summary
SELECT
  customer_segment,
  COUNT(*) AS total_customers
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

