-- ============================================================================
-- Product Report 
-- ============================================================================
-- Purpose:
--   - Consolidates key product metrics and behaviors
--   - Segments products by revenue performance
--   - Computes KPIs like lifespan, recency, AOR, and monthly revenue
-- ============================================================================

-- DROP existing view if it exists
DROP VIEW IF EXISTS report_products;

-- CREATE the new product report view
CREATE VIEW report_products AS

WITH base_query AS (
  -- Step 1: Join sales with product info
  SELECT
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
  FROM fact_sales f
  LEFT JOIN dim_products p ON f.product_key = p.product_key
  WHERE f.order_date IS NOT NULL AND f.order_date != ''
),

product_aggregations AS (
  -- Step 2: Aggregate key product-level metrics
  SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    MAX(order_date) AS last_sale_date,

    -- Calculate lifespan in months
    (CAST(strftime('%Y', MAX(order_date)) AS INTEGER) - CAST(strftime('%Y', MIN(order_date)) AS INTEGER)) * 12 +
    (CAST(strftime('%m', MAX(order_date)) AS INTEGER) - CAST(strftime('%m', MIN(order_date)) AS INTEGER)) AS lifespan,

    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,

    -- Average Selling Price (ASP)
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
  FROM base_query
  GROUP BY product_key, product_name, category, subcategory, cost
)

-- Step 3: Final output with segmentation and KPIs
SELECT
  product_key,
  product_name,
  category,
  subcategory,
  cost,
  last_sale_date,

  -- Recency in months: now - last sale
  (CAST(strftime('%Y', 'now') AS INTEGER) - CAST(strftime('%Y', last_sale_date) AS INTEGER)) * 12 +
  (CAST(strftime('%m', 'now') AS INTEGER) - CAST(strftime('%m', last_sale_date) AS INTEGER)) AS recency_in_months,

  -- Segment products by revenue performance
  CASE
    WHEN total_sales > 50000 THEN 'High-Performer'
    WHEN total_sales >= 10000 THEN 'Mid-Range'
    ELSE 'Low-Performer'
  END AS product_segment,

  lifespan,
  total_orders,
  total_sales,
  total_quantity,
  total_customers,
  avg_selling_price,

  -- Average Order Revenue (AOR)
  CASE
    WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders
  END AS avg_order_revenue,

  -- Average Monthly Revenue
  CASE
    WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
  END AS avg_monthly_revenue

FROM product_aggregations;
