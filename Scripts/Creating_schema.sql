-- Create tables (SQLite doesn't support schemas like MS SQL, so we drop "gold.")

DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS fact_sales;

CREATE TABLE dim_customers (
    customer_key INTEGER,
    customer_id INTEGER,
    customer_number TEXT,
    first_name TEXT,
    last_name TEXT,
    country TEXT,
    marital_status TEXT,
    gender TEXT,
    birthdate TEXT,
    create_date TEXT
);

CREATE TABLE dim_products (
    product_key INTEGER,
    product_id INTEGER,
    product_number TEXT,
    product_name TEXT,
    category_id TEXT,
    category TEXT,
    subcategory TEXT,
    maintenance TEXT,
    cost INTEGER,
    product_line TEXT,
    start_date TEXT
);

CREATE TABLE fact_sales (
    order_number TEXT,
    product_key INTEGER,
    customer_key INTEGER,
    order_date TEXT,
    shipping_date TEXT,
    due_date TEXT,
    sales_amount INTEGER,
    quantity INTEGER,
    price INTEGER
);

-- Importing data 
/*
.mode csv
.separator ","
.import --skip 1 '/Users/mananbajaj/Desktop/Projects/Tutorial Projects/SQL Data Analyst Portfolio Project/datasets/csv-files/gold.dim_customers.csv' dim_customers
.import --skip 1 '/Users/mananbajaj/Desktop/Projects/Tutorial Projects/SQL Data Analyst Portfolio Project/datasets/csv-files/gold.dim_products.csv' dim_products
.import --skip 1 '/Users/mananbajaj/Desktop/Projects/Tutorial Projects/SQL Data Analyst Portfolio Project/datasets/csv-files/gold.fact_sales.csv' fact_sales
*/
