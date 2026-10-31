/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    Validates the integrity and consistency of the gold views:
        - Uniqueness of surrogate keys in the dimensions
        - Duplicates introduced by the joins
        - Referential integrity between the fact and the dimensions
        - Row counts against the silver layer

Usage:
    Run after creating the gold views (ddl_gold.sql).
    Expectation: every check returns NO ROWS, unless a comment says otherwise.
===============================================================================
*/

USE DWH;
GO

-- ====================================================================
-- gold.dim_customers
-- ====================================================================

-- Uniqueness of the surrogate key (Expectation: No Result)
SELECT customer_key, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Duplicates introduced by the joins (Expectation: No Result)
SELECT customer_id, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Gender integration between CRM and ERP (Expectation: Female / Male / n/a)
SELECT DISTINCT gender FROM gold.dim_customers;

-- NULL in key columns (Expectation: No Result)
SELECT * FROM gold.dim_customers
WHERE customer_key IS NULL OR customer_id IS NULL OR customer_number IS NULL;

-- ====================================================================
-- gold.dim_products
-- ====================================================================

-- Uniqueness of the surrogate key (Expectation: No Result)
SELECT product_key, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Duplicates introduced by the joins / history (Expectation: No Result)
SELECT product_number, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Products without a matching category in the ERP (review any rows returned)
SELECT * FROM gold.dim_products
WHERE category IS NULL;

-- ====================================================================
-- gold.fact_sales
-- ====================================================================

-- Foreign key integrity: sales without a customer or a product (Expectation: No Result)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products  p ON p.product_key  = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

-- Duplicated order lines (Expectation: No Result)
SELECT order_number, product_key, customer_key, COUNT(*) AS cnt
FROM gold.fact_sales
GROUP BY order_number, product_key, customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Row counts: gold vs silver
-- ====================================================================
SELECT 'dim_customers' AS view_name,
       (SELECT COUNT(*) FROM silver.crm_cust_info)     AS silver_rows,
       (SELECT COUNT(*) FROM gold.dim_customers)       AS gold_rows
UNION ALL
SELECT 'fact_sales',
       (SELECT COUNT(*) FROM silver.crm_sales_details),
       (SELECT COUNT(*) FROM gold.fact_sales);
-- dim_customers and fact_sales should match their silver tables.
-- dim_products is smaller than silver.crm_prd_info on purpose, because
-- only the current version of each product (prd_end_dt IS NULL) is kept.
